//
//  TooltipBackgroundLayer.swift
//  housetainer-ios
//
//  Created by 김수아 on 1/3/24.
//

import Foundation
import UIKit

final class TooltipBackgroundLayer: CALayer{
    enum Radius{
        static let half: CGFloat = -1
        static let quad: CGFloat = -2
    }
    
    var topLeftRadius: CGFloat = Radius.quad{
        didSet{
            setNeedsDisplay()
        }
    }
  
    var topRightRadius: CGFloat = Radius.half{
        didSet{
            setNeedsDisplay()
        }
    }
    
    var bottomLeftRadius: CGFloat = Radius.half{
        didSet{
            setNeedsDisplay()
        }
    }
    
    var bottomRightRadius: CGFloat = Radius.half{
        didSet{
            setNeedsDisplay()
        }
    }
    
    var fillColor: UIColor = Color.gray600{
        didSet{
            setNeedsDisplay()
        }
    }
    
    override init() {
        super.init()
        setNeedsDisplay()
    }
    
    override init(layer: Any) {
        super.init(layer: layer)
        setNeedsDisplay()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(in ctx: CGContext) {
        super.draw(in: ctx)
        let size = CGSize(width: self.frame.width, height: self.frame.height)
        let topLeftRadius = radius(topLeftRadius, for: size.height)
        let topRightRadius = radius(topRightRadius, for: size.height)
        let bottomRightRadius = radius(bottomRightRadius, for: size.height)
        let bottomLeftRadius = radius(bottomLeftRadius, for: size.height)
        
        UIGraphicsPushContext(ctx)
        fillColor.setFill()
        let path = UIBezierPath()
        path.move(to: CGPoint(x: radius(topLeftRadius, for: size.height), y: 0))
        path.addLine(to: CGPoint(x: size.width - radius(topRightRadius, for: size.height), y: 0))
        path.addQuadCurve(to: CGPoint(x: size.width, y: topRightRadius), controlPoint: CGPoint(x: size.width, y: 0))
        path.addQuadCurve(to: CGPoint(x: size.width - bottomRightRadius, y: size.height), controlPoint: CGPoint(x: size.width, y: size.height))
        path.addLine(to: CGPoint(x: bottomLeftRadius, y: size.height))
        path.addQuadCurve(to: CGPoint(x: 0, y: bottomLeftRadius), controlPoint: CGPoint(x: 0, y: size.height))
        path.addLine(to: CGPoint(x: 0, y: topLeftRadius))
        path.addQuadCurve(to: CGPoint(x: topLeftRadius, y: 0), controlPoint: CGPoint(x: 0, y: 0))
        path.close()
        path.fill()
        UIGraphicsPopContext()
    }
    
    private func radius(_ radius: CGFloat, for height: CGFloat) -> CGFloat{
        if radius == Radius.half{
            return height / 2
        }
        
        if radius == Radius.quad{
            return height * 4 / 13
        }
        
        return radius
    }
}
