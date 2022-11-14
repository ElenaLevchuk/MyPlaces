//
//  MapViewController.swift
//  MyPlaces
//
//  Created by Lena on 14.11.2022.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    
    // MARK: - Properties
    var place: Place!
    
    @IBOutlet weak var mapView: MKMapView!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPlacemark()
    }
    
    // MARK: - Private methods
    
    private func setupPlacemark()  {
        guard let location = place.location else {
            return
        }
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(location){(placemarks, error) in
            if let error = error {
                print(error)
                return
            }
            guard let placemarks = placemarks else {
                return
            }
            let placemark = placemarks.first
            let annotation = MKPointAnnotation()
            annotation.title = self.place.name
            annotation.subtitle = self.place.type
            
            guard let placemarkLocation = placemark?.location else {
                return
            }
            annotation.coordinate = placemarkLocation.coordinate
            self.mapView?.showAnnotations([annotation], animated: true)
            self.mapView?.selectAnnotation(annotation, animated: true)
        }
    }
    
    @IBAction func close() {
        dismiss(animated: true)
    }
    
}
