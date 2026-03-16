<p align="center">
  <img src="Assets/icon.svg" alt="NemJPG" width="128" height="128">
</p>

<h1 align="center">NemJPG</h1>

<p align="center">
  <strong>Batch image converter for macOS and Windows</strong><br>
  Convert 20+ image formats to JPG, PNG, WebP, or TIFF in seconds.
</p>

<p align="center">
  <a href="https://hejmadi.com/NemJPG/">Website</a> &middot;
  <a href="#download">Download</a> &middot;
  <a href="#supported-formats">Formats</a>
</p>

---

## About

NemJPG is a free, open-source batch image converter that processes everything locally on your machine. No uploads, no accounts, no bloatware. Just fast, reliable image conversion.

- **macOS**: Native SwiftUI app with drag-and-drop support
- **Windows**: Right-click context menu integration with PowerShell conversion engine

## Features

- Convert 20+ image formats to JPG, PNG, or WebP
- Batch processing -- convert hundreds of images at once
- Drag and drop files or entire folders (macOS)
- Right-click context menu integration (Windows)
- Configurable quality settings (high, medium, web, compressed)
- Optional image resizing with preserved aspect ratio
- Transparent PNG backgrounds handled automatically (white fill)
- File size report showing space saved per image
- All processing done locally -- no data leaves your machine
- Free and open source

## Screenshots

<p align="center">
  <img src="Assets/screenshot-macos.png" alt="NemJPG macOS" width="600">
</p>

<p align="center">
  <img src="Assets/screenshot-windows.png" alt="NemJPG Windows" width="600">
</p>

## Download

### macOS

<a href="https://apps.apple.com/app/nemjpg/id6760638406">
  <img src="https://developer.apple.com/assets/elements/badges/download-on-the-mac-app-store.svg" alt="Download on the Mac App Store" height="48">
</a>

**Requirements:** macOS 13 Ventura or later. Supports Apple Silicon and Intel.

### Windows

**Option 1: Download zip (recommended)**

1. Download [NemJPG-Windows-v1.1.zip](https://github.com/DrHejmadi/NemJPG/releases/latest/download/NemJPG-Windows-v1.1.zip)
2. Extract the zip file
3. Double-click `Installer NemJPG.bat`
4. Done! Right-click any image or folder in File Explorer to convert

**Option 2: Clone this repo**

```
git clone https://github.com/DrHejmadi/NemJPG.git
cd NemJPG/Windows
```

Then run `Installer NemJPG.bat` to install the right-click context menu.

**Requirements:** Windows 10 or later. PowerShell 5.1+ (built-in).

### Windows Installation Details

The installer does the following:
- Copies `nemjpg.ps1` and `nemjpg.ini` to `%LOCALAPPDATA%\NemJPG\`
- Registers a right-click context menu for image files and folders (HKCU registry, no admin required)

After installation, right-click any image or folder and choose from:

```
NemJPG >
  ├── Konverter til JPG (Hoej kvalitet)     95% quality
  ├── Konverter til JPG (Web)                80% quality
  ├── Konverter til JPG + Resize (1920px)    Resize to max 1920px width
  ├── Konverter til PNG
  └── Konverter til WebP
```

Converted files are saved in a `NemJPG_output` subfolder. Originals are never modified.

### Configuration

Edit `%LOCALAPPDATA%\NemJPG\nemjpg.ini` to change defaults:

```ini
[NemJPG]
Quality=95              ; JPEG quality (1-100)
OutputFolder=NemJPG_output
BackgroundColor=White   ; For transparent PNGs: White, Black, #RRGGBB
Recursive=false         ; Process subfolders
MaxWidth=0              ; Max width in px (0 = no limit)
MaxHeight=0             ; Max height in px (0 = no limit)
PreserveMetadata=true   ; Keep EXIF data
```

### Uninstall

Run `Afinstaller NemJPG.bat` (included in the zip) to remove all registry entries and files.

## Supported Formats

### Standard Formats
| Format | Extension |
|--------|-----------|
| PNG | `.png` |
| BMP | `.bmp` |
| GIF | `.gif` |
| TIFF | `.tiff`, `.tif` |
| WebP | `.webp` |
| ICO | `.ico` |
| JPEG 2000 | `.jp2` |
| PSD | `.psd` |

### Apple / Modern Formats
| Format | Extension |
|--------|-----------|
| HEIC | `.heic` |
| HEIF | `.heif` |
| AVIF | `.avif` |

### RAW Camera Formats
| Format | Camera | Extension |
|--------|--------|-----------|
| DNG | Adobe | `.dng` |
| CR2 | Canon | `.cr2` |
| NEF | Nikon | `.nef` |
| ARW | Sony | `.arw` |
| ORF | Olympus | `.orf` |
| RAW | Generic | `.raw` |

> **Note (Windows):** HEIC/HEIF and AVIF support requires codecs from the Microsoft Store (often pre-installed on Windows 10/11). RAW formats require camera-specific codecs.

## System Requirements

| | macOS | Windows |
|---|---|---|
| **OS** | macOS 13 Ventura+ | Windows 10/11 |
| **Architecture** | Apple Silicon & Intel | x64 |
| **Runtime** | None (native SwiftUI) | PowerShell 5.1+ (built-in) |
| **Price** | Free | Free |

## License

[MIT License](LICENSE) -- Copyright 2026 Michael Skov Hejmadi

## Links

- **Website:** [hejmadi.com/NemJPG](https://hejmadi.com/NemJPG/)
- **Author:** [Michael Skov Hejmadi](https://hejmadi.com)
- **GitHub:** [github.com/DrHejmadi/NemJPG](https://github.com/DrHejmadi/NemJPG)
