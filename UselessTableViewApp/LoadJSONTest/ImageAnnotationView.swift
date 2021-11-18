//
//  ImageAnnotationView.swift
//  UselessTableViewApp
//
//  Created by Aramis on 11/17/21.
//

import MapKit
import UIKit
import CloudKit

class ImageAnnotationView: MKAnnotationView {
    /// Honestly, might be smoother to use the built-in image property and draw a white border around it
    /// The point on the bottom doesn't even seem to be anchored on the point so the
    /// view is likely centered
    
    let marginWidth: CGFloat = 10
    let cornerPointHeight: CGFloat = 10
    let cornerPointWidth: CGFloat = 5
    let cornerRadius: CGFloat = 5
    let annotationWidth: CGFloat = 90
    let clusterCountRadius: CGFloat = 10
    
    var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    let clusterCountView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        view.layer.cornerRadius = 10
        view.backgroundColor = .red
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let clusterCountLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 14)
        label.text = ""
        label.textAlignment = .center
        label.numberOfLines = 1
        label.clipsToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Constraints that change when the size of the annotation's image changes
    var dynamicConstraints: [NSLayoutConstraint] = []
    
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        self.frame = CGRect(x: 0, y: 0, width: annotationWidth, height: annotationWidth)
        setupSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func draw(_ rect: CGRect) {
        drawBackground()
        super.draw(rect)
    }
    
    override func prepareForDisplay() {
        super.prepareForDisplay()
        guard let annotation = annotation else {return}
        // Removing this will create conflicts because annotation views are recycled
        clusterCountView.isHidden = true
        removeConstraints(dynamicConstraints)
        dynamicConstraints.removeAll()
        showImage(for: annotation)
    }
    
    //MARK: private fns
    fileprivate func setupSubviews() {
        isOpaque = false
        backgroundColor = .clear
        layoutMargins = UIEdgeInsets(top: marginWidth, left: marginWidth, bottom: marginWidth + cornerPointHeight, right: marginWidth)
        translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(imageView)
        addSubview(clusterCountView)
        clusterCountView.addSubview(clusterCountLabel)
        clusterCountView.isHidden = true
        
        NSLayoutConstraint.activate([
            // Image and parent constraints
            widthAnchor.constraint(equalToConstant: annotationWidth),
            imageView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor),
            // Cluster count constraints
            clusterCountLabel.centerXAnchor.constraint(equalTo: clusterCountView.centerXAnchor),
            clusterCountLabel.centerYAnchor.constraint(equalTo: clusterCountView.centerYAnchor),
            clusterCountView.heightAnchor.constraint(equalToConstant: 2 * clusterCountRadius),
            clusterCountView.widthAnchor.constraint(equalTo: clusterCountView.heightAnchor),
            clusterCountView.centerXAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
            clusterCountView.centerYAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor)
        ])
    }
    
    fileprivate func showImage(for annotation: MKAnnotation) {
        var displayAnnotation: HistoricalImage? = annotation as? HistoricalImage
        var clusterSize: Int?
        
        if let cluster = annotation as? MKClusterAnnotation {
            print("Annotation was cluster")
            // In this case, displayAnnotation is currently nil
            displayAnnotation = cluster.memberAnnotations.first as? HistoricalImage
            clusterSize = cluster.memberAnnotations.count
            // Won't make the cluster count view visible here because the image hasn't loaded yet
        }
        // displayAnnotation is a random annotation whose image will be displayed
        guard let displayAnnotation = displayAnnotation else {return}

        
        if let cachedImage = displayAnnotation.thumbnailImage {
            imageView.image = cachedImage
            resize(for: cachedImage)
            // If it is a cluster, add the number of images to the corner
            if let clusterSize = clusterSize {
                self.clusterCountLabel.text = "\(clusterSize)"
                self.clusterCountView.isHidden = false
            }
        } else {
            displayAnnotation.cacheThumbnailImage() { [weak self] cachedImage, success in
                guard success,
                      let cachedImage = cachedImage
                else {return}
                // Technically success implies cachedImage != nil, but I don't like force unwrapping
                DispatchQueue.main.async {
                    guard let self = self else {return}
                    self.imageView.image = cachedImage
                    self.resize(for: cachedImage)
                    // If it is a cluster, add the number of images to the corner
                    if let clusterSize = clusterSize {
                        self.clusterCountLabel.text = "\(clusterSize)"
                        self.clusterCountView.isHidden = false
                    }
                }
            }
        }
    }
    
    /// Resizes the parent view to accomodate an image. Does not insert the image into child image view
    /// - Parameter image: Image to use when calculating new size
    fileprivate func resize(for image: UIImage) {
        let aspectRatio = (image.size.height + 2 * marginWidth) / (image.size.width + 2 * marginWidth)
        let dynamicConstraint = heightAnchor.constraint(equalTo: widthAnchor, multiplier: aspectRatio, constant: cornerPointHeight)
        NSLayoutConstraint.activate([dynamicConstraint])
        dynamicConstraints.append(dynamicConstraint)
        // Redraw the background now that the size of the parent view is determined
        self.setNeedsDisplay()
    }
    
    /// Draws the background as a white rounded rectangle with a pointed bottom-left corner
    fileprivate func drawBackground() {
        // Housekeeping
        let drawLayer = CAShapeLayer()
        drawLayer.contentsScale = UIScreen.main.scale
        drawLayer.isOpaque = false  // False because the region right of the pointed corner is transparent
        layer.addSublayer(drawLayer)
        
        let width: CGFloat = bounds.size.width,
            height: CGFloat =  bounds.size.height
        let path = UIBezierPath()
        path.move(to: CGPoint(x: cornerRadius, y: 0))
        path.addLine(to: CGPoint(x: width - cornerRadius, y: 0))
        path.addArc(
            withCenter: CGPoint(x: width - cornerRadius, y: cornerRadius),
            radius: cornerRadius,
            startAngle: 3 * CGFloat.pi / 2,
            endAngle: 2 * CGFloat.pi,
            clockwise: true)
        path.addLine(to: CGPoint(x: width, y: height - cornerPointHeight - cornerRadius))
        path.addArc(
            withCenter: CGPoint(x: width - cornerRadius, y: height - cornerPointHeight - cornerRadius),
            radius: cornerRadius,
            startAngle: 0,
            endAngle: CGFloat.pi / 2,
            clockwise: true)
        path.addLine(to: CGPoint(x: cornerPointWidth, y: height - cornerPointHeight))
        path.addLine(to: CGPoint(x: 0, y: height))
        path.addArc(
            withCenter: CGPoint(x: cornerRadius, y: cornerRadius),
            radius: cornerRadius,
            startAngle: CGFloat.pi,
            endAngle: 3 * CGFloat.pi / 2,
            clockwise: true)
        
        drawLayer.path = path.cgPath
        drawLayer.fillColor = UIColor.white.cgColor
        drawLayer.zPosition = -1
    }
}