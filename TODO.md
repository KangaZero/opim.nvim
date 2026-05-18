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

Motions That Add to Jump List
Line-based large motions

gg — go to first line
G — go to last line
{number}G — go to specific line
{number}gg — go to specific line
H — go to top of screen
M — go to middle of screen
L — go to bottom of screen
{ — jump to previous empty line (paragraph back)
} — jump to next empty line (paragraph forward)
( — jump to previous sentence
) — jump to next sentence
[[ — jump to previous { in column 0
]] — jump to next { in column 0
[] — jump to previous } in column 0
][ — jump to next } in column 0

Search

/pattern — search forward
?pattern — search backward
n — repeat last search forward
N — repeat last search backward
* — search word under cursor forward
# — search word under cursor backward
g* — like * but partial match
g# — like # but partial match

Marks

`a — jump to exact position of mark a (any letter)
'a — jump to line of mark a (any letter)
`. — jump to position of last change
'. — jump to line of last change
`^ — jump to last insert position
`[ — jump to start of last yanked/changed text
`] — jump to end of last yanked/changed text
`< — jump to start of last visual selection
`> — jump to end of last visual selection
    — jump to position before last jump (itself a jump)
'' — jump to line before last jump

Bracket/tag matching

% — jump to matching bracket, paren, brace, or #if/#endif
[{ — jump to unclosed { above
]} — jump to unclosed } below
[( — jump to unclosed ( above
]) — jump to unclosed ) below

Tag navigation

Ctrl-] — jump to tag under cursor
Ctrl-T — jump back from tag (also pops tag stack)
:tag {name} — jump to tag by name
:tags — not a jump, just lists the tag stack


Ex Commands That Add to Jump List

:line — e.g. :42 jumps to line 42
:/{pattern} — search via ex
:?{pattern} — search backward via ex
:edit {file} / :e — opening a file
:buffer {n} / :b — switching buffers
:bnext / :bprev / :bfirst / :blast
:grep / :vimgrep followed by jumping to results
:cnext / :cprev / :cc — quickfix navigation
:lnext / :lprev / :ll — location list navigation
:make result jumps


Window/File Actions That Add to Jump List

Ctrl-W Ctrl-] — open tag in new split (adds to jump list in new window)
gf — go to file under cursor
gF — go to file + line number under cursor
Ctrl-^ / Ctrl-6 — alternate file (last edited buffer)


Jump List Navigation Itself

Ctrl-O — jump to older position (moves cursor back)
Ctrl-I / Tab — jump to newer position (moves cursor forward)
These do not add new entries but do move the cursor pointer, which affects where truncation happens if you then make a new jump


What Explicitly Does NOT Add to Jump List
MotionWhy excludedh j k lToo granularw b e ge W B EWord motions, considered small0 ^ $Line-internal onlyf F t TCharacter search, in-line; ,Repeat of f/F/t/T+ - _Line motions but not "jumps"zz zt zbScrolling, no cursor line changeCtrl-D Ctrl-UScroll — no jump entryCtrl-F Ctrl-BPage scroll — no jump entryi a o etcInsert mode entryx X d c etcEdits without separate jump

Notes on Entries That Alter the List

Truncation — any new jump while not at the newest entry discards everything forward
Deduplication — Vim may merge consecutive entries pointing to the same location
Per-window — each window (Ctrl-W split) has its own independent jump list
Size limit — capped at 100 entries by default; oldest entries fall off when full
:clearjumps — wipes the entire jump list for the current window
