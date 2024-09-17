//
//  Card3DView.swift
//  SwitchControlSpatialChallenge
//
//  Created by Cristian Díaz on 14.09.24.
//

import RealityKit
import SwiftUI

struct CardCompoonent: Component {
  let card: Card
}

struct Card3DView: View {
  let card: Card
  @State private var container = Entity()

  var body: some View {
    RealityView { content, attachments in
      if let cardEntity = try? await makeCardEntity(),
        let front = attachments.entity(for: "Front"),
        let symbol = attachments.entity(for: "Symbol")
      {
        let cardBounds = cardEntity.visualBounds(relativeTo: nil)

        front.position.x = cardBounds.center.x
        front.position.y = cardBounds.center.y
        front.position.z = cardBounds.extents.z
        cardEntity.addChild(front)

        symbol.position.x = cardBounds.center.x
        symbol.position.y = cardBounds.center.y
        symbol.position.z = -cardBounds.extents.z
        cardEntity.addChild(symbol)

        cardEntity.position.x = -cardBounds.center.x

        container.components[CardCompoonent.self] = CardCompoonent(card: card)
        
        container.addChild(cardEntity)
        content.add(container)
      }
    } attachments: {
      Attachment(id: "Front") {
        Image(systemName: Symbol.inactive.symbolName)
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(width: 50, height: 50)
          .frame(depth: 1)
      }

      Attachment(id: "Symbol") {
        Image(systemName: card.symbolName)
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(width: 50, height: 50)
          .frame(depth: 1)
      }
    }
    .onChange(of: card.isFaceUp) { oldValue, newValue in
      guard newValue != oldValue else { return }
      flipCard(container)
    }
  }

  private func flipCard(_ entity: Entity) {
    // Create an action that performs a spin around the specified local axis
    // with a linear transition.
    let spinAction = SpinAction(
      revolutions: 0.5,
      localAxis: [0, -1, 0],
      timingFunction: .easeIn,
      isAdditive: false)

    // A five second animation that plays an animation causing the entity to
    // spin around a specified local axis.
    //3
    let spinAnimation = try! AnimationResource.makeActionAnimation(
      for: spinAction,
      duration: 0.5,
      bindTarget: .transform)

    // Play the five second spin animation.
    let animationPlaybackController = entity.playAnimation(spinAnimation)
    //TODO: observe animation completion
  }
}

/// Material used for the front face of the logomark.
@MainActor private let frontMaterial: PhysicallyBasedMaterial = {
  var material = PhysicallyBasedMaterial()
  material.metallic = .init(floatLiteral: 0.9)
  material.roughness = .init(floatLiteral: 0.1)
  material.baseColor = .init(
    tint: #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1))
  material.emissiveColor = .init(
    color: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
  material.emissiveIntensity = 0.7
  material.clearcoat = .init(floatLiteral: 0.9)
  return material
}()

@MainActor private let backMaterial: PhysicallyBasedMaterial = {
  var material = PhysicallyBasedMaterial()
  material.metallic = .init(floatLiteral: 0.9)
  material.roughness = .init(floatLiteral: 0.1)
  material.baseColor = .init(
    tint: #colorLiteral(red: 0.1411764771, green: 0.3960784376, blue: 0.5647059083, alpha: 1))
  material.emissiveColor = .init(
    color: #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1))
  material.emissiveIntensity = 0.7
  material.clearcoat = .init(floatLiteral: 0.9)
  return material
}()

/// Material used for the sides of the meshes on the splash screen.
@MainActor private let borderMaterial: PhysicallyBasedMaterial = {
  var borderMaterial = PhysicallyBasedMaterial()
  borderMaterial.metallic = .init(floatLiteral: 0.15)
  borderMaterial.roughness = .init(floatLiteral: 0.85)
  borderMaterial.baseColor = .init(
    tint: #colorLiteral(red: 0.1019607857, green: 0.2784313858, blue: 0.400000006, alpha: 1))
  return borderMaterial
}()

/// Creates the `ModelEntity` for the Card.
@MainActor private func makeCardEntity() async throws -> ModelEntity {

  let width: CGFloat = 0.05
  let height: CGFloat = 0.08

  let graphicPath = Path { path in
    path.addRoundedRect(
      in: CGRect(x: 0, y: 0, width: width, height: height),
      cornerSize: CGSize(width: 0.01, height: 0.01))
  }

  var extrusionOptions = MeshResource.ShapeExtrusionOptions()
  extrusionOptions.extrusionMethod = .linear(depth: 0.005)
  extrusionOptions.boundaryResolution = .uniformSegmentsPerSpan(segmentCount: 32)

  // Set a different material for the sides of the mesh.
  extrusionOptions.materialAssignment = .init(
    front: 0,
    back: 2,
    extrusion: 1,
    frontChamfer: 1,
    backChamfer: 1
  )

  // Generate the mesh.
  let graphicMesh = try await MeshResource(
    extruding: graphicPath, extrusionOptions: extrusionOptions)
  return ModelEntity(mesh: graphicMesh, materials: [frontMaterial, borderMaterial, backMaterial])
}

#Preview("Card") {
  Card3DView(card: .init(symbol: Symbol.ant))
}
