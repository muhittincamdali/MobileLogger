#!/usr/bin/env bash
# Captures the README screenshots of the LogExplorer example app on an iPhone simulator.
#
# The script builds and installs the app, launches it with `-demo` (which logs the four sample
# events at start) and takes a simulator screenshot in light and dark appearance with a fixed
# status bar. What the screenshots show is what the app's sinks received from the redactor.
#
# Usage: scripts/capture-example-screens.sh [simulator name or UDID]
# Without an argument it uses the first available iPhone simulator. Output: docs/images/
set -euo pipefail

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
device="${1:-}"
if [[ -z "$device" ]]; then
  device="$(xcrun simctl list devices available | grep -m1 -oE 'iPhone [^(]+' | sed 's/ *$//')"
fi
if [[ -z "$device" ]]; then
  echo "No available iPhone simulator found." >&2
  exit 1
fi

bundle_id="io.github.muhittincamdali.LogExplorer"
output_dir="$repo_root/docs/images"
build_dir="$(mktemp -d)"
trap 'rm -rf "$build_dir"' EXIT
mkdir -p "$output_dir"

echo "Building LogExplorer for '$device'"
destination="platform=iOS Simulator,name=$device"
if [[ "$device" =~ ^[0-9A-F-]{36}$ ]]; then
  destination="platform=iOS Simulator,id=$device"
fi
xcodebuild build \
  -project "$repo_root/Examples/LogExplorer/LogExplorer.xcodeproj" \
  -scheme LogExplorer \
  -destination "$destination" \
  -derivedDataPath "$build_dir" \
  -quiet
app="$(find "$build_dir/Build/Products" -maxdepth 2 -name 'LogExplorer.app' -path '*iphonesimulator*' | head -1)"

xcrun simctl boot "$device" 2>/dev/null || true
xcrun simctl bootstatus "$device" -b >/dev/null
xcrun simctl status_bar "$device" override --time 9:41 --batteryState charged --batteryLevel 100 \
  --cellularBars 4 --wifiBars 3 --operatorName ""
xcrun simctl uninstall "$device" "$bundle_id" 2>/dev/null || true
xcrun simctl install "$device" "$app"

for appearance in light dark; do
  xcrun simctl ui "$device" appearance "$appearance"
  xcrun simctl launch --terminate-running-process "$device" "$bundle_id" -demo >/dev/null
  sleep 4 # let the first layout finish
  file="$output_dir/log-explorer-$appearance.png"
  xcrun simctl io "$device" screenshot --type=png "$file" >/dev/null 2>&1
  # Half the width of an iPhone screenshot keeps the README light.
  sips --resampleWidth 603 "$file" >/dev/null
  echo "$file"
done

xcrun simctl status_bar "$device" clear
xcrun simctl terminate "$device" "$bundle_id" 2>/dev/null || true
