//
//  GridView.swift
//  Set
//
//  Created by Dmitry Reshetnik on 16.04.2020.
//  Copyright © 2020 Dmitry Reshetnik. All rights reserved.
//

import UIKit

@IBDesignable
class GridView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    var cardViews: [SetCardView] = [] {
        willSet {
            removeSubviews()
        }
        didSet {
            addSubviews()
            setNeedsLayout()
        }
    }
    
    private func removeSubviews() {
        for card in cardViews {
            card.removeFromSuperview()
        }
        layoutIfNeeded()
    }
    
    private func addSubviews() {
        for card in cardViews {
            addSubview(card)
        }
        layoutIfNeeded()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        var grid: Grid = Grid(layout: Grid.Layout.aspectRatio(Coefficient.cardAspectRatio), frame: bounds)
        grid.cellCount = cardViews.count
        
        for row in 0..<grid.dimensions.rowCount {
            for column in 0..<grid.dimensions.columnCount {
                if cardViews.count > (row * grid.dimensions.columnCount + column) {
                    UIViewPropertyAnimator.runningPropertyAnimator(
                        withDuration: 0.2,
                        delay: 0.2,
                        options: UIView.AnimationOptions.curveEaseInOut,
                        animations: {
                            self.cardViews[row * grid.dimensions.columnCount + column].frame = grid[row, column]!.insetBy(dx: Coefficient.offsetX, dy: Coefficient.offsetY)
                        },
                        completion: nil
                    )
                }
            }
        }
    }

}

extension GridView {
    struct Coefficient {
        static let cardAspectRatio: CGFloat = 0.625
        static let offsetX: CGFloat = 2.0
        static let offsetY: CGFloat = 2.0
    }
}
