//
//  SwitchControlSpatialChallengeApp.swift
//  SwitchControlSpatialChallenge
//
//  Created by Cristian Díaz on 10.09.24.
//

import SwiftUI

@main
struct SwitchControlSpatialChallengeApp: App {
  @State private var appModel = AppModel()
  @State private var gameModel = Game(numberOfCards: 16)

  var body: some Scene {
    WindowGroup {
      GameBoardView()
        .environment(appModel)
        .environment(gameModel)
    }
    .defaultSize(width: 600, height: 800)
  }
}
