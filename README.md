# SwiftFFmpeg

A Swift wrapper for the FFmpeg API

## Installation

You should install [FFmpeg](http://ffmpeg.org/) before use this library, on macOS, you can:

```bash
brew install ffmpeg
```

### Swift Package Manager

SwiftFFmpeg primarily uses [SwiftPM](https://swift.org/package-manager/) as its build tool, so we recommend using that as well. If you want to depend on SwiftFFmpeg in your own project, it's as simple as adding a `dependencies` clause to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/sunlubo/SwiftFFmpeg.git", from: "1.0.0")
]
```
