# WebSocketClient

WebSocket Client for iOS

<a href="https://apps.apple.com/us/app/simple-websocket-client/id6448638174?itsct=apps_box_badge&amp;itscg=30200" style="display: inline-block; overflow: hidden; border-radius: 13px; width: 250px; height: 83px;"><img src="https://tools.applemediaservices.com/api/badges/download-on-the-app-store/black/en-us?size=250x83&amp;releaseDate=1683331200" alt="Download on the App Store" style="border-radius: 13px; width: 250px; height: 83px;"></a>

## Environment

### Xcode

```command
$ xcodebuild -verison
Xcode 14.2
Build version 14C18
```

### Ruby

```command
$ ruby -v
ruby 3.2.0 (2022-12-25 revision a528908271) [arm64-darwin21]
```

## Setup

```command
$ git clone git@github.com:nnsnodnb/websocket-client-ios.git
$ cd websocket-client-ios
$ xed .
```

## Tests

This project needs fastlane.

```command
$ gem install bunder -v "$(tail -n 1 Gemfile.lock | sed -r 's/ //g')"
$ bundle config set './vendor/bundle'
$ bundle install --jobs 3
$ bundle exec fastlane ios test
```

## License

This software is licensed under the MIT License (See [LICENSE](LICENSE)).
