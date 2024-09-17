//
//  YouWinEmmiterView.swift
//  SwitchControlSpatialChallenge
//
//  Created by Cristian Díaz on 15.09.24.
//

import RealityKit
import SwiftUI

struct YouWinEmmiterView: View {
  private let emitterEntity = Entity()
  private var emitterComponent = ParticleEmitterComponent.Presets.magic

  public var body: some View {
    RealityView { content in
      emitterEntity.components.set(emitterComponent)
      // Configure the entity so that it's translucent.
      // emitterEntity.components.set(OpacityComponent(opacity: 0.3))
      content.add(emitterEntity)
    }
    .task {
      if let resource = try? await AudioFileResource(
        named: "Orchestral Jingle Positive 03_322127_557059")
      {
        emitterEntity.playAudio(resource)
      }
    }
  }
}
#Preview {
  YouWinEmmiterView()
}
