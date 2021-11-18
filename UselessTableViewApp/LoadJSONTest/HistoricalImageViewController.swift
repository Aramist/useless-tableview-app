//
//  HistoricalImageViewController.swift
//  UselessTableViewApp
//
//  Created by Aramis on 11/10/21.
//

import UIKit
import MapKit
import CoreLocation
import CoreData

class HistoricalImageViewController: UIViewController {
    
    @IBOutlet weak var historicalImageTable: UITableView!
    
    let imageCellReuseID = "historicalImageCell"
    var locationManager: CLLocationManager?
    var nearbyImages: [HistoricalImage] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        historicalImageTable.delegate = self
        historicalImageTable.dataSource = self
        
        
        // Apparently there is a special way to work with core data outside the main thread
        // See: https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/CoreData/Concurrency.html
        // Furthermore, NSManagedObjects are not thread safe
        // This is likely why I'm seeing nil values on all properties after assigning nearbyImages...
        
        
        // Removing everything from this class for now. Might delete later
        
        locationManager = CLLocationManager()
        guard let locationManager = locationManager,
              CLLocationManager.significantLocationChangeMonitoringAvailable()
        else {return}
        locationManager.startMonitoringSignificantLocationChanges()
    }
    
}

//MARK: UITableView Extensions
extension HistoricalImageViewController: UITableViewDelegate {}

extension HistoricalImageViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nearbyImages.count
    }
    
    /// Creates a table cell with a historical image and a description
    /// The images are requested from NYPL servers using the URLs listed
    /// in the database JSON file. The descriptions come from the same source
    /// TODO: adopt a new database storage method that does not require keeping
    /// the entire DB in memory at all times...
    /// - Parameters:
    ///   - tableView: Table view to which this cell will belong
    ///   - indexPath: Location of the cell within the table
    /// - Returns: A reusable cell with image and text
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: imageCellReuseID) as? HistoricalImageTableViewCell
        else {
            fatalError("Programmer error: failed to dequeue cell for historical image table")
        }
        
        let dbIndex = indexPath.row
        let imageDBEntry = nearbyImages[dbIndex]
        
        let imageDescription = imageDBEntry.photoDescription ?? ""
        cell.imageDescription.text = imageDescription
        
        guard let thumbnailURL = imageDBEntry.thumbnailURL else {
            return cell
        }
        
        let imageThumbnailURL = URL(string: thumbnailURL)
        guard let imageThumbnailURL = imageThumbnailURL else {return cell}
        
        // It's entirely possible that the cell has gone off-screen and had its
        // strong reference removed before the image has been successfully requested
        // As such, capture a weak ref to cell within the closure
        URLSession.shared.dataTask(with: imageThumbnailURL) { [weak cell] (data, response, error) in
            if let data = data{
                guard let image = UIImage(data: data) else {return}
                DispatchQueue.main.async {
                    guard let cell = cell else {return}
                    cell.historicalImage.image = image
                    //                    let aspectRatio = image.size.height / image.size.width
                    //                    NSLayoutConstraint.activate([
                    //                        cell.historicalImage.heightAnchor.constraint(
                    //                            equalTo: cell.historicalImage.widthAnchor,
                    //                            multiplier: aspectRatio)
                    //                    ])
                    // Apparently creating an image view with a constraint in only
                    // One size dimension does this automatically.
                    // Could also be a side effect of the aspect fill option...
                    
                    // For some reason the labels end in an elipses randomly the first time
                    // the cell view is loaded, but fix themselves if the cell is deallocated
                    // And reloaded later. I think it has something to do with the image
                    // Being empty the first time the cell is loaded
                    // cell.layoutIfNeeded()  // Didn't fix it
                    // One potential solution: Don't fill label until image is present
                }
            }
        }.resume()
        
        return cell
    }
}

//MARK: CLLocationManager Extension
extension HistoricalImageViewController: CLLocationManagerDelegate {
    /// Recomputes nearby images and presents annotations for them
    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]) {
        guard let recentLocation = locations.last else {return}
        
    }
}
