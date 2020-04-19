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
    
    var dataController: DataController {
        let object = UIApplication.shared.delegate
        let appDelegate = object as! AppDelegate
        return appDelegate.dataController
    }
    var fetchedResultsController:NSFetchedResultsController<CountryData>!
    
    fileprivate func setupFetchedResultsController() {
        let fetchRequest:NSFetchRequest<CountryData> = CountryData.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "slug", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
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
        

        
//        fetchedResultsController.fetchedObjects
        
//        loadData()
        
        
        
        
    }
    
    func loadData() {
        activityIndicator.isHidden = false
        Covid19Client.loadCountries(dataController: dataController) { (countries, error) in
            
            self.activityIndicator.isHidden = true
            return
        }
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
        print(view.annotation?.title)
    }
    
}

extension CovidMapVC:NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            print ("insert")
            let cd = anObject as! CountryData
    
            let lat = CLLocationDegrees(cd.lat)
            let lon = CLLocationDegrees(cd.lon)
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            annotation.title = cd.name
            mapView.addAnnotation(annotation)

            
            
            
            break
        case .delete:
            print ("delete")
            break
        case .update:
            print ("update")
        case .move:
            print ("move")
        @unknown default:
            fatalError()
        }
    }
    


    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print ("controllerWillChangeContent")
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print ("controllerDidChangeContent")
    }
    
}
