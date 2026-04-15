# TODO

## MVP — Basic Vim motions

- [x] `j` moves mouse down
- [ ] `h` moves mouse left
- [ ] `k` moves mouse up
- [ ] `l` moves mouse right
- [ ] Define all hjkl keycodes in `main.h`
- [ ] Move keycodes to a dedicated header (noted in `main.h`)

## Motion feel

- [ ] Configurable movement speed (step size, currently hardcoded to 10)
- [ ] Acceleration — hold key to move faster over time
- [ ] Count prefix support (e.g. `5j` moves down 5x the step size)

## Mouse actions

- [ ] Left click
- [ ] Right click
- [ ] Middle click
- [ ] Scroll up/down (`Ctrl-u` / `Ctrl-d` style)

## Mode system (Vim-inspired)

- [ ] Activation key to enter mouse mode (to avoid intercepting all keypresses globally)
- [ ] ESC / deactivation to exit mouse mode and restore normal input
- [ ] Visual indicator (e.g. cursor change or overlay) when in mouse mode

## Advanced motions

- [ ] `gg` / `G` — jump to top/bottom of screen
- [ ] `0` / `$` — jump to left/right edge of screen
- [ ] `H` / `M` / `L` — jump to top/middle/bottom of screen (like Vim screen lines)
- [ ] `/` search — warp to a labeled target on screen (warpd-style)

## Infrastructure

- [ ] Proper `Makefile` / build system
- [ ] Install script
- [ ] Run as a background LaunchAgent (launchd plist)
- [ ] Config file support (speed, keybindings)
