//
//  LibraryButtonView.swift
//  UselessTableViewApp
//
//  Created by Aramis on 10/17/21.
//

import UIKit

class LibraryButtonView: UIButton {
    
    
    let pi: CGFloat = 3.141592653589793
    let iconBackgroundColor: CGColor = UIColor.white.cgColor
    let iconTintColor: CGColor = UIColor(red: 0.1882, green: 0.4000, blue: 0.7451, alpha: 1.0).cgColor
    
    var bookmark: CALayer!
    
  
    private func makeShapeLayer() -> CAShapeLayer {
        let sl = CAShapeLayer()
        sl.contentsScale = UIScreen.main.scale
        layer.addSublayer(sl)
        sl.frame = layer.bounds
        return sl
    }
    
    func registerTouch() {
        addTarget(self, action: #selector(touchHandler), for: .touchUpInside)
    }
    
    // Creates an L with a rounded outer corner
    private func computeLeftBottomEdgePath(withFrame frame: CGRect) -> CGPath {
        let edgePath = UIBezierPath()
        let width = frame.width,
            height = frame.height
            
        edgePath.move(to: CGPoint(
            x: 0,
            y: 0.2 * height
        ))
        edgePath.addLine(to: CGPoint(
            x: 0.1 * width,
            y: 0.2 * height
        ))
        edgePath.addLine(to: CGPoint(
            x: 0.1 * width,
            y: 0.9 * height
        ))
        edgePath.addLine(to: CGPoint(
            x: 0.8 * width,
            y: 0.9 * height
        ))
        edgePath.addLine(to: CGPoint(
            x: 0.8 * width,
            y: 1.0 * height
        ))
        edgePath.addLine(to: CGPoint(
            x: 0.1 * height,
            y: 1.0 * height
        ))
        edgePath.addArc(
            withCenter: CGPoint(x: 0.1 * width, y: 0.90 * height),
            radius: 0.1 * width,
            startAngle: 1/2*pi, endAngle: pi, clockwise: true)
        edgePath.addLine(to: CGPoint(
            x: 0,
            y: 0.9 * height
        ))
        edgePath.addLine(to: CGPoint(
            x: 0.0,
            y: 0.2 * height
        ))
        return edgePath.cgPath
    }
    
    // Creates a square with rounded corners
    private func computeBookOuterPath(withFrame frame: CGRect) -> CGPath {
        let bookOuterPath = UIBezierPath()
        let width = frame.width,
            height = frame.height
        
        bookOuterPath.move(to: CGPoint(
            x: 0.30 * width,
            y: 0
        ))
        bookOuterPath.addLine(to: CGPoint(
            x: 0.90 * width,
            y: 0
        ))
        bookOuterPath.addArc(
            withCenter: CGPoint(x: 0.90 * width, y: 0.1 * height),
            radius: 0.1 * width,
            startAngle: 3/2 * pi,
            endAngle: 0,
            clockwise: true
        )
        bookOuterPath.addLine(to: CGPoint(
            x: 1.0 * width,
            y: 0.7 * height
        ))
        bookOuterPath.addArc(
            withCenter: CGPoint(x: 0.90 * width, y: 0.7 * height),
            radius: 0.1 * width,
            startAngle: 0,
            endAngle: 1/2 * pi,
            clockwise: true
        )
        bookOuterPath.addLine(to: CGPoint(
            x: 0.30 * width,
            y: 0.80 * height
        ))
        bookOuterPath.addArc(
            withCenter: CGPoint(x: 0.30 * width, y: 0.70 * height),
            radius: 0.1 * width,
            startAngle: 1/2 * pi,
            endAngle: pi,
            clockwise: true
        )
        bookOuterPath.addLine(to: CGPoint(
            x: 0.20 * width,
            y: 0.10 * height
        ))
        bookOuterPath.addArc(
            withCenter: CGPoint(x: 0.30 * width, y: 0.1 * height),
            radius: 0.1 * width,
            startAngle: pi,
            endAngle: 3/2 * pi,
            clockwise: true
        )
        return bookOuterPath.cgPath
    }
    
    
    private func computeBookinnerPath(withFrame frame: CGRect) -> CGPath {
        let width = frame.width,
            height = frame.height
        let bookInnerPath = UIBezierPath(rect: CGRect(
            x: 0.0 * width,
            y: 0.0 * height,
            width: 1.0 * width,
            height: 1.0 * height
        ))
        return bookInnerPath.cgPath
    }
    
    
    private func computeBookmarkPath(withFrame frame: CGRect) -> CGPath {
        
        // Treat the bounds as a square when creating it, it will be resized later
        let bookmarkPath = UIBezierPath()
        let width = frame.width,
            height = frame.height
        
        bookmarkPath.move(to: CGPoint(
            x: 0.0 * width,
            y: 0.0 * height
        ))
        bookmarkPath.addLine(to: CGPoint(
            x: 1.0 * width,
            y: 0.0 * height
        ))
        bookmarkPath.addLine(to: CGPoint(
            x: 1.0 * width,
            y: 1.0 * height
        ))
        bookmarkPath.addLine(to: CGPoint(
            x: 0.50 * width,
            y: 0.80 * height // try 40 maybe
        ))
        bookmarkPath.addLine(to: CGPoint(
            x: 0.0 * width,
            y: 1.0 * height
        ))
        bookmarkPath.addLine(to: CGPoint(
            x: 0.0 * width,
            y: 0.0 * height
        ))
        return bookmarkPath.cgPath
    }
    
    override func draw(_ rect: CGRect) {
        let leftBottomEdge = makeShapeLayer()
        
        let width = layer.bounds.size.width,
            height = layer.bounds.size.height
        
        let edgePath = computeLeftBottomEdgePath(withFrame: leftBottomEdge.frame)
        leftBottomEdge.path = edgePath
        leftBottomEdge.fillColor = iconTintColor
        leftBottomEdge.strokeColor = nil
        leftBottomEdge.opacity = 1.0
        
        let bookOuter = makeShapeLayer()
        let bookOuterPath = computeBookOuterPath(withFrame: bookOuter.frame)
        bookOuter.path = bookOuterPath
        bookOuter.fillColor = iconTintColor
        bookOuter.strokeColor = nil
        bookOuter.opacity = 1.0
        
        let bookInner = makeShapeLayer()
        bookInner.frame = CGRect(
            x: 0.30 * width,
            y: 0.10 * width,
            width: 0.60 * width,
            height: 0.60 * height
        )
        let bookInnerPath = computeBookinnerPath(withFrame: bookInner.frame)
        bookInner.path = bookInnerPath
        bookInner.fillColor = iconBackgroundColor
        bookInner.strokeColor = nil
        bookInner.opacity = 1.0
        
        let bookmark = makeShapeLayer()
        // Replace parent with bookInner
        bookmark.removeFromSuperlayer()
        bookInner.addSublayer(bookmark)
        //bookInner.masksToBounds = true  // Allows the animation to actually work
        bookmark.frame = CGRect(
            x: 0.60 * bookInner.bounds.width,
            y: 0.0 * bookInner.bounds.height,
            width: 0.30 * bookInner.bounds.width,
            height: 0.60 * bookInner.bounds.height
        )
        let bookmarkPath = computeBookmarkPath(withFrame: bookmark.frame)
        bookmark.path = bookmarkPath
        bookmark.fillColor = iconTintColor
        bookmark.strokeColor = nil
        bookmark.opacity = 1.0
        self.bookmark = bookmark
        
        
        makePoint(inLayer: bookInner, atPosition: CGPoint(x: 0, y: 0))
        makePoint(inLayer: bookInner, atPosition: CGPoint(x: 20, y: 20))
    }
    
    
    @objc func touchHandler(_ sender: UIButton?) {
        makeBookmarkAnimation(withBookmark: bookmark)
    }
    
    func makePoint(inLayer superLayer: CALayer, atPosition position: CGPoint) {
        let pointLayer = CAShapeLayer()
        superLayer.addSublayer(pointLayer)
        let circlePath = UIBezierPath(ovalIn: CGRect(x: position.x, y: position.y, width: 10, height: 10)).cgPath
        pointLayer.path = circlePath
        pointLayer.strokeColor = UIColor.black.cgColor
    }
    
    func makeBookmarkAnimation(withBookmark bookmark: CALayer) {
        // Start with the animation that morphs the bookmark into a rectangle
        let oldSize = bookmark.bounds.size
        let oldPosition = bookmark.position
        
        print("Old size: (\(oldSize.width), \(oldSize.height))")
        print("Old position: (\(oldPosition.x), \(oldPosition.y))")
        
        let sizeAnimation = CABasicAnimation(keyPath: "bounds.size")
        sizeAnimation.fromValue = oldSize
        
        let newSize = CGSize(
            width: (bookmark.superlayer?.bounds.width ?? 0) * 4,
            height: (bookmark.superlayer?.bounds.height ?? 0) * 4
        )
        
        sizeAnimation.toValue = newSize
        sizeAnimation.duration = 2
        
        
        let positionAnimation = CABasicAnimation(keyPath: "position")
        let newPosition = CGPoint(x: 0, y: 0)
        positionAnimation.fromValue = oldPosition
        positionAnimation.toValue = newPosition
        positionAnimation.duration = 2
        
        
//        bookmark.bounds.size = newSize
//        bookmark.position = newPosition
//        bookmark.add(positionAnimation, forKey: "position")
        bookmark.add(sizeAnimation, forKey: "bounds.size")
        
    }

}
