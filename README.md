# WebSocketClient

WebSocket Client for iOS

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
