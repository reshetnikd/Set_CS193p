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
            cardButtons[index].layer.cornerRadius = 8.0
            cardButtons[index].layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)
            cardButtons[index].setTitle(game.playingSetCardDeck[index].shape, for: UIControl.State.normal)
            if index >= 12 {
                cardButtons[index].setTitle("", for: UIControl.State.normal)
                cardButtons[index].backgroundColor = #colorLiteral(red: 0.9952403903, green: 0.7589642406, blue: 0.1794864237, alpha: 0)
                cardButtons[index].isEnabled = false
            } else {
                cardsOnScreen.append(game.playingSetCardDeck.remove(at: index))
            }
        }
    }

    @IBOutlet weak var iPhoneLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet var cardButtons: [UIButton]!
    
    var game: SetGame = SetGame()
    var cardsOnScreen: [SetCard] = []
    var selectedIndices: [Int] = []
    var isMatched: Bool = false
    
    @IBAction func startNewGame(_ sender: UIButton) {
        cardsOnScreen.removeAll()
        selectedIndices.removeAll()
        game = SetGame()
        self.viewDidLoad()
    }
    
    /// Allow to select cards to try to match as a Set, also support deselection.
    @IBAction func selectCard(_ sender: UIButton) {
        if let cardIndex = cardButtons.firstIndex(of: sender) {
            let card: SetCard = cardsOnScreen[cardIndex]
            
            if game.selectedCards.count == 3 {
                if isMatched {
                    dealMoreCards(sender)
                } else {
                    for index in selectedIndices {
                        cardButtons[index].layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)
                    }
                }
                game.selectedCards.removeAll()
                selectedIndices.removeAll()
                game.selectedCards.append(card)
                selectedIndices.append(cardIndex)
                cardButtons[cardIndex].layer.borderWidth = 2.0
                cardButtons[cardIndex].layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            } else {
                if game.selectedCards.contains(card) {
                    cardButtons[cardIndex].layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)
                    game.selectedCards.removeAll { (selectedCard: SetCard) -> Bool in
                        return selectedCard == card
                    }
                    selectedIndices.removeAll { (selectedIndex: Int) -> Bool in
                        return selectedIndex == cardIndex
                    }
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
        
        if cards.isEmpty {
            for index in game.selectedCards.indices {
                cardButtons[selectedIndices[index]].setTitle(game.selectedCards[index].shape, for: UIControl.State.normal)
                cardButtons[selectedIndices[index]].layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)
            }
            game.selectedCards.removeAll()
            selectedIndices.removeAll()
        }
        
        for index in cardButtons.indices {
            if cardButtons[index].currentTitle == "" && !cards.isEmpty {
                cardButtons[index].setTitle(cards.first!.shape, for: UIControl.State.normal)
                cardButtons[index].layer.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
                cardButtons[index].isEnabled = true
                cardsOnScreen.append(cards.removeFirst())
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
                isMatched = true
            } else {
                cardButtons[selectedIndices[index]].layer.borderWidth = 3.0
                cardButtons[selectedIndices[index]].layer.borderColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
                isMatched = false
            }
        }
    }
}

