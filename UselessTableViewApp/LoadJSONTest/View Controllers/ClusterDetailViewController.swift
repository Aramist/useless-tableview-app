//
//  ClusterDetailViewController.swift
//  UselessTableViewApp
//
//  Created by Aramis on 11/21/21.
//

import UIKit

class ClusterDetailViewController: UIViewController {

    
    @IBOutlet weak var intersectionLabel: UILabel!
    @IBOutlet weak var imageCollectionView: UICollectionView!
    
    var images: [HistoricalImage] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        intersectionLabel.text = "Test"
        intersectionLabel.textColor = .richBlack
        
        testGradientMask()
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
