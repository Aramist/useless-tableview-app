//
//  LightweightImageAnnotationView.swift
//  UselessTableViewApp
//
//  Created by Aramis on 11/20/21.
//

import MapKit
import UIKit

class LightweightImageAnnotationView: MKAnnotationView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    public static let reuseID = "LightweightImageAnnotationView"
    
    var radius: CGFloat = 5
    let circle: UIView = {
        let v = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        v.backgroundColor = .imperialRed
        v.translatesAutoresizingMaskIntoConstraints = false
        
        let inner = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        inner.backgroundColor = .white
        inner.translatesAutoresizingMaskIntoConstraints = false
        v.addSubview(inner)
        NSLayoutConstraint.activate([
            inner.widthAnchor.constraint(equalTo: v.widthAnchor, multiplier: 0.5),
            inner.heightAnchor.constraint(equalTo: v.heightAnchor, multiplier: 0.5),
            inner.centerXAnchor.constraint(equalTo: v.centerXAnchor),
            inner.centerYAnchor.constraint(equalTo: v.centerYAnchor)
        ])
        return v
    }()
    
    var childAnnotationView: ImageAnnotationView?
    

    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        arrangeSubview()
    }
    
    override func prepareForDisplay() {
        super.prepareForDisplay()
        guard let annotation = annotation as? ImageGroup else {return}
        childAnnotationView?.prepareForDisplay(withAnnotation: annotation)
    }
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        childAnnotationView?.prepareForReuse()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func activate() {
        childAnnotationView?.show()
    }
    
    func deactivate() {
        childAnnotationView?.hide()
    }
    
    fileprivate func arrangeSubview() {
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(circle)
        NSLayoutConstraint.activate([
            circle.widthAnchor.constraint(equalToConstant: radius * 2),
            circle.heightAnchor.constraint(equalToConstant: radius * 2),
            circle.centerXAnchor.constraint(equalTo: centerXAnchor),
            circle.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        circle.layer.cornerRadius = radius
        circle.subviews.first?.layer.cornerRadius = radius / 2
        
        let child = ImageAnnotationView()
        childAnnotationView = child
        addSubview(child)
        print(child.isUserInteractionEnabled)
        child.isUserInteractionEnabled = true
        NSLayoutConstraint.activate([
            child.leadingAnchor.constraint(equalTo: centerXAnchor),
            child.bottomAnchor.constraint(equalTo: centerYAnchor),
        ])
    }
}
