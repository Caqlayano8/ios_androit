# GitHub iOS Build Setup

This project can build the iPhone app on GitHub Actions without a local Mac.

## What Works Without Apple Signing

The workflow `.github/workflows/ios-mergebridge.yml` always runs a simulator
build. This verifies that the Swift code and Xcode project compile.

## What Requires Apple Signing

Installing on a real iPhone requires Apple signing assets:

- Apple Developer Program membership
- iOS Distribution or Development certificate exported as `.p12`
- Provisioning profile for the app bundle id
- Team ID

Add these repository secrets:

- `IOS_CERTIFICATE_BASE64`
- `IOS_CERTIFICATE_PASSWORD`
- `IOS_PROVISION_PROFILE_BASE64`
- `IOS_KEYCHAIN_PASSWORD`
- `IOS_TEAM_ID`
- `IOS_BUNDLE_ID`

Recommended bundle id:

```text
com.codegy.mergebridge
```

## Creating Base64 Secrets

On macOS:

```sh
base64 -i certificate.p12 | pbcopy
base64 -i MergeBridge.mobileprovision | pbcopy
```

Paste the copied values into GitHub repository secrets.

## Running

1. Push this repo to GitHub.
2. Open the repository on GitHub.
3. Go to `Actions`.
4. Run `iOS MergeBridge`.
5. The simulator build should run automatically.
6. The signed archive job runs only with `workflow_dispatch` and signing secrets.

## Current Limitation

The workflow uploads an `.xcarchive`. To generate a `.ipa`, add an
`ExportOptions.plist` matching your Apple signing profile and call
`xcodebuild -exportArchive`.
