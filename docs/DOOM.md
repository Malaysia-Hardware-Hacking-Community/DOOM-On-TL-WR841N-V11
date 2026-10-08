# DOOM on the Router — Controls

`http://192.168.1.1:8000/` (or whatever LAN IP the router has) opens a
canvas that streams rendered frames over WebSocket and sends key events
back. Works from a desktop browser (keyboard) or a phone (on-screen
touch buttons render automatically on narrow/touch screens).

## Keyboard

| Key | Action | Internal DOOM keycode |
|---|---|---|
| `↑` / `W` | Move forward | `KEY_UPARROW` (0xad / 173) |
| `↓` / `S` | Move backward | `KEY_DOWNARROW` (0xaf / 175) |
| `←` / `A` | Turn left | `KEY_LEFTARROW` (0xac / 172) |
| `→` / `D` | Turn right | `KEY_RIGHTARROW` (0xae / 174) |
| `Q` | Strafe left | `KEY_STRAFE_L` (0xa0 / 160) |
| `R` | Strafe right | `KEY_STRAFE_R` (0xa1 / 161) |
| `E` | Use (open doors, switches) | `KEY_USE` (0xa2 / 162) |
| `Space` | Fire | `KEY_FIRE` (0xa3 / 163) |
| `Tab` | Toggle automap | `KEY_TAB` (9) |
| `Enter` | Menu / confirm | `KEY_ENTER` (13) |
| `Esc` | Menu / back | `KEY_ESCAPE` (27) |
| `Y` | **Confirm "Quit DOOM?" / other menu Yes prompts** | `key_menu_confirm` (`'y'` / 121) |
| `N` | Cancel "Quit DOOM?" / other menu No prompts | `key_menu_abort` (`'n'` / 110) |

These are the **only** keys this web page listens for — defined in
`doomgeneric_mips.c`'s `onkeydown`/`onkeyup` handlers:
```js
var k = {38:173, 40:175, 37:172, 39:174, 87:173, 83:175, 65:172, 68:174,
         81:160, 82:161, 69:162, 32:163, 27:27, 13:13, 9:9, 89:121, 78:110};
```
Any key not in that map (including letters used for vanilla DOOM cheat
codes — `IDDQD`, `IDKFA`, `IDCLIP`, `IDCLEV##`, etc.) is simply never sent
to the engine. Cheats won't work through this interface; they'd require
adding those letter keys to the JS map and rebuilding.

> **Fixed bug:** `Y`/`N` (89/78) weren't in the original keymap. DOOM's
> quit confirmation (`Esc` → `Quit` → "are you sure? y/n") calls
> `M_QuitResponse()`, which checks the raw key against
> `key_menu_confirm`/`key_menu_abort` — literal ASCII `'y'`/`'n'`
> (`m_controls.c`), not a menu-navigable option. Without those two keys
> wired up in the JS map, the confirmation prompt could never be answered
> and the game appeared stuck unable to quit. Fixed by adding `89:121` and
> `78:110` to the map above (and rebuilding/redeploying).

## Touch controls (phone / tablet, no keyboard needed)

Rendered automatically by the same page — five on-screen buttons:

| Button | Action |
|---|---|
| **UP** / **DN** | Move forward / backward |
| **LT** / **RT** | Turn left / right |
| **FIRE** | Fire |
| **USE** | Use |
| **MAP** | Toggle automap |

No strafe button is exposed on touch — only via `Q`/`R` on a keyboard.

## Weapon switching

Not bound at all in this build — there's no number-key (`1`-`7`) handling
in the JS keymap, so weapon switching relies on whatever DOOM auto-selects
on pickup. This is a reasonable thing to extend (see "Extending the
keymap" below) if you want manual weapon select for a demo.

## Extending the keymap

To add a key (e.g. a cheat code letter, or number-key weapon select), edit
the `k = {...}` object and the `window.onkeydown`/`onkeyup` handlers in
`doom/source/doomgeneric/doomgeneric_mips.c`, then rebuild per `CHEATSHEET.md` §1 and
redeploy per §6-7. The browser-side JS only forwards `(pressed, keycode)`
pairs over the WebSocket — all actual key semantics live in the engine via
`doomgeneric_ProcessKey()`, so new JS key entries just need a valid
`doomkeys.h` constant on the right-hand side.
