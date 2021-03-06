//
//  MangaListViewController.swift
//  UselessTableViewApp
//
//  Created by Aramis on 11/5/21.
//

import UIKit

class MangaListViewController: UIViewController {
    
    let cdContext = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
    var mangaDirectory: [Manga]?
    
    @IBOutlet weak var mangaNameTable: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mangaNameTable.delegate = self
        mangaNameTable.dataSource = self
        queryManga()
    }
    
    
    /// Fetches all manga objects from persistent storage
    func queryManga() {
        let fetchRequest = Manga.fetchRequest()
        do {
            let results = try cdContext?.fetch(fetchRequest)
            mangaDirectory = results
            DispatchQueue.main.async {
                self.mangaNameTable.reloadData()
            }
        }
        catch {
            print("Error fetching manga list")
        }
    }
    
    /// Adds a manga object to the persistent store
    /// - Parameters:
    ///   - title: Title of the manga
    ///   - chapters: Number of chapters
    func addManga(withTitle title: String, withChapterCount chapters: Int) {
        guard let cdContext = cdContext else {
            print("No context.")
            return
        }
        let newManga = Manga(context: cdContext)
        newManga.name = title
        newManga.chapterCount = Int16(chapters)
        newManga.synopsis = ""
        
        do {
            try cdContext.save()
        }
        catch {
            print("Failed to save Core Data context.")
        }
        queryManga()
    }
    
    /// Removes a manga instance from the persistent store
    /// - Parameter manga: Qbject to remove
    func removeManga(_ manga: Manga) {
        do {
            cdContext?.delete(manga)
            try cdContext?.save()
            
            queryManga()
        }
        catch {
            print("Failed to save Core Data context.")
        }
    }
    
    
    /// Presents a display to create a manga object
    @IBAction func didPressAddButton() {
        let alertView = UIAlertController(title: "Add a manga", message: "Enter title and chapter count", preferredStyle: .alert)
        alertView.addTextField()  // Title
        alertView.addTextField()  // Chapter count
        
        let submitButton = UIAlertAction(title: "Add", style: .default) {_ in
            let title = alertView.textFields![0].text!
            let chapCount = Int(alertView.textFields![1].text!)!
            self.addManga(withTitle: title, withChapterCount: chapCount)
        }
        
        alertView.addAction(submitButton)
        present(alertView, animated: true, completion: nil)
    }

}


// MARK: Extensions
extension MangaListViewController: UITableViewDelegate {}

extension MangaListViewController: UITableViewDataSource {
    /// Inserts a manga's title into every table row
    /// - Parameters:
    ///   - tableView: The table being populated
    ///   - indexPath: Location of the current entry
    /// - Returns: A cell for the entry
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "mangaCell")
        guard let cell = cell else {
            return UITableViewCell()
        }
        cell.textLabel?.text = mangaDirectory?[indexPath.row].name
        
        return cell
    }
    
    /// Creates a swipe-to-delete action for each row
    /// - Parameters:
    ///   - tableView: The table view receiving the action
    ///   - indexPath: The location of the current entry
    /// - Returns: A configuration containing a swipe-to-delete action
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, view, handler) in
            let deletionTarget = self.mangaDirectory![indexPath.row]
            self.removeManga(deletionTarget)
            handler(true)
        }
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        return configuration
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mangaDirectory?.count ?? 0
    }
}
