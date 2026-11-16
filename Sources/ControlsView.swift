import SwiftUI
import Foundation

struct ControlsOverlay: View {
    @ObservedObject var flight: FlightController

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                HStack {
                    Spacer()
                    LookPad(flight: flight)
                        .frame(width: geometry.size.width * 0.52, height: geometry.size.height)
                }

                VStack {
                    Spacer()
                    HStack(alignment: .bottom) {
                        Joystick(vector: $flight.moveVector)
                            .frame(width: 150, height: 150)
                            .padding(.leading, 22)
                            .padding(.bottom, 20)

                        Spacer()

                        VStack(spacing: 9) {
                            HoldButton(label: "BOOST", tint: .orange) { active in
                                flight.setBoost(active)
                            }
                            HStack(spacing: 9) {
                                HoldButton(label: "UP", tint: .cyan) { active in
                                    flight.setVertical(active ? 1 : 0)
                                }
                                HoldButton(label: "DOWN", tint: .cyan) { active in
                                    flight.setVertical(active ? -1 : 0)
                                }
                            }
                            Button {
                                flight.isPaused.toggle()
                            } label: {
                                Text(flight.isPaused ? "PLAY" : "PAUSE")
                                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                                    .foregroundColor(.white)
                                    .frame(width: 138, height: 40)
                                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.black.opacity(0.55)))
                                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.white.opacity(0.35), lineWidth: 1))
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.trailing, 22)
                        .padding(.bottom, 20)
                    }
                }
            }
        }
    }
}

struct Joystick: View {
    @Binding var vector: CGVector

    var body: some View {
        GeometryReader { geometry in
            let diameter = min(geometry.size.width, geometry.size.height)
            let radius = diameter / 2

            ZStack {
                Circle()
                    .fill(Color.black.opacity(0.34))
                    .overlay(Circle().stroke(Color.white.opacity(0.38), lineWidth: 1.2))
                Circle()
                    .stroke(Color.white.opacity(0.16), lineWidth: 1)
                    .frame(width: diameter * 0.58, height: diameter * 0.58)
                Circle()
                    .fill(Color.white.opacity(0.86))
                    .frame(width: diameter * 0.34, height: diameter * 0.34)
                    .overlay(Circle().stroke(Color.black.opacity(0.25), lineWidth: 1))
                    .offset(
                        x: vector.dx * diameter * 0.30,
                        y: vector.dy * diameter * 0.30
                    )
            }
            .contentShape(Circle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        let dx = (value.location.x - radius) / radius
                        let dy = (value.location.y - radius) / radius
                        let length = sqrt(dx * dx + dy * dy)
                        if length > 1.0 {
                            vector = CGVector(dx: dx / length, dy: dy / length)
                        } else {
                            vector = CGVector(dx: dx, dy: dy)
                        }
                    }
                    .onEnded { _ in
                        vector = .zero
                    }
            )
        }
    }
}

struct LookPad: View {
    @ObservedObject var flight: FlightController
    @State private var lastLocation: CGPoint?

    var body: some View {
        ZStack {
            Color.clear
                .contentShape(Rectangle())
            Image(systemName: "scope")
                .font(.system(size: 42, weight: .ultraLight))
                .foregroundColor(.white.opacity(0.14))
        }
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    if let last = lastLocation {
                        flight.look(delta: CGSize(
                            width: value.location.x - last.x,
                            height: value.location.y - last.y
                        ))
                    }
                    lastLocation = value.location
                }
                .onEnded { _ in
                    lastLocation = nil
                }
        )
    }
}

struct HoldButton: View {
    let label: String
    let tint: Color
    let onChange: (Bool) -> Void
    @State private var pressed = false

    var body: some View {
        Text(label)
            .font(.system(size: 12, weight: .bold, design: .monospaced))
            .foregroundColor(.white)
            .frame(width: 62, height: 44)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(tint.opacity(pressed ? 0.80 : 0.32))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.white.opacity(0.42), lineWidth: 1)
            )
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        if !pressed {
                            pressed = true
                            onChange(true)
                        }
                    }
                    .onEnded { _ in
                        pressed = false
                        onChange(false)
                    }
            )
    }
}
