//
//  CardBehavior.swift
//  Set
//
//  Created by Dmitry Reshetnik on 20.04.2020.
//  Copyright © 2020 Dmitry Reshetnik. All rights reserved.
//

import UIKit

class CardBehavior: UIDynamicBehavior {
    
    lazy var collisionBehavior: UICollisionBehavior = {
        let behavior: UICollisionBehavior = UICollisionBehavior()
        behavior.translatesReferenceBoundsIntoBoundary = true
        return behavior
    }()
    
    lazy var itemBehavior: UIDynamicItemBehavior = {
        let behavior: UIDynamicItemBehavior = UIDynamicItemBehavior()
        behavior.allowsRotation = true
        behavior.elasticity = 0.8
        behavior.resistance = 0.2
        return behavior
    }()
    
    var spotToSnap: CGPoint = CGPoint()
    
    private func push(_ item: UIDynamicItem) {
        let push: UIPushBehavior = UIPushBehavior(items: [item], mode: UIPushBehavior.Mode.instantaneous)
        push.angle = CGFloat.pi * 3 / 4 - (CGFloat.pi * 2).random
        push.magnitude = CGFloat(10.0) + CGFloat(2.0).random
        push.action = { [unowned push, weak self] in
            self?.removeChildBehavior(push)
        }
        addChildBehavior(push)
    }
    
    private func snap(_ item: UIDynamicItem) {
        let snap: UISnapBehavior = UISnapBehavior(item: item, snapTo: spotToSnap)
        snap.damping = 0.2
        addChildBehavior(snap)
    }
    
    func addItem(_ item: UIDynamicItem) {
        collisionBehavior.addItem(item)
        itemBehavior.addItem(item)
        push(item)
        
        Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { (_) in
            self.collisionBehavior.removeItem(item)
            self.snap(item)
        }
    }
    
    func removeItem(_ item: UIDynamicItem) {
        collisionBehavior.removeItem(item)
        itemBehavior.removeItem(item)
    }
    
    override init() {
        super.init()
        addChildBehavior(collisionBehavior)
        addChildBehavior(itemBehavior)
    }
    
    convenience init(in animator: UIDynamicAnimator) {
        self.init()
        animator.addBehavior(self)
    }

}

extension CGFloat {
    /// Return random CGFloat value in given range.
    var random: CGFloat {
        return self * (CGFloat(UInt32.random(in: .min ... .max)) / CGFloat(UInt32.max))
    }
}
