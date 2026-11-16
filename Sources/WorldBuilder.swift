import Foundation
import SceneKit
import UIKit

enum WorldBuilder {
    static func populate(scene: SCNScene) {
        scene.background.contents = UIColor(red: 0.035, green: 0.055, blue: 0.075, alpha: 1)
        scene.fogColor = UIColor(red: 0.08, green: 0.12, blue: 0.15, alpha: 1)
        scene.fogStartDistance = 85
        scene.fogEndDistance = 330

        let root = SCNNode()
        root.name = "kazan"
        scene.rootNode.addChildNode(root)

        addLights(to: root)
        addTerrain(to: root)
        addWater(to: root)
        addRoads(to: root)
        addBuildings(to: root)
        addTrees(to: root)
        addLandmarks(to: root)
    }

    static func height(_ x: Float, _ z: Float) -> Float {
        let broad = sinf(x / 18.0) * cosf(z / 22.0) * 4.0
        let detail = sinf((x + z) / 9.0) * 1.15
        let grain = cosf(x / 5.0) * 0.35
        return 2.3 + broad + detail + grain
    }

    private static func addLights(to root: SCNNode) {
        let ambient = SCNLight()
        ambient.type = .ambient
        ambient.color = UIColor(red: 0.34, green: 0.42, blue: 0.52, alpha: 1)
        ambient.intensity = 420
        let ambientNode = SCNNode()
        ambientNode.light = ambient
        root.addChildNode(ambientNode)

        let sun = SCNLight()
        sun.type = .directional
        sun.color = UIColor(red: 1.0, green: 0.94, blue: 0.82, alpha: 1)
        sun.intensity = 1100
        sun.castsShadow = true
        sun.shadowMode = .deferred
        sun.shadowSampleCount = 8
        sun.shadowMapSize = CGSize(width: 2048, height: 2048)
        sun.shadowRadius = 6
        let sunNode = SCNNode()
        sunNode.light = sun
        sunNode.eulerAngles = SCNVector3(-0.85, 0.55, 0)
        root.addChildNode(sunNode)
    }

    private static func addTerrain(to root: SCNNode) {
        let side: Float = 300
        let segments = 84
        var vertices: [SCNVector3] = []
        var normals: [SCNVector3] = []
        var uvs: [CGPoint] = []

        for z in 0...segments {
            for x in 0...segments {
                let fx = Float(x) / Float(segments)
                let fz = Float(z) / Float(segments)
                let px = (fx - 0.5) * side
                let pz = (fz - 0.5) * side
                let py = height(px, pz)
                vertices.append(SCNVector3(px, py, pz))
                normals.append(SCNVector3(0, 1, 0))
                uvs.append(CGPoint(x: CGFloat(fx) * 12, y: CGFloat(fz) * 12))
            }
        }

        var indices: [UInt32] = []
        let row = UInt32(segments + 1)
        for z in 0..<segments {
            for x in 0..<segments {
                let i = UInt32(z) * row + UInt32(x)
                indices.append(contentsOf: [i, i + row, i + 1])
                indices.append(contentsOf: [i + 1, i + row, i + row + 1])
            }
        }

        let positionSource = SCNGeometrySource(vertices: vertices)
        let normalSource = SCNGeometrySource(normals: normals)
        let uvSource = SCNGeometrySource(textureCoordinates: uvs)
        let element = SCNGeometryElement(indices: indices, primitiveType: .triangles)
        let geometry = SCNGeometry(sources: [positionSource, normalSource, uvSource], elements: [element])

        let material = SCNMaterial()
        material.lightingModel = .physicallyBased
        material.diffuse.contents = UIColor(red: 0.20, green: 0.33, blue: 0.18, alpha: 1)
        material.roughness.contents = 0.92
        material.metalness.contents = 0.0
        material.isDoubleSided = false
        geometry.firstMaterial = material

        let node = SCNNode(geometry: geometry)
        node.name = "terrain"
        root.addChildNode(node)
    }

    private static func addWater(to root: SCNNode) {
        let plane = SCNPlane(width: 620, height: 620)
        let material = SCNMaterial()
        material.lightingModel = .physicallyBased
        material.diffuse.contents = UIColor(red: 0.06, green: 0.30, blue: 0.42, alpha: 1)
        material.emission.contents = UIColor(red: 0.02, green: 0.08, blue: 0.11, alpha: 1)
        material.transparency = 0.72
        material.roughness.contents = 0.18
        material.metalness.contents = 0.25
        material.isDoubleSided = true
        plane.materials = [material]

        let node = SCNNode(geometry: plane)
        node.eulerAngles.x = -Float.pi / 2
        node.position = SCNVector3(0, 2.15, 0)
        node.name = "water"
        root.addChildNode(node)
    }

    private static func addRoads(to root: SCNNode) {
        let material = SCNMaterial()
        material.lightingModel = .physicallyBased
        material.diffuse.contents = UIColor(red: 0.16, green: 0.17, blue: 0.18, alpha: 1)
        material.roughness.contents = 0.88

        let northSouth = SCNBox(width: 16, height: 0.12, length: 230, chamferRadius: 0.0)
        northSouth.firstMaterial = material
        let nsNode = SCNNode(geometry: northSouth)
        nsNode.position = SCNVector3(0, 2.64, 0)
        root.addChildNode(nsNode)

        let eastWest = SCNBox(width: 230, height: 0.12, length: 14, chamferRadius: 0.0)
        eastWest.firstMaterial = material
        let ewNode = SCNNode(geometry: eastWest)
        ewNode.position = SCNVector3(0, 2.72, 0)
        root.addChildNode(ewNode)
    }

    private static func addBuildings(to root: SCNNode) {
        let placements: [(Float, Float, Float, Float)] = [
            (-58, -28, 18, 7), (-42, -62, 26, 8), (-24, -36, 14, 6),
            (30, -54, 22, 8), (52, -30, 16, 7), (68, -68, 30, 9),
            (-70, 24, 20, 8), (-48, 52, 14, 6), (42, 34, 24, 8),
            (72, 52, 18, 7), (24, 72, 20, 7), (-18, 78, 12, 5),
            (-84, -54, 34, 9), (86, 12, 26, 8), (-12, -86, 16, 6)
        ]

        for (index, item) in placements.enumerated() {
            let (x, z, heightValue, widthValue) = item
            let width = CGFloat(widthValue)
            let length = CGFloat(widthValue + (index % 3 == 0 ? 5 : 0))
            let box = SCNBox(width: width, height: CGFloat(heightValue), length: length, chamferRadius: 0.35)

            let material = SCNMaterial()
            material.lightingModel = .physicallyBased
            let tone = CGFloat(0.42 + Float(index % 4) * 0.06)
            material.diffuse.contents = UIColor(red: tone, green: tone * 0.94, blue: tone * 0.82, alpha: 1)
            material.roughness.contents = 0.78
            material.metalness.contents = 0.08
            box.firstMaterial = material

            let node = SCNNode(geometry: box)
            node.position = SCNVector3(x, height(x, z) + Float(heightValue) / 2.0, z)
            root.addChildNode(node)

            addWindows(to: node, width: width, height: CGFloat(heightValue), length: length)
        }
    }

    private static func addWindows(to building: SCNNode, width: CGFloat, height: CGFloat, length: CGFloat) {
        let material = SCNMaterial()
        material.lightingModel = .constant
        material.diffuse.contents = UIColor(red: 0.50, green: 0.68, blue: 0.68, alpha: 1)
        material.emission.contents = UIColor(red: 0.20, green: 0.32, blue: 0.30, alpha: 1)

        let rows = max(2, Int(height / 5))
        let columns = max(2, Int(width / 3))
        for row in 0..<rows {
            for column in 0..<columns {
                let window = SCNBox(width: 0.7, height: 1.1, length: 0.12, chamferRadius: 0.0)
                window.firstMaterial = material
                let node = SCNNode(geometry: window)
                let px = -width / 2 + 1.4 + CGFloat(column) * (width - 2.8) / CGFloat(max(columns - 1, 1))
                let py = -height / 2 + 1.5 + CGFloat(row) * (height - 3.0) / CGFloat(max(rows - 1, 1))
                node.position = SCNVector3(Float(px), Float(py), Float(length / 2 + 0.08))
                building.addChildNode(node)
            }
        }
    }

    private static func addTrees(to root: SCNNode) {
        let positions: [(Float, Float)] = [
            (-95, -10), (-88, 38), (-64, 82), (-36, 14), (-10, 48),
            (12, -12), (36, 18), (58, -10), (84, 32), (104, -44),
            (18, 96), (-110, 70), (118, 80), (-124, -80), (96, -102),
            (-30, -120), (44, -132), (130, -8), (-140, 8), (-70, -100)
        ]

        let trunkMaterial = SCNMaterial()
        trunkMaterial.diffuse.contents = UIColor(red: 0.24, green: 0.15, blue: 0.08, alpha: 1)
        trunkMaterial.roughness.contents = 1.0

        for (index, position) in positions.enumerated() {
            let (x, z) = position
            let baseY = height(x, z)

            let trunk = SCNCylinder(radius: 0.45, height: 4.2)
            trunk.firstMaterial = trunkMaterial
            let trunkNode = SCNNode(geometry: trunk)
            trunkNode.position = SCNVector3(x, baseY + 2.1, z)

            let foliage = SCNCone(topRadius: 0, bottomRadius: 3.2, height: 7.8)
            let foliageMaterial = SCNMaterial()
            foliageMaterial.lightingModel = .physicallyBased
            foliageMaterial.diffuse.contents = UIColor(
                red: 0.10 + CGFloat(index % 3) * 0.02,
                green: 0.28 + CGFloat(index % 4) * 0.02,
                blue: 0.13,
                alpha: 1
            )
            foliageMaterial.roughness.contents = 0.95
            foliage.firstMaterial = foliageMaterial
            let foliageNode = SCNNode(geometry: foliage)
            foliageNode.position = SCNVector3(x, baseY + 6.4, z)

            let tree = SCNNode()
            tree.addChildNode(trunkNode)
            tree.addChildNode(foliageNode)
            root.addChildNode(tree)
        }
    }

    private static func addLandmarks(to root: SCNNode) {
        let text = SCNText(string: "ALIS // KAZAN", extrusionDepth: 0.8)
        text.font = UIFont.systemFont(ofSize: 9, weight: .heavy)
        text.flatness = 0.15
        let textMaterial = SCNMaterial()
        textMaterial.lightingModel = .constant
        textMaterial.diffuse.contents = UIColor(red: 0.50, green: 0.92, blue: 0.88, alpha: 1)
        textMaterial.emission.contents = UIColor(red: 0.18, green: 0.45, blue: 0.42, alpha: 1)
        text.materials = [textMaterial]
        let textNode = SCNNode(geometry: text)
        textNode.position = SCNVector3(-22, 12, -46)
        textNode.scale = SCNVector3(0.7, 0.7, 0.7)
        root.addChildNode(textNode)

        let tower = SCNCylinder(radius: 3.0, height: 44)
        let towerMaterial = SCNMaterial()
        towerMaterial.lightingModel = .physicallyBased
        towerMaterial.diffuse.contents = UIColor(red: 0.38, green: 0.43, blue: 0.46, alpha: 1)
        towerMaterial.metalness.contents = 0.55
        towerMaterial.roughness.contents = 0.42
        tower.firstMaterial = towerMaterial
        let towerNode = SCNNode(geometry: tower)
        towerNode.position = SCNVector3(0, 26, -112)
        root.addChildNode(towerNode)

        let beacon = SCNCone(topRadius: 0, bottomRadius: 2.0, height: 8)
        let beaconMaterial = SCNMaterial()
        beaconMaterial.lightingModel = .constant
        beaconMaterial.diffuse.contents = UIColor(red: 0.95, green: 0.32, blue: 0.20, alpha: 1)
        beaconMaterial.emission.contents = UIColor(red: 0.65, green: 0.12, blue: 0.06, alpha: 1)
        beacon.firstMaterial = beaconMaterial
        let beaconNode = SCNNode(geometry: beacon)
        beaconNode.position = SCNVector3(0, 52, -112)
        root.addChildNode(beaconNode)
    }
}
