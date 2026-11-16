# ALIS — World Reborn: iOS native forced-port demo

This repository builds a **real, unsigned arm64 iOS IPA** on GitHub-hosted `macos-26`.

It is **not** the Unreal Engine 5.8 original. The upstream ALIS v2.0.0 project requires a macOS machine with UE5.8 installed, UBT/UHT, Cook, Stage and Apple signing. GitHub-hosted `macos-26` has Xcode but no Unreal Engine, so a direct UE build is impossible there.

This forced-port instead reimplements the public **Kazan PreviewFlight** showcase natively:

- SceneKit 3D terrain, water, roads, buildings, trees, tower and “ALIS // KAZAN” landmark
- first-person flight camera
- left floating joystick for movement
- right drag pad for look
- boost, altitude up/down, pause
- landscape-only, iOS 17+, arm64

## Build

Push to `main` or run **Actions → Build ALIS iOS IPA → Run workflow**.

Workflow:

1. `xcodegen generate`
2. `xcodebuild -sdk iphoneos -configuration Release CODE_SIGNING_ALLOWED=NO`
3. package `Payload/ALISNative.app` into `ALIS-iOS.ipa`
4. upload artifact and publish GitHub Release tag `build`

The IPA is unsigned. Install with Sideloadly using a free Apple ID; the app expires after 7 days and must be re-signed.

## Limits

- This does not use ALIS `.uasset/.umap` content, UE5.8 shaders, gameplay systems, Hero, survival loop or the original UI.
- It is a playable reconstruction/demo, not a source-accurate UE port.
- The public v2.0.0 payload itself is missing 157 `/Project` asset references and Hero dependencies; a complete survival port cannot be delivered from public content alone.
