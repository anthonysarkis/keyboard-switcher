#!/bin/zsh
set -euo pipefail

repository_root="${0:A:h:h}"
cd "$repository_root"

app_name="Keyboard Switcher"
app_bundle="$repository_root/build/$app_name.app"
release_folder="$repository_root/build/release"
upload_zip="$release_folder/notary-upload.zip"
notary_answer="$release_folder/notary-answer.json"
release_zip="$release_folder/Keyboard-Switcher.zip"
notary_profile="${NOTARY_PROFILE:-notary}"
version="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' App/Info.plist)"
tag="v$version"

if [[ -n "$(git status --porcelain)" ]]; then
  echo "Commit your changes first: each release is built from a commit on GitHub."
  exit 1
fi

git fetch --quiet origin
release_commit="$(git rev-parse HEAD)"
if ! git merge-base --is-ancestor "$release_commit" origin/main; then
  echo "Push $release_commit to main first: GitHub needs the code each release is built from."
  exit 1
fi

if git ls-remote --exit-code --tags origin "refs/tags/$tag" >/dev/null; then
  echo "$tag is already out: raise CFBundleShortVersionString and CFBundleVersion in App/Info.plist."
  exit 1
fi

if ! xcrun notarytool history --keychain-profile "$notary_profile" >/dev/null 2>&1; then
  echo "No working notary login named \"$notary_profile\" in your keychain. Save one with:"
  echo "xcrun notarytool store-credentials $notary_profile --apple-id <your Apple ID> --team-id <your team ID>"
  exit 1
fi

scripts/build-app.sh --release

rm -rf "$release_folder"
mkdir -p "$release_folder"
ditto -c -k --keepParent "$app_bundle" "$upload_zip"

echo "Apple is checking the app. It usually takes a few minutes."
if ! xcrun notarytool submit "$upload_zip" --keychain-profile "$notary_profile" --wait --output-format json > "$notary_answer"; then
  echo "notarytool stopped early:"
  cat "$notary_answer"
fi
submission_id="$(plutil -extract id raw "$notary_answer")"
notary_status="$(plutil -extract status raw "$notary_answer")"
if [[ "$notary_status" != "Accepted" ]]; then
  xcrun notarytool log "$submission_id" --keychain-profile "$notary_profile"
  echo "Apple answered \"$notary_status\" for submission $submission_id."
  exit 1
fi
echo "Apple accepted submission $submission_id."

xcrun stapler staple "$app_bundle"
xcrun stapler validate "$app_bundle"
spctl --assess --type execute --verbose=2 "$app_bundle"
syspolicy_check distribution "$app_bundle"

rm "$upload_zip"
ditto -c -k --keepParent "$app_bundle" "$release_zip"
release_checksum="$(shasum -a 256 "$release_zip" | cut -d ' ' -f 1)"

release_notes="**Download Keyboard-Switcher.zip below**, open it, and drag Keyboard Switcher to your Applications folder.
Then open it: its badge shows up in the menu bar.
Or with Homebrew: \`brew install --cask anthonysarkis/tap/keyboard-switcher\`

- Needs macOS 14 or later, on Apple Silicon or Intel.
- Signed with a Developer ID and notarized by Apple.
- SHA-256 of the zip: \`$release_checksum\`"

gh release create "$tag" "$release_zip" \
  --target "$release_commit" \
  --title "$app_name $version" \
  --notes "$release_notes" \
  --generate-notes
git fetch --quiet --tags origin

release_page="$(gh release view "$tag" --json url --jq .url)"
echo "Released $tag: $release_page"
echo "SHA-256: $release_checksum"

scripts/update-homebrew-cask.sh "$version"
