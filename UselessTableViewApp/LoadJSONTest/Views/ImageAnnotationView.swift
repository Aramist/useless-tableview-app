//
//  ImageAnnotationView.swift
//  UselessTableViewApp
//
//  Created by Aramis on 11/17/21.
//

import MapKit
import UIKit
import CloudKit

class ImageAnnotationView: UIView {
    
    let marginWidth: CGFloat = 8
    let cornerPointHeight: CGFloat = 20
    let cornerPointWidth: CGFloat = 10
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
        view.backgroundColor = .imperialRed
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let clusterCountLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        label.text = ""
        label.textAlignment = .center
        label.numberOfLines = 1
        label.clipsToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var aspectRatioConstraint: NSLayoutConstraint?
    
    var previewImage: HistoricalImage?
    var clusterSize: Int = 0
    
    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: annotationWidth, height: annotationWidth))
        isHidden = true
        setupSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        drawBackground()
        super.draw(rect)
    }
    
    func prepareForDisplay(withAnnotation annotation: ImageGroup) {
        samplePreviewImage(from: annotation)
        resize()
        showImage()
    }
    
    func show() {
        guard isHidden else {return}
        let animation = CAKeyframeAnimation(keyPath: "transform.scale")
        animation.values = [0.05, 1.2, 0.8, 1.0]
        animation.keyTimes = [0.0, 0.15, 0.3, 0.60]
        animation.duration = 0.60
        isHidden = false
        layer.add(animation, forKey: "bounceAnimation")
    }
    
    func hide() {
        guard !isHidden else {return}
        CATransaction.begin()
        CATransaction.setCompletionBlock { [weak self] in
            self?.isHidden = true
        }
        let animation = CAKeyframeAnimation(keyPath: "transform.scale")
        animation.values = [1.0, 0.05]
        animation.keyTimes = [0.0, 0.30]
        animation.duration = 0.30
        layer.add(animation, forKey: "bounceAnimation")
        CATransaction.commit()
    }
    
    func prepareForReuse() {
        isHidden = true
        clusterCountView.isHidden = true
        
        if let aspectRatioConstraint = aspectRatioConstraint {
            aspectRatioConstraint.isActive = false
            removeConstraint(aspectRatioConstraint)
        }
        aspectRatioConstraint = nil
        imageView.image = nil
        previewImage = nil
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
    
    
    /// When annotation is an ImageGroup, instantiates previewImage with a
    /// random HistoricalImage from the annotation's children
    /// - Parameter annotation: ImageGroup to sample from
    fileprivate func samplePreviewImage(from annotation: MKAnnotation) {
        guard let imageGroup = annotation as? ImageGroup else {return}
        previewImage = imageGroup.sampleImage
        clusterSize = imageGroup.images?.count ?? 0
    }
    
    fileprivate func showImage() {
        guard let previewImage = previewImage else {return}

        
        if let cachedImage = previewImage.thumbnailImage {
            imageView.image = cachedImage
            // If it is a cluster, add the number of images to the corner
            if clusterSize > 0 {
                let clusterText = clusterSize > 9 ? "9+" : "\(clusterSize)"
                self.clusterCountLabel.text = clusterText
                self.clusterCountView.isHidden = false
            }
        } else {
            previewImage.cacheThumbnailImage() { [weak self] cachedImage, success in
                guard success,
                      let cachedImage = cachedImage
                else {return}
                // Technically success implies cachedImage != nil, but I don't like force unwrapping
                DispatchQueue.main.async {
                    guard let self = self else {return}
                    self.imageView.image = cachedImage
                    // If it is a cluster, add the number of images to the corner
                    if self.clusterSize > 0 {
                        let clusterText = self.clusterSize > 9 ? "9+" : "\(self.clusterSize)"
                        self.clusterCountLabel.text = clusterText
                        self.clusterCountView.isHidden = false
                    }
                }
            }
        }
    }
    
    /// Resizes the parent view to accomodate an image. Does not insert the image into child image view
    /// - Parameter image: Image to use when calculating new size
    fileprivate func resize() {
        guard let image = previewImage else {return}
        
        let height: CGFloat = CGFloat(image.imageHeight),
            width: CGFloat = CGFloat(image.imageWidth)
        let aspectRatio = (height + 2 * marginWidth) / (width + 2 * marginWidth)
        let aspectRatioConstraint = heightAnchor.constraint(equalTo: widthAnchor, multiplier: aspectRatio, constant: cornerPointHeight)
        self.aspectRatioConstraint = aspectRatioConstraint
        self.addConstraint(aspectRatioConstraint)
        aspectRatioConstraint.isActive = true
        setNeedsDisplay()
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
        drawLayer.fillColor = UIColor.honeydew.cgColor
        drawLayer.zPosition = -1
    }
}
