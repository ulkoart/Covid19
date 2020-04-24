//
//  DetailVC.swift
//  Covid19
//
//  Created by user on 20.04.2020.
//  Copyright © 2020 ulkoart. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class DetailVC: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var countryNameLabel: UILabel!
    @IBOutlet weak var confirmedCountLabel: UILabel!
    @IBOutlet weak var deathsCountLabel: UILabel!
    @IBOutlet weak var recoveredCountLabel: UILabel!
    @IBOutlet weak var activeCountLabel: UILabel!
    @IBOutlet weak var mortalityRateCountLabel: UILabel!

    var slugSelectedPing: String!
    var fetchedResultsController: NSFetchedResultsController<CountryData>!
    var countryData: CountryData {
        return (fetchedResultsController.fetchedObjects?[0])!
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupFetchedResultsController()
        updateData(countryData)
        updateMap(countryData)
    }

    fileprivate func setupFetchedResultsController() {
        let fetchRequest: NSFetchRequest<CountryData> = CountryData.fetchRequest()
        let predicate = NSPredicate(format: "slug == %@", slugSelectedPing!)
        fetchRequest.predicate = predicate
        let sortDescriptor = NSSortDescriptor(key: "slug", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: DataController.shared.viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        fetchedResultsController.delegate = self

        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }

    func updateMap(_ countryData: CountryData) {
        let lat = CLLocationDegrees(countryData.lat)
        let long = CLLocationDegrees(countryData.lon)
        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
        mapView.setCenter(coordinate, animated: true)
    }

    func updateData(_ countryData: CountryData) {
        countryNameLabel.text = countryData.name
        confirmedCountLabel.text = String(countryData.confirmed)
        deathsCountLabel.text = String(countryData.deaths)
        recoveredCountLabel.text = String(countryData.recovered)
        activeCountLabel.text = String(countryData.active)
        let mortalityRate: Float = (Float(countryData.deaths) / Float(countryData.confirmed)) * 100
        mortalityRateCountLabel.text = String(round(100 * mortalityRate)/100) + "%"
    }

}

extension DetailVC: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
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
