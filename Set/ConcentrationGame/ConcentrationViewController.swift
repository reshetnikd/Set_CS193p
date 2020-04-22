//
//  ViewController.swift
//  Concentration
//
//  Created by Dmitry Reshetnik on 12.01.2020.
//  Copyright © 2020 Dmitry Reshetnik. All rights reserved.
//

import UIKit

class ConcentrationViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
//        chooseTheme(from: themes)
        // Remove UITabBar top border line in iPadOS 13.
        tabBarController?.tabBar.layer.borderWidth = 0
        tabBarController?.tabBar.clipsToBounds = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateViewFromModel()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateViewFromModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        newGameButton.setTitleColor(cardsColor, for: UIControl.State.normal)
        flipCountLabel.textColor = cardsColor
        scoreLabel.textColor = cardsColor
    }
    
    private lazy var game: Concentration = Concentration(numberOfPairsOfCards: numberOfPairsOfCards)
    
    private var emojiChoices: String = "👻🎃😈💀🧛🏻‍♂️🦇🕸🕷🧟‍♂️🧙🏻🧞👹"
    private var emoji: [Card:String] = [:]
    private var cardsColor: UIColor = #colorLiteral(red: 0.9952403903, green: 0.7589642406, blue: 0.1794864237, alpha: 1)
    
    private var faceUpCards: [UIButton] {
        return visibleCardButtons.filter { (cardButton) -> Bool in
            return game.cards[visibleCardButtons.firstIndex(of: cardButton)!].isFaceUp
        }
    }
    
    private var visibleCardButtons: [UIButton]! {
        return cardButtons?.filter { (cardButton) -> Bool in
            !cardButton.superview!.isHidden
        }
    }
    
    var numberOfPairsOfCards: Int {
        return (visibleCardButtons.count + 1) / 2
    }
    
    var theme: String? {
        didSet {
            emojiChoices = theme ?? ""
            emoji = [:]
            updateViewFromModel()
        }
    }
    
    var themeColor: UIColor? {
        didSet {
            cardsColor = themeColor ?? #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
            if newGameButton != nil, flipCountLabel != nil, scoreLabel != nil {
                newGameButton.setTitleColor(themeColor, for: .normal)
                flipCountLabel.textColor = themeColor
                scoreLabel.textColor = themeColor
            }
            updateViewFromModel()
        }
    }
    
    var backgroundThemeColor: UIColor? {
        didSet {
            self.view.backgroundColor = backgroundThemeColor
            updateViewFromModel()
        }
    }
    
    @IBOutlet private weak var scoreLabel: UILabel!
    @IBOutlet private weak var flipCountLabel: UILabel!
    @IBOutlet private weak var newGameButton: UIButton!
    @IBOutlet private var cardButtons: [UIButton]!
    
    @IBAction func newGame(_ sender: UIButton) {
        emoji.removeAll()
        game = Concentration(numberOfPairsOfCards: numberOfPairsOfCards)
        emojiChoices = theme ?? self.emojiChoices
        cardsColor = themeColor ?? self.cardsColor
        updateViewFromModel()
    }
    
    @IBAction private func touchCard(_ sender: UIButton) {
        if let cardNumber = visibleCardButtons.firstIndex(of: sender) {
            UIView.transition(
                with: sender,
                duration: 0.5,
                options: .transitionFlipFromLeft,
                animations: {
                    self.game.chooseCard(at: cardNumber)
                    self.updateViewFromModel()
                },
                completion: { (_) in
                    if self.faceUpCards.count == 2 {
                        self.faceUpCards.forEach({ (cardButton) in
                            UIView.transition(
                                with: cardButton,
                                duration: 0.5,
                                options: .transitionFlipFromLeft,
                                animations: {
                                    self.updateViewFromModel()
                                },
                                completion: nil
                            )
                        })
                    }
                }
            )
        } else {
            print("chosen card was not in cardButtons")
        }
    }
    
    private func updateViewFromModel() {
        guard visibleCardButtons != nil else {
            return
        }
        
        for index in visibleCardButtons.indices {
            let button: UIButton = visibleCardButtons[index]
            let card: Card = game.cards[index]
            if card.isFaceUp {
                button.setTitle(emoji(for: card), for: .normal)
                button.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            } else {
                button.setTitle("", for: .normal)
                button.backgroundColor = card.isMatched ? #colorLiteral(red: 0.9952403903, green: 0.7589642406, blue: 0.1794864237, alpha: 0) : cardsColor
            }
        }
        
        scoreLabel.text = traitCollection.verticalSizeClass == UIUserInterfaceSizeClass.compact ? "Score\n\(game.score)" : "Score: \(game.score)"
        flipCountLabel.text = traitCollection.verticalSizeClass == UIUserInterfaceSizeClass.compact ? "Flips\n\(game.flips)" : "Flips: \(game.flips)"
        newGameButton.titleLabel?.numberOfLines = 0
        newGameButton.titleLabel?.textAlignment = NSTextAlignment.center
        newGameButton.setTitle(traitCollection.verticalSizeClass == UIUserInterfaceSizeClass.compact ? "New\nGame" : "New Game", for: UIControl.State.normal)
    }
    
    private func emoji(for card: Card) -> String {
        if emoji[card] == nil, emojiChoices.count > 0 {
            let stringIndex = emojiChoices.index(emojiChoices.startIndex, offsetBy: Int.random(in: 0..<emojiChoices.count))
            emoji[card] = String(emojiChoices.remove(at: stringIndex))
        }
        return emoji[card] ?? "?"
    }
    
}
