@echo off
chcp 65001 >nul
title NemJPG - Konverter billeder til JPG
echo.
echo   ============================================
echo    NemJPG - Konverterer alle billeder til JPG
echo   ============================================
echo.

set "PSFILE=%TEMP%\nemjpg_%RANDOM%.ps1"

:: Trin 1: Udtræk PowerShell-koden fra denne fil
powershell -ExecutionPolicy Bypass -Command "((Get-Content -Raw '%~f0') -split '# PSSTART\r?\n', 2)[1] | Set-Content -Path '%PSFILE%' -Encoding UTF8"

:: Trin 2: Kør scriptet
powershell -ExecutionPolicy Bypass -NoProfile -File "%PSFILE%" -ScriptDir "%~dp0"

:: Ryd op
del "%PSFILE%" 2>nul
echo.
pause
exit /b
# PSSTART
param([string]$ScriptDir)

try {
    Add-Type -AssemblyName PresentationCore
    Add-Type -AssemblyName WindowsBase
} catch {
    Write-Host "  FEJL: Kunne ikke indlaese Windows-biblioteker." -ForegroundColor Red
    Write-Host "  $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

$ScriptDir = $ScriptDir.TrimEnd('\')

$extensions = @(
    '.png', '.bmp', '.gif', '.tiff', '.tif', '.webp',
    '.ico', '.heic', '.heif', '.avif', '.wdp', '.hdp',
    '.dng', '.cr2', '.nef', '.arw', '.orf', '.rw2'
)

$converted = 0
$skipped = 0
$errors = @()

$files = Get-ChildItem -Path $ScriptDir -File | Sort-Object Name

$imageFiles = @()
foreach ($file in $files) {
    $ext = $file.Extension.ToLower()
    if ($ext -in @('.jpg', '.jpeg', '.bat', '.cmd', '.ps1', '.exe', '.txt', '.lnk')) { continue }
    if ($ext -notin $extensions) { continue }
    $imageFiles += $file
}

if ($imageFiles.Count -eq 0) {
    Write-Host "  Ingen billedfiler fundet i mappen." -ForegroundColor Yellow
    Write-Host "  Mappe: $ScriptDir" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  Understottede formater:" -ForegroundColor Cyan
    Write-Host "  PNG, BMP, GIF, TIFF, WebP, ICO, HEIC, HEIF, AVIF, WDP" -ForegroundColor Cyan
    exit 0
}

Write-Host "  Fundet $($imageFiles.Count) billede(r) der skal konverteres." -ForegroundColor Cyan
Write-Host ""

foreach ($file in $imageFiles) {
    $outputName = $file.BaseName + '.jpg'
    $outputPath = Join-Path $ScriptDir $outputName

    if (Test-Path $outputPath) {
        Write-Host "  SPRING OVER  $($file.Name) -> $outputName (findes allerede)" -ForegroundColor Yellow
        $skipped++
        continue
    }

    $stream = $null
    $outStream = $null

    try {
        $stream = [System.IO.File]::OpenRead($file.FullName)

        $decoder = [System.Windows.Media.Imaging.BitmapDecoder]::Create(
            $stream,
            [System.Windows.Media.Imaging.BitmapCreateOptions]::PreservePixelFormat,
            [System.Windows.Media.Imaging.BitmapCacheOption]::OnLoad
        )

        $frame = $decoder.Frames[0]
        $w = $frame.PixelWidth
        $h = $frame.PixelHeight

        $dpiX = 96
        if ($frame.DpiX -gt 0) { $dpiX = $frame.DpiX }
        $dpiY = 96
        if ($frame.DpiY -gt 0) { $dpiY = $frame.DpiY }

        # Tegn billedet paa hvid baggrund (haandterer gennemsigtighed)
        $dv = New-Object System.Windows.Media.DrawingVisual
        $dc = $dv.RenderOpen()
        $rect = New-Object System.Windows.Rect(0, 0, $w, $h)
        $dc.DrawRectangle([System.Windows.Media.Brushes]::White, $null, $rect)
        $dc.DrawImage($frame, $rect)
        $dc.Close()

        $rtb = New-Object System.Windows.Media.Imaging.RenderTargetBitmap(
            $w, $h, $dpiX, $dpiY, [System.Windows.Media.PixelFormats]::Pbgra32)
        $rtb.Render($dv)

        # Gem som JPEG
        $encoder = New-Object System.Windows.Media.Imaging.JpegBitmapEncoder
        $encoder.QualityLevel = 95
        $encoder.Frames.Add([System.Windows.Media.Imaging.BitmapFrame]::Create($rtb))

        $outStream = [System.IO.File]::Create($outputPath)
        $encoder.Save($outStream)
        $outStream.Close()
        $outStream = $null
        $stream.Close()
        $stream = $null

        Write-Host "  OK           $($file.Name) -> $outputName" -ForegroundColor Green
        $converted++
    }
    catch {
        Write-Host "  FEJL         $($file.Name): $($_.Exception.Message)" -ForegroundColor Red
        $errors += $file.Name
        if (Test-Path $outputPath) { Remove-Item $outputPath -Force -ErrorAction SilentlyContinue }
    }
    finally {
        if ($outStream) { try { $outStream.Close() } catch {} }
        if ($stream) { try { $stream.Close() } catch {} }
    }
}

$errColor = 'Green'
if ($errors.Count -gt 0) { $errColor = 'Red' }

Write-Host ""
Write-Host "  ============================================" -ForegroundColor Cyan
Write-Host "  Konverteret:    $converted" -ForegroundColor Green
Write-Host "  Sprunget over:  $skipped" -ForegroundColor Yellow
Write-Host "  Fejl:           $($errors.Count)" -ForegroundColor $errColor
Write-Host "  ============================================" -ForegroundColor Cyan

if ($errors.Count -gt 0) {
    Write-Host ""
    Write-Host "  Filer med fejl:" -ForegroundColor Red
    foreach ($e in $errors) {
        Write-Host "    - $e" -ForegroundColor Red
    }
    Write-Host ""
    Write-Host "  TIP: HEIC/WEBP kraever codecs fra Microsoft Store" -ForegroundColor DarkGray
    Write-Host "       (HEIF Image Extension / WebP Image Extension)" -ForegroundColor DarkGray
}
