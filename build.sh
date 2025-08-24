#!/usr/bin/env bash
set -euo pipefail

# ===== Config (env ile override edilebilir) ==========================
APP_NAME="${APP_NAME:-DevTools}"
BUNDLE_ID="${BUNDLE_ID:-com.example.devtools}"
MIN_OS="${MIN_OS:-13.0}"
ARCH="${ARCH:-arm64}"            # Intel için: x86_64
CONFIG="${CONFIG:-Debug}"        # Release için: CONFIG=Release

# Debug/Release derleme bayrakları
if [[ "$CONFIG" == "Release" ]]; then
  SWIFTC_OPTS="-O"
else
  SWIFTC_OPTS="-g"
fi

# ===== Yol ve klasörler =============================================
SDK_PATH="$(xcrun --sdk macosx --show-sdk-path)"
BUILD_DIR=".build-cli"
APP_DIR="${BUILD_DIR}/${APP_NAME}.app"
CONTENTS_DIR="${APP_DIR}/Contents"
MACOS_DIR="${CONTENTS_DIR}/MacOS"
RES_DIR="${CONTENTS_DIR}/Resources"

# ===== Temizle / hazırla ============================================
rm -rf "$BUILD_DIR"
mkdir -p "$MACOS_DIR"

# ===== Swift kaynaklarını topla (readarray YOK; find -print0 + while read) ==
SWIFT_SOURCES=()
while IFS= read -r -d '' f; do
  SWIFT_SOURCES+=("$f")
done < <(find . -type f -name "*.swift" \
  -not -path "*/.git/*" \
  -not -path "*/.build/*" \
  -not -path "*/.build-cli/*" \
  -not -path "*/.vscode/*" \
  -not -path "*/DerivedData/*" \
  -not -path "*/Tests/*" \
  -print0)

if [[ ${#SWIFT_SOURCES[@]} -eq 0 ]]; then
  echo "Hata: Swift kaynak dosyası bulunamadı."
  exit 1
fi

# ===== Derle =========================================================
echo "Derleniyor (${CONFIG}, ${ARCH})..."
swiftc \
  -sdk "$SDK_PATH" \
  -target "${ARCH}-apple-macos${MIN_OS}" \
  $SWIFTC_OPTS \
  -framework AppKit \
  -framework SwiftUI \
  -framework Combine \
  -emit-executable \
  -module-name "$APP_NAME" \
  -o "${MACOS_DIR}/${APP_NAME}" \
  "${SWIFT_SOURCES[@]}"

# ===== Info.plist oluştur ===========================================
mkdir -p "$RES_DIR"
cat > "${CONTENTS_DIR}/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleDevelopmentRegion</key> <string>en</string>
  <key>CFBundleExecutable</key>        <string>${APP_NAME}</string>
  <key>CFBundleIdentifier</key>        <string>${BUNDLE_ID}</string>
  <key>CFBundleInfoDictionaryVersion</key> <string>6.0</string>
  <key>CFBundleName</key>              <string>${APP_NAME}</string>
  <key>CFBundlePackageType</key>       <string>APPL</string>
  <key>CFBundleShortVersionString</key><string>0.1.0</string>
  <key>CFBundleVersion</key>           <string>1</string>
  <key>LSMinimumSystemVersion</key>    <string>${MIN_OS}</string>
  <key>NSHighResolutionCapable</key>   <true/>
  <key>NSPrincipalClass</key>          <string>NSApplication</string>
  <!-- Dock ikonu olmasın; menü bar agent app -->
  <key>LSUIElement</key>               <true/>
</dict>
</plist>
PLIST

# ===== Bundle içine fallback manifest (isteğe bağlı) ================
if [[ -f "Manifest/tools.manifest.json" ]]; then
  mkdir -p "${RES_DIR}/Manifest"
  cp -f "Manifest/tools.manifest.json" "${RES_DIR}/Manifest/tools.manifest.json"
fi

# ===== Kullanıcı manifest klasörünü hazırla =========================
USR_MAN_DIR="$HOME/Library/Application Support/${APP_NAME}"
mkdir -p "$USR_MAN_DIR"
if [[ -f "Manifest/tools.manifest.json" ]]; then
  cp -f "Manifest/tools.manifest.json" "${USR_MAN_DIR}/tools.manifest.json"
fi

# ===== Ad-hoc imza ==================================================
echo "Codesign (ad-hoc)..."
codesign -s - --force --timestamp=none "${APP_DIR}"

# ===== Bitir / Çalıştır ============================================
echo "✅ Build tamam: ${APP_DIR}"
open "${APP_DIR}"