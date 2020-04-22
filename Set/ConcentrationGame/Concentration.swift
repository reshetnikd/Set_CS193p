//
//  Concentration.swift
//  Concentration
//
//  Created by Dmitry Reshetnik on 13.01.2020.
//  Copyright © 2020 Dmitry Reshetnik. All rights reserved.
//

import Foundation

struct Concentration {
    
    private(set) var startTime: Date = Date()
    private(set) var flips: Int = 0
    private(set) var score: Int = 0
    private var indexOfOneAndOnlyFaceUpCard: Int? {
        get {
            return cards.indices.filter { (index) -> Bool in
                cards[index].isFaceUp
            }.oneAndOnly
        }
        set {
            for index in cards.indices {
                cards[index].isFaceUp = (index == newValue)
            }
        }
    }
    
    var cards: [Card] = []
    
    mutating func chooseCard(at index: Int) {
        assert(cards.indices.contains(index), "Concentration.chooseCard(at: \(index)): chosen index not in the cards")
        if !cards[index].isMatched {
            if let matchIndex = indexOfOneAndOnlyFaceUpCard, matchIndex != index {
                // check if cards match, giving 2 points for every match and penalizing 1 point for every previously seen card that is involved in a mismatch in addition time-based
                if cards[matchIndex] == cards[index] {
                    cards[matchIndex].isMatched = true
                    cards[index].isMatched = true
                    score += 2 * ((60 / -Int(startTime.timeIntervalSinceNow)) > 0 ? (60 / -Int(startTime.timeIntervalSinceNow)) : 1)
                } else {
                    if cards[matchIndex].isInvolvedInMismatch && cards[index].isInvolvedInMismatch {
                        score -= 2 * ((-Int(startTime.timeIntervalSinceNow)) < 60 ? (-Int(startTime.timeIntervalSinceNow)) : 1)
                    } else if cards[matchIndex].isInvolvedInMismatch || cards[index].isInvolvedInMismatch {
                        score -= 1 * ((-Int(startTime.timeIntervalSinceNow)) < 60 ? (-Int(startTime.timeIntervalSinceNow)) : 1)
                    }
                    cards[matchIndex].isInvolvedInMismatch = true
                    cards[index].isInvolvedInMismatch = true
                }
                cards[index].isFaceUp = true
            } else {
                // either no cards or two cards are face up
                indexOfOneAndOnlyFaceUpCard = index
            }
        }
        flips += 1
    }
    
    init(numberOfPairsOfCards: Int) {
        assert(numberOfPairsOfCards > 0, "Concentration.init(\(numberOfPairsOfCards)): you must have at least one pair of cards")
        for _ in 1...numberOfPairsOfCards {
            let card = Card()
            cards += [card, card]
        }
        cards.shuffle()
    }
    
}

extension Collection {
    var oneAndOnly: Element? {
        return count == 1 ? first : nil
    }
}
