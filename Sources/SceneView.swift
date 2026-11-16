import SwiftUI
import SceneKit
import Foundation

struct SceneView: UIViewRepresentable {
    @ObservedObject var controller: FlightController

    func makeUIView(context: Context) -> SCNView {
        let view = SCNView()
        view.scene = controller.scene
        view.pointOfView = controller.cameraNode
        view.backgroundColor = .black
        view.antialiasingMode = .multisampling4X
        view.preferredFramesPerSecond = 60
        view.isPlaying = true
        view.delegate = context.coordinator
        return view
    }

    func updateUIView(_ uiView: SCNView, context: Context) {
        uiView.pointOfView = controller.cameraNode
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(controller: controller)
    }

    final class Coordinator: NSObject, SCNSceneRendererDelegate {
        private let controller: FlightController
        private var lastTime: TimeInterval = 0

        init(controller: FlightController) {
            self.controller = controller
        }

        func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
            let delta = lastTime == 0 ? 0 : min(time - lastTime, 0.05)
            lastTime = time
            guard delta > 0 else { return }
            DispatchQueue.main.async {
                self.controller.step(deltaTime: delta)
            }
        }
    }
}
