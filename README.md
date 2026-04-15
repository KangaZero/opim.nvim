# neowarpd

A keyboard-driven mouse control daemon for macOS, inspired by [warpd](https://github.com/rvaiya/warpd) but built around true Vim motions.

The goal is to feel like you never left Vim — mouse control that maps naturally to muscle memory.

## How it works

`neowarpd` installs a system-wide `CGEventTap` that intercepts keyboard events and translates Vim motions into mouse movements, without the key presses reaching other applications.

## Building

```sh
# Debug build (enables debug logging)
gcc -DDEBUG main.c -framework ApplicationServices -o mouse

# Release build
gcc main.c -framework ApplicationServices -o mouse
```

> macOS will prompt for Accessibility permissions on first run. Grant them in **System Settings → Privacy & Security → Accessibility**.

## Usage

```sh
./mouse
```

Once running, use Vim motions to move the mouse:

| Key | Action          |
|-----|-----------------|
| `h` | Move left       |
| `j` | Move down       |
| `k` | Move up         |
| `l` | Move right      |

## Project structure

```
main.c          — entry point, event tap setup and callback
main.h          — key code definitions and debug flag
utils/debug.c   — timestamped debug logging (compile with -DDEBUG to enable)
```

## Debugging

The `debug()` function in `utils/debug.c` is a no-op unless `DEBUG` is defined. Either compile with `-DDEBUG` or add `#define DEBUG` in `main.h` (already present for dev builds).
