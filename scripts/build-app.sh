#!/bin/zsh
set -euo pipefail

repository_root="${0:A:h:h}"
cd "$repository_root"

app_name="Keyboard Switcher"
build_folder="$repository_root/build"
app_bundle="$build_folder/$app_name.app"
app_binary="$app_bundle/Contents/MacOS/KeyboardSwitcher"
ad_hoc_identity="-"
developer_id_prefix="Developer ID Application"
apple_development_prefix="Apple Development"
is_release=false

for argument in "$@"; do
  case "$argument" in
    --release) is_release=true ;;
    *)
      echo "Usage: scripts/build-app.sh [--release]"
      exit 64
      ;;
  esac
done

installed_identities="$(security find-identity -v -p codesigning)"

first_identity_named() {
  local prefix="$1"
  print -r -- "$installed_identities" | sed -n "s/^.*\"\($prefix: .*\)\"\$/\1/p" | head -n 1
}

signing_identity="${SIGNING_IDENTITY:-}"
if [[ -z "$signing_identity" ]]; then
  signing_identity="$(first_identity_named "$developer_id_prefix")"
fi
if [[ -z "$signing_identity" && "$is_release" == false ]]; then
  signing_identity="$(first_identity_named "$apple_development_prefix")"
fi
if [[ -z "$signing_identity" && "$is_release" == false ]]; then
  signing_identity="$ad_hoc_identity"
fi

if [[ "$is_release" == true && "$signing_identity" != "$developer_id_prefix: "* ]]; then
  echo "A release needs a \"$developer_id_prefix\" certificate."
  echo "Make one in Xcode › Settings › Accounts › Manage Certificates › + › $developer_id_prefix."
  exit 1
fi

if [[ "$signing_identity" != "$ad_hoc_identity" ]] && ! print -r -- "$installed_identities" | grep -qF "\"$signing_identity\""; then
  echo "No \"$signing_identity\" certificate on this Mac."
  exit 1
fi

if [[ "$is_release" == true ]]; then
  build_options=(--configuration release --product KeyboardSwitcher --arch arm64 --arch x86_64)
  timestamp_option="--timestamp"
else
  build_options=(--configuration release --product KeyboardSwitcher)
  timestamp_option="--timestamp=none"
fi

swift build "${build_options[@]}"
binary_folder="$(swift build "${build_options[@]}" --show-bin-path)"

mkdir -p "$build_folder"
icon_file="$build_folder/AppIcon.icns"
if [[ ! -f "$icon_file" || scripts/make-icon.swift -nt "$icon_file" ]]; then
  swift scripts/make-icon.swift "$build_folder"
fi

rm -rf "$app_bundle"
mkdir -p "$app_bundle/Contents/MacOS" "$app_bundle/Contents/Resources"
cp "$binary_folder/KeyboardSwitcher" "$app_binary"
cp App/Info.plist "$app_bundle/Contents/Info.plist"
cp "$icon_file" "$app_bundle/Contents/Resources/AppIcon.icns"

codesign --force --options runtime "$timestamp_option" \
  --entitlements App/KeyboardSwitcher.entitlements \
  --sign "$signing_identity" \
  "$app_bundle"
codesign --verify --strict "$app_bundle"

architectures="$(lipo -archs "$app_binary")"
if [[ "$is_release" == true && ( "$architectures" != *arm64* || "$architectures" != *x86_64* ) ]]; then
  echo "A release needs Apple Silicon and Intel in one app, but it only has: $architectures"
  exit 1
fi

echo "Built $app_bundle"
echo "Chips: $architectures"
echo "Signed: $signing_identity"
