import Foundation
import SceneKit
import CoreGraphics

final class FlightController: ObservableObject {
    let scene = SCNScene()
    let cameraNode = SCNNode()

    @Published var moveVector = CGVector.zero
    @Published var altitude: Double = 0
    @Published var speed: Double = 0
    @Published var heading: Double = 0
    @Published var isPaused = false
    @Published var isReady = false

    private var yaw: Float = 0
    private var pitch: Float = -0.25
    private var hudAccumulator: Float = 0
    private var boost = false
    private var vertical: Float = 0

    init() {
        let camera = SCNCamera()
        camera.zNear = 0.1
        camera.zFar = 1200
        camera.fieldOfView = 68
        camera.wantsHDR = true
        camera.wantsExposureAdaptation = true
        cameraNode.camera = camera
        cameraNode.position = SCNVector3(0, 34, 72)
        cameraNode.eulerAngles = SCNVector3(pitch, yaw, 0)
        scene.rootNode.addChildNode(cameraNode)
    }

    func bootstrap() {
        guard !isReady else { return }
        WorldBuilder.populate(scene: scene)
        isReady = true
    }

    func setBoost(_ active: Bool) {
        boost = active
    }

    func setVertical(_ value: Float) {
        vertical = value
    }

    func look(delta: CGSize) {
        guard isReady, !isPaused else { return }
        let dx = Float(delta.width)
        let dy = Float(delta.height)
        yaw -= dx * 0.0042
        pitch -= dy * 0.0042
        pitch = min(max(pitch, -1.05), 1.05)
        cameraNode.eulerAngles = SCNVector3(pitch, yaw, cameraNode.eulerAngles.z)
    }

    func step(deltaTime: TimeInterval) {
        guard isReady, !isPaused, deltaTime > 0 else { return }
        let dt = Float(min(deltaTime, 0.05))

        let flatForward = SCNVector3(-sinf(yaw), 0, -cosf(yaw))
        let right = SCNVector3(cosf(yaw), 0, -sinf(yaw))

        let forwardInput = Float(moveVector.dy)
        let strafeInput = Float(moveVector.dx)
        let horizontalSpeed: Float = boost ? 56 : 27

        var horizontal = SCNVector3(
            flatForward.x * forwardInput + right.x * strafeInput,
            0,
            flatForward.z * forwardInput + right.z * strafeInput
        )
        horizontal.x *= horizontalSpeed
        horizontal.z *= horizontalSpeed

        cameraNode.position.x += horizontal.x * dt
        cameraNode.position.z += horizontal.z * dt
        cameraNode.position.y += vertical * 17 * dt
        cameraNode.position.y = min(max(cameraNode.position.y, 4.5), 125)

        let roll = -strafeInput * 0.14
        cameraNode.eulerAngles = SCNVector3(pitch, yaw, roll)

        hudAccumulator += dt
        if hudAccumulator >= 0.12 {
            hudAccumulator = 0
            altitude = Double(cameraNode.position.y)
            speed = Double(sqrtf(horizontal.x * horizontal.x + horizontal.z * horizontal.z))
            let degrees = atan2f(flatForward.x, -flatForward.z) * 180.0 / Float.pi
            heading = Double(degrees < 0 ? degrees + 360 : degrees)
        }
    }

    func resetFlight() {
        cameraNode.position = SCNVector3(0, 34, 72)
        yaw = 0
        pitch = -0.25
        cameraNode.eulerAngles = SCNVector3(pitch, yaw, 0)
        moveVector = .zero
        vertical = 0
        boost = false
        isPaused = false
    }
}
