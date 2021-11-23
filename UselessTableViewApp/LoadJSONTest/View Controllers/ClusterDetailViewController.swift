//
//  ClusterDetailViewController.swift
//  UselessTableViewApp
//
//  Created by Aramis on 11/21/21.
//

import UIKit

class ClusterDetailViewController: UIViewController {

    static let storyboardID = "clusterDetailVC"
    
    @IBOutlet weak var intersectionLabel: UILabel!
    @IBOutlet weak var imageCollectionView: UICollectionView!
    
    let contentInset: CGFloat = 5.0
    let sectionInset: CGFloat = 5.0
    
    var images: [HistoricalImage] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        intersectionLabel.text = "Test"
        intersectionLabel.textColor = .richBlack
        
        imageCollectionView.delegate = self
        imageCollectionView.dataSource = self
        
//        testGradientMask()
    }
    

    func testGradientMask() {
        let gradientStart: CGFloat = 0.0
        let gradientEnd: CGFloat = 50.0 / view.layer.bounds.height
        
        let transparent = UIColor.honeydew.withAlphaComponent(0.0).cgColor
        let white = UIColor.honeydew.cgColor
        
        let drawingLayer = CAGradientLayer()
        drawingLayer.isOpaque = false
        drawingLayer.contentsScale = UIScreen.main.scale
        view.layer.addSublayer(drawingLayer)
        
        drawingLayer.colors = [white, transparent]
        drawingLayer.startPoint = CGPoint(x: 0.5, y: gradientStart)
        drawingLayer.endPoint = CGPoint(x: 0.5, y: gradientEnd)
        drawingLayer.type = .axial
        drawingLayer.shouldRasterize = true
        
        drawingLayer.frame = view.layer.bounds
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


extension ClusterDetailViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let image = images[indexPath.item]
        let availWidth = collectionView.bounds.inset(by: collectionView.layoutMargins).width
//        let individualWidth = (totalWidth - 2.0 * contentInset - 2.0 * sectionInset) / 2.0  // 2 columns
        let cellWidth = (availWidth / 2.0).rounded(.down)
        
        let height = cellWidth * CGFloat(image.imageHeight) / CGFloat(image.imageWidth)
        return CGSize(width: cellWidth, height: height)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: sectionInset, left: sectionInset, bottom: sectionInset, right: sectionInset)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        sectionInset
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        contentInset
    }
    
}

extension ClusterDetailViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageDetailCollectionViewCell.reuseID, for: indexPath)
        guard let cell = cell as? ImageDetailCollectionViewCell else {return cell}
        let historicalImage = images[indexPath.item]
        
        if let fullImage = historicalImage.fullImage {
            cell.image.image = fullImage
        } else {
            historicalImage.cacheFullImage { [weak cell, weak self] fullImage, success in
                DispatchQueue.main.async {
                    guard success,
                          let fullImage = fullImage,
                          let cell = cell,
                          let self = self
                    else {
                        return
                    }
                    cell.image.image = fullImage
                    self.imageCollectionView.reloadData()
                }
            }
        }
        
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
}
