#!/bin/zsh
set -euo pipefail

repository_root="${0:A:h:h}"
cd "$repository_root"

homebrew_tap="anthonysarkis/homebrew-tap"
cask_path="Casks/keyboard-switcher.rb"
release_asset="Keyboard-Switcher.zip"
version="${1:-$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' App/Info.plist)}"
tag="v$version"

if ! gh api "repos/$homebrew_tap" --silent 2>/dev/null; then
  echo "No Homebrew tap at $homebrew_tap yet: the cask is not updated."
  exit 0
fi

author_name="$(git config user.name)"
author_email="$(git config user.email)"
if [[ "$author_email" != *@users.noreply.github.com ]]; then
  echo "Set this repo's git email to your GitHub noreply address first, so the cask commit doesn't show your personal email."
  exit 1
fi

download_folder="$(mktemp -d)"
trap 'rm -rf "$download_folder"' EXIT
gh release download "$tag" --pattern "$release_asset" --dir "$download_folder"
release_checksum="$(shasum -a 256 "$download_folder/$release_asset" | cut -d ' ' -f 1)"

cask_blob="$(gh api "repos/$homebrew_tap/contents/$cask_path" --jq .sha)"
current_cask="$(gh api "repos/$homebrew_tap/contents/$cask_path" -H 'Accept: application/vnd.github.raw+json')"
updated_cask="$(print -r -- "$current_cask" | sed -E "s/^(  version )\".*\"\$/\1\"$version\"/; s/^(  sha256 )\".*\"\$/\1\"$release_checksum\"/")"

if [[ "$updated_cask" != *"version \"$version\""* || "$updated_cask" != *"sha256 \"$release_checksum\""* ]]; then
  echo "Couldn't find the version and sha256 lines in $cask_path."
  exit 1
fi

if [[ "$updated_cask" == "$current_cask" ]]; then
  echo "The cask already installs $version."
  exit 0
fi

encoded_cask="$(print -r -- "$updated_cask" | base64)"
gh api -X PUT "repos/$homebrew_tap/contents/$cask_path" \
  -f message="keyboard-switcher $version" \
  -f content="$encoded_cask" \
  -f sha="$cask_blob" \
  -f "committer[name]=$author_name" \
  -f "committer[email]=$author_email" \
  -f "author[name]=$author_name" \
  -f "author[email]=$author_email" \
  --silent
echo "The Homebrew cask now installs $version (SHA-256 $release_checksum)."
