# Keyboard Switcher

A Mac menu bar app that picks the keyboard for each app and each website, by itself.

- WhatsApp gets Canadian – CSA; VS Code and Ghostty (where Claude Code runs) get Canadian.
- In Chrome, Brave and Safari, a website can have its own keyboard (claude.ai, web.whatsapp.com…).
- Apps without a rule come back on the last keyboard you picked in them by hand.
- The badge in the menu bar shows the keyboard that is on (CA filled, CSA outlined); click it to change the rule for the app or site you're on.
- macOS draws that badge itself, so it looks exactly like the Mac's own input menu.

## Install

- `scripts/install.sh` builds the app, signs it and opens `~/Applications/Keyboard Switcher.app`.
- macOS asks once per browser ("Keyboard Switcher wants access to control …"): the first time you use that browser with a website rule, or when you click Allow in the badge menu or Settings › Websites. Click Allow.
- To quit: badge › Quit Keyboard Switcher. Opening the app again (Spotlight, Finder) opens Settings.

## How it works

1. `NSWorkspace` tells the app which app just came to the front.
2. In a browser, Apple Events read the address of the current tab, twice a second while the browser is in front.
3. The rules decide, in this order: website rule, then the app's rule, then the last one used.
4. `TISSelectInputSource` switches the keyboard, and the badge updates with the image macOS draws for that keyboard.

- Rules live in `~/Library/Application Support/com.anthonysarkis.keyboard-switcher/rules.json`.
- "Open at login" uses Login Items; "Show the Mac's own keyboard icon" flips macOS's own "Show Input menu in menu bar".

## Develop

- `swift test`: the rules and the engine, with stand-ins for macOS.
- `swift run keyboard-switcher-dev keyboards`: the keyboards turned on in macOS.
- `swift run keyboard-switcher-dev switch-test`: switches to another keyboard and back.
- `swift run keyboard-switcher-dev badges`: checks that macOS draws the badges, and how close the app's own drawing comes.
- `swift run keyboard-switcher-dev snapshots <folder>`: draws the Settings tabs, the badges and the bubbles as PNG files.
- Logs: `/usr/bin/log show --last 10m --predicate 'subsystem == "com.anthonysarkis.keyboard-switcher" AND process == "KeyboardSwitcher"'` (the tests log under the same subsystem; the process filter keeps only the app; in zsh, plain `log` is a different command).
