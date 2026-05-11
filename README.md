# neomouse

A keyboard-driven mouse control daemon for macOS, inspired by [warpd](https://github.com/rvaiya/warpd) but built around true Vim motions.

The goal is to feel like you never left Vim — mouse control that maps naturally to muscle memory.

## How it works

`neomouse` is a SwiftUI macOS app that installs a global event monitor to intercept keyboard events and translate Vim motions into mouse movements and gestures. It uses [GRDB](https://github.com/groue/GRDB.swift) for local session state.

## Requirements

- macOS 13 (Ventura) or later
- Swift 6.3+ toolchain (Xcode 16 or `swift --version` ≥ 6.3)
- Accessibility permissions (granted on first run)

## Build

```sh
# Debug build
swift build

# Release build
swift build -c release
```

The release binary is written to `.build/release/neomouse`.

## Run

```sh
swift run -c release
# or directly:
.build/release/neomouse
```

> macOS will prompt for Accessibility permissions on first launch. Grant them in **System Settings → Privacy & Security → Accessibility**, then relaunch.

## Install (optional)

Copy the release binary somewhere on your `PATH`:

```sh
swift build -c release
cp .build/release/neomouse /usr/local/bin/
```

## Project structure

```
Package.swift                — SwiftPM manifest
Sources/neomouse/            — app sources
  swift.swift                — @main entry point, event monitors, app state
  mode.swift                 — mode definitions (normal, visual, find, …)
  operation.swift            — keymap → operation dispatch
  undotree.swift             — undo/redo state
  ui/                        — SwiftUI overlays (command line, keycast)
  utils/                     — helpers (mouse, screen, window, gestures, …)
  database/                  — GRDB session store
Tests/neomouseTests/         — unit tests
```

## Status

Active development. See [TODO.md](TODO.md) for the roadmap.
