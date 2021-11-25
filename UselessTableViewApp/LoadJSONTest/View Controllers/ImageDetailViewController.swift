//
//  ImageDetailViewController.swift
//  UselessTableViewApp
//
//  Created by Aramis on 11/24/21.
//

import UIKit

class ImageDetailViewController: UIViewController {
    
    static let storyboardID = "ImageDetailVC"
    
    var annotation: HistoricalImage?
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var historicalImage: UIImageView!
    @IBOutlet weak var imageDescription: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .richBlack
        contentView.backgroundColor = .richBlack
        imageDescription.textColor = .white
        
        guard let annotation = annotation else { return }
        
        imageDescription.text = annotation.photoDescription
        historicalImage.addConstraint(
            historicalImage.widthAnchor.constraint(
                equalTo: historicalImage.heightAnchor,
                multiplier: annotation.aspectRatio))
        loadImage()
    }
    
    func loadImage() {
        guard let annotation = annotation else { return }
        
        if let fullImage = annotation.fullImage {
            historicalImage.image = fullImage
            return
        }
        
        annotation.cacheFullImage { [weak self] image, success in
            guard success,
                  let fullImage = image
            else {
                return
            }
            
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.historicalImage.image = fullImage
            }
        }
    }
}
