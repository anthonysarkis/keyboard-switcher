<p align="center">
  <img src="docs/images/icon.png" width="128" height="128" alt="Keyboard Switcher icon">
</p>

<h1 align="center">Keyboard Switcher</h1>

<p align="center">
  <strong>The right keyboard in every app and on every website. Automatically.</strong><br>
  A tiny, native menu bar app for people who type in more than one language on a Mac.
</p>

<p align="center">
  <img alt="macOS 14 or later" src="https://img.shields.io/badge/macOS-14%2B-111111?logo=apple">
  <img alt="Swift 6" src="https://img.shields.io/badge/Swift-6-F05138?logo=swift&logoColor=white">
  <img alt="Zero dependencies" src="https://img.shields.io/badge/dependencies-0-2EA44F">
  <img alt="No network access" src="https://img.shields.io/badge/network-none-1F6FEB">
</p>

<p align="center">
  <img src="docs/images/hero.png" width="880" alt="WhatsApp gets Canadian – CSA, VS Code and claude.ai in Chrome get Canadian, and the menu bar badge follows">
</p>

## Sound familiar?

- You reply on WhatsApp in French, but the Mac is still on the English keyboard, so every `é` comes out as `/`.
- You jump back to your code editor and your brackets and slashes turn into accents.
- You press 🌐 or Control-Space dozens of times a day, and still type the first word wrong.

Keyboard Switcher remembers which keyboard belongs where.
The moment an app or a browser tab comes to the front, the right keyboard is already on.

## Features

- **Per app.** WhatsApp in French, VS Code in English, Ghostty in English. Set it once, forget it.
- **Per website.** claude.ai in English and web.whatsapp.com in French, in Chrome, Brave and Safari. The most precise rule wins: a rule for `mail.google.com` beats one for `google.com`.
- **Remembers the rest.** Apps without a rule come back on the last keyboard you used in them.
- **Respects your hands.** Switch by hand and the app either goes back to the rule next time, or makes your pick the new rule. Your choice.
- **Looks like it came with your Mac.** The menu bar badge is drawn by macOS itself, so it matches the Mac's own input menu pixel for pixel: CA filled, CSA outlined, same size, same font.
- **A quiet heads-up.** A small bubble next to your pointer tells you which keyboard just turned on.
- **Private by design.** No network code, no analytics, no account. Your rules are one small JSON file on your Mac.
- **Tiny and native.** About 3,400 lines of Swift, zero dependencies, no Electron. Opens at login and stays out of the way.

## A look inside

| Apps | Websites |
| :---: | :---: |
| <img src="docs/images/settings-apps.png" width="420" alt="Apps tab: WhatsApp on Canadian – CSA, Visual Studio Code and Ghostty on Canadian"> | <img src="docs/images/settings-websites.png" width="420" alt="Websites tab: claude.ai on Canadian, web.whatsapp.com on Canadian – CSA, and the browsers' permission status"> |

Click the badge in the menu bar to change the rule for the app or website you're on, without opening Settings.

## Install

You need macOS 14 Sonoma or later, and Xcode 26 or later (or its Command Line Tools).

```sh
git clone https://github.com/anthonysarkis/keyboard-switcher.git
cd keyboard-switcher
scripts/install.sh
```

- The script builds the app, signs it, puts it in `~/Applications/Keyboard Switcher.app` and opens it.
- To sign with your own certificate, run `SIGNING_IDENTITY="Apple Development: Your Name (TEAMID)" scripts/install.sh`.
- Without a certificate it signs the app "ad hoc": it works the same, but macOS asks again for browser access after each rebuild.
- The first time a website rule meets a browser, macOS asks "Keyboard Switcher wants access to control …". Click Allow: that is how the app reads the address of the current tab, and nothing more.

To uninstall: badge › Quit Keyboard Switcher, delete the app, and delete `~/Library/Application Support/com.anthonysarkis.keyboard-switcher`.

## How it works

1. `NSWorkspace` tells the app which app just came to the front.
2. In a browser, Apple Events read the address of the current tab, twice a second, and only while you have a website rule.
3. The rules decide, in this order: the website rule, then the app's rule, then the last keyboard used in that app.
4. `TISSelectInputSource` switches the keyboard.
   Right after a switch, macOS sometimes puts the previous keyboard back; the app waits 600 ms and switches again if it did.
5. The badge comes from `KLInputSourceIconManager`, the macOS class behind the Mac's own input menu.
   It is a private API: if a macOS update removes it, the app draws the same badge itself.

- Rules live in `~/Library/Application Support/com.anthonysarkis.keyboard-switcher/rules.json`.
- "Open at login" uses Login Items; "Show the Mac's own keyboard icon" flips macOS's own "Show Input menu in menu bar".

## Questions

**Does it work with Firefox?**
App rules do.
Website rules don't yet: Firefox doesn't share the current tab's address with other apps.

**Does it need Accessibility or Screen Recording access?**
No.
The only thing it ever asks for is permission to read the current tab, browser by browser, and only once you add a website rule.

**Will it fight me when I switch by hand?**
No.
It notices the difference between its own switches and yours, and Settings › General decides what happens next.

## Develop

- `swift test`: the rules and the switching engine, with stand-ins for macOS.
- `swift run keyboard-switcher-dev keyboards`: the keyboards turned on in macOS.
- `swift run keyboard-switcher-dev switch-test`: switches to another keyboard and back.
- `swift run keyboard-switcher-dev badges`: checks that macOS draws the badges, and how close the app's own drawing comes.
- `swift run keyboard-switcher-dev snapshots <folder>`: draws the Settings tabs, the badges and the bubbles as PNG files.
- `swift run keyboard-switcher-dev readme-images`: redraws the pictures in this README into `docs/images`.
- Logs: `/usr/bin/log show --last 10m --predicate 'subsystem == "com.anthonysarkis.keyboard-switcher" AND process == "KeyboardSwitcher"'` (in zsh, plain `log` is a different command).
