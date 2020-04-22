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
        chooseTheme(from: themes)
    }
    
    private lazy var game: Concentration = Concentration(numberOfPairsOfCards: numberOfPairsOfCards)
    private var emojiChoices: [String] = []
    private var emoji: [Card:String] = [:]
    private var buttonColor: UIColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)
    private var themes: [Theme] = [Theme(name: "helloween", emoji: ["👻","🎃","😈","💀","🧛🏻‍♂️","🦇","🧛🏻‍♂️","🕸","🕷"], color: #colorLiteral(red: 0.9952403903, green: 0.7589642406, blue: 0.1794864237, alpha: 1), backgroundColor: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)),
    Theme(name: "animals", emoji: ["🐶","🐱","🐭","🐹","🐰","🦊","🐻","🐼","🐵"], color: #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1), backgroundColor: #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1)),
    Theme(name: "sports", emoji: ["⚽️","🏀","🏈","⚾️","🥎","🎾","🏐","🏉","🎱"], color: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), backgroundColor: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)),
    Theme(name: "faces", emoji: ["😁","😊","😅","😆","😂","😎","🤪","🤓","🥳"], color: #colorLiteral(red: 0.9994240403, green: 0.9855536819, blue: 0, alpha: 1), backgroundColor: #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)),
    Theme(name: "fruits", emoji: ["🍏","🍐","🍊","🍋","🍌","🍉","🍓","🍑","🥭"], color: #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1), backgroundColor: #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1)),
    Theme(name: "flowers", emoji: ["💐","🌷","🌹","🥀","🌺","🌸","🌼","🌻","🍀"], color: #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1), backgroundColor: #colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1))]
    var numberOfPairsOfCards: Int {
        get {
            return (cardButtons.count + 1) / 2
        }
    }
    
    @IBOutlet private weak var scoreLabel: UILabel!
    @IBOutlet private weak var flipCountLabel: UILabel!
    @IBOutlet private weak var newGameButton: UIButton!
    @IBOutlet private var cardButtons: [UIButton]!
    
    @IBAction func newGame(_ sender: UIButton) {
        game = Concentration(numberOfPairsOfCards: numberOfPairsOfCards)
        chooseTheme(from: themes)
    }
    
    @IBAction private func touchCard(_ sender: UIButton) {
        if let cardNumber = cardButtons.firstIndex(of: sender) {
            game.chooseCard(at: cardNumber)
            updateViewFromModel()
        } else {
            print("chosen card was not in cardButtons")
        }
    }
    
    private func updateViewFromModel() {
        for index in cardButtons.indices {
            let button = cardButtons[index]
            let card = game.cards[index]
            if card.isFaceUp {
                button.setTitle(emoji(for: card), for: UIControl.State.normal)
                button.backgroundColor = #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 1)
            } else {
                button.setTitle("", for: UIControl.State.normal)
                button.backgroundColor = card.isMatched ? #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0) : buttonColor
            }
        }
        flipCountLabel.text = "Flips: \(game.flips)"
        scoreLabel.text = "Score: \(game.score)"
    }
    
    private func emoji(for card: Card) -> String {
        if emoji[card] == nil, emojiChoices.count > 0 {
            emoji[card] = emojiChoices.remove(at: emojiChoices.count.random)
        }
        return emoji[card] ?? "?"
    }
    
    private func chooseTheme(from themes: [Theme]) {
        let randomIndex = themes.count.random
        buttonColor = themes[randomIndex].color
        emojiChoices = themes[randomIndex].emoji
        scoreLabel.textColor = themes[randomIndex].color
        flipCountLabel.textColor = themes[randomIndex].color
        self.view.backgroundColor = themes[randomIndex].backgroundColor
        newGameButton.setTitleColor(themes[randomIndex].color, for: .normal)
        updateViewFromModel()
    }
    
}
