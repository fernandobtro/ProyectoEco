//
//  MapView.swift
//  Eco
//
//  Created by Fernando Buenrostro on 02/03/26.
//

import Foundation
import MapKit
import SwiftUI

struct MapView: View {
    @StateObject var viewModel: MapViewModel
    @StateObject var router: MapRouter
    
    var body: some View {
        ZStack {
            Map {
                ForEach(viewModel.nearbyStories) { story in
                    Annotation(story.title, coordinate: CLLocationCoordinate2D(latitude: story.latitude, longitude: story.longitude)) {
                        VStack {
                            Image(systemName: "leaf.fill")
                                .font(.title)
                                .foregroundStyle(.green)
                            Text(story.title)
                                .font(.caption)
                                .padding(4)
                                .background(.ultraThinMaterial)
                                .cornerRadius(8)
                        }
                    }
                }
            }
            .mapStyle(.standard(elevation: .realistic))
            .ignoresSafeArea()
            
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: { router.navigateToCreateStory()
                    },
                           label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(.green)
                            .background(.white)
                            .clipShape(Circle())
                            .shadow(radius: 4)
                        }
                    )
                    .padding()
                }
            }
        }
        .sheet(item: $router.sheetDestination) { destination in
            router.view(for: destination)
        }
    }
}
