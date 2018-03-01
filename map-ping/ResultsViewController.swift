//
//  ResultsViewController.swift
//  map-ping
//
//  Created by Nicholas Whyte on 25/2/18.
//  Copyright © 2018 Nicholas Whyte. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import Groot


class ResultsViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    var ctx: NSManagedObjectContext!
    var fetchedResultsController: NSFetchedResultsController<Session>!
    var dateFormatter: DateFormatter! = nil
    
    override func viewDidLoad() {
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, h:mm a"
        
        initializeFetchedResultsController()
    }
    
    func initializeFetchedResultsController() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        ctx = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<Session>(entityName: "Session")
        let dateSort = NSSortDescriptor(key: "date", ascending: false)
        request.sortDescriptors = [dateSort]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: ctx, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("Failed to initialize FetchedResultsController: \(error)")
        }
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        case .move:
            break
        case .update:
            break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            tableView.reloadRows(at: [indexPath!], with: .fade)
        case .move:
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        guard let session = self.fetchedResultsController?.object(at: indexPath) else {
            fatalError("Attempt to configure cell without a managed object")
        }
        //Populate the cell from the object
        cell.textLabel?.text = dateFormatter.string(from: session.date! as Date)
        let numPoints = session.requests?.count ?? 0
        cell.detailTextLabel?.text = "\(session.network ?? "") - \(numPoints) points"
        return cell
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections!.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = fetchedResultsController.sections else {
            fatalError("No sections in fetchedResultsController")
        }
        let sectionInfo = sections[section]
        return sectionInfo.numberOfObjects
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            // handle delete (by removing the data from your array and updating the tableview)
            let obj = fetchedResultsController.object(at: indexPath)
            ctx.delete(obj)
            try! ctx.save()
        }
    }
    
    // TODO (NW) Reintroduce data export.
    func exportData(obj: Session) {
        let jsonData = try! JSONSerialization.data(withJSONObject: obj.serialize(), options: .prettyPrinted)
        let reqJSONStr = String(data: jsonData, encoding: .utf8)
        let itemsToShare = [reqJSONStr!]
        let activityViewController = UIActivityViewController(activityItems: itemsToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)
    }
    

    private var selectedSession: Session?
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedSession = fetchedResultsController.object(at: indexPath)
        performSegue(withIdentifier: "showResultsDetail", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "showResultsDetail") {
            let destination = segue.destination as! SessionViewController
            destination.session = selectedSession
            selectedSession = nil
        }
    }
}
