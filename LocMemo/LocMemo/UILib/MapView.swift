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

    func makeUIView(context: UIViewRepresentableContext<MapView>) -> MKMapView {
        let mapView = MKMapView()
        return mapView
    }

    func updateUIView(_ view: MKMapView, context: UIViewRepresentableContext<MapView>) {

    }
}
