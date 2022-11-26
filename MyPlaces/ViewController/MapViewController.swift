//
//  MapViewController.swift
//  MyPlaces
//
//  Created by Lena on 14.11.2022.
//

import UIKit
import MapKit
import CoreLocation

protocol MapViewcontrollerDelegate {
    func getAdress(_ adress: String)
}

class MapViewController: UIViewController {
    
    // MARK: - Properties
    var place = Place ()
    let annotationID = "annotationID"
    let locationManager = CLLocationManager()
    let regionInMeters = 10_000.00
    var incomeSegueIdentifier = ""
    var mapViewControllerDelegate: MapViewcontrollerDelegate?
    var placeCoordinate: CLLocationCoordinate2D?
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var pinImageView: UIImageView!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var adressLabel: UILabel!
    @IBOutlet weak var goButton: UIButton!
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        adressLabel.text = ""
        setupMapView()
        checkLocationServices()
    }
    
    // MARK: - Private methods
    private func setupMapView() {
        if incomeSegueIdentifier == "showPlace" {
            setupPlacemark()
            adressLabel.isHidden = true
            doneButton.isHidden = true
            goButton.isHidden = false
            pinImageView.isHidden = true
        }
    }
    
    private func getDirection() {
        guard let location = locationManager.location?.coordinate else {
            showAlert(title: "Error", message: "Current location is not found")
            return
        }
        guard let request = createDirectionRequest(from: location) else {
            showAlert(title: "Error", message: "Destination is not found")
            return
        }
        let directions = MKDirections(request: request)
        directions.calculate { response, error in
            if let error = error { print(error); return }
            guard let response = response else {
                self.showAlert(title: "Error", message: "Directions is not available")
                return
            }
            for route in response.routes {
                self.mapView.addOverlay(route.polyline)
                self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                let distance = String(format: "%.1f", route.distance / 1000)
                let time = route.expectedTravelTime
                print("Відстань в км: \(distance)")
                print("Час маршруту в секундах: \(time)")
            }
        }
    }
    
    private func createDirectionRequest(from coordinate: CLLocationCoordinate2D) -> MKDirections.Request? {
        guard let destinationCoordinate = placeCoordinate else { return nil }
        let start = MKPlacemark(coordinate: coordinate)
        let destination = MKPlacemark(coordinate: destinationCoordinate)
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: start)
        request.destination = MKMapItem(placemark: destination)
        request.transportType = .automobile
        request.requestsAlternateRoutes = true
        return request
    }
    
    private func setupPlacemark()  {
        guard let location = place.location else {
            return
        }
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(location){(placemarks, error) in
            if let error = error { print(error); return }
            guard let placemarks = placemarks else { return }
            let placemark = placemarks.first
            let annotation = MKPointAnnotation()
            annotation.title = self.place.name
            annotation.subtitle = self.place.type
            
            guard let placemarkLocation = placemark?.location else { return }
            annotation.coordinate = placemarkLocation.coordinate
            self.placeCoordinate = placemarkLocation.coordinate
            
            self.mapView?.showAnnotations([annotation], animated: true)
            self.mapView?.selectAnnotation(annotation, animated: true)
        }
    }
   
    private func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
         checkLocationAuthorization()
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now()+1){
                self.showAlert(title: "Location Services are Disabled", message: "To enable it go: Settings - Privacy - Location Services and turn on")
            }
        }
    }
    
    private func setupLocationManager(){
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    private func checkLocationAuthorization () {
        switch CLLocationManager.authorizationStatus() {
        case.authorizedWhenInUse:mapView.showsUserLocation = true
            if incomeSegueIdentifier == "getAdress" { showUserLocation() }
            break
        case.denied:
            break
        case.notDetermined:locationManager.requestWhenInUseAuthorization()
        case.restricted:
            break
        case.authorizedAlways:
            break
        @unknown default:
            print("New case is avialable")
        }
    }
    
    private func showUserLocation() {
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion(
                center: location,
                latitudinalMeters: regionInMeters,
                longitudinalMeters: regionInMeters)
            mapView.setRegion(region, animated: true)
        }
    }
    
    private func showAlert(title: String, message: String){
        let alert = UIAlertController (title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction (title: "Ok", style: .default)
        alert.addAction(ok)
        present(alert, animated: true)
    }
    
    private func getCenterLocation (for mapView: MKMapView) -> CLLocation {
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    // MARK: - IBActions

    @IBAction func centerViewInUserLocation() {
       showUserLocation()
    }
    
    @IBAction func close() {
        dismiss(animated: true)
    }
    
    @IBAction func donePressed(_ sender: Any) {
        mapViewControllerDelegate?.getAdress(adressLabel.text ?? "")
        dismiss(animated: true)
    }
    
    @IBAction func goButtonPressed(_ sender: Any) {
        getDirection()
    }
    
}

// MARK: - MKMapViewDelegate

extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let center = getCenterLocation(for: mapView)
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(center) { placemarks, error in
            if let error = error { print(error); return }
            guard let placemarks = placemarks else { return }
            let placemark = placemarks.first
            let street = placemark?.thoroughfare
            let build = placemark?.subThoroughfare
            self.adressLabel.text = "\(street ?? "")  \(build ?? "")"
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        guard !(annotation is MKUserLocation) else { return nil }
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationID) as? MKPinAnnotationView
        
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: annotationID)
            annotationView!.canShowCallout = true
        }
        
        if let imageData = place.imageData {
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            imageView.layer.cornerRadius = 10
            imageView.clipsToBounds = true
            imageView.image = UIImage(data: imageData)
            annotationView?.rightCalloutAccessoryView = imageView
        }
        
        return annotationView
    }

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        renderer.strokeColor = .blue
        return renderer
    }
}

extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
    
}
