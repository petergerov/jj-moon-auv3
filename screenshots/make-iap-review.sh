#!/bin/bash
#
# Builds the IAP App Review screenshot for App Store Connect.
#
#   screenshots/make-iap-review.sh
#
# Writes:
#   screenshots/store/AppReview-IAP-unlock.png   640×920, RGB, no alpha
#
# That is the legacy size App Store Connect’s IAP “Review Screenshot”
# uploader still validates. It is NOT a Store listing image — do not put it
# in the iPhone / iPad carousel.

set -euo pipefail

cd "$(dirname "$0")/.."
ROOT="$PWD"
WORK="$(mktemp -d)"
DD="$ROOT/DerivedData/screenshots"
trap 'rm -rf "$WORK"' EXIT
mkdir -p "$DD" "$ROOT/screenshots/store"

IPHONE="iPhone 17 Pro Max"

echo "==> Generating project"
xcodegen generate >/dev/null

udid=$(xcrun simctl list devices available \
      | grep -F "$IPHONE (" | head -1 | sed -E 's/.*\(([0-9A-F-]{36})\).*/\1/')
if [ -z "$udid" ]; then
  echo "!! No simulator named '$IPHONE'" >&2
  exit 1
fi

echo "==> $IPHONE (IAP review paywall)"
xcrun simctl boot "$udid" 2>/dev/null || true
xcrun simctl bootstatus "$udid" -b >/dev/null
xcrun simctl status_bar "$udid" override \
    --time "9:41" \
    --cellularMode active --cellularBars 4 \
    --dataNetwork wifi --wifiMode active --wifiBars 3 \
    --batteryState charged --batteryLevel 100

xcodebuild -project JJMoon.xcodeproj \
           -scheme screenshots \
           -configuration Debug \
           -sdk iphonesimulator \
           -destination "platform=iOS Simulator,id=$udid" \
           -derivedDataPath "$DD" \
           -resultBundlePath "$WORK/iap.xcresult" \
           -only-testing:JJMoonScreenshots/ScreenshotTests/testAppReviewPaywall \
           test >"$WORK/iap.log" 2>&1 \
  || { echo "!! Test failed; see $WORK/iap.log" >&2; tail -50 "$WORK/iap.log" >&2; exit 1; }

xcrun xcresulttool export attachments \
      --path "$WORK/iap.xcresult" \
      --output-path "$WORK/att" >/dev/null

SRC=$(python3 - "$WORK/att" <<'PY'
import json, os, struct, sys
root = sys.argv[1]
for test in json.load(open(os.path.join(root, "manifest.json"))):
    for a in test.get("attachments", []):
        if a["suggestedHumanReadableName"].startswith("04-iap-review"):
            raw_path = os.path.join(root, a["exportedFileName"])
            raw = open(raw_path, "rb").read()
            # Drop eXIf so browsers / sips don't rotate.
            out, i = bytearray(raw[:8]), 8
            while i < len(raw):
                length = struct.unpack(">I", raw[i:i + 4])[0]
                kind = raw[i + 4:i + 8]
                if kind != b"eXIf":
                    out += raw[i:i + 12 + length]
                i += 12 + length
            clean = os.path.join(root, "04-iap-review.clean.png")
            open(clean, "wb").write(bytes(out))
            print(clean)
            raise SystemExit
raise SystemExit("no 04-iap-review attachment")
PY
)

OUT="$ROOT/screenshots/store/AppReview-IAP-unlock.png"
W=$(sips -g pixelWidth  "$SRC" | awk '/pixelWidth/{print $2}')
H=$(sips -g pixelHeight "$SRC" | awk '/pixelHeight/{print $2}')
NEW_H=$(python3 -c "print(int(round($W * 920 / 640)))")

if [ "$NEW_H" -le "$H" ]; then
  Y=$(python3 -c "print(max(0, ($H - $NEW_H) // 2))")
  sips --cropToHeightWidth "$NEW_H" "$W" --cropOffset "$Y" 0 "$SRC" --out "$WORK/cropped.png" >/dev/null
else
  NEW_W=$(python3 -c "print(int(round($H * 640 / 920)))")
  X=$(python3 -c "print(max(0, ($W - $NEW_W) // 2))")
  sips --cropToHeightWidth "$H" "$NEW_W" --cropOffset 0 "$X" "$SRC" --out "$WORK/cropped.png" >/dev/null
fi

# JPEG round-trip drops alpha; ASC rejects review screenshots with an alpha channel.
sips --resampleHeightWidth 920 640 "$WORK/cropped.png" \
     --setProperty format jpeg --setProperty formatOptions 100 \
     --out "$WORK/flat.jpg" >/dev/null
sips -s format png "$WORK/flat.jpg" --out "$OUT" >/dev/null

python3 - "$OUT" <<'PY'
import struct, sys
d = open(sys.argv[1], "rb").read()
assert d[:8] == b"\x89PNG\r\n\x1a\n"
i = 8
while i + 8 <= len(d):
    length = struct.unpack(">I", d[i:i+4])[0]
    kind = d[i+4:i+8]
    if kind == b"IHDR":
        w, h, bit, ctype = struct.unpack(">IIBB", d[i+8:i+18])
        alpha = "alpha" if ctype in (4, 6) else "no alpha"
        print(f"    AppReview-IAP-unlock.png  {w}x{h}  ({alpha})")
        break
    i += 12 + length
PY

echo
echo "Done. Upload screenshots/store/AppReview-IAP-unlock.png as the IAP Review Screenshot."
