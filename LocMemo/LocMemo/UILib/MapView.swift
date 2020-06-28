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
        mapView.isUserInteractionEnabled = true
        refresh(mapView)
        return mapView
    }

    func updateUIView(_ view: MKMapView, context: Context) {
        refresh(view)
    }

    fileprivate func refresh(_ view: MKMapView) {
        view.removeOverlays(view.overlays)
        view.removeAnnotations(view.annotations)
        if center == nil {
            return
        }
        print("MapView - refresh. region=\(center!.region)")

        let region = MKCoordinateRegion(center: center!.region.center,
                                        latitudinalMeters: center!.region.radius * 4,
                                        longitudinalMeters: center!.region.radius * 4)
        view.setRegion(region, animated: false)

        let circle = MKCircle(center: center!.region.center, radius: center!.region.radius)
        view.addOverlay(circle)

        let centerAnnotation = MKPointAnnotation()
        centerAnnotation.coordinate = center!.region.center
        view.addAnnotation(centerAnnotation)
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

        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            let circleRenderer = MKCircleRenderer(overlay: overlay as! MKCircle)
            circleRenderer.fillColor = .blue
            circleRenderer.alpha = 0.1
            return circleRenderer
        }
    }
}
