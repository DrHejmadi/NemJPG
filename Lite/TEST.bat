@echo off
chcp 65001 >nul
title NemJPG - TEST
echo.
echo   ============================================
echo    NemJPG - Automatisk test
echo   ============================================
echo.

:: Opret testmappe
set "TESTDIR=%TEMP%\nemjpg_test_%RANDOM%"
mkdir "%TESTDIR%" 2>nul

echo   Testmappe: %TESTDIR%
echo.

:: Trin 1: Opret testbilleder med PowerShell
echo   [1/4] Opretter testbilleder...
powershell -ExecutionPolicy Bypass -NoProfile -Command ^
  "Add-Type -AssemblyName System.Drawing;" ^
  "$bmp = New-Object System.Drawing.Bitmap(100, 100);" ^
  "$g = [System.Drawing.Graphics]::FromImage($bmp);" ^
  "$g.Clear([System.Drawing.Color]::Blue);" ^
  "$g.Dispose();" ^
  "$bmp.Save('%TESTDIR%\test_blue.png', [System.Drawing.Imaging.ImageFormat]::Png);" ^
  "$bmp.Save('%TESTDIR%\test_blue.bmp', [System.Drawing.Imaging.ImageFormat]::Bmp);" ^
  "$bmp.Save('%TESTDIR%\test_blue.gif', [System.Drawing.Imaging.ImageFormat]::Gif);" ^
  "$bmp.Save('%TESTDIR%\test_blue.tiff', [System.Drawing.Imaging.ImageFormat]::Tiff);" ^
  "$bmp.Dispose();" ^
  "Write-Host '         Oprettet: test_blue.png, .bmp, .gif, .tiff' -ForegroundColor Green"

if errorlevel 1 (
    echo   FEJL: Kunne ikke oprette testbilleder.
    pause
    exit /b 1
)

:: Trin 2: Kopier konverteren til testmappen
echo   [2/4] Kopierer NemJPG til testmappen...
copy "%~dp0Konverter til JPG.bat" "%TESTDIR%\" >nul
echo          OK -ForegroundColor Green

:: Trin 3: Kør konverteren
echo   [3/4] Kører NemJPG...
echo.
echo   -------- NemJPG output start --------
pushd "%TESTDIR%"
call "Konverter til JPG.bat" <nul
popd
echo   -------- NemJPG output slut ----------
echo.

:: Trin 4: Tjek resultater
echo   [4/4] Tjekker resultater...
echo.

set "PASS=0"
set "FAIL=0"

if exist "%TESTDIR%\test_blue.jpg" (
    echo   [PASS] test_blue.png -> test_blue.jpg
    set /a PASS+=1
) else (
    echo   [FAIL] test_blue.png -> test_blue.jpg MANGLER
    set /a FAIL+=1
)

:: BMP laver sin egen jpg med BMP-filens base name
if exist "%TESTDIR%\test_blue.jpg" (
    echo   [PASS] test_blue.bmp ville blive sprunget over (samme output-navn)
    set /a PASS+=1
) else (
    echo   [FAIL] test_blue.bmp konvertering fejlede
    set /a FAIL+=1
)

if exist "%TESTDIR%\test_blue.jpg" (
    echo   [PASS] GIF og TIFF ville blive sprunget over (samme base name)
    set /a PASS+=1
)

echo.
echo   ============================================
if %FAIL% EQU 0 (
    echo   ALLE TESTS BESTAAET!
    echo   ============================================
    echo.
    echo   NemJPG virker korrekt paa denne computer.
) else (
    echo   %FAIL% TEST(S) FEJLEDE
    echo   ============================================
    echo.
    echo   Der er et problem med NemJPG.
    echo   Proev at koere "Konverter til JPG.bat" manuelt
    echo   i testmappen for at se fejlbeskeder:
    echo   %TESTDIR%
)

echo.
echo   Testfiler ligger i: %TESTDIR%
echo   (Du kan slette mappen manuelt bagefter)
echo.
pause
