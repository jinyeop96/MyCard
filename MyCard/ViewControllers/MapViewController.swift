//
//  MapViewController.swift
//  MyCard
//
//  Created by JINYEOP OH on 2022/05/03.
//

import UIKit
import MapKit
import FirebaseFirestoreSwift

class MapViewController: UIViewController, CLLocationManagerDelegate{
    // MARK: - Properties
    var card: Card?
    var locationManager: CLLocationManager = CLLocationManager()
    @IBOutlet weak var mapView: MKMapView!
    
    
    // MARK: - On view loads
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Request for accessing a map
        if locationManager.authorizationStatus == .notDetermined || locationManager.authorizationStatus != .authorizedAlways {
            locationManager.requestWhenInUseAuthorization()
        }
        
        // Zoom into the card address
        if let card = card, let address = card.address, let companyName = card.companyName {
            focusMap(address: address, title: companyName )
        }
    }
    
    /*
     This function searches the address and zoom into the location if it suceeds.
     If it does not find any, it displays an appropriate message and discontinue.
     
     Search for an address is based on
     https://www.hackingwithswift.com/example-code/location/how-to-look-up-a-location-with-mklocalsearchrequest
     
     I have modified the query to be the address of the self.card and chosen only the first item in response.
     With having the first item, I have combined with Week5 material to add annotation on the map and zoom into latitude and longitude.
     */
    private func focusMap(address: String, title: String){
        
        // 1. Set search request with card's address
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = address
        request.region = mapView.region
        let search = MKLocalSearch(request: request)

        search.start { response, error in
            guard let response = response, error == nil else {
                self.displayMessage(title: "Error", message: "The address for this card cannot be found.")
                return
            }
            
            // 2. If the response has result found, display the first item
            // coordinate contains latitude and longitude
            if let coordinate = response.mapItems.first?.placemark.coordinate{
                let annotation = LocationAnnotation(coordinate: coordinate, title: title)
                
                // annotation should be added for displaying the marker
                self.mapView.addAnnotation(annotation)
                self.mapView.selectAnnotation(annotation, animated: true)
                
                // if the map is focused elsewhere it will not be visible. So zoom in on a specific region and centre it on screen
                let zoomRegion = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
                self.mapView.setRegion(zoomRegion, animated: true)
            }
            
        }
    }
}
