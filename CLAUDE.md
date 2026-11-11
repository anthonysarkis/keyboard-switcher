# Keyboard Switcher

- Mac menu bar app: switches the keyboard (input source) per app and per website.
- Swift package, Swift 6 with main-actor default isolation, no dependencies, macOS 14+.

## Commands

- Test: `swift test`
- Build the signed app: `scripts/build-app.sh` → `build/Keyboard Switcher.app`
- Install and relaunch: `scripts/install.sh` → `~/Applications/Keyboard Switcher.app`
- Dev checks: `swift run keyboard-switcher-dev keyboards | switch-test | badges | snapshots <folder>`
- Check UI changes with `snapshots`, then read the PNGs.
- README pictures: `swift run keyboard-switcher-dev readme-images` redraws `docs/images` (hero + Settings tabs); `docs/images/icon.png` is `build/AppIcon.iconset/icon_256x256@2x.png`.

## Conventions

- No comments and no doc comments: names, small functions and blank lines carry the meaning.
- One type per file, grouped in feature folders.
- Full names, no abbreviations; named closure parameters instead of `$0`.
- Bind a call's result to a named value before passing it to another call, string interpolation included.

## Layout

- `Sources/KeyboardSwitcherCore`: pure rules logic, fully tested.
  - `Keyboards/`, `Rules/`, `Websites/`, `Resolution/` (rule sources and the resolver), `Storage/` (rules.json).
- `Sources/KeyboardSwitcherKit`: the macOS parts.
  - `Switching/`: `SwitchCoordinator` turns events into switches; `ManualSwitchDetector` tells your switches from the app's.
  - `Keyboards/` (`KeyboardCatalog`, Text Input Sources), `Rules/` (`RuleBook`), `Browsers/` (`BrowserTabTracker`, tab reading, permissions), `Apps/`.
  - `Badge/`: the badge images, shared by the menu bar and the bubble: `MacBadgeImages` (drawn by macOS) with `DrawnBadgeImages` as the fallback.
  - `MenuBar/`, `Bubble/`, `Settings/`, `System/` (Login Items, the Mac's own icon), `Labels/`, `Logging/`.
  - `App/`: `AppServices` (everything that talks to macOS), `AppContext` (the object graph), `AppDelegate`.
- `Sources/KeyboardSwitcherFakes`: stand-ins for macOS, shared by the tests and the snapshot tool.
- `App/`: Info.plist and entitlements, copied into the bundle by the build script.

## Extending

- New kind of rule: a `KeyboardRuleSource` in `Resolution/`, listed in `RuleResolver.standard` at its priority.
- New browser: one line in `SupportedBrowser.all`; its family picks the AppleScript.
- New settings tab: a view in `Settings/`, listed in `SettingsWindowController.tabs`.
- New macOS connection: a protocol plus a live class in `AppServices.live`, and a fake in `KeyboardSwitcherFakes`.

## Gotchas

- Keyboard change notices need `.deliverImmediately`; a menu bar app is never active, so macOS would hold them.
- Always sign with the same Apple Development identity, or macOS forgets the browsers' "Allow".
- Never let a tab read trigger macOS's "allow" question: reads time out after 1 second, which closes the question, and the next read opens a new one. Ask with `BrowserTabTracker.requestPermission` (off the main thread, one at a time) and read tabs only when allowed.
- Tabs are read only while a website rule exists, or once when the badge menu opens in a browser.
- Right after a switch, macOS can put back the previous app's keyboard for 20 to 60 ms: `ManualSwitchDetector` ignores changes for 600 ms after each switch, then the coordinator re-selects once if needed.
- `RuleBook.recordManualSwitch` must not announce an edit, or the app's rule would undo the switch you just made.
- Safari in /Applications is a symlink: resolve it before asking for its icon, or the icon gets an alias arrow.
- Badges come from macOS's private `KLInputSourceIconManager` (KeyboardLayouts framework), the drawer behind the Mac's own input menu, so they match it pixel for pixel.
- Outlined capsules use `Capsule(style: .circular)`: `strokeBorder` on the default continuous capsule draws stray vertical lines past its ends.
- Snapshots can't show switches in their "on" colour (that needs a real front window), so README pictures skip the General tab.
- `useRoundCorenr:` in `InputSourceIconManaging` is Apple's own spelling: keep the typo, or the call stops matching.
- Which badge is filled depends on every keyboard that is on (Canadian alone shows "A"): rebuild all badges when the keyboard list changes, never one at a time.
- If a macOS update removes that drawer, `DrawnBadgeImages` takes over with the measured look: 22 × 16 pt, 5 pt corners, SF semibold 11 pt, narrowed (wdth 65, opsz 16) when the letters don't fit.
- `swift run keyboard-switcher-dev badges` says whether macOS still draws them and how far the fallback is (CSA identical, CA about 0.1 pt to the left).
