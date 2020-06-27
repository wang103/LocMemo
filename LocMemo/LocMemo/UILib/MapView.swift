//
//  MapView.swift
//  LocMemo
//
//  Created by Tianyi Wang on 6/2/20.
//  Copyright © 2020 hyperware. All rights reserved.
//

import MapKit
import SwiftUI

struct MapView: UIViewRepresentable {

    @Binding var center: LMPlacemark?

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.isUserInteractionEnabled = false
        return mapView
    }

    func updateUIView(_ view: MKMapView, context: Context) {
        // intentionally empty
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView

        init(_ parent: MapView) {
            self.parent = parent
        }

        func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
            // intentionally empty
        }
    }
}
