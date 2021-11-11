//
//  HistoricalImageViewController.swift
//  UselessTableViewApp
//
//  Created by Aramis on 11/10/21.
//

import UIKit

class HistoricalImageViewController: UIViewController {
    
    struct HistoricalImage: Codable {
        var width: Double
        var height: Double
        var thumb_url: String
        var image_url: String
        var title: String
        var date: String
        var text: String?
        var folder: String
    }
    
    enum DatabaseError: Error {
        case failedToOpenFile
        case invalidJSON
    }
    
    
    var imageDatabase: [HistoricalImage]?
    let imageCellReuseID = "historicalImageCell"
    
    @IBOutlet weak var historicalImageTable: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        historicalImageTable.delegate = self
        historicalImageTable.dataSource = self
        
        // Was afraid that creating this without keeping a reference would cause problems
        // Seems like it doesn't
        DispatchQueue(label: "DataLoader").async {
            do {
                try self.loadJSONDatabase()
            }
            catch {
                print(error)
            }
        }
    }
    
    
    /// Loads the local image database JSON file and uses it to populate
    /// the table view's data source, imageDatabase
    func loadJSONDatabase() throws {
        if let jsonPath = Bundle.main.path(forResource: "historical_images_compact", ofType: "json") {
            do {
                let jsonData = try String(contentsOfFile: jsonPath).data(using: .utf8)
                guard let jsonData = jsonData else {
                    throw DatabaseError.failedToOpenFile
                }
                imageDatabase = try JSONDecoder().decode([HistoricalImage].self, from: jsonData)
                DispatchQueue.main.async {
                    self.historicalImageTable.reloadData()
                }
            }
            // TODO: Diversify error responses
            catch DecodingError.dataCorrupted(_), DecodingError.keyNotFound(_, _), DecodingError.typeMismatch(_, _), DecodingError.valueNotFound(_, _){
                throw DatabaseError.invalidJSON
            }
            catch {
                throw DatabaseError.failedToOpenFile
            }
        }
    }
}

//MARK: UITableView Extensions
extension HistoricalImageViewController: UITableViewDelegate {}

extension HistoricalImageViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        imageDatabase?.count ?? 0
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
        guard let imageDatabase = imageDatabase,
              let cell = tableView.dequeueReusableCell(withIdentifier: imageCellReuseID) as? HistoricalImageTableViewCell
        else {
            fatalError("Programmer error: failed to dequeue cell for historical image table")
        }
        
        let dbIndex = indexPath.row
        let imageDBEntry = imageDatabase[dbIndex]
        
        cell.imageDescription.text = imageDBEntry.text ?? ""
        //        cell.historicalImage
        
        let imageThumbnailURL = URL(string: imageDBEntry.image_url)
        guard let imageThumbnailURL = imageThumbnailURL else {return cell}
        
        // It's entirely possible that the cell has gone off-screen and had its
        // strong reference removed before the image has been successfully requested
        // As such, capture a weak ref to cell within the closure
        URLSession.shared.dataTask(with: imageThumbnailURL) { [weak cell] (data, response, error) in
            if let data = data{
                guard let image = UIImage(data: data) else {return}
                guard let cell = cell else {return}
                DispatchQueue.main.async {
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
                }
            }
        }.resume()
        
        return cell
    }
    
    
}
