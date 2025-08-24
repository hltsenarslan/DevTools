# DevTools

DevTools, macOS için Swift/SwiftUI ile geliştirilmiş **menü çubuğu
aracı**dır.\
Menü çubuğu ikonuna tıklayınca sağ üstte 600px yüksekliğinde bir panel
açılır.\
Panelden istediğin tool'u seçtiğinde, panel kapanır ve o tool'un
penceresi açılır.

## ✨ Özellikler

-   Menü çubuğundan tek tıkla erişim
-   Manifest dosyası ile kolay tool ekleme/çıkarma
-   Her tool kendi klasöründe izole (modüler yapı)
-   CLI ile derleme (Xcode gerekmez)
-   VS Code + CodeLLDB ile debug

## 📂 Klasör Yapısı

    DevTools/
     ├─ DevToolsApp.swift
     ├─ StatusBar/         # Menü ikonu ve panel
     ├─ Manifest/          # tools.manifest.json
     ├─ Registry/          # ToolRegistry
     ├─ Views/             # TopPanel UI
     ├─ Tools/
     │   ├─ JSONBeautifier/
     │   ├─ UUIDGenerator/
     │   ├─ Base64Coder/
     │   ├─ JWTInspector/
     │   ├─ URLCoder/
     │   ├─ RegexTester/
     │   └─ SystemInfo/
     ├─ Resources/
     │   └─ Assets.xcassets
     ├─ build.sh
     └─ README.md

## 🛠️ Yerleşik Tool'lar

-   **JSON Beautifier** -- JSON pretty/minify
-   **UUID Generator** -- çoklu UUID üret
-   **Base64 Coder** -- encode/decode
-   **JWT Inspector** -- header/payload decode
-   **URL Encoder/Decoder**
-   **Regex Tester** -- regex ile eşleşme
-   **System Info** -- OS, CPU, RAM, uptime, kernel, sıcaklık, fan, pil

## 📦 Manifest

Kullanıcıya gösterilen tool listesi `Manifest/tools.manifest.json`
dosyasından yüklenir.

``` json
{
  "version": 1,
  "tools": [
    { "id": "json_beautifier", "name": "JSON Beautifier", "type": "builtin", "icon": "curlybraces" },
    { "id": "uuid_generator",  "name": "UUID Generator",  "type": "builtin", "icon": "number" },
    { "id": "system_info",     "name": "System Info",     "type": "builtin", "icon": "desktopcomputer" }
  ]
}
```

Manifest sırası ekranda aynı şekilde görünür.\
Kullanıcı kendi
`~/Library/Application Support/DevTools/tools.manifest.json` dosyasıyla
listeyi değiştirebilir.

## 🔨 Derleme (Xcode olmadan)

1.  Komut satırı araçlarını yükle:

    ``` bash
    xcode-select --install
    ```

2.  build.sh'ye çalıştırma izni ver:

    ``` bash
    chmod +x build.sh
    ```

3.  Derle & çalıştır:

    ``` bash
    ./build.sh              # Debug, arm64
    CONFIG=Release ./build.sh
    ARCH=x86_64 ./build.sh  # Intel
    ```

Derleme sonrası `.build-cli/DevTools.app` oluşturulur ve otomatik
açılır.

## 🐞 VS Code Debug

`.vscode/launch.json` CodeLLDB konfigürasyonu içerir.\
F5 → "DevTools (Debug via build.sh)" seçerek
`.app/Contents/MacOS/DevTools` ikilisini debug edebilirsin.

## 📜 Lisans

MIT
