# Keyboard Switcher

- Mac menu bar app: switches the keyboard (input source) per app and per website.
- Swift package, Swift 6 with main-actor default isolation, no dependencies, macOS 14+.

## Commands

- Test: `swift test`
- Build the signed app: `scripts/build-app.sh` → `build/Keyboard Switcher.app` (this Mac's chip only)
- Install and relaunch: `scripts/install.sh` → `~/Applications/Keyboard Switcher.app`
- Release: raise `CFBundleShortVersionString` and `CFBundleVersion` in `App/Info.plist`, commit, push, then `scripts/release.sh`.
  - It runs `scripts/build-app.sh --release` (Apple Silicon + Intel, Developer ID, Apple's timestamp), sends the zip to Apple's notary service, staples the ticket and publishes `Keyboard-Switcher.zip` as GitHub release `v<version>`.
  - Then `scripts/update-homebrew-cask.sh` points the cask (`Casks/keyboard-switcher.rb` in `anthonysarkis/homebrew-tap`) at that zip: version and SHA-256 of the published file.
  - Needs the "Developer ID Application" certificate and the notary login saved in the keychain as `notary` (`xcrun notarytool store-credentials notary`).
  - The README's download link is `releases/latest/download/Keyboard-Switcher.zip`: keep that file name.
- Dev checks: `swift run keyboard-switcher-dev keyboards | switch-test | badges | snapshots <folder>`
- Check UI changes with `snapshots`, then read the PNGs.
- README pictures: `swift run keyboard-switcher-dev readme-images` redraws `docs/images`: the hero, websites and languages animations (SVG, light and dark) and the Settings tabs.
  - The example (VS Code in English, WhatsApp in French, Teams in Spanish, Claude in Russian, three websites, the typed messages) lives in `ReadmeExample`.
  - `ReadmeExample.macBadges` holds macOS's own badge for each keyboard; the command stops if one no longer matches macOS pixel for pixel.
  - The bubble's size, place and timing come from `BubbleMetrics`, the numbers the app itself uses.
  - GitHub shows README SVGs as images under `default-src 'none'`: CSS keyframes only, no scripts, no outside files, every picture embedded as PNG.
  - No live blur in the SVGs (browsers repaint it every frame): shadows are drawn ahead as PNGs by `ShadowPainter`.
  - Measure text at the font size the SVG writes (2 decimals): CoreText widths differ between 14.4 and 12 × 1.2.
  - App icons come from `docs/app-icons`, not this Mac, so the pictures look the same on any Mac; the Apps tab gets them through `appIconOverrides`.
  - `docs/images/icon.png` is `build/AppIcon.iconset/icon_256x256@2x.png`.
- README language table: `swift run keyboard-switcher-dev languages` prints it from macOS; paste it over the table in README.md.
  - Each language gets its likely country's flag; languages spoken across borders (Kurdish, Uyghur, Tibetan, Rohingya…) keep 🌐 on purpose.

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
  - `Keyboards/` (`KeyboardCatalog`, Text Input Sources), `Rules/` (`RuleBook`), `Browsers/` (`BrowserTabTracker`, tab reading, permissions), `WebsiteIcons/` (`WebsiteIconStore`, each site's own icon), `Apps/`.
  - `Badge/`: the badge images, shared by the menu bar and the bubble: `MacBadgeImages` (drawn by macOS) with `DrawnBadgeImages` as the fallback.
  - `MenuBar/`, `Bubble/`, `Settings/`, `System/` (Login Items, the Mac's own icon), `Labels/`, `Logging/`.
  - `App/`: `AppServices` (everything that talks to macOS), `AppContext` (the object graph), `AppDelegate`.
- `Sources/KeyboardSwitcherFakes`: stand-ins for macOS, shared by the tests and the snapshot tool.
- `App/`: Info.plist and entitlements, copied into the bundle by the build script.

## Extending

- New kind of rule: a `KeyboardRuleSource` in `Resolution/`, listed in `RuleResolver.standard` at its priority.
- New browser: one line in `SupportedBrowser.all`; its family picks the Apple Event codes (`TabAddressCodes`, from the browser's `sdef`).
- New settings tab: a view in `Settings/`, listed in `SettingsWindowController.tabs`.
- New setting: a row in General's one list (one `Section`, never groups); an on/off choice is a switch, and if its effect isn't obvious, a second `Text` in its label says what happens, one sentence per line.
- New macOS connection: a protocol plus a live class in `AppServices.live`, and a fake in `KeyboardSwitcherFakes`.

## Gotchas

- Keyboard change notices need `.deliverImmediately`; a menu bar app is never active, so macOS would hold them.
- Always sign with the same identity, or macOS forgets the browsers' "Allow": the build script picks Developer ID first, then Apple Development, then ad hoc (`SIGNING_IDENTITY` overrides).
- `syspolicy_check notary-submission` rejects every app Apple hasn't notarized yet ("Gatekeeper rejected this file"), so the release script relies on the notary service's own log instead.
- Never let a tab read open macOS's "allow" question: the read times out after 1 second, which closes it, and the next read opens a new one. Reads send `kAEDoNotPromptForUserConsent`; ask with `BrowserTabTracker.requestPermission` (off the main thread, one at a time) and read tabs only when allowed.
- Tabs are read only when needed: twice a second while `RuleBook.needsTabAddresses` (a website rule exists, or « Every site you visit »), once at each switch by hand in a browser, and once when the badge menu opens in one.
- Tab reads never run on the main thread: `AppleEventTabReader` sends the Apple Event from a background queue, so a frozen browser can't freeze the app.
- Entering a browser waits up to `firstTabReadPatience` (0.2 s) for the first read, so it switches once, straight to the site's keyboard. Past that, the app rule applies and the late answer still switches to the site.
- `BrowserTabTracker.track` counts each start (`trackingCount`): an answer from a browser you already left is dropped.
- The badge menu rebuilds when its tab read lands, if it is still open (`StatusItemController.isMenuShowing`).
- In zsh, `log` is a built-in: read the app's log with `/usr/bin/log show --predicate 'process == "KeyboardSwitcher"'`.
- Website icons come from the site itself (`LinkPresentationIconFetcher`), never a favicon service, which would learn the whole list. That is the app's only network use: say so in the README if that changes.
- `WebsiteIconStore` follows `RuleBook.onWebsiteListChange`: icons live in `Application Support/<bundle id>/Website Icons/<site>.png` (96 px at most, uncropped), are asked again after 30 days, and a site without one is asked again at most every 5 minutes, when its row shows.
- LinkPresentation answers on a background queue: use its `async` call, or `@Sendable` closures in `nonisolated` code, never a closure written under the main actor (Swift 6 stops the app).
- `WebsiteIconView` copies the app icons beside it, measured on Chrome's icon at 2x: 20 pt body, 4.5 pt continuous corners, raised 0.5 pt, shadow 36 % black, 1 pt blur, 0.5 pt down. Logos (under 90 % opaque) are cropped to what shows on white and drawn once on a white square, so every icon is one opaque square.
- README pictures take website icons from `docs/website-icons/`; refresh them with `swift run keyboard-switcher-dev website-icons docs/website-icons <every README site>` (that folder keeps only the sites named).
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
- New users start with an empty list. `SampleRules` in `KeyboardSwitcherFakes` (WhatsApp, VS Code, Ghostty) is test and preview data only: never ship it as a starting list.
- Settings › General has two « Remember » menus with the same 3 choices (`RememberingMode`): every one / ones you switch language on / only ones you add. Defaults: « Every app you open » and « Sites you switch language on ». Older files' on/off switch maps to those defaults (off → only ones you add).
- An app outside the list joins it with the keyboard it had when it first comes to the front (`AppEntryPolicy`: regular apps only, « Every app you open »). During a switch's settle window that is the keyboard being switched to, not the one macOS briefly puts back. A switch by hand adds an app too, unless « Only apps you add ».
- A switch by hand on a site adds or updates that site (`ManualSwitchPolicy`), never the browser, unless « Only sites you add ». The coordinator reads the tab fresh at that moment and records once the answer lands (`manualSwitchRecording`): when the app isn't following tabs, its last known site can be stale. If the browser hasn't been asked yet, it asks and keeps that first pick for the browser, so the answer can't undo it.
- « Every site you visit » (`WebsiteVisitPolicy`) is the only choice that follows tabs without website rules (`RuleBook.needsTabAddresses`).
- There is one list: older files' hidden `lastUsedByApp` memory moves into it when the file opens (`moveRememberedAppsIntoTheList`), and nothing writes that memory any more.
- The Apps and Websites tabs have a fixed height and scroll (`settingsListTabFrame`), so adding or removing a row animates in place and never resizes the window; README pictures set `fitsSettingsListsToContent` to size those tabs to their rows.
- Both lists show A→Z (`appRulesByName`, `websiteRulesByAddress`), with their add button on top; rules.json keeps the order they were added.
- `scripts/install.sh` waits until LaunchServices forgets the killed app (`lsappinfo find`): opening too soon fails with -600 (procNotFound) and leaves the app closed.
