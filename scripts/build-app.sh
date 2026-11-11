#!/bin/zsh
set -euo pipefail

repository_root="${0:A:h:h}"
cd "$repository_root"

app_name="Keyboard Switcher"
build_folder="$repository_root/build"
app_bundle="$build_folder/$app_name.app"
signing_identity="${SIGNING_IDENTITY:-Apple Development: Anthony Sarkis (NTTP7FGFP2)}"
ad_hoc_identity="-"

if [[ "$signing_identity" != "$ad_hoc_identity" ]] && ! security find-identity -v -p codesigning | grep -qF "\"$signing_identity\""; then
  echo "No \"$signing_identity\" certificate on this Mac: signing ad hoc instead."
  signing_identity="$ad_hoc_identity"
fi

swift build --configuration release --product KeyboardSwitcher
binary_folder="$(swift build --configuration release --show-bin-path)"

mkdir -p "$build_folder"
icon_file="$build_folder/AppIcon.icns"
if [[ ! -f "$icon_file" || scripts/make-icon.swift -nt "$icon_file" ]]; then
  swift scripts/make-icon.swift "$build_folder"
fi

rm -rf "$app_bundle"
mkdir -p "$app_bundle/Contents/MacOS" "$app_bundle/Contents/Resources"
cp "$binary_folder/KeyboardSwitcher" "$app_bundle/Contents/MacOS/KeyboardSwitcher"
cp App/Info.plist "$app_bundle/Contents/Info.plist"
cp "$icon_file" "$app_bundle/Contents/Resources/AppIcon.icns"

codesign --force --options runtime --timestamp=none \
  --entitlements App/KeyboardSwitcher.entitlements \
  --sign "$signing_identity" \
  "$app_bundle"
codesign --verify --strict "$app_bundle"

echo "Built $app_bundle"
