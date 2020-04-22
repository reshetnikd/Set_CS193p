//
//  SetCardView.swift
//  Set
//
//  Created by Dmitry Reshetnik on 16.04.2020.
//  Copyright © 2020 Dmitry Reshetnik. All rights reserved.
//

import UIKit

class SetCardView: UIView {

    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        isOpaque = false
        backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        let roundedRect: UIBezierPath = UIBezierPath(roundedRect: bounds, cornerRadius: 8.0)
        roundedRect.addClip()
        UIColor.white.setFill()
        roundedRect.fill()
        // Draw figures or cardback on self.
        if isFaceUp {
            drawContent()
        } else {
            if let cardBackImage = UIImage(named: "cardback", in: Bundle(for: self.classForCoder), compatibleWith: traitCollection) {
                cardBackImage.draw(in: bounds)
            }
        }
    }
    
    var number: Int? {
        didSet {
            setNeedsDisplay()
        }
    }
    var shape: String? {
        didSet {
            setNeedsDisplay()
        }
    }
    var shading: String? {
        didSet {
            setNeedsDisplay()
        }
    }
    var color: String? {
        didSet {
            setNeedsDisplay()
        }
    }
    var isFaceUp: Bool = false {
        didSet {
            setNeedsDisplay()
        }
    }
    
    /// Draw diamond figure via UIBezierPath mechanism.
    private func drawDiamond(in rect: CGRect) -> UIBezierPath {
        let diamond: UIBezierPath = UIBezierPath()
        diamond.move(to: CGPoint(x: rect.midX, y: rect.minY))
        diamond.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        diamond.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        diamond.addLine(to: CGPoint(x: rect.minX, y: rect.midY))
        diamond.close()
        return diamond
    }
    
    /// Draw squiggle figure via UIBezierPath mechanism.
    private func drawSquiggle(in rect: CGRect) -> UIBezierPath {
        let squiggle: UIBezierPath = UIBezierPath()
        squiggle.move(to: CGPoint(x: rect.minX, y: rect.midY))
        squiggle.addCurve(to: CGPoint(x: rect.minX + rect.size.width * 1/2, y: rect.minY + rect.size.height/8),
                          controlPoint1: CGPoint(x: rect.minX, y: rect.minY),
                          controlPoint2: CGPoint(x: rect.minX + rect.size.width * 1/2 - (rect.size.width * Coefficient.widthDeviation), y: rect.minY + rect.size.height/8 - (rect.size.height * Coefficient.heightDeviation)))
        squiggle.addCurve(to: CGPoint(x: rect.minX + rect.size.width * 4/5, y: rect.minY + rect.size.height/8),
                          controlPoint1: CGPoint(x: rect.minX + rect.size.width * 1/2 + (rect.size.width * Coefficient.widthDeviation), y: rect.minY + rect.size.height/8 + (rect.size.height * Coefficient.heightDeviation)),
                          controlPoint2: CGPoint(x: rect.minX + rect.size.width * 4/5 - (rect.size.width * Coefficient.widthDeviation), y: rect.minY + rect.size.height/8 + (rect.size.height * Coefficient.heightDeviation)))
        squiggle.addCurve(to: CGPoint(x: rect.maxX, y: rect.minY + rect.size.height/2),
                          controlPoint1: CGPoint(x: rect.minX + rect.size.width * 4/5 + (rect.size.width * Coefficient.widthDeviation), y: rect.minY + rect.size.height/8 - (rect.size.height * Coefficient.heightDeviation)),
                          controlPoint2: CGPoint(x: rect.maxX, y: rect.minY))
        // Create rotated copy of squiggle path and add it to original path.
        let path: UIBezierPath = UIBezierPath(cgPath: squiggle.cgPath)
        path.apply(CGAffineTransform.identity.rotated(by: CGFloat.pi))
        path.apply(CGAffineTransform.identity.translatedBy(x: bounds.width, y: bounds.height))
        squiggle.move(to: CGPoint(x: rect.minX, y: rect.midY))
        squiggle.append(path)
        return squiggle
    }
    
    /// Draw oval figure via UIBezierPath mechanism.
    private func drawOval(in rect: CGRect) -> UIBezierPath {
        let oval: UIBezierPath = UIBezierPath()
        oval.addArc(withCenter: CGPoint(x: rect.midX - rect.size.width/4, y: rect.midY), radius: rect.height/2, startAngle: CGFloat.pi/2, endAngle: (3 * CGFloat.pi)/2, clockwise: true)
        oval.addLine(to: CGPoint(x: rect.midX + rect.size.width/4, y: rect.minY))
        oval.addArc(withCenter: CGPoint(x: rect.midX + rect.size.width/4, y: rect.midY), radius: rect.height/2, startAngle: (3 * CGFloat.pi)/2, endAngle: CGFloat.pi/2, clockwise: true)
        oval.close()
        return oval
    }
    
    /// Draw strips on a symbol.
    private func stripeSymbol(path: UIBezierPath, in rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        context?.saveGState()
        path.addClip()
        drawStripes(rect)
        context?.restoreGState()
    }
    
    /// Draw dashed line with width of bounds size height.
    private func drawStripes(_ rect: CGRect) {
        let stripe: UIBezierPath = UIBezierPath()
        let dashes: [CGFloat] = [1.0,4.0]
        stripe.setLineDash(dashes, count: dashes.count, phase: 0.0)
        stripe.lineWidth = bounds.size.height
        stripe.lineCapStyle = CGLineCap.butt
        stripe.move(to: CGPoint(x: bounds.minX, y: bounds.midY))
        stripe.addLine(to: CGPoint(x: bounds.maxX, y: bounds.midY))
        stripe.stroke()
    }
    
    /// Selects the required shape, color and shape shading and call it draw methods.
    private func drawSymbol(in rect: CGRect) {
        var symbol: UIBezierPath = UIBezierPath()

        switch shape {
        case "diamond":
            symbol = drawDiamond(in: rect)
        case "squiggle":
            symbol = drawSquiggle(in: rect)
        case "oval":
            symbol = drawOval(in: rect)
        default:
            break
        }

        switch color {
        case "red":
            UIColor.red.setFill()
            UIColor.red.setStroke()
        case "green":
            UIColor.green.setFill()
            UIColor.green.setStroke()
        case "purple":
            UIColor.purple.setFill()
            UIColor.purple.setStroke()
        default:
            break
        }

        switch shading {
        case "striped":
            stripeSymbol(path: symbol, in: rect)
        case "solid":
            symbol.fill()
        default:
            break
        }

        symbol.stroke()
    }
    
    /// Controls the location of figures on the view depending on the number.
    private func drawContent() {
        let symbolWidth: CGFloat = bounds.size.width * Coefficient.widthParameter
        let symbolHeight: CGFloat = bounds.size.height * Coefficient.heightParameter
        let symbolRect: CGRect = CGRect(x: bounds.midX.advanced(by: -(symbolWidth/2)), y: bounds.midY.advanced(by: -(symbolHeight/2)), width: symbolWidth, height: symbolHeight)
        switch number {
        case 1:
            drawSymbol(in: symbolRect)
        case 2:
            drawSymbol(in: CGRect(origin: CGPoint(x: symbolRect.origin.x, y: symbolRect.origin.y - symbolHeight/2 - Coefficient.ident), size: symbolRect.size))
            drawSymbol(in: CGRect(origin: CGPoint(x: symbolRect.origin.x, y: symbolRect.origin.y + symbolHeight/2 + Coefficient.ident), size: symbolRect.size))
        case 3:
            drawSymbol(in: CGRect(origin: CGPoint(x: symbolRect.origin.x, y: symbolRect.origin.y - symbolHeight - Coefficient.ident), size: symbolRect.size))
            drawSymbol(in: symbolRect)
            drawSymbol(in: CGRect(origin: CGPoint(x: symbolRect.origin.x, y: symbolRect.origin.y + symbolHeight + Coefficient.ident), size: symbolRect.size))
        default:
            break
        }
    }

}

extension SetCardView {
    struct Coefficient {
        static let ident: CGFloat = 2.0
        static let widthParameter: CGFloat = 0.6
        static let heightParameter: CGFloat = 0.25
        static let widthDeviation: CGFloat = 0.1
        static let heightDeviation: CGFloat = 0.2
    }
}
