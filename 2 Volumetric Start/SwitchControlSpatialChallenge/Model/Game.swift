//
//  Game.swift
//  SwitchControlSpatialChallenge
//
//  Created by Cristian Díaz on 10.09.24.
//

import Accessibility
import Foundation

@Observable
class Game {
  private(set) var deck: Deck
  var score: Int = 0
  var didWinGame = false

  var cards: [Card] { deck.cards }

  private var currentlySelectedCardIndex: Int?

  private var numberOfCards: Int { cards.count }
  private var numberOfPairs: Int { numberOfCards / 2 }

  init(numberOfCards: Int) {
    deck = Deck(numberOfCards: numberOfCards)
    deck.shuffle()
  }

  func select(_ card: Card) {
    guard let requestedCardIndex = cards.firstIndex(where: { $0.id == card.id }) else { return }

    let requestedCard = cards[requestedCardIndex]

    guard !requestedCard.isFaceUp else { return }

    deck.cards[requestedCardIndex].isFaceUp = true

    if let currentlySelectedCardIndex = currentlySelectedCardIndex {
      let currentlySelectedCard = cards[currentlySelectedCardIndex]
      if requestedCard.symbol == currentlySelectedCard.symbol {
        // Match!
        Task { @MainActor in
          score += 1
          try await Task.sleep(nanoseconds: 1_000_000_000)
          AccessibilityNotification.Announcement("Found a match!").post()
          deck.cards[requestedCardIndex].isMatched = true
          deck.cards[currentlySelectedCardIndex].isMatched = true

          if score == numberOfPairs {
            AccessibilityNotification.Announcement("You Win!").post()
            didWinGame = true
          }
        }
      } else {
        Task { @MainActor in
          try await Task.sleep(nanoseconds: 1_000_000_000)
          AccessibilityNotification.Announcement("Not a match!").post()
          self.deck.cards[requestedCardIndex].isFaceUp = false
          self.deck.cards[currentlySelectedCardIndex].isFaceUp = false
        }
      }
      self.currentlySelectedCardIndex = nil
    } else {
      for cardIndex in 0..<cards.count where cardIndex != requestedCardIndex {
        deck.cards[cardIndex].isFaceUp = false
      }
      currentlySelectedCardIndex = requestedCardIndex
    }
  }

  func reset() {
    deck = Deck(numberOfCards: numberOfCards)
    deck.shuffle()
    score = 0
    didWinGame = false
    currentlySelectedCardIndex = nil
  }
}
