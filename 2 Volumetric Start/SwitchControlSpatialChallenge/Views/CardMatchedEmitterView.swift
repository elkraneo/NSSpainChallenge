//
//  EmitterView.swift
//  SwitchControlSpatialChallenge
//
//  Created by Cristian Díaz on 15.09.24.
//

import RealityKit
import SwiftUI

struct CardMatchedEmitterView: View {
  private let emitterEntity = Entity()
  private var emitterComponent = ParticleEmitterComponent.Presets.impact

  init() {
    emitterComponent.torusInnerRadius = 0.05
    emitterComponent.emissionDirection = SIMD3(x: 0, y: 1, z: 0)
    emitterComponent.mainEmitter.lifeSpan = 0.3
    emitterComponent.mainEmitter.attractionCenter = SIMD3(x: 0, y: 1, z: 0)
    emitterComponent.mainEmitter.attractionStrength = 1

    emitterComponent.mainEmitter.color = .constant(.random(a: .systemCyan, b: .systemBlue))
    emitterComponent.isEmitting = false
    emitterEntity.components.set(emitterComponent)
  }

  public var body: some View {
    RealityView { content in
      // Configure the entity so that it's translucent.
      emitterEntity.components.set(OpacityComponent(opacity: 0.3))
      emitterEntity.position.y = 0.025
      content.add(emitterEntity)
    }
    .task {
      do {
        try await Task.sleep(for: .seconds(0.3))
        let resource = try await AudioFileResource(named: "Arcade Click Positive 06_0_137567")
        let audioController = emitterEntity.playAudio(resource)
        emitterEntity.components[ParticleEmitterComponent.self]?.burst()
      } catch {
        print(error.localizedDescription)
      }
    }
  }
}

#Preview {
  CardMatchedEmitterView()
}
