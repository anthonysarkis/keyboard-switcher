#!/bin/zsh
set -euo pipefail

repository_root="${0:A:h:h}"
app_name="Keyboard Switcher"
installed_app="$HOME/Applications/$app_name.app"

"$repository_root/scripts/build-app.sh"

if pgrep -x KeyboardSwitcher >/dev/null; then
  pkill -x KeyboardSwitcher
  while pgrep -x KeyboardSwitcher >/dev/null; do sleep 0.2; done
fi

mkdir -p "$HOME/Applications"
rm -rf "$installed_app"
ditto "$repository_root/build/$app_name.app" "$installed_app"
open "$installed_app"
echo "Installed and opened $installed_app"
