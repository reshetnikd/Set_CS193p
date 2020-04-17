//
//  SetCard.swift
//  Set
//
//  Created by Dmitry Reshetnik on 7/1/19.
//  Copyright © 2019 Dmitry Reshetnik. All rights reserved.
//

import Foundation

struct SetCard: Equatable {
    let number: Int
    let shape: String
    let shading: String
    let color: String
    
    enum Number: Int {
        case one = 1
        case two = 2
        case three = 3
        
        static var all: [Number] = [Number.one, Number.two, Number.three]
    }
    
    enum Shape: String {
        case diamond
        case squiggle
        case oval
        
        static var all: [Shape] = [Shape.diamond, Shape.squiggle, Shape.oval]
    }
    
    enum Shading: String {
        case striped
        case solid
        case outlined
        
        static var all: [Shading] = [Shading.striped, Shading.solid, Shading.outlined]
    }
    
    enum Color: String {
        case red
        case green
        case purple
        
        static var all: [Color] = [Color.red, Color.green, Color.purple]
    }
    
}
