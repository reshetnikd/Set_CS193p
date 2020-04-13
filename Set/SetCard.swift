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
    let shading: Shading
    let color: Color
    
    enum Number: Int {
        case one = 1
        case two = 2
        case three = 3
        
        static var all: [Number] = [Number.one, Number.two, Number.three]
    }
    
    enum Shape: String {
        case triangle = "▲"
        case square = "■"
        case circle = "●"
        
        static var all: [Shape] = [Shape.triangle, Shape.square, Shape.circle]
    }
    
    enum Shading: Equatable {
        case striped
        case solid
        case open
        
        static var all: [Shading] = [Shading.striped, Shading.solid, Shading.open]
    }
    
    enum Color: Equatable {
        case red
        case green
        case purple
        
        static var all: [Color] = [Color.red, Color.green, Color.purple]
    }
    
}
