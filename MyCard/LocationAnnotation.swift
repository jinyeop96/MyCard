//
//  LocationAnnotation.swift
//  MyCard
//
//  Created by JINYEOP OH on 2022/05/03.
//

import UIKit
import MapKit

// This class inherits from MKAnnotation to be added and selected in MapView.
class LocationAnnotation: NSObject, MKAnnotation {
    // This has latitude and longitude for displaying a particular location
    var coordinate: CLLocationCoordinate2D
    
    // This is used for displaying a description of the displayed location underneath the annotation.
    var title: String?
    
    init(coordinate: CLLocationCoordinate2D, title: String) {
        self.coordinate = coordinate
        self.title = title
    }

}
