//
//  SetGame.swift
//  Set
//
//  Created by Dmitry Reshetnik on 12.04.2020.
//  Copyright © 2020 Dmitry Reshetnik. All rights reserved.
//
//  A set consists of three cards satisfying all of these conditions:
//  - They all have the same number or have three different numbers.
//  - They all have the same shape or have three different shapes.
//  - They all have the same shading or have three different shadings.
//  - They all have the same color or have three different colors.

import Foundation

struct SetGame {
    var playingSetCardDeck: [SetCard] = []
    var selectedCards: [SetCard] = []
    var matchedCards: [SetCard] = []
    
    /// Checking if selected cards are match according to game of Set rules.
    mutating func checkSetCards(from selected: [SetCard]) {
        if selected.count == 3 {
            if (((selected[0].number == selected[1].number) && (selected[1].number == selected[2].number)) || ((selected[0].number != selected[1].number) && (selected[0].number != selected[2].number) && (selected[1].number != selected[2].number))) && (((selected[0].shading == selected[1].shading) && (selected[1].shading == selected[2].shading)) || ((selected[0].shading != selected[1].shading) && (selected[0].shading != selected[2].shading) && (selected[1].shading != selected[2].shading))) && (((selected[0].color == selected[1].color) && (selected[1].color == selected[2].color)) || ((selected[0].color != selected[1].color) && (selected[0].color != selected[2].color) && (selected[1].color != selected[2].color))) && (((selected[0].shape == selected[1].shape) && (selected[1].shape == selected[2].shape)) || ((selected[0].shape != selected[1].shape) && (selected[0].shape != selected[2].shape) && (selected[1].shape != selected[2].shape))) {
                for index in selected.indices {
                    matchedCards.append(selected[index])
                }
            }
        }
    }
    
    /// Replace the selected cards if they are match or add 3 cards to the game.
    mutating func dealSetCard() -> [SetCard] {
        var deal: [SetCard] = []
        
        if selectedCards.count == 3, !playingSetCardDeck.isEmpty {
            for index in selectedCards.indices {
                if matchedCards.contains(selectedCards[index]) {
                    selectedCards[index] = playingSetCardDeck.removeFirst()
                } else {
                    deal.append(playingSetCardDeck.removeFirst())
                }
            }
        } else if !playingSetCardDeck.isEmpty {
            for _ in 0...2 {
                deal.append(playingSetCardDeck.removeFirst())
            }
        }
        
        return deal
    }
    
    /// Search for cards on screen, of which the Set is consist.
    mutating func searchForSet(on screen: [SetCard]) -> [Int: [SetCard]] {
        let previouslyMatched: [SetCard] = matchedCards
        var mark: Int = 0
        var counter: Int = matchedCards.count
        var found: [Int: [SetCard]] = [:]
        var temp: [SetCard] = []
        
        for index in screen.indices {
            temp.append(screen[index])
            for index in 1...(screen.count - 1) {
                if !temp.contains(screen[index]) {
                    temp.append(screen[index])
                    for index in 2...(screen.count - 1) {
                        if !temp.contains(screen[index]) {
                            temp.append(screen[index])
                            checkSetCards(from: temp)
                            if counter < matchedCards.count {
                                found[mark] = Array(matchedCards.dropFirst(counter))
                                counter = matchedCards.count
                                mark += 1
                            }
                            temp.removeLast()
                        }
                    }
                    temp.removeLast()
                }
            }
            temp.removeLast()
        }
        matchedCards = previouslyMatched
        return found
    }
    
    /// Create deck of 81 SetCard's.
    init() {
        for number in SetCard.Number.all {
            for shape in SetCard.Shape.all {
                for shade in SetCard.Shading.all {
                    for color in SetCard.Color.all {
                        playingSetCardDeck.append(SetCard(number: number.rawValue, shape: shape.rawValue, shading: shade.rawValue, color: color.rawValue))
                    }
                }
            }
        }
        playingSetCardDeck.shuffle()
    }
}
