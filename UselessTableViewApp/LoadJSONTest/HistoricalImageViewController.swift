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
        
        DispatchQueue(label: "DataLoader").async {
            do {
                try self.loadJSONDatabase()
            }
            catch {
                print(error)
            }
        }
    }
    
    
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
            catch DecodingError.dataCorrupted(_), DecodingError.keyNotFound(_, _), DecodingError.typeMismatch(_, _), DecodingError.valueNotFound(_, _){
                throw DatabaseError.invalidJSON
            }
            catch {
                print(error)
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let imageDatabase = imageDatabase,
              let cell = tableView.dequeueReusableCell(withIdentifier: imageCellReuseID) as? HistoricalImageTableViewCell
        else {
            fatalError("Progammer error: failed to dequeue cell for historical image table")
        }
        
        let dbIndex = indexPath.row
        let imageDBEntry = imageDatabase[dbIndex]
        
        cell.imageDescription.text = imageDBEntry.text ?? ""
//        cell.historicalImage
        
        let imageThumbnailURL = URL(string: imageDBEntry.image_url)
        guard let imageThumbnailURL = imageThumbnailURL else {return cell}

        URLSession.shared.dataTask(with: imageThumbnailURL) { [weak cell] (data, response, error) in
            if let data = data{
                guard let image = UIImage(data: data) else {return}
                guard let cell = cell else {return}
                DispatchQueue.main.async {
                    cell.historicalImage.image = image
//                    let aspectRatio = image.size.height / image.size.width
//                    NSLayoutConstraint.activate([
//                        cell.historicalImage.heightAnchor.constraint(equalTo: cell.historicalImage.widthAnchor, multiplier: aspectRatio)
//                    ])
                }
            }
        }.resume()
        
        return cell
    }
    
    
}
