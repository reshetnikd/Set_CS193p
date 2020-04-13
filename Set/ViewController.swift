//
//  ViewController.swift
//  Set
//
//  Created by Dmitry Reshetnik on 14.02.2020.
//  Copyright © 2020 Dmitry Reshetnik. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        for index in cardButtons.indices {
            applyAttributesTo(game.playingSetCardDeck[index])
            cardButtons[index].isEnabled = true
            cardButtons[index].layer.cornerRadius = 8.0
            cardButtons[index].layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)
            cardButtons[index].setAttributedTitle(NSAttributedString(string: game.playingSetCardDeck[index].shape, attributes: attributes), for: UIControl.State.normal)
            if index >= 12 {
                cardButtons[index].setAttributedTitle(nil, for: UIControl.State.normal)
                cardButtons[index].backgroundColor = #colorLiteral(red: 0.9952403903, green: 0.7589642406, blue: 0.1794864237, alpha: 0)
                cardButtons[index].isEnabled = false
            } else {
                cardsOnScreen.append(game.playingSetCardDeck.remove(at: index))
            }
        }
        dealButton.isEnabled = true
    }

    @IBOutlet weak var dealButton: UIButton!
    @IBOutlet weak var iPhoneLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet var cardButtons: [UIButton]!
    
    var game: SetGame = SetGame()
    var cardsOnScreen: [SetCard] = []
    var selectedIndices: [Int] = []
    var isMatchedAsSet: Bool = false
    
    var score: Int = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    var attributes: [NSAttributedString.Key : Any] = [
        .foregroundColor : UIColor.black.withAlphaComponent(1),
        .strokeColor : UIColor.black,
        .strokeWidth : -8.0 // negative number here would nean fill (positive means outline)
    ]
    
    @IBAction func startNewGame(_ sender: UIButton) {
        cardsOnScreen.removeAll()
        selectedIndices.removeAll()
        game = SetGame()
        score = 0
        self.viewDidLoad()
    }
    
    /// Allow to select cards to try to match as a Set, also support deselection.
    @IBAction func selectCard(_ sender: UIButton) {
        if let cardIndex = cardButtons.firstIndex(of: sender) {
            let card: SetCard = cardsOnScreen[cardIndex]
            
            if game.selectedCards.count == 3 {
                if isMatchedAsSet && game.selectedCards.contains(card) {
                    // No card should be selected.
                    return
                } else {
                    if isMatchedAsSet {
                        dealMoreCards(sender)
                    } else {
                        // Deselect 3 non-matching cards.
                        for index in selectedIndices {
                            cardButtons[index].layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)
                        }
                    }
                    // Select chosen card.
                    game.selectedCards.removeAll()
                    selectedIndices.removeAll()
                    game.selectedCards.append(card)
                    selectedIndices.append(cardIndex)
                    cardButtons[cardIndex].layer.borderWidth = 2.0
                    cardButtons[cardIndex].layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
                }
            } else {
                // Deselect currently selected card either select new one.
                if game.selectedCards.contains(card) {
                    cardButtons[cardIndex].layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)
                    game.selectedCards.removeAll { (selectedCard: SetCard) -> Bool in
                        return selectedCard == card
                    }
                    selectedIndices.removeAll { (selectedIndex: Int) -> Bool in
                        return selectedIndex == cardIndex
                    }
                    score -= 1
                } else {
                    game.selectedCards.append(card)
                    selectedIndices.append(cardIndex)
                    if selectedIndices.count == 3 {
                        checkAndIndicateCards()
                    } else {
                        cardButtons[cardIndex].layer.borderWidth = 2.0
                        cardButtons[cardIndex].layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
                    }
                }
            }
        }
    }
    
    /// Replace the selected cards if they are match or add 3 cards to the game.
    @IBAction func dealMoreCards(_ sender: UIButton) {
        var cards: [SetCard] = game.dealSetCard()
        
        if !game.playingSetCardDeck.isEmpty {
            if cards.isEmpty {
                // Replace selected cards if they matched with new ones from the Playing Deck.
                for index in game.selectedCards.indices {
                    applyAttributesTo(game.selectedCards[index])
                    cardButtons[selectedIndices[index]].setAttributedTitle(NSAttributedString(string: game.selectedCards[index].shape, attributes: attributes), for: UIControl.State.normal)
                    cardButtons[selectedIndices[index]].layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)
                    cardsOnScreen[selectedIndices[index]] = game.selectedCards[index]
                }
                game.selectedCards.removeAll()
                selectedIndices.removeAll()
            } else {
                // Add 3 more cards to the UI.
                for index in cardButtons.indices {
                    if cardButtons[index].currentAttributedTitle == nil && !cards.isEmpty {
                        applyAttributesTo(cards.first!)
                        cardButtons[index].setAttributedTitle(NSAttributedString(string: cards.first!.shape, attributes: attributes), for: UIControl.State.normal)
                        cardButtons[index].layer.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
                        cardButtons[index].isEnabled = true
                        cardsOnScreen.append(cards.removeFirst())
                    }
                }
            }
            // Disable Deal Button if no more room on the UI.
            if cardsOnScreen.count == 24 {
                dealButton.isEnabled = false
            }
        }
    }
    
    /// Uses coloration to indicate whether cards are match or mismatch.
    func checkAndIndicateCards() {
        game.checkSetCards(from: game.selectedCards)
        
        for index in game.selectedCards.indices {
            if game.matchedCards.contains(game.selectedCards[index]) {
                cardButtons[selectedIndices[index]].layer.borderWidth = 3.0
                cardButtons[selectedIndices[index]].layer.borderColor = #colorLiteral(red: 0, green: 0.9768045545, blue: 0, alpha: 1)
                isMatchedAsSet = true
                
                if !game.playingSetCardDeck.isEmpty {
                    dealButton.isEnabled = true
                } else {
                    // Disable card button if no more cards in Playing Deck.
                    cardButtons[selectedIndices[index]].isEnabled = false
                }
                
                score += 3
            } else {
                cardButtons[selectedIndices[index]].layer.borderWidth = 3.0
                cardButtons[selectedIndices[index]].layer.borderColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
                isMatchedAsSet = false
                
                score -= 5
            }
        }
    }
    
    /// Apply attributes to given card.
    func applyAttributesTo(_ card: SetCard) {
        // Color.
        switch card.color {
        case .green:
            attributes[.strokeColor] = UIColor.green
        case .purple:
            attributes[.strokeColor] = UIColor.purple
        case .red:
            attributes[.strokeColor] = UIColor.red
        }
        
        // Shading style.
        switch card.shading {
        case .open:
            attributes[.foregroundColor] = (attributes[.strokeColor] as! UIColor).withAlphaComponent(0.4)
            attributes[.strokeWidth] = 8.0
        case .striped:
            attributes[.foregroundColor] = (attributes[.strokeColor] as! UIColor).withAlphaComponent(0.15)
            attributes[.strokeWidth] = -8.0
        case .solid:
            attributes[.foregroundColor] = (attributes[.strokeColor] as! UIColor).withAlphaComponent(1)
            attributes[.strokeWidth] = -8.0
        }
        
    }
}

