# WebSocketClient

WebSocket Client for iOS

<a href="https://apps.apple.com/us/app/simple-websocket-client/id6448638174?itsct=apps_box_badge&amp;itscg=30200" style="display: inline-block; overflow: hidden; border-radius: 13px; width: 250px; height: 83px;"><img src="https://tools.applemediaservices.com/api/badges/download-on-the-app-store/black/en-us?size=250x83&amp;releaseDate=1683331200" alt="Download on the App Store" style="border-radius: 13px; width: 250px; height: 83px;"></a>

## Environment

### Xcode

```command
$ xcodebuild -version
Xcode 27.1
Build version 27A9275
```

### Ruby

```command
$ ruby -v
ruby 4.0.9 (2026-10-23 revision 3e93b23afc) +PRISM [arm64-darwin23]
```

## Setup

```command
$ git clone git@github.com:nnsnodnb/websocket-client-ios.git
$ cd websocket-client-ios
$ xed .
```

## Bump version

Please edit MARKETING_VERSION of `update_app_version` in `fastlane/Fastfile`.

and

```bash
$ bundle exec fastlane update_app_version
```

## License

This software is licensed under the MIT License (See [LICENSE](LICENSE)).
