# NemJPG - Windows Image Batch Converter
# PowerShell 5.1 compatible conversion engine
# Uses WPF BitmapDecoder/Encoder for image processing

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("jpg95", "jpg80", "jpgresize1920", "png", "webp", "settings")]
    [string]$Action,

    [Parameter(Mandatory=$false)]
    [string]$Path
)

# ============================================================================
# Load WPF assemblies
# ============================================================================
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName WindowsBase
Add-Type -AssemblyName System.Drawing

# ============================================================================
# Configuration
# ============================================================================
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$IniPath = Join-Path $ScriptDir "nemjpg.ini"
$LogPath = Join-Path $ScriptDir "nemjpg_log.txt"

$SupportedExtensions = @(
    ".png", ".bmp", ".gif", ".tiff", ".tif", ".webp",
    ".ico", ".heic", ".heif", ".avif", ".wdp", ".hdp",
    ".dng", ".cr2", ".nef", ".arw", ".jxr"
)

# ============================================================================
# INI Reader
# ============================================================================
function Read-IniFile {
    param([string]$FilePath)

    $config = @{
        Quality          = 95
        OutputFolder     = "NemJPG_output"
        BackgroundColor  = "White"
        Recursive        = $false
        MaxWidth         = 0
        MaxHeight        = 0
        PreserveMetadata = $true
    }

    if (-not (Test-Path $FilePath)) {
        return $config
    }

    $lines = Get-Content $FilePath
    foreach ($line in $lines) {
        $trimmed = $line.Trim()
        if ($trimmed -eq "" -or $trimmed.StartsWith("[") -or $trimmed.StartsWith(";") -or $trimmed.StartsWith("#")) {
            continue
        }
        $parts = $trimmed -split "=", 2
        if ($parts.Count -eq 2) {
            $key = $parts[0].Trim()
            $val = $parts[1].Trim()
            switch ($key) {
                "Quality"          { $config.Quality = [int]$val }
                "OutputFolder"     { $config.OutputFolder = $val }
                "BackgroundColor"  { $config.BackgroundColor = $val }
                "Recursive"        { $config.Recursive = ($val -eq "true") }
                "MaxWidth"         { $config.MaxWidth = [int]$val }
                "MaxHeight"        { $config.MaxHeight = [int]$val }
                "PreserveMetadata" { $config.PreserveMetadata = ($val -eq "true") }
            }
        }
    }
    return $config
}

# ============================================================================
# Logging
# ============================================================================
function Write-Log {
    param([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $entry = "$timestamp  $Message"
    Add-Content -Path $LogPath -Value $entry -Encoding UTF8
}

# ============================================================================
# Format file size for display
# ============================================================================
function Format-FileSize {
    param([long]$Bytes)
    if ($Bytes -ge 1MB) {
        return "{0:N2} MB" -f ($Bytes / 1MB)
    }
    elseif ($Bytes -ge 1KB) {
        return "{0:N1} KB" -f ($Bytes / 1KB)
    }
    else {
        return "$Bytes B"
    }
}

# ============================================================================
# Collect image files from a path
# ============================================================================
function Get-ImageFiles {
    param(
        [string]$TargetPath,
        [bool]$Recurse
    )

    $files = @()
    if (Test-Path $TargetPath -PathType Leaf) {
        $ext = [System.IO.Path]::GetExtension($TargetPath).ToLower()
        if ($SupportedExtensions -contains $ext) {
            $files += Get-Item $TargetPath
        }
    }
    elseif (Test-Path $TargetPath -PathType Container) {
        if ($Recurse) {
            $allFiles = Get-ChildItem -Path $TargetPath -File -Recurse -ErrorAction SilentlyContinue
        }
        else {
            $allFiles = Get-ChildItem -Path $TargetPath -File -ErrorAction SilentlyContinue
        }
        foreach ($f in $allFiles) {
            $ext = $f.Extension.ToLower()
            if ($SupportedExtensions -contains $ext) {
                $files += $f
            }
        }
    }
    return $files
}

# ============================================================================
# Parse background color from config string
# ============================================================================
function Get-BackgroundColor {
    param([string]$ColorName)

    $colorMap = @{
        "White"       = [System.Windows.Media.Colors]::White
        "Black"       = [System.Windows.Media.Colors]::Black
        "Transparent" = [System.Windows.Media.Colors]::Transparent
        "Red"         = [System.Windows.Media.Colors]::Red
        "Green"       = [System.Windows.Media.Colors]::Green
        "Blue"        = [System.Windows.Media.Colors]::Blue
        "Gray"        = [System.Windows.Media.Colors]::Gray
        "Grey"        = [System.Windows.Media.Colors]::Gray
    }

    if ($colorMap.ContainsKey($ColorName)) {
        return $colorMap[$ColorName]
    }

    # Try hex: #RRGGBB
    if ($ColorName -match "^#([0-9a-fA-F]{6})$") {
        $r = [Convert]::ToByte($Matches[1].Substring(0, 2), 16)
        $g = [Convert]::ToByte($Matches[1].Substring(2, 2), 16)
        $b = [Convert]::ToByte($Matches[1].Substring(4, 2), 16)
        return [System.Windows.Media.Color]::FromRgb($r, $g, $b)
    }

    return [System.Windows.Media.Colors]::White
}

# ============================================================================
# Convert a single image file
# ============================================================================
function Convert-Image {
    param(
        [System.IO.FileInfo]$SourceFile,
        [string]$OutputFormat,       # "jpg" or "png" or "webp"
        [int]$Quality,
        [string]$OutputFolder,
        [string]$BgColorName,
        [int]$MaxWidth,
        [int]$MaxHeight,
        [bool]$PreserveMetadata
    )

    $sourcePath = $SourceFile.FullName
    $originalSize = $SourceFile.Length
    $baseName = [System.IO.Path]::GetFileNameWithoutExtension($SourceFile.Name)

    # Determine output extension
    $outExt = $OutputFormat
    if ($OutputFormat -eq "jpg") {
        $outExt = "jpg"
    }

    # Determine output directory
    $sourceDir = $SourceFile.DirectoryName
    $outDir = Join-Path $sourceDir $OutputFolder
    if (-not (Test-Path $outDir)) {
        New-Item -ItemType Directory -Path $outDir -Force | Out-Null
    }

    $outPath = Join-Path $outDir "$baseName.$outExt"

    # Skip if output already exists
    if (Test-Path $outPath) {
        return @{
            Success     = $false
            Skipped     = $true
            Source      = $sourcePath
            Output      = $outPath
            OrigSize    = $originalSize
            NewSize     = 0
            Error       = "Filen eksisterer allerede"
        }
    }

    try {
        # Open image with BitmapDecoder
        $stream = [System.IO.File]::OpenRead($sourcePath)
        $decoder = [System.Windows.Media.Imaging.BitmapDecoder]::Create(
            $stream,
            [System.Windows.Media.Imaging.BitmapCreateOptions]::PreservePixelFormat,
            [System.Windows.Media.Imaging.BitmapCacheOption]::OnLoad
        )
        $frame = $decoder.Frames[0]
        $stream.Close()
        $stream.Dispose()

        $pixelWidth = $frame.PixelWidth
        $pixelHeight = $frame.PixelHeight

        # Calculate target dimensions
        $targetWidth = $pixelWidth
        $targetHeight = $pixelHeight

        if ($MaxWidth -gt 0 -and $targetWidth -gt $MaxWidth) {
            $ratio = [double]$MaxWidth / [double]$targetWidth
            $targetWidth = $MaxWidth
            $targetHeight = [int]([double]$targetHeight * $ratio)
        }
        if ($MaxHeight -gt 0 -and $targetHeight -gt $MaxHeight) {
            $ratio = [double]$MaxHeight / [double]$targetHeight
            $targetHeight = $MaxHeight
            $targetWidth = [int]([double]$targetWidth * $ratio)
        }

        # Ensure minimum dimensions
        if ($targetWidth -lt 1) { $targetWidth = 1 }
        if ($targetHeight -lt 1) { $targetHeight = 1 }

        # Use DrawingVisual to composite on background and optionally resize
        $bgColor = Get-BackgroundColor -ColorName $BgColorName
        $drawingVisual = New-Object System.Windows.Media.DrawingVisual
        $dc = $drawingVisual.RenderOpen()

        # Draw background rectangle
        $bgBrush = New-Object System.Windows.Media.SolidColorBrush($bgColor)
        $bgRect = New-Object System.Windows.Rect(0, 0, $targetWidth, $targetHeight)
        $dc.DrawRectangle($bgBrush, $null, $bgRect)

        # Draw the image on top
        $imgRect = New-Object System.Windows.Rect(0, 0, $targetWidth, $targetHeight)
        $dc.DrawImage($frame, $imgRect)

        $dc.Close()

        # Render to bitmap
        $rtb = New-Object System.Windows.Media.Imaging.RenderTargetBitmap(
            $targetWidth, $targetHeight, 96, 96,
            [System.Windows.Media.PixelFormats]::Pbgra32
        )
        $rtb.Render($drawingVisual)

        # Copy metadata if requested
        $metadata = $null
        if ($PreserveMetadata) {
            try {
                $metadata = $frame.Metadata
                if ($null -ne $metadata) {
                    $metadata = $metadata.Clone()
                }
            }
            catch {
                $metadata = $null
            }
        }

        # Encode output
        $encoder = $null
        switch ($OutputFormat) {
            "jpg" {
                $encoder = New-Object System.Windows.Media.Imaging.JpegBitmapEncoder
                $encoder.QualityLevel = $Quality
            }
            "png" {
                $encoder = New-Object System.Windows.Media.Imaging.PngBitmapEncoder
            }
            "webp" {
                # WPF does not have a native WebP encoder.
                # Use WIC (Windows Imaging Component) via BitmapEncoder if available (Windows 10+).
                # Fall back to JPEG if WebP encoding is not supported.
                try {
                    # WebP GUID: {7BAA4153-684E-4749-BB86-A7A9A0B541CC} (decode only on many systems)
                    # Try using WmpBitmapEncoder (WDP/HDP) as a high-quality alternative
                    # or attempt the native WIC WebP encoder via interop
                    $encoder = New-Object System.Windows.Media.Imaging.WmpBitmapEncoder
                    $encoder.ImageQualityLevel = ([float]$Quality / 100.0)
                    $outExt = "wdp"
                    $outPath = Join-Path $outDir "$baseName.$outExt"
                    Write-Host "  [INFO] WebP-kodning er ikke tilgaengelig - gemmer som WDP i stedet" -ForegroundColor Yellow
                }
                catch {
                    $encoder = New-Object System.Windows.Media.Imaging.JpegBitmapEncoder
                    $encoder.QualityLevel = $Quality
                    $outExt = "jpg"
                    $outPath = Join-Path $outDir "$baseName.$outExt"
                    Write-Host "  [INFO] WebP-kodning er ikke tilgaengelig - gemmer som JPG i stedet" -ForegroundColor Yellow
                }
            }
        }

        # Create frame with or without metadata
        $outputFrame = $null
        if ($null -ne $metadata -and $OutputFormat -eq "jpg") {
            try {
                $outputFrame = [System.Windows.Media.Imaging.BitmapFrame]::Create(
                    $rtb, $null, $metadata, $null
                )
            }
            catch {
                $outputFrame = [System.Windows.Media.Imaging.BitmapFrame]::Create($rtb)
            }
        }
        else {
            $outputFrame = [System.Windows.Media.Imaging.BitmapFrame]::Create($rtb)
        }

        $encoder.Frames.Add($outputFrame)

        # Write to file
        $outStream = [System.IO.File]::Create($outPath)
        $encoder.Save($outStream)
        $outStream.Close()
        $outStream.Dispose()

        $newSize = (Get-Item $outPath).Length

        return @{
            Success     = $true
            Skipped     = $false
            Source      = $sourcePath
            Output      = $outPath
            OrigSize    = $originalSize
            NewSize     = $newSize
            Error       = $null
        }
    }
    catch {
        return @{
            Success     = $false
            Skipped     = $false
            Source      = $sourcePath
            Output      = $null
            OrigSize    = $originalSize
            NewSize     = 0
            Error       = $_.Exception.Message
        }
    }
}

# ============================================================================
# Open settings file in notepad
# ============================================================================
function Open-Settings {
    if (-not (Test-Path $IniPath)) {
        # Create default ini
        $defaultIni = @"
[NemJPG]
Quality=95
OutputFolder=NemJPG_output
BackgroundColor=White
Recursive=false
MaxWidth=0
MaxHeight=0
PreserveMetadata=true
"@
        Set-Content -Path $IniPath -Value $defaultIni -Encoding UTF8
    }
    Start-Process notepad.exe -ArgumentList $IniPath
}

# ============================================================================
# Main
# ============================================================================

# Handle settings action
if ($Action -eq "settings") {
    Open-Settings
    exit 0
}

# Validate path
if (-not $Path) {
    Write-Host "FEJL: Ingen sti angivet. Brug -Path parameteren." -ForegroundColor Red
    exit 1
}

if (-not (Test-Path $Path)) {
    Write-Host "FEJL: Stien findes ikke: $Path" -ForegroundColor Red
    exit 1
}

# Read configuration
$config = Read-IniFile -FilePath $IniPath

# Determine conversion parameters from action
$outputFormat = "jpg"
$quality = $config.Quality
$maxWidth = $config.MaxWidth
$maxHeight = $config.MaxHeight

switch ($Action) {
    "jpg95" {
        $outputFormat = "jpg"
        $quality = 95
    }
    "jpg80" {
        $outputFormat = "jpg"
        $quality = 80
    }
    "jpgresize1920" {
        $outputFormat = "jpg"
        $quality = $config.Quality
        $maxWidth = 1920
        $maxHeight = 0
    }
    "png" {
        $outputFormat = "png"
        $quality = 100
    }
    "webp" {
        $outputFormat = "webp"
        $quality = $config.Quality
    }
}

# Print banner
Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  NemJPG - Billedkonvertering til Windows" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Handling:        $Action" -ForegroundColor White
Write-Host "Format:          $($outputFormat.ToUpper())" -ForegroundColor White
Write-Host "Kvalitet:        $quality%" -ForegroundColor White
Write-Host "Outputmappe:     $($config.OutputFolder)" -ForegroundColor White
Write-Host "Baggrund:        $($config.BackgroundColor)" -ForegroundColor White
if ($maxWidth -gt 0) {
    Write-Host "Maks bredde:     ${maxWidth}px" -ForegroundColor White
}
if ($maxHeight -gt 0) {
    Write-Host "Maks hoejde:     ${maxHeight}px" -ForegroundColor White
}
Write-Host "Rekursiv:        $($config.Recursive)" -ForegroundColor White
Write-Host ""

# Collect files
$files = Get-ImageFiles -TargetPath $Path -Recurse $config.Recursive

if ($files.Count -eq 0) {
    Write-Host "Ingen understottede billedfiler fundet." -ForegroundColor Yellow
    Write-Log "Ingen filer fundet i: $Path"
    Write-Host ""
    Write-Host "Tryk paa en tast for at lukke..." -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 0
}

Write-Host "Fundet $($files.Count) billedfil(er)" -ForegroundColor Green
Write-Host ""

Write-Log "===== NemJPG Start: $Action paa $Path ====="
Write-Log "Fundet $($files.Count) filer"

# Process files
$successCount = 0
$skipCount = 0
$errorCount = 0
$totalOrigSize = [long]0
$totalNewSize = [long]0

for ($i = 0; $i -lt $files.Count; $i++) {
    $file = $files[$i]
    $pct = [int](($i + 1) / $files.Count * 100)
    Write-Host "[$pct%] Konverterer: $($file.Name)" -ForegroundColor White -NoNewline

    $result = Convert-Image `
        -SourceFile $file `
        -OutputFormat $outputFormat `
        -Quality $quality `
        -OutputFolder $config.OutputFolder `
        -BgColorName $config.BackgroundColor `
        -MaxWidth $maxWidth `
        -MaxHeight $maxHeight `
        -PreserveMetadata $config.PreserveMetadata

    if ($result.Success) {
        $successCount++
        $totalOrigSize += $result.OrigSize
        $totalNewSize += $result.NewSize

        $origFormatted = Format-FileSize -Bytes $result.OrigSize
        $newFormatted = Format-FileSize -Bytes $result.NewSize

        $saved = 0
        if ($result.OrigSize -gt 0) {
            $saved = [int](100.0 - ([double]$result.NewSize / [double]$result.OrigSize * 100.0))
        }

        Write-Host "  OK  $origFormatted -> $newFormatted ($saved% sparet)" -ForegroundColor Green
        Write-Log "OK: $($file.Name) | $origFormatted -> $newFormatted | $saved% sparet"
    }
    elseif ($result.Skipped) {
        $skipCount++
        Write-Host "  SPRUNGET OVER ($($result.Error))" -ForegroundColor Yellow
        Write-Log "SPRUNGET OVER: $($file.Name) | $($result.Error)"
    }
    else {
        $errorCount++
        Write-Host "  FEJL: $($result.Error)" -ForegroundColor Red
        Write-Log "FEJL: $($file.Name) | $($result.Error)"
    }
}

# Summary
Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  Resultat" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "Konverteret:     $successCount" -ForegroundColor Green
if ($skipCount -gt 0) {
    Write-Host "Sprunget over:   $skipCount" -ForegroundColor Yellow
}
if ($errorCount -gt 0) {
    Write-Host "Fejl:            $errorCount" -ForegroundColor Red
}

if ($totalOrigSize -gt 0) {
    $totalSaved = $totalOrigSize - $totalNewSize
    $pctSaved = [int](100.0 - ([double]$totalNewSize / [double]$totalOrigSize * 100.0))
    Write-Host ""
    Write-Host "Original:        $(Format-FileSize -Bytes $totalOrigSize)" -ForegroundColor White
    Write-Host "Ny:              $(Format-FileSize -Bytes $totalNewSize)" -ForegroundColor White
    Write-Host "Sparet:          $(Format-FileSize -Bytes $totalSaved) ($pctSaved%)" -ForegroundColor Green
}

Write-Log "Faerdig: $successCount OK, $skipCount sprunget over, $errorCount fejl"
Write-Log "===== NemJPG Slut ====="

Write-Host ""
Write-Host "Tryk paa en tast for at lukke..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
