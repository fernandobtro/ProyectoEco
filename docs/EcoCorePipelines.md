# Eco — Core Pipelines

This document describes end-to-end flows as implemented in the codebase. It is not exhaustive for every feature.

**Documentation split:** narrative and sequencing live here; API contracts and non-obvious behavior belong in DocC-style `///` comments on public types and methods in code (single-line summary first, present tense, trailing period). Link types with double backticks (for example, ``StoryRepository``) instead of repeating long explanations in Swift files. The repository **[README](README.md)** summarizes the stack and points here for flows.

## Development tooling (`scripts/`)

Optional **local-only** folder at the project root: `scripts/` is listed in `.gitignore` so personal automation (e.g. header batch scripts) is not committed. Nothing under `scripts/` is part of the shipped app.

---

# Map Story Discovery Pipeline

## Trigger

- **Near user:** GPS updates after the user opens the Map tab and discovery has started (`LocationService` → delegate).
- **Explore:** The user pans/zooms the map so the camera region changes (`MapView` → `onMapCameraChange`).

---

## Flow

1. **`MapView`** (`Features/Map/MapView.swift`)  
   - `.task { await viewModel.onAppear() }` on first appearance; `onMapCameraChange` forwards region changes to the view model.

2. **`MapViewModel`** (`Features/Map/MapViewModel.swift`)  
   - `onAppear()`: first time runs `syncStoriesUseCase.executeWithFullRemotePull()`, starts `LocationDiscoveryControlling`, subscribes to `discoverUseCase.nearbyStories()` `AsyncStream`, then `refreshDiscovery()` and `updateGeofencingRegions()`.  
   - Location-driven refresh: `refreshDiscovery()` → `runRefreshDiscoveryWithPriority()` → `discoverUseCase` per `mapDiscoveryMode`.  
   - Explore mode: `onMapCameraChanged` debounces and calls `discoverUseCase.refreshForVisibleBounds(region.toVisibleBounds())`.

3. **`LocationEventsAdapter`** (`Core/Location/LocationEventsAdapter.swift`)  
   - Implements `LocationServiceDelegate`: `didUpdateLocation` calls `discoverNearbyStoriesUseCase.onUserLocationUpdated` and `trackProgressOnStoryEntryUseCase` for current nearby IDs.

4. **`DiscoverNearbyStoriesUseCaseImpl`** (`Core/Data/UseCases/Story/DiscoverNearbyStoriesUseCaseImpl.swift`)  
   - `refreshNearUser`: `GeographicBounds.boundingBox` (radius ≈ `nearUserRadiusMeters × 1.1`) → `storyRepository.fetchActiveStoriesInBoundingBox`, then filters by exact distance vs `nearUserRadiusMeters`, yields.  
   - `refreshForVisibleBounds`: checks max span vs config, `fetchActiveStoriesInBoundingBox` for `MapVisibleBounds`, caps with `maxExploreStoryFetch`, yields.  
   - Subscribes to `storyRepository.storiesUpdatePublisher` (debounced) and replays last refresh.

5. **`StoryRepository`** (`Core/Data/Persistence/Repositories/StoryRepository.swift`)  
   - `fetchActiveStoriesInBoundingBox` delegates to `StoryLocalDataSourceProtocol.fetchActiveStoriesInBoundingBox` and maps with `StoryPersistenceMapper.toDomain`.  
   - Other callers may use `fetchAllStories()` / sorted active fetches where the full non-deleted set is required (not the Collection planted tab).

6. **`SwiftDataStoryDataSource`** (`Core/Data/Persistence/SwiftDataStoryDataSource.swift`)  
   - `fetchActiveStoriesInBoundingBox` uses a SwiftData `#Predicate` (`deletedAt == nil` + lat/lon range).  
   - `fetchActiveStories()` / `fetchActiveStoriesSortedByUpdatedAtDescending()` load all *active* rows (no soft-deleted) for callers that still need the full active set.

7. **Remote fill (separate path):** `SyncStoriesUseCaseImpl` + `SyncWorker` pull from `FirestoreStoryDataSource` into local storage; then `notifyStoriesUpdatePublisher` causes discovery to replay.

---

## Data Transformations

- **Persistence → Domain:** `StoryEntity` → `Story` via `StoryPersistenceMapper.toDomain`.  
- **No separate DTO** in this path: discovery reads **domain `Story`** from the repository.  
- **Firestore → local entities** happens inside sync (`SyncWorker` / pull use case), not inside `DiscoverNearbyStoriesUseCaseImpl` directly.

---

## Edge Cases

- Explore span larger than `MapDiscoveryConfig.maxExplorationSpanDegrees` → empty list yielded.  
- `DiscoverNearbyStoriesUseCaseImpl.runRefresh`: on error, logs and **keeps last successful** stream value.  
- Concurrent refreshes: `isRefreshing` + `pendingRefreshAfterCurrent` serializes work.  
- No GPS in explore path: `MapViewModel` may skip switching to explore until `lastKnownCoordinate` exists.

---

## Technical Risks

- Discovery still does a **distance filter in memory** after the bounding-box fetch; cost scales with stories **inside the box**, not the whole database.  
- `DiscoverNearbyStoriesUseCaseImpl` is **`@MainActor`** and uses **Combine** for repository updates — mind isolation when testing.  
- Map and sync both touch the same stream indirectly via repository notifications — ordering depends on debounce and task scheduling.

---

## Debug Tips

- Breakpoints: `DiscoverNearbyStoriesUseCaseImpl.refreshNearUser`, `refreshForVisibleBounds`, `runRefresh`.  
- Inspect: `lastNearbyStoryIDs`, `discoveryMode`, `MapViewModel.nearbyStories` after stream yield.  
- Logging: `Logger` category `DiscoverNearbyStories` on refresh failure (DEBUG also prints map discovery in `MapViewModel`).

---

# Collection (Planted / Discovered) Pipeline

## Trigger

User opens the **Collection** tab (`RootView` → `CollectionView`). Pull-to-refresh runs the same reload path as initial load.

## Flow (summary)

1. **`CollectionView`** — `.task { await viewModel.onAppear() }` → `refresh()`.
2. **`CollectionViewModel.refresh()`** — `syncStoriesUseCase.executeWithFullRemotePull()`, then loads **planted** page 0 via ``GetPlantedStoriesUseCase`` / ``StoriesPage`` and **discovered** via ``GetDiscoveredStoriesUseCase`` (still reads `user.foundStories`; see TODO in ``GetDiscoveredStoriesUseCaseImpl`` for a future relational + paginated design).
3. **Scroll (planted)** — Last visible row triggers `loadMorePlantedIfNeeded()` with guards against overlapping requests; uses the same use case with increasing `page`.
4. **`StoryRepository.fetchPlantedStories`** — Delegates to ``SwiftDataStoryDataSource.fetchPlantedStories`` (stable sort: `updatedAt`, then `id`).

---

# Plant Story Pipeline

## Trigger

User taps the tab bar **+** (`RootView` → `CustomTabBar` → `mapRouter.navigateToCreateStory()`), fills the sheet, taps **Plantar eco** (`StoryCreationView`).

---

## Flow

1. **`RootView`** (`Features/Root/RootView.swift`)  
   - Presents `MapRouter` sheet; factory builds `StoryCreationView` with `onPlantingSuccess` storing coordinate + id on `MapRouter`, then dismiss.

2. **`StoryCreationView` / `StoryCreationViewModel`** (`Features/StoryCreation/`)  
   - `plantStory()`: validates non-empty title/content and `lastLocation`, calls `plantUseCase.execute`, then `syncStoriesUseCase.execute()`, clears fields, invokes `onPlantingSuccess` + `dismiss()`.

3. **`MapRouter`** (`App/Navigation/MapRouter.swift`)  
   - Callback sets `recentPlanting`; sheet `onDismiss` in `RootView` may `consumeRecentPlanting()`, `queuePlantingAnimation` on `MapViewModel`, and `mapViewModel.onAppear()`.

4. **`PlantStoryUseCaseImpl`** (`Core/Data/UseCases/Story/PlantStoryUseCaseImpl.swift`)  
   - `sessionRepository.getCurrentUserId()`, builds domain `Story`, `storyRepository.createStory`, fires unstructured `Task { try? await userRepository.syncWithCloud() }`, returns UUID.

5. **`StoryRepository.createStory`**  
   - `StoryPersistenceMapper.toEntity(story, existing: nil)` → `storyLocalDataSource.saveNew` → `updatesSubject.send`.

6. **`SwiftDataStoryDataSource.saveNew`**  
   - Inserts `StoryEntity` into `ModelContext` and saves.

7. **`SyncStoriesUseCaseImpl.execute()`** (after plant, from view model)  
   - `SyncWorker.sync(forceFullPull: false)` push/pull, `notifyStoriesUpdated()`.

---

## Data Transformations

- **View → Domain:** trimmed strings + GPS doubles → `Story` inside `PlantStoryUseCaseImpl`.  
- **Domain → Persistence:** `Story` → `StoryEntity` via `StoryPersistenceMapper.toEntity` (pending create sync state on new rows).

---

## Edge Cases

- Missing location: `StoryCreationViewModel` sets error “Esperando señal del GPS…”.  
- Empty title/content: validation error before use case.  
- `userRepository.syncWithCloud()` errors are **ignored** (`try?`) in the background task.

---

## Technical Risks

- **Fire-and-forget** `syncWithCloud` after plant — failures are silent.  
- Plant + immediate `syncStoriesUseCase.execute()` can overlap with other sync work (`SyncStateService`).

---

## Debug Tips

- Breakpoints: `PlantStoryUseCaseImpl.execute`, `StoryRepository.createStory`, `StoryCreationViewModel.plantStory`.  
- Verify: new row in SwiftData, `storiesUpdatePublisher` leading to map refresh, `SyncWorker.sync` after `execute()`.

---

# Story Detail (Read / Unlock / Edit / Delete) Pipeline

## Trigger

- **From map:** Second tap on pin → `MapView` → `MapRouter.navigateToStoryDetail` → sheet with `MapPresentedStoryDetailView` / reader.  
- **From collection:** `CollectionView` sheet with `StoryDetailView`.  
- **From notification/deep link:** `AppRouter` / `RootView` sheet with `StoryDetailFromDeepLinkView`.

---

## Flow

1. **`StoryDetailView`** (`Features/StoryDetail/StoryDetailView.swift`)  
   - `.task { await viewModel.loadDetail() }` (pattern per project rules).

2. **`StoryDetailViewModel`** (`Features/StoryDetail/StoryDetailViewModel.swift`)  
   - `loadDetail()`: `fetchStoryWithTimeout()` (6s) using `getStoryDetailUseCase.execute(id:)`.  
   - Sets `state`, compares `sessionRepository.getCurrentUserId()` to `story.authorID` for `isAuthor`.  
   - Non-authors: `getLocationUseCase.requestLocation()`, distance vs `unlockRadius` (50 m) → `isUnlocked`.  
   - `updateStory` / `deleteStory`: use cases + `Task { await syncStoriesUseCase.execute() }` + reload.

3. **`GetStoryDetailUseCaseImpl`** (`Core/Data/UseCases/Story/GetStoryDetailUseCaseImpl.swift`)  
   - Delegates to `storyRepository.fetchStory(by:)`.

4. **`StoryRepository.fetchStory`**  
   - Local fetch by id; skips soft-deleted rows; maps to domain.

5. **`UpdateStoryUseCaseImpl` / `DeleteStoryUseCaseImpl`**  
   - Session/author checks (delete/update), then repository update, soft delete, or stop.

6. **`SwiftDataStoryDataSource`**  
   - Persists mutations via `ModelContext`.

---

## Data Transformations

- **Persistence → UI:** `StoryEntity` → `Story` → `StoryDetailState.loaded`.  
- **Edit:** new `Story` value built in view model with updated text/`updatedAt`, passed to `updateStoryUseCase`.

---

## Edge Cases

- Story missing or soft-deleted → `.error("No encontramos este Eco.")`.  
- `fetchStoryWithTimeout` can throw `StoryDetailLoadingError.timeout`.  
- Reader without location: `isUnlocked` stays false unless author.

---

## Technical Risks

- **Timeout race** with `withThrowingTaskGroup` — first completed task wins; ensure cancellation behavior is understood.  
- Edit/delete fire **async** `syncStoriesUseCase` without awaiting in the VM’s public API.

---

## Debug Tips

- Breakpoints: `StoryDetailViewModel.loadDetail`, `fetchStoryWithTimeout`, `GetStoryDetailUseCaseImpl.execute`.  
- Watch: `state`, `isAuthor`, `isUnlocked`, `distanceToStory`.

---

# Email Login Pipeline

## Trigger

User chooses email path in unauthenticated flow (`AuthGateView` → `LoginView`) and submits credentials.

---

## Flow

1. **`LoginView`** (`Features/AuthLogin/LoginView.swift`)  
   - Calls `viewModel.login()`.

2. **`LoginViewModel`** (`Features/AuthLogin/LoginViewModel.swift`)  
   - `Task { try await loginUseCase.execute(email:password:) }`; sets generic Spanish error on any failure.

3. **`LoginUseCaseImpl`** (`Core/Data/UseCases/Auth/LoginUseCaseImpl.swift`)  
   - `repository.login(email:password:)` → returns UID string.

4. **`FirebaseAuthRepository`** (`Core/Data/Remote/Auth/FirebaseAuthRepository.swift`)  
   - Delegates to `FirebaseAuthDataSource.login`.

5. **`FirebaseAuthDataSource`** (Firebase SDK)  
   - Performs Firebase Auth sign-in.

6. **`AuthGateViewModel`** (`Features/AuthLogin/AuthGateViewModel.swift`)  
   - `Auth.auth().addStateDidChangeListener` → `evaluateState`: profile/nickname reconciliation via `GetAuthorProfileUseCase`, `SaveSessionNicknameUseCase`, `GetCurrentSessionUseCase`; transitions to `.authenticated(uid)` or `.needsNickname`.

7. **`RootView`**  
   - Shown when gate state is authenticated (wiring via `EcoApp` / container).

---

## Data Transformations

- **Credentials:** plain `String` in VM → Firebase Auth → **Firebase `User.uid`**.  
- **Session / nickname:** author profile (remote) vs local session nickname rules (`EcoAuthorDisplayFormatting`).

---

## Edge Cases

- Any auth error becomes the same user-facing message in `LoginViewModel` (“Error al iniciar sesión”).  
- Network / invalid credentials indistinguishable in UI without reading `error` inside the VM (currently not exposed).

---

## Technical Risks

- **Tight coupling** of `AuthGateViewModel` to `FirebaseAuth` listener type in the same file.  
- Login success UX depends on **async** listener, not only the login `Task` completion order.

---

## Debug Tips

- Breakpoints: `FirebaseAuthDataSource.login`, `AuthGateViewModel.evaluateState`, `LoginViewModel.login`.  
- After login, confirm listener fires and `state` moves to `.authenticated` or `.needsNickname`.

---

# Cross-Cutting: Sync, Geofencing, Notifications

- **`SyncWorker`** (`Core/Data/Sync/SyncWorker.swift`): push pending `StoryEntity` rows via `FirestoreStoryDataSource`; pull is delegated to **`SyncPullStoriesUseCaseImpl`** (`Core/Data/UseCases/Sync/SyncPullStoriesUseCaseImpl.swift`); updates `SyncStateService` on success/failure.  
- **Sync pull:** `remoteDataSource.fetchStoriesUpdated(since:)` returns DTOs; **`SyncPullStoriesUseCaseImpl`** calls **`StoryLocalDataSourceProtocol.fetchByRemoteIds(_:)`** once per pull batch (chunked in `SwiftDataStoryDataSource`), builds a `remoteId → StoryEntity` map, then for each DTO runs **`SyncConflictResolver.resolve`** (insert / update local / keep local / delete local). It does **not** use `storyRepository.fetchAllStories()` during pull.  
- **`GeofencingService`** (`Core/Geofencing/GeofencingService.swift`): `MapViewModel.updateGeofencingRegions()` loads candidates via **`GetStoriesForGeofencingUseCaseImpl`**, which uses **`StoryRepository.fetchActiveStoriesInBoundingBox`** (≈5 km prefetch) + sort by distance + `prefix(limit)` → `startMonitoring`; **entry** events schedule local notifications via `NotificationPolicy` + `UserNotificationService`.  
- **`EcoApp` `AppDelegate`**: notification tap → `handleNotificationPayload` → `AppRouter` story id / open map.

These interact with discovery indirectly after sync changes local data (`storiesUpdatePublisher` / full pull on map appear).

---

## Performance notes (current implementation)

| Area | Approach | Follow-ups if data grows further |
|------|-----------|----------------------------------|
| Map discovery | `fetchActiveStoriesInBoundingBox` via `GeographicBounds` + in-memory distance (near user) or box + cap (explore) | Spatial index / grid column; tighten caps |
| Geofencing | `fetchActiveStoriesInBoundingBox` with ~5 km prefetch + sort + `prefix(limit)` | Tune prefetch radius vs `GeofencingService` region size |
| Sync pull | `fetchByRemoteIds` in chunks of 200 + in-memory map + same `SyncConflictResolver` loop | Adjust chunk size; optional DB index on `remoteId` |
| Lists / other | Planted tab: `GetPlantedStoriesUseCase` pages via `StoryRepository.fetchPlantedStories` (SwiftData `limit`/`offset`, stable sort). Discovered tab still loads from `user.foundStories` (see TODO in use case). | Collection planted list scales with paging; discovered is future relational work |
