import SwiftUI
import Foundation

struct ContentView: View {
    @StateObject private var flight = FlightController()
    @State private var showHelp = true

    var body: some View {
        ZStack {
            SceneView(controller: flight)
                .ignoresSafeArea()

            LinearGradient(
                colors: [Color.black.opacity(0.42), .clear, Color.black.opacity(0.50)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            .allowsHitTesting(false)

            VStack {
                header
                Spacer()
            }
            .padding(.horizontal, 22)
            .padding(.top, 14)

            ControlsOverlay(flight: flight)
                .ignoresSafeArea()

            if showHelp {
                HelpOverlay {
                    withAnimation(.easeOut(duration: 0.25)) {
                        showHelp = false
                    }
                }
                .transition(.opacity)
            }
        }
        .background(Color.black)
        .onAppear {
            flight.bootstrap()
        }
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 2) {
                Text("ALIS")
                    .font(.system(size: 26, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                Text("WORLD REBORN")
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundColor(Color(red: 0.45, green: 0.92, blue: 0.88))
                Text("KAZAN // NATIVE FORCED-PORT DEMO")
                    .font(.system(size: 9, weight: .medium, design: .monospaced))
                    .foregroundColor(.white.opacity(0.55))
            }
            .shadow(color: .black.opacity(0.7), radius: 4, x: 1, y: 2)

            Spacer()

            HStack(spacing: 16) {
                readout(label: "ALT", value: String(format: "%05.1f", flight.altitude))
                readout(label: "SPD", value: String(format: "%04.0f", flight.speed))
                readout(label: "HDG", value: String(format: "%03.0f", flight.heading))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 9)
            .background(RoundedRectangle(cornerRadius: 10).fill(Color.black.opacity(0.48)))
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.white.opacity(0.22), lineWidth: 1))
        }
    }

    private func readout(label: String, value: String) -> some View {
        VStack(alignment: .trailing, spacing: 1) {
            Text(label)
                .font(.system(size: 9, weight: .bold, design: .monospaced))
                .foregroundColor(.white.opacity(0.55))
            Text(value)
                .font(.system(size: 15, weight: .bold, design: .monospaced))
                .foregroundColor(.white)
        }
    }
}

struct HelpOverlay: View {
    let dismiss: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.78)
                .ignoresSafeArea()

            VStack(spacing: 18) {
                Text("ALIS — WORLD REBORN")
                    .font(.system(size: 24, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                Text("iOS NATIVE FORCED-PORT DEMO")
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundColor(Color(red: 0.45, green: 0.92, blue: 0.88))

                Text("This is not the UE5.8 original. It is a native SceneKit\nreconstruction of the Kazan flight showcase, built to\nproduce a real unsigned arm64 IPA on GitHub Actions.")
                    .font(.system(size: 12, weight: .regular, design: .monospaced))
                    .foregroundColor(.white.opacity(0.72))
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)

                VStack(alignment: .leading, spacing: 8) {
                    instruction("LEFT", "move / strafe")
                    instruction("RIGHT", "drag to look")
                    instruction("BOOST", "hold for speed")
                    instruction("UP / DOWN", "change altitude")
                }
                .padding(.top, 4)

                Button(action: dismiss) {
                    Text("ENTER KAZAN")
                        .font(.system(size: 13, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                        .frame(width: 210, height: 44)
                        .background(RoundedRectangle(cornerRadius: 12).fill(Color(red: 0.12, green: 0.45, blue: 0.42)))
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(red: 0.45, green: 0.92, blue: 0.88).opacity(0.55), lineWidth: 1))
                }
                .buttonStyle(.plain)
                .padding(.top, 6)
            }
            .padding(28)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color(red: 0.035, green: 0.055, blue: 0.065, alpha: 0.94))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(Color.white.opacity(0.18), lineWidth: 1)
            )
            .padding(.horizontal, 42)
        }
    }

    private func instruction(_ key: String, _ value: String) -> some View {
        HStack(spacing: 12) {
            Text(key)
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundColor(.white)
                .frame(width: 90, alignment: .leading)
            Text(value)
                .font(.system(size: 10, weight: .regular, design: .monospaced))
                .foregroundColor(.white.opacity(0.62))
        }
    }
}
