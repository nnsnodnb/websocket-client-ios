# WebSocketClient

WebSocket Client for iOS

<a href="https://apps.apple.com/us/app/simple-websocket-client/id6448638174?itsct=apps_box_badge&amp;itscg=30200" style="display: inline-block; overflow: hidden; border-radius: 13px; width: 250px; height: 83px;"><img src="https://tools.applemediaservices.com/api/badges/download-on-the-app-store/black/en-us?size=250x83&amp;releaseDate=1683331200" alt="Download on the App Store" style="border-radius: 13px; width: 250px; height: 83px;"></a>

## Environment

### Xcode

```command
$ xcodebuild -version
Xcode 26.2
Build version 17C52
```

### Ruby

```command
$ ruby -v
ruby 3.4.8 (2025-12-17 revision 995b59f666) +PRISM [arm64-darwin25]
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
