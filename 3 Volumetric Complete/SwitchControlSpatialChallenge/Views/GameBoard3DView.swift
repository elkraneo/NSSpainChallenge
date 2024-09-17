//
//  GameBoard3DView.swift
//  SwitchControlSpatialChallenge
//
//  Created by Cristian Díaz on 11.09.24.
//

import Combine
import RealityKit
import SwiftUI

struct GameBoard3DView: View {

  /// https://developer.apple.com/documentation/swiftui/environmentvalues#Accessibility
  @Environment(\.accessibilitySwitchControlEnabled) var accessibilitySwitchControlEnabled
  @Environment(\.accessibilityVoiceOverEnabled) var accessibilityVoiceOverEnabled
  @Environment(\.accessibilityReduceMotion) var accessibilityReduceMotion
  
  /// https://developer.apple.com/documentation/swiftui/environmentvalues#View-attributes
  @Environment(\.realityKitScene) private var scene

  @Environment(Game.self) var gameModel

  // @State private var isIntroPresented = false
  // @State private var isAlertPresented = false
  @State private var activationSubscription: Cancellable?

  let columns: [GridItem] = Array(repeating: .init(.fixed(90)), count: 4)

  var body: some View {
    VStack {
      if !gameModel.didWinGame {
        LazyVGrid(columns: columns, spacing: 8) {
          ForEach(0..<gameModel.cards.count, id: \.self) { index in
            let card = gameModel.cards[index]
            if !card.isMatched {
              Card3DView(card: card)
                .aspectRatio(2 / 3, contentMode: .fit)
            } else {
              // Placeholder for matched card (empty space)
              Spacer()
                .aspectRatio(2 / 3, contentMode: .fit)
                .overlay(CardMatchedEmitterView())
            }
          }
        }
        .frame(height: 700)
      } else {
        Image(decorative: "Win")
          .overlay(YouWinEmmiterView())
        
        RealityView { content in
          let text = try! await makeTextEntity()
          text.scale = SIMD3(x: 0.15, y: 0.15, z: 0.15)
          let textBounds = text.visualBounds(relativeTo: nil)
          text.position.x -= textBounds.extents.x / 1.5
          text.position.y -= textBounds.extents.y * 1.25

          var accessibilityComponent = AccessibilityComponent()
          accessibilityComponent.isAccessibilityElement = true
          accessibilityComponent.traits = [.staticText]
          accessibilityComponent.label = "You Win!"
          accessibilityComponent.value = "Congrats on learning Switch Control!"

          text.components[AccessibilityComponent.self] = accessibilityComponent

          content.add(text)
        }
        .frame(height: 200)
        .frame(depth: 0.1)

        Button("Play Again") {
          gameModel.reset()
        }
        .controlSize(.extraLarge)
        .padding()
      }
    }
    .task {
      /// https://developer.apple.com/documentation/realitykit/accessibilityevents/activate
      activationSubscription = scene?.subscribe(
        to: AccessibilityEvents.Activate.self,
        on: nil,
        componentType: nil
      ) { activation in
        guard let selectedCard = activation.entity.components[CardCompoonent.self]?.card else {
          return
        }
        gameModel.select(selectedCard)
      }
    }
    //FIXME: volumes can not present alerts or sheets
    // .alert("No Taps Allowed!", isPresented: $isAlertPresented) {
    //   Button {
    //     isAlertPresented = false
    //   } label: {
    //     Text("Got it!")
    //   }
    //
    //   Button {
    //     isAlertPresented = false
    //     isIntroPresented = true
    //   } label: {
    //     Text("Help!")
    //   }
    // }
    // .sheet(isPresented: $isIntroPresented) {
    //   IntroPage()
    // }
    .toolbar {
      ToolbarItem(placement: .bottomOrnament) {
        VStack {
          Text("Accessibility environment")
            .font(.headline)
          LabeledContent(
            "Switch Control", value: "\(accessibilitySwitchControlEnabled ? "YES" : "NO")")
          LabeledContent("VoiceOver", value: "\(accessibilityVoiceOverEnabled ? "YES" : "NO")")
          LabeledContent("Reduce Motion", value: "\(accessibilityReduceMotion ? "YES" : "NO")")

          
        }
        .accessibilityElement(children: .combine)
        .font(.caption)
        .foregroundStyle(.secondary)
        .padding()
      }
    }
  }
}

#Preview {
  GameBoard3DView()
    .environment(Game(numberOfCards: 16))
}

// MARK: -

/// Material used for the sides of the meshes on the splash screen.
@MainActor private let borderMaterial: PhysicallyBasedMaterial = {
  var borderMaterial = PhysicallyBasedMaterial()
  borderMaterial.metallic = .init(floatLiteral: 0.15)
  borderMaterial.roughness = .init(floatLiteral: 0.85)
  borderMaterial.baseColor = .init(
    tint: #colorLiteral(red: 0.1019607857, green: 0.2784313858, blue: 0.400000006, alpha: 1))
  return borderMaterial
}()

/// Creates the `ModelEntity` for the 3D text "RealityKit Drawing App" in a customized layout and font.
@MainActor private func makeTextEntity() async throws -> ModelEntity {
  var textString = AttributedString("You Win!")
  textString.font = .preferredFont(forTextStyle: .title1)

  let attributes = AttributeContainer([.font: UIFont.preferredFont(forTextStyle: .subheadline)])
  textString.append(
    AttributedString("\nCongrats on learning Switch Control!", attributes: attributes))

  // Center the text.
  let paragraphStyle = NSMutableParagraphStyle()
  paragraphStyle.alignment = .center
  textString.mergeAttributes(AttributeContainer([.paragraphStyle: paragraphStyle]))

  // Define the container frame of the text.
  var textOptions = MeshResource.GenerateTextOptions()
  textOptions.containerFrame = CGRect(x: 0, y: 0, width: 180, height: 120)

  var extrusionOptions = MeshResource.ShapeExtrusionOptions()

  // Set the extrusion depth to 2 pt.
  extrusionOptions.extrusionMethod = .linear(depth: 2)

  // Set a different material for the sides of the mesh.
  extrusionOptions.materialAssignment = .init(
    front: 0, back: 0, extrusion: 1, frontChamfer: 1, backChamfer: 1)

  // Set the chamfer radius to 0.1 pt.
  extrusionOptions.chamferRadius = 0.1

  // Generate the mesh.
  let textMesh = try await MeshResource(
    extruding: textString,
    textOptions: textOptions,
    extrusionOptions: extrusionOptions)
  return ModelEntity(mesh: textMesh, materials: [SimpleMaterial(), borderMaterial])
}
