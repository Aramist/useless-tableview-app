//
//  BottomShadowView.swift
//  UselessTableViewApp
//
//  Created by Aramis on 10/17/21.
//

import UIKit

class BottomShadowView: UIView {
    
    convenience init() {
        self.init(frame: CGRect())
        self.translatesAutoresizingMaskIntoConstraints = false
        isOpaque = false
    }

    override func draw(_ rect: CGRect) {
        // Draws a gradent from 0.80 to 1.0 on the y axis going from a clear black
        // (0, 0, 0, 0.0) to an opaque-ish black (0, 0, 0, 0.6)
        let gradientStart: CGFloat = 0.75
        let transparent = UIColor(red: 0, green: 0, blue: 0, alpha: 0).cgColor
        let black = UIColor(red: 0, green: 0, blue: 0, alpha: 0.6).cgColor
        
        let drawingLayer = CAGradientLayer()
        drawingLayer.isOpaque = false
        drawingLayer.contentsScale = UIScreen.main.scale
        layer.addSublayer(drawingLayer)
        
        drawingLayer.colors = [transparent, black]
        drawingLayer.startPoint = CGPoint(x: 0.5, y: gradientStart)
        drawingLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        drawingLayer.type = .axial
        drawingLayer.shouldRasterize = true
        
        drawingLayer.frame = bounds
    }

}
