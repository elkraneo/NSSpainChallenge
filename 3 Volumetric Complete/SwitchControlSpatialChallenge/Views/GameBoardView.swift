/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
SwiftUI view representing the full board of cards for a game.
*/

import SwiftUI

struct GameBoardView: View {

  /// https://developer.apple.com/documentation/swiftui/environmentvalues#Accessibility
  @Environment(\.accessibilitySwitchControlEnabled) var accessibilitySwitchControlEnabled
  @Environment(\.accessibilityVoiceOverEnabled) var accessibilityVoiceOverEnabled

  @Environment(Game.self) var gameModel

  @State var isIntroPresented = false
  @State var isAlertPresented = false

  let columns: [GridItem] = Array(repeating: .init(.fixed(80)), count: 4)

  var body: some View {
    NavigationStack {
      VStack {
        if !gameModel.didWinGame {
          Spacer()

          LazyVGrid(columns: columns, spacing: 10) {
            ForEach(0..<gameModel.cards.count, id: \.self) { index in
              let card = gameModel.cards[index]
              if !card.isMatched {
                CardView(card: card)
                  .aspectRatio(2 / 3, contentMode: .fit)
                  .onTapGesture {
                    isAlertPresented = true
                  }
                  .accessibilityAction {
                    gameModel.select(card)
                  }
              } else {
                // Placeholder for matched card (empty space)
                Spacer()
                  .aspectRatio(2 / 3, contentMode: .fit)
              }
            }
          }

          Spacer()

          GroupBox("Accessibility Environment") {
            LabeledContent(
              "Switch Control", value: "\(accessibilitySwitchControlEnabled ? "YES" : "NO")")
            LabeledContent("VoiceOver", value: "\(accessibilityVoiceOverEnabled ? "YES" : "NO")")
          }
          .accessibilityElement(children: .combine)
          .font(.caption)
          .foregroundStyle(.secondary)
          .padding(60)
          
        } else {
          Image("Win")
          Text("You Win!")
            .font(.title)

          Text("Congrats on learning Switch Control!")
            .font(.subheadline)
            .padding()

          Button("Play Again") {
            gameModel.reset()
          }
          .padding()
        }
      }
      .navigationTitle(Text("Memory Match"))
    }
    .alert("No Taps Allowed!", isPresented: $isAlertPresented) {
      Button {
        isAlertPresented = false
      } label: {
        Text("Got it!")
      }

      Button("Help!") {
        isAlertPresented = false
        isIntroPresented = true
      }
    }
    .sheet(isPresented: $isIntroPresented) {
      IntroPage()
    }
  }
}

#Preview {
  GameBoardView()
    .environment(Game(numberOfCards: 16))
}
