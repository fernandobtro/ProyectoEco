# Eco

Eco is an iOS app for **location-based stories** (“Ecos”): plant stories at real-world places, discover nearby content on a map, and keep everything in sync using **Firebase** (Auth + Firestore) and **SwiftData**.

## Features

- **Map & discovery**
  - Live map of nearby stories with distance and author info
  - “Near me” vs “Explore” modes with debounced camera-driven refresh
  - Geofencing-based notifications when you walk into the radius of a story
- **Plant & edit stories**
  - Compose stories tied to your current GPS location
  - Stable ordering and pagination for planted stories
  - Edit and delete stories you authored
- **Collection**
  - “My Ecos” (planted) and “Discovered” tabs
  - Infinite scroll-style pagination for planted stories
  - Shared presentation for list rows and explore cards
- **Story detail**
  - Locked/unlocked content based on physical distance
  - In-map reader and full-screen detail with edit sheet
  - Deep link and notification entry to a specific story
- **Auth & onboarding**
  - Email/password, Apple, and Google sign-in
  - Nickname onboarding and profile editing
  - Location and notifications onboarding flows
- **Notifications & sync**
  - Local notification policy with dedupe and rate limiting
  - Background sync retry with backoff
  - Pull/push pipelines with conflict resolution

## Tech Stack

- SwiftUI
- SwiftData
- Firebase (Auth, Firestore)
- Clean Architecture style:
  - `Core/Domain` for entities, repository/use case protocols, and cross-cutting contracts
  - `Core/Data` for SwiftData, Firestore, repositories, mappers, and use case implementations
  - `Core/DesignSystem` for colors, fonts, components, and formatters
  - `Features/*` for screen-level views and `@Observable` view models
  - `App/*` for dependency injection, routers, and app wiring

## Project Structure

```text
Eco/
  App/
  Core/
    Configuration/
    Data/
    Domain/
    DesignSystem/
    Geofencing/
    Location/
    Notification/
  Features/
    AuthLogin/
    Collection/
    Map/
    Notifications/
    Onboarding/
    Profile/
    Root/
    Shared/Story/
    StoryCreation/
    StoryDetail/
  EcoTests/
  docs/
    EcoCorePipelines.md
```

## Getting Started

### Requirements

- Xcode 16+
- iOS 17+ simulator/device

### Setup

1. Clone this repository.
2. Create your own Firebase project and download `GoogleService-Info.plist`.
3. Place `GoogleService-Info.plist` in the `Eco` app target directory (it is **gitignored** and not committed).
4. Open `Eco.xcodeproj` in Xcode.
5. Select the `Eco` scheme.
6. Build and run on an iOS 17+ simulator or device.

## Documentation

- **[Core Pipelines](docs/EcoCorePipelines.md)** — End-to-end flows (map discovery, collection, planting, story detail, auth, sync, notifications).  
  Public types link back to this file via `/// Narrative:` comments where it helps.

## Testing

Eco uses unit tests in `EcoTests` to cover:

- Sync pull/push and conflict resolution
- Plant/update story use cases
- Planted stories pagination (`StoriesPage`)
- Persistence mappers (SwiftData ↔ Domain)
- Distance, bounds, and formatting helpers

Run tests from Xcode (`Product > Test`) or with:

```bash
xcodebuild test \
  -project "Eco.xcodeproj" \
  -scheme "Eco" \
  -destination "platform=iOS Simulator,name=iPhone 17"
```

## Notes

- `GoogleService-Info.plist` and other secrets are excluded from version control via `.gitignore`.
- The shared `Eco` scheme is committed to keep local and CI behavior consistent.
