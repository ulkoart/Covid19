//
//  ViewController.swift
//  Covid19
//
//  Created by user on 19.04.2020.
//  Copyright © 2020 ulkoart. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class CovidMapVC: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var fetchedResultsController:NSFetchedResultsController<CountryData>!
    var slugSelectedPing: String!
    
    fileprivate func setupFetchedResultsController() {
        let fetchRequest:NSFetchRequest<CountryData> = CountryData.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "slug", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: DataController.shared.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        setupFetchedResultsController()
        showCountries()
        loadData()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .refresh,
            target: self,
            action: #selector(refreshButtonPressed)
        )
    }
    
    
    @objc func refreshButtonPressed() {
        loadData()
    }
    
    func showCountries() {
        fetchedResultsController.fetchedObjects?.forEach({ (cd ) in
            addCountryOnMap(cd)
        })
    }
    
    func loadData() {
        activityIndicator.isHidden = false
        Covid19Client.loadCountries(dataController: DataController.shared) { (countries, error) in
            
            if error != nil {
                DispatchQueue.main.async {
                    self.showAlert(title: "Oops :-(", message: error?.localizedDescription ?? "Network error.")
                    return
                }
            }
            
            self.activityIndicator.isHidden = true
            return
        }
    }
    
    func addCountryOnMap(_ cd: CountryData) {
        let lat = CLLocationDegrees(cd.lat)
        let lon = CLLocationDegrees(cd.lon)
        let annotation = Covid19PointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        annotation.title = cd.name
        annotation.slug = cd.slug
        mapView.addAnnotation(annotation)
    }
    
    
}


extension CovidMapVC: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        performSegue(withIdentifier: "showCountryDetail", sender: (Any).self)
        

    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let annotation = view.annotation as? Covid19PointAnnotation
        slugSelectedPing = annotation?.slug
        
        
    }
}

extension CovidMapVC:NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            let cd = anObject as! CountryData
            addCountryOnMap(cd)
            break
        case .delete:
            break
        case .update:
            break
        case .move:
            break
        @unknown default:
            fatalError()
        }
    }
    
}

extension CovidMapVC {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showCountryDetail" {
            let detail = segue.destination as! DetailVC
            detail.slugSelectedPing = slugSelectedPing
        }
    }
}


extension CovidMapVC {
    func showAlert(title: String, message: String) -> Void {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true)
    }
}
