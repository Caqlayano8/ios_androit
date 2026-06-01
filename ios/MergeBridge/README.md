# MergeBridge iOS App

This folder contains the iPhone-side source for a future iOS companion app.

It is meant to be opened from macOS with Xcode. Windows can store and edit the
files, but Apple only allows building and signing iPhone apps with Xcode on
macOS.

## What This App Can Do

- Ask for HealthKit read permission.
- Ask for Contacts permission.
- Start a CoreBluetooth peripheral manager.
- Advertise a custom bridge service for the WearOS watch app.
- Encode health/contact updates into small JSON packets that can be sent over BLE.

## What Still Needs Native Device Testing

- iPhone background BLE behavior.
- HealthKit permissions on the real iPhone 12.
- Contacts payload size limits.
- Matching the WearOS BLE manager to this custom service.
- App Store/TestFlight signing.

## Xcode Setup

1. Open Xcode on macOS.
2. Create a new iOS App project named `MergeBridge`.
3. Use Swift and SwiftUI.
4. Set the bundle identifier, for example `com.codegy.mergebridge`.
5. Add every `.swift` file from `Sources/MergeBridgeApp` to the app target.
6. Add `Resources/Info.plist` entries to the target Info settings.
7. Enable these capabilities:
   - HealthKit
   - Background Modes: Uses Bluetooth LE accessories
   - Background Modes: Acts as a Bluetooth LE accessory
8. Build and run on the iPhone 12.

## Important

This app cannot read every private Apple service. HealthKit and Contacts require
explicit user permission. Find My is not exposed as a public Apple API for third
party apps, so only Find My notifications can be forwarded if iOS delivers them
as notifications.
