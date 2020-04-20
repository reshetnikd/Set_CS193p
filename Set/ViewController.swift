//
//  ViewController.swift
//  Set
//
//  Created by Dmitry Reshetnik on 14.02.2020.
//  Copyright © 2020 Dmitry Reshetnik. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIDynamicAnimatorDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        for index in 0...11 {
            cardsOnScreen.append(game.playingSetCardDeck.remove(at: index))
            let card: SetCard = cardsOnScreen[index]
            let cardView: SetCardView = SetCardView()
            // Add gesture recognizer to card.
            let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectCard(_:)))
            cardView.addGestureRecognizer(tap)
            cardView.isUserInteractionEnabled = true
            // Correspondence between view and model.
            cardView.number = card.number
            cardView.shape = card.shape
            cardView.shading = card.shading
            cardView.color = card.color
            board.cardViews.append(cardView)
            board.cardViews[index].draw(board.bounds) // Need to call draw method to trim black corners.
            // Animation block.
            dealAnimation(card: cardView, delayTime: Double(index + 1))
        }
        dealButton.isEnabled = true
        hintButton.isEnabled = true
        availableSetOnScreen = game.searchForSet(on: cardsOnScreen)
        // A swipe down gesture deal more cards.
        let swipe: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(dealMoreCards))
        swipe.direction = UISwipeGestureRecognizer.Direction.down
        view.addGestureRecognizer(swipe)
        // A rotation gesture cause all of cards to reshuffle.
        let rotate: UIRotationGestureRecognizer = UIRotationGestureRecognizer(target: self, action: #selector(reshuffle(sender:)))
        view.addGestureRecognizer(rotate)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        cardBehavior.spotToSnap = view.convert(scoreLabel.center, to: board)
    }

    @IBOutlet weak var hintButton: UIButton!
    @IBOutlet weak var dealButton: UIButton!
    @IBOutlet weak var playerButton: UIButton!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var board: GridView!
    
    var game: SetGame = SetGame()
    var cardsOnScreen: [SetCard] = []
    var selectedIndices: [Int] = []
    var isMatchedAsSet: Bool = false
    var timeOfPlay: Date = Date()
    var availableSetOnScreen: [Int: [SetCard]] = [:]
    var currentPlayerId: Int = 0
    var tempCards: [SetCardView] = []
    
    var playerOne: Player = Player(id: 0, score: 0) {
        didSet {
            scoreLabel.text = "Score: \(playerOne.score)/\(playerTwo.score)"
        }
    }
    
    var playerTwo: Player = Player(id: 1, score: 0) {
        didSet {
            scoreLabel.text = "Score: \(playerOne.score)/\(playerTwo.score)"
        }
    }
    
    // UIDynamicAnimator properties.
    private lazy var animator: UIDynamicAnimator = {
        let animator: UIDynamicAnimator = UIDynamicAnimator(referenceView: board)
        animator.delegate = self
        return animator
    }()
    
    private lazy var cardBehavior: CardBehavior = CardBehavior(in: animator)
    
    /// Allow to select cards to try to match as a Set, also support deselection.
    @objc func selectCard(_ sender: UITapGestureRecognizer) {
        if let cardIndex = board.cardViews.firstIndex(of: sender.view as! SetCardView) {
            let card: SetCard = cardsOnScreen[cardIndex]
            
            if game.selectedCards.count == 3 {
                if isMatchedAsSet && game.selectedCards.contains(card) {
                    // No card should be selected.
                    return
                } else {
                    if isMatchedAsSet {
                        dealMoreCards()
                    } else {
                        // Deselect 3 non-matching cards.
                        for index in selectedIndices {
                            board.cardViews[index].layer.cornerRadius = 8.0
                            board.cardViews[index].layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)
                        }
                    }
                    // Select chosen card.
                    game.selectedCards.removeAll()
                    selectedIndices.removeAll()
                    game.selectedCards.append(card)
                    selectedIndices.append(cardIndex)
                    // Visually indicate selected card.
                    board.cardViews[cardIndex].layer.cornerRadius = 8.0
                    board.cardViews[cardIndex].layer.borderWidth = 2.0
                    board.cardViews[cardIndex].layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
                }
            } else {
                // Deselect currently selected card either select new one.
                if game.selectedCards.contains(card) {
                    board.cardViews[cardIndex].layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)
                    game.selectedCards.removeAll { (selectedCard: SetCard) -> Bool in
                        return selectedCard == card
                    }
                    selectedIndices.removeAll { (selectedIndex: Int) -> Bool in
                        return selectedIndex == cardIndex
                    }
                    // Scoring the current player who made the move.
                    if currentPlayerId == 0 {
                        playerOne.score -= 2
                    } else if currentPlayerId == 1 {
                        playerTwo.score -= 2
                    }
                } else {
                    game.selectedCards.append(card)
                    selectedIndices.append(cardIndex)
                    
                    if selectedIndices.count == 3 {
                        checkAndIndicateCards()
                    } else {
                        // Visually indicate selected card.
                        board.cardViews[cardIndex].layer.cornerRadius = 8.0
                        board.cardViews[cardIndex].layer.borderWidth = 2.0
                        board.cardViews[cardIndex].layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
                    }
                }
            }
        }
    }
    
    /// Replace the selected cards if they are match or add 3 cards to the game.
    @objc func dealMoreCards() {
        if !game.playingSetCardDeck.isEmpty {
            var cards: [SetCard] = game.dealSetCard()
            
            if cards.isEmpty {
                // Replace selected cards if they matched with new ones from the Playing Deck.
                for index in game.selectedCards.indices {
                    // Copy cardView for dynamic animator.
                    let tempCard: SetCardView = duplicateCard(board.cardViews[selectedIndices[index]])
                    tempCard.draw(board.bounds)
                    tempCards.append(tempCard)
                    board.addSubview(tempCard)
                    // Perform "flyaway" and snapping to the "discard pile" animation.
                    cardBehavior.addItem(tempCard)
                    // Cards replacement.
                    board.cardViews[selectedIndices[index]].number = game.selectedCards[index].number
                    board.cardViews[selectedIndices[index]].shape = game.selectedCards[index].shape
                    board.cardViews[selectedIndices[index]].shading = game.selectedCards[index].shading
                    board.cardViews[selectedIndices[index]].color = game.selectedCards[index].color
                    board.cardViews[selectedIndices[index]].layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)
                    board.cardViews[selectedIndices[index]].alpha = 1.0
                    board.cardViews[selectedIndices[index]].draw(board.bounds) // Need to call draw method to trim black corners.
                    // Animation block.
                    let animatedCardIndex: Int = selectedIndices[index]
                    board.cardViews[animatedCardIndex].alpha = 0
                    board.cardViews[animatedCardIndex].isFaceUp = false
                    dealAnimation(card: board.cardViews[animatedCardIndex], delayTime: Double(index + 1)) {
                        self.board.cardViews.forEach { (cardView) in
                            cardView.isUserInteractionEnabled = false
                        }
                    }
                    cardsOnScreen[selectedIndices[index]] = game.selectedCards[index]
                }
                Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { (_) in
                    self.game.selectedCards.removeAll()
                    self.selectedIndices.removeAll()
                    self.board.cardViews.forEach { (cardView) in
                        cardView.isUserInteractionEnabled = true
                        if cardView.layer.borderWidth == 2.0 && cardView.layer.borderColor == #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1) {
                            let index = self.board.cardViews.firstIndex(of: cardView)
                            let card: SetCard = self.cardsOnScreen[index!]
                            self.game.selectedCards.append(card)
                            self.selectedIndices.append(index!)
                        }
                    }
                }
            } else {
                // Penalize if there is a Set available in the visible cards.
                if !game.searchForSet(on: cardsOnScreen).isEmpty {
                    if currentPlayerId == 0 {
                        playerOne.score -= 10
                    } else if currentPlayerId == 1 {
                        playerTwo.score -= 10
                    }
                }
                // Add 3 more cards to the UI.
                if !cards.isEmpty {
                    for card in cards {
                        cardsOnScreen.append(cards.removeFirst())
                        let cardView: SetCardView = SetCardView()
                        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectCard(_:)))
                        cardView.addGestureRecognizer(tap)
                        cardView.isUserInteractionEnabled = true
                        cardView.number = card.number
                        cardView.shape = card.shape
                        cardView.color = card.color
                        cardView.shading = card.shading
                        board.cardViews.append(cardView)
                        board.cardViews.last!.draw(board.bounds) // Need to call draw method to trim black corners.
                        // Animation block.
                        let divider: Double = cards.count > 0 ? Double(cards.count) : 0.4
                        dealAnimation(card: cardView, delayTime: Double(cards.count + 1) / divider)
                    }
                }
            }
            hintButton.isEnabled = true
            
            if game.playingSetCardDeck.isEmpty {
                dealButton.isEnabled = false
            }
        }
    }
    
    /// Rotation gesture action shuffles cards view representation according to each model component.
    @objc func reshuffle(sender: UIRotationGestureRecognizer) {
        switch sender.state {
        case UIGestureRecognizer.State.ended:
            var lastIndex: Int = cardsOnScreen.count - 1
            
            while lastIndex > 0 {
                let randomIndex: Int = lastIndex.random
                board.cardViews.swapAt(lastIndex, randomIndex)
                cardsOnScreen.swapAt(lastIndex, randomIndex)
                lastIndex -= 1
            }
            
            for index in selectedIndices.indices {
                if let selectedCard = cardsOnScreen.firstIndex(of: game.selectedCards[index]) {
                    selectedIndices[index] = selectedCard
                }
            }
        default:
            break
        }
    }
    
    /// Start new game.
    @IBAction func startNewGame(_ sender: UIButton) {
        cardsOnScreen.removeAll()
        selectedIndices.removeAll()
        board.cardViews.removeAll()
        game = SetGame()
        playerOne.score = 0
        playerTwo.score = 0
        self.viewDidLoad()
    }
    
    /// Deal 3 new cards to the board.
    @IBAction func dealCardsToBoard(_ sender: UIButton) {
        dealMoreCards()
    }
    
    /// Change current Player that makes move, previously selected Player automatically turns back after 15 seconds.
    @IBAction func changePlayer(_ sender: UIButton) {
        switch currentPlayerId {
        case 0:
            currentPlayerId = 1
            playerButton.setAttributedTitle(NSAttributedString(string: "Player Two", attributes: [NSAttributedString.Key.foregroundColor : UIColor.blue]), for: UIControl.State.normal)
            Timer.scheduledTimer(withTimeInterval: 15, repeats: false) {
                (_) in self.currentPlayerId = 0
                self.playerButton.setAttributedTitle(NSAttributedString(string: "Player One", attributes: [NSAttributedString.Key.foregroundColor : UIColor.red]), for: UIControl.State.normal)
            }
        case 1:
            currentPlayerId = 0
            playerButton.setAttributedTitle(NSAttributedString(string: "Player One", attributes: [NSAttributedString.Key.foregroundColor : UIColor.red]), for: UIControl.State.normal)
            Timer.scheduledTimer(withTimeInterval: 15, repeats: false) {
                (_) in self.currentPlayerId = 1
                self.playerButton.setAttributedTitle(NSAttributedString(string: "Player Two", attributes: [NSAttributedString.Key.foregroundColor : UIColor.blue]), for: UIControl.State.normal)
            }
        default:
            break
        }
    }
    
    /// "cheat" button that a struggling user could use to find a Set.
    @IBAction func hint(_ sender: UIButton) {
        for index in board.cardViews.indices {
            board.cardViews[index].alpha = 1.0
        }
        // Search for available Set on screen and indicate it if it does.
        availableSetOnScreen = game.searchForSet(on: cardsOnScreen)
        
        if !availableSetOnScreen.isEmpty {
            let indexOfSet: Int = (availableSetOnScreen.count - 1).random
            
            for card in availableSetOnScreen[indexOfSet]! {
                if game.matchedCards.contains(card) {
                    for index in board.cardViews.indices {
                        board.cardViews[index].alpha = 1.0
                    }
                    break
                } else {
                    // highlight for 1 second.
                    board.cardViews[cardsOnScreen.firstIndex(of: card)!].alpha = 0.5
                    Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { (_) in
                        self.board.cardViews[self.cardsOnScreen.firstIndex(of: card)!].alpha = 1.0
                    }
                }
            }
        } else {
            hintButton.isEnabled = false
        }
    }
    
    /// Animate "discard pile" vanishing.
    public func dynamicAnimatorDidPause(_ animator: UIDynamicAnimator) {
        tempCards.forEach { (tempCard) in
            UIView.transition(
                with: tempCard,
                duration: 0.2,
                options: UIView.AnimationOptions.transitionFlipFromRight,
                animations: {
                    tempCard.isFaceUp = false
                },
                completion: { (_) in
                    UIViewPropertyAnimator.runningPropertyAnimator(
                        withDuration: 0.2,
                        delay: 0.2,
                        options: UIView.AnimationOptions.curveEaseIn,
                        animations: {
                            tempCard.alpha = 0
                        },
                        completion: { (_) in
                            self.cardBehavior.removeItem(tempCard)
                            tempCard.removeFromSuperview()
                        }
                    )
                }
            )
        }
    }
    
    /// Animate deal card action.
    private func dealAnimation(card: SetCardView, delayTime: Double, optional: @escaping () -> Void = {}) {
        let cardCenter: CGPoint = card.center
        card.center = view.convert(dealButton.center, to: board)
        card.alpha = 0
        UIViewPropertyAnimator.runningPropertyAnimator(
            withDuration: 0.5,
            delay: 0.2 * delayTime,
            options: UIView.AnimationOptions.curveEaseInOut,
            animations: {
                optional()
                card.isUserInteractionEnabled = false
                card.center = cardCenter
                card.alpha = 1
            },
            completion: { (_) in
                UIView.transition(
                    with: card,
                    duration: 0.2,
                    options: UIView.AnimationOptions.transitionFlipFromLeft,
                    animations: {
                        card.isFaceUp = true
                    },
                    completion: { (_) in
                        card.isUserInteractionEnabled = true
                    }
                )
            }
        )
    }
    
    /// Return copy of given SetCardView.
    private func duplicateCard(_ card: SetCardView) -> SetCardView {
        let duplicate: SetCardView = SetCardView()
        duplicate.bounds = card.bounds
        duplicate.frame = card.frame
        duplicate.alpha = 1
        duplicate.number = card.number
        duplicate.shape = card.shape
        duplicate.shading = card.shading
        duplicate.color = card.color
        duplicate.isFaceUp = true
        return duplicate
    }
    
    /// Uses coloration to indicate whether cards are match or mismatch.
    private func checkAndIndicateCards() {
        game.checkSetCards(from: game.selectedCards)
        
        for index in game.selectedCards.indices {
            if game.matchedCards.contains(game.selectedCards[index]) {
                board.cardViews[selectedIndices[index]].layer.cornerRadius = 8.0
                board.cardViews[selectedIndices[index]].layer.borderWidth = 3.0
                board.cardViews[selectedIndices[index]].layer.borderColor = #colorLiteral(red: 0, green: 0.9768045545, blue: 0, alpha: 1)
                isMatchedAsSet = true
                
                if !game.playingSetCardDeck.isEmpty {
                    dealButton.isEnabled = true
                    hintButton.isEnabled = false
                } else {
                    // Remove matched cards if no more cards in Playing Deck.
                    // Copy cardView for dynamic animator.
                    let tempCard: SetCardView = duplicateCard(board.cardViews[selectedIndices[index]])
                    tempCard.draw(board.bounds)
                    tempCards.append(tempCard)
                    board.addSubview(tempCard)
                    // Perform "flyaway" and snapping to the "discard pile" animation.
                    cardBehavior.addItem(tempCard)
                    selectedIndices.sort { (index, comparable) -> Bool in
                        return index > comparable
                    }
                    board.cardViews.forEach { (cardView) in
                        cardView.isUserInteractionEnabled = false
                    }
                    board.cardViews[selectedIndices[index]].isHidden = true
                    Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { (_) in
                        self.board.cardViews.remove(at: self.selectedIndices[index])
                        self.cardsOnScreen.remove(at: self.selectedIndices[index])
                        self.board.cardViews.forEach { (cardView) in
                            cardView.isUserInteractionEnabled = true
                        }
                    }
                    hintButton.isEnabled = true
                }
                
                // Scoring points for correctly chosen Set.
                if currentPlayerId == 0 {
                    playerOne.score += 15
                } else if currentPlayerId == 1 {
                    playerTwo.score += 15
                }
            } else {
                board.cardViews[selectedIndices[index]].layer.cornerRadius = 8.0
                board.cardViews[selectedIndices[index]].layer.borderWidth = 3.0
                board.cardViews[selectedIndices[index]].layer.borderColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
                isMatchedAsSet = false
                
                // Penalize for 3 non-matching Set cards.
                if currentPlayerId == 0 {
                    playerOne.score -= 5
                } else if currentPlayerId == 1 {
                    playerTwo.score -= 5
                }
            }
        }
        timeOfPlay = Date()
    }
    
}

// Additional structure for multiplayer game.
struct Player {
    let id: Int
    var score: Int
}

extension Int {
    /// Returns a random Integer selected from a range of 0 to this value.
    var random: Int {
        if self > 0 {
            return Int(arc4random_uniform(UInt32(self)))
        } else if self < 0 {
            return -Int(arc4random_uniform(UInt32(self)))
        } else {
            return 0
        }
    }
}
