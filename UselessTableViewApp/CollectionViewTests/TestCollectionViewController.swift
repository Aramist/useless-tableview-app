//
//  TestCollectionViewController.swift
//  UselessTableViewApp
//
//  Created by Aramis on 11/21/21.
//

import UIKit

class TestCollectionViewController: UIViewController {
    
    private struct LightImage: Codable {
        var thumbnailURL: String
        var width: Int
        var height: Int
    }

    
    @IBOutlet weak var imageCollectionView: UICollectionView!
    
    private let jsonDataFileName = "url_list"
    private let sectionInsets = UIEdgeInsets(top: 20, left: 10, bottom: 10, right: 10)
    private var imageURLs: [LightImage] = []
    private var wideImages: [LightImage] = []
    private var narrowImages: [LightImage] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageCollectionView.delegate = self
        imageCollectionView.dataSource = self
        
        imageURLs = loadJSON()
        imageCollectionView.reloadData()
        imageURLs.forEach {
            if $0.width >= $0.height {
                wideImages.append($0)
            } else {
                narrowImages.append($0)
            }
        }
        
        // Images with a more extreme aspect ratio come first
        wideImages.sorted {
            ($0.width / $0.height) > ($1.width / $1.height)
        }
        // Therefore all the squares come last (and perfect squares reside in wideImages
        narrowImages.sorted {
            ($0.height / $0.width) > ($1.height / $1.width)
        }
    }
    
    
    private func loadJSON() -> [LightImage] {
        if let jsonPath = Bundle.main.path(forResource: jsonDataFileName, ofType: "json") {
            let jsonData = try? String(contentsOfFile: jsonPath).data(using: .utf8)
            guard let jsonData = jsonData else {
                return []
            }
            
            let jsonImageDataset = try? JSONDecoder().decode([LightImage].self, from: jsonData)
            return jsonImageDataset ?? []
        }
        return []
    }
    
    func requestImage(
        withURL url: String,
        completion: ((_: UIImage?, _: Bool) -> ())? ) {
            guard let url = URL(string: url)
            else {
                completion?(nil, false)
                return
            }
            
            URLSession.shared.dataTask(with: url) { data, _, error in
                guard error == nil,
                      let data = data,
                      let image = UIImage(data: data)
                else {
                    completion?(nil, false)
                    return
                }
                completion?(image, true)
            }.resume()
        }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension TestCollectionViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return min(100, imageURLs.count)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TestCollectionViewCell.reuseID, for: indexPath) as! TestCollectionViewCell
        let useWideImage = indexPath.item % 3 == 2
        let wideIndex = indexPath.item > 1 ? Int((indexPath.item - 2) / 3) : 0
        // Subtracting wideIndex accounts for the 'gap' in the indices created
        let imageStruct = useWideImage ? wideImages[wideIndex] : narrowImages[indexPath.item - wideIndex]
        requestImage(withURL: imageStruct.thumbnailURL) { [weak cell] image, success in
            guard success,
                  let image = image
            else {return}
            DispatchQueue.main.async {
                guard let cell = cell else {return}
                cell.imageView.image = image
            }
        }
        cell.backgroundColor = .honeydew
        return cell
    }
}

extension TestCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let useWideImage = indexPath.item % 3 == 2
        let wideIndex = indexPath.item > 1 ? Int((indexPath.item - 2) / 3) : 0
        // Subtracting wideIndex accounts for the 'gap' in the indices created
        let im = useWideImage ? wideImages[wideIndex] : narrowImages[indexPath.item - wideIndex]
        
        let itemsPerRow: CGFloat = useWideImage ? 1 : 2
        let padding = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = collectionView.bounds.width - padding
        let widthForItem = availableWidth / itemsPerRow
        let aspectRatio = CGFloat(im.height) / CGFloat(im.width)
        let heightForItem = widthForItem * aspectRatio
        
        return CGSize(width: widthForItem, height: heightForItem)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    }
}
