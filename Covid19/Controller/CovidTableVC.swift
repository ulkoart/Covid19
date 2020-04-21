//
//  CovidTableVC.swift
//  Covid19
//
//  Created by user on 20.04.2020.
//  Copyright © 2020 ulkoart. All rights reserved.
//

import UIKit
import CoreData

class CovidTableVC: UITableViewController {
    
    var fetchedResultsController:NSFetchedResultsController<CountryData>!
    
    fileprivate func setupFetchedResultsController() {
        let fetchRequest:NSFetchRequest<CountryData> = CountryData.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "slug", ascending: true)
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
        setupFetchedResultsController()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .refresh,
            target: self,
            action: #selector(refreshButtonPressed)
        )
        
    }
    
    @objc func refreshButtonPressed() {
        loadData()
    }
    
    func loadData() {
        Covid19Client.loadCountries(dataController: DataController.shared) { (countries, error) in
            if error != nil {
                DispatchQueue.main.async {
                    self.showAlert(title: "Oops :-(", message: error?.localizedDescription ?? "Network error.")
                    return
                }
            }
            return
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "countryCell", for: indexPath)
        let countryData = fetchedResultsController.object(at: indexPath)
        cell.textLabel?.text = countryData.name
        
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let countryData:CountryData = fetchedResultsController.object(at: indexPath)
        let detail = storyboard?.instantiateViewController(withIdentifier: "сountryDetail") as! DetailVC
        detail.slugSelectedPing = countryData.slug
        navigationController?.showDetailViewController(detail, sender: self)
        
    }
    
}


extension CovidTableVC:NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
            break
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
            break
        case .update:
            tableView.reloadRows(at: [indexPath!], with: .fade)
        case .move:
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
        @unknown default:
            fatalError()
            
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        let indexSet = IndexSet(integer: sectionIndex)
        switch type {
        case .insert: tableView.insertSections(indexSet, with: .fade)
        case .delete: tableView.deleteSections(indexSet, with: .fade)
        case .update, .move:
            fatalError()
        @unknown default:
            fatalError()
        }
    }
    
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}

extension CovidTableVC {
    func showAlert(title: String, message: String) -> Void {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true)
    }
}
