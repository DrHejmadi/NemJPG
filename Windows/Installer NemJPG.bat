@echo off
chcp 65001 >nul 2>&1
title NemJPG - Installation

echo.
echo ============================================
echo   NemJPG - Installation
echo ============================================
echo.

:: Determine install directory
set "INSTALLDIR=%LOCALAPPDATA%\NemJPG"

:: Get script directory (where this .bat file is)
set "SRCDIR=%~dp0"

:: Create install directory
if not exist "%INSTALLDIR%" (
    mkdir "%INSTALLDIR%"
)

:: Copy files
echo Kopierer filer til %INSTALLDIR%...
copy /Y "%SRCDIR%nemjpg.ps1" "%INSTALLDIR%\nemjpg.ps1" >nul
if errorlevel 1 (
    echo FEJL: Kunne ikke kopiere nemjpg.ps1
    goto :error
)

copy /Y "%SRCDIR%nemjpg.ini" "%INSTALLDIR%\nemjpg.ini" >nul
if errorlevel 1 (
    echo FEJL: Kunne ikke kopiere nemjpg.ini
    goto :error
)

echo Filer kopieret.
echo.

:: ============================================================================
:: Register context menu for image files (SystemFileAssociations\image)
:: ============================================================================
echo Registrerer hojrekliksmenu for billedfiler...

set "IMGBASE=HKCU\Software\Classes\SystemFileAssociations\image\shell\NemJPG"
set "PSCMD=powershell.exe -NoProfile -ExecutionPolicy Bypass -File \"%INSTALLDIR%\nemjpg.ps1\""

:: Main NemJPG menu entry
reg add "%IMGBASE%" /ve /d "NemJPG" /f >nul
reg add "%IMGBASE%" /v "MUIVerb" /d "NemJPG" /f >nul
reg add "%IMGBASE%" /v "SubCommands" /d "" /f >nul
reg add "%IMGBASE%" /v "Icon" /d "imageres.dll,67" /f >nul

:: Submenu: JPG High Quality
set "KEY=%IMGBASE%\shell\01_jpg95"
reg add "%KEY%" /ve /d "Konverter til JPG (Hoej kvalitet)" /f >nul
reg add "%KEY%" /v "Icon" /d "imageres.dll,67" /f >nul
reg add "%KEY%\command" /ve /d "%PSCMD% -Action jpg95 -Path \"%%1\"" /f >nul

:: Submenu: JPG Web
set "KEY=%IMGBASE%\shell\02_jpg80"
reg add "%KEY%" /ve /d "Konverter til JPG (Web)" /f >nul
reg add "%KEY%" /v "Icon" /d "imageres.dll,67" /f >nul
reg add "%KEY%\command" /ve /d "%PSCMD% -Action jpg80 -Path \"%%1\"" /f >nul

:: Submenu: JPG Resize 1920
set "KEY=%IMGBASE%\shell\03_jpgresize"
reg add "%KEY%" /ve /d "Konverter til JPG + Resize (1920px)" /f >nul
reg add "%KEY%" /v "Icon" /d "imageres.dll,67" /f >nul
reg add "%KEY%\command" /ve /d "%PSCMD% -Action jpgresize1920 -Path \"%%1\"" /f >nul

:: Submenu: PNG
set "KEY=%IMGBASE%\shell\04_png"
reg add "%KEY%" /ve /d "Konverter til PNG" /f >nul
reg add "%KEY%" /v "Icon" /d "imageres.dll,67" /f >nul
reg add "%KEY%\command" /ve /d "%PSCMD% -Action png -Path \"%%1\"" /f >nul

:: Submenu: WebP
set "KEY=%IMGBASE%\shell\05_webp"
reg add "%KEY%" /ve /d "Konverter til WebP" /f >nul
reg add "%KEY%" /v "Icon" /d "imageres.dll,67" /f >nul
reg add "%KEY%\command" /ve /d "%PSCMD% -Action webp -Path \"%%1\"" /f >nul

echo Billedfil-menu registreret.
echo.

:: ============================================================================
:: Register context menu for directories
:: ============================================================================
echo Registrerer hojrekliksmenu for mapper...

set "DIRBASE=HKCU\Software\Classes\Directory\shell\NemJPG"

:: Main NemJPG menu entry for directories
reg add "%DIRBASE%" /ve /d "NemJPG" /f >nul
reg add "%DIRBASE%" /v "MUIVerb" /d "NemJPG" /f >nul
reg add "%DIRBASE%" /v "SubCommands" /d "" /f >nul
reg add "%DIRBASE%" /v "Icon" /d "imageres.dll,67" /f >nul

:: Submenu: JPG High Quality
set "KEY=%DIRBASE%\shell\01_jpg95"
reg add "%KEY%" /ve /d "Konverter til JPG (Hoej kvalitet)" /f >nul
reg add "%KEY%" /v "Icon" /d "imageres.dll,67" /f >nul
reg add "%KEY%\command" /ve /d "%PSCMD% -Action jpg95 -Path \"%%1\"" /f >nul

:: Submenu: JPG Web
set "KEY=%DIRBASE%\shell\02_jpg80"
reg add "%KEY%" /ve /d "Konverter til JPG (Web)" /f >nul
reg add "%KEY%" /v "Icon" /d "imageres.dll,67" /f >nul
reg add "%KEY%\command" /ve /d "%PSCMD% -Action jpg80 -Path \"%%1\"" /f >nul

:: Submenu: JPG Resize 1920
set "KEY=%DIRBASE%\shell\03_jpgresize"
reg add "%KEY%" /ve /d "Konverter til JPG + Resize (1920px)" /f >nul
reg add "%KEY%" /v "Icon" /d "imageres.dll,67" /f >nul
reg add "%KEY%\command" /ve /d "%PSCMD% -Action jpgresize1920 -Path \"%%1\"" /f >nul

:: Submenu: PNG
set "KEY=%DIRBASE%\shell\04_png"
reg add "%KEY%" /ve /d "Konverter til PNG" /f >nul
reg add "%KEY%" /v "Icon" /d "imageres.dll,67" /f >nul
reg add "%KEY%\command" /ve /d "%PSCMD% -Action png -Path \"%%1\"" /f >nul

:: Submenu: WebP
set "KEY=%DIRBASE%\shell\05_webp"
reg add "%KEY%" /ve /d "Konverter til WebP" /f >nul
reg add "%KEY%" /v "Icon" /d "imageres.dll,67" /f >nul
reg add "%KEY%\command" /ve /d "%PSCMD% -Action webp -Path \"%%1\"" /f >nul

echo Mappe-menu registreret.
echo.

:: ============================================================================
:: Done
:: ============================================================================
echo ============================================
echo   NemJPG er installeret!
echo ============================================
echo.
echo Filer installeret i:
echo   %INSTALLDIR%
echo.
echo Hojreklik paa en billedfil eller mappe
echo for at bruge NemJPG.
echo.
echo Rediger indstillinger i:
echo   %INSTALLDIR%\nemjpg.ini
echo.
pause
exit /b 0

:error
echo.
echo Installation fejlede!
echo.
pause
exit /b 1
