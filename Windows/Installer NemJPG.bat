@echo off
chcp 65001 >nul 2>&1
title NemJPG - Installation

echo.
echo ============================================
echo   NemJPG - Installation
echo ============================================
echo.

:: ============================================================================
:: Check for PowerShell availability
:: ============================================================================
where powershell.exe >nul 2>&1
if errorlevel 1 (
    echo FEJL: PowerShell blev ikke fundet paa denne computer.
    echo NemJPG kraever PowerShell 5.0 eller nyere.
    echo.
    goto :error
)

:: Verify PowerShell version is at least 5.0
for /f "tokens=*" %%v in ('powershell.exe -NoProfile -Command "$PSVersionTable.PSVersion.Major"') do set "PSVER=%%v"
if "%PSVER%"=="" (
    echo ADVARSEL: Kunne ikke bestemme PowerShell-version.
    echo.
) else (
    if %PSVER% LSS 5 (
        echo FEJL: PowerShell %PSVER% fundet, men version 5.0 eller nyere kraeves.
        echo.
        goto :error
    )
    echo PowerShell version %PSVER% fundet.
    echo.
)

:: ============================================================================
:: Determine install directory
:: ============================================================================
set "INSTALLDIR=%LOCALAPPDATA%\NemJPG"

:: Get script directory (where this .bat file is)
set "SRCDIR=%~dp0"

:: ============================================================================
:: Create install directory
:: ============================================================================
if not exist "%INSTALLDIR%" (
    mkdir "%INSTALLDIR%"
    if errorlevel 1 (
        echo FEJL: Kunne ikke oprette mappen: %INSTALLDIR%
        goto :error
    )
)

:: ============================================================================
:: Copy files
:: ============================================================================
echo Kopierer filer til %INSTALLDIR%...

if not exist "%SRCDIR%nemjpg.ps1" (
    echo FEJL: Filen nemjpg.ps1 blev ikke fundet i: %SRCDIR%
    goto :error
)
copy /Y "%SRCDIR%nemjpg.ps1" "%INSTALLDIR%\nemjpg.ps1" >nul
if errorlevel 1 (
    echo FEJL: Kunne ikke kopiere nemjpg.ps1
    goto :error
)

if exist "%SRCDIR%nemjpg.ini" (
    copy /Y "%SRCDIR%nemjpg.ini" "%INSTALLDIR%\nemjpg.ini" >nul
    if errorlevel 1 (
        echo FEJL: Kunne ikke kopiere nemjpg.ini
        goto :error
    )
) else (
    echo [INFO] nemjpg.ini ikke fundet - standardindstillinger bruges.
)

echo Filer kopieret.
echo.

:: ============================================================================
:: Build the PowerShell command for registry entries
:: The command stored in registry must handle file paths with spaces.
:: We use single quotes around the path (%%%%1 -> %%1 in registry) so that
:: paths with spaces, parentheses, and special characters are handled.
:: The -Command approach is more reliable than -File for complex quoting.
:: ============================================================================
set "PSEXE=powershell.exe -NoProfile -NoLogo -ExecutionPolicy Bypass -WindowStyle Normal -Command"
set "PSSCRIPT=%INSTALLDIR%\nemjpg.ps1"

:: ============================================================================
:: Register context menu for image files (SystemFileAssociations\image)
:: ============================================================================
echo Registrerer hojrekliksmenu for billedfiler...

set "IMGBASE=HKCU\Software\Classes\SystemFileAssociations\image\shell\NemJPG"

:: Main NemJPG menu entry
reg add "%IMGBASE%" /ve /d "NemJPG" /f >nul 2>&1
if errorlevel 1 ( echo FEJL: Kunne ikke registrere billedmenu & goto :error )
reg add "%IMGBASE%" /v "MUIVerb" /d "NemJPG" /f >nul 2>&1
reg add "%IMGBASE%" /v "SubCommands" /d "" /f >nul 2>&1
reg add "%IMGBASE%" /v "Icon" /d "imageres.dll,67" /f >nul 2>&1

:: Submenu: JPG High Quality
set "KEY=%IMGBASE%\shell\01_jpg95"
reg add "%KEY%" /ve /d "Konverter til JPG (Hoej kvalitet)" /f >nul 2>&1
reg add "%KEY%" /v "Icon" /d "imageres.dll,67" /f >nul 2>&1
reg add "%KEY%\command" /ve /d "%PSEXE% \"& '%PSSCRIPT%' -Action jpg95 -Path '%%1'\"" /f >nul 2>&1

:: Submenu: JPG Web
set "KEY=%IMGBASE%\shell\02_jpg80"
reg add "%KEY%" /ve /d "Konverter til JPG (Web)" /f >nul 2>&1
reg add "%KEY%" /v "Icon" /d "imageres.dll,67" /f >nul 2>&1
reg add "%KEY%\command" /ve /d "%PSEXE% \"& '%PSSCRIPT%' -Action jpg80 -Path '%%1'\"" /f >nul 2>&1

:: Submenu: JPG Resize 1920
set "KEY=%IMGBASE%\shell\03_jpgresize"
reg add "%KEY%" /ve /d "Konverter til JPG + Resize (1920px)" /f >nul 2>&1
reg add "%KEY%" /v "Icon" /d "imageres.dll,67" /f >nul 2>&1
reg add "%KEY%\command" /ve /d "%PSEXE% \"& '%PSSCRIPT%' -Action jpgresize1920 -Path '%%1'\"" /f >nul 2>&1

:: Submenu: PNG
set "KEY=%IMGBASE%\shell\04_png"
reg add "%KEY%" /ve /d "Konverter til PNG" /f >nul 2>&1
reg add "%KEY%" /v "Icon" /d "imageres.dll,67" /f >nul 2>&1
reg add "%KEY%\command" /ve /d "%PSEXE% \"& '%PSSCRIPT%' -Action png -Path '%%1'\"" /f >nul 2>&1

:: Submenu: WebP
set "KEY=%IMGBASE%\shell\05_webp"
reg add "%KEY%" /ve /d "Konverter til WebP" /f >nul 2>&1
reg add "%KEY%" /v "Icon" /d "imageres.dll,67" /f >nul 2>&1
reg add "%KEY%\command" /ve /d "%PSEXE% \"& '%PSSCRIPT%' -Action webp -Path '%%1'\"" /f >nul 2>&1

echo Billedfil-menu registreret.
echo.

:: ============================================================================
:: Register context menu for directories
:: ============================================================================
echo Registrerer hojrekliksmenu for mapper...

set "DIRBASE=HKCU\Software\Classes\Directory\shell\NemJPG"

:: Main NemJPG menu entry for directories
reg add "%DIRBASE%" /ve /d "NemJPG" /f >nul 2>&1
if errorlevel 1 ( echo FEJL: Kunne ikke registrere mappemenu & goto :error )
reg add "%DIRBASE%" /v "MUIVerb" /d "NemJPG" /f >nul 2>&1
reg add "%DIRBASE%" /v "SubCommands" /d "" /f >nul 2>&1
reg add "%DIRBASE%" /v "Icon" /d "imageres.dll,67" /f >nul 2>&1

:: Submenu: JPG High Quality
set "KEY=%DIRBASE%\shell\01_jpg95"
reg add "%KEY%" /ve /d "Konverter til JPG (Hoej kvalitet)" /f >nul 2>&1
reg add "%KEY%" /v "Icon" /d "imageres.dll,67" /f >nul 2>&1
reg add "%KEY%\command" /ve /d "%PSEXE% \"& '%PSSCRIPT%' -Action jpg95 -Path '%%1'\"" /f >nul 2>&1

:: Submenu: JPG Web
set "KEY=%DIRBASE%\shell\02_jpg80"
reg add "%KEY%" /ve /d "Konverter til JPG (Web)" /f >nul 2>&1
reg add "%KEY%" /v "Icon" /d "imageres.dll,67" /f >nul 2>&1
reg add "%KEY%\command" /ve /d "%PSEXE% \"& '%PSSCRIPT%' -Action jpg80 -Path '%%1'\"" /f >nul 2>&1

:: Submenu: JPG Resize 1920
set "KEY=%DIRBASE%\shell\03_jpgresize"
reg add "%KEY%" /ve /d "Konverter til JPG + Resize (1920px)" /f >nul 2>&1
reg add "%KEY%" /v "Icon" /d "imageres.dll,67" /f >nul 2>&1
reg add "%KEY%\command" /ve /d "%PSEXE% \"& '%PSSCRIPT%' -Action jpgresize1920 -Path '%%1'\"" /f >nul 2>&1

:: Submenu: PNG
set "KEY=%DIRBASE%\shell\04_png"
reg add "%KEY%" /ve /d "Konverter til PNG" /f >nul 2>&1
reg add "%KEY%" /v "Icon" /d "imageres.dll,67" /f >nul 2>&1
reg add "%KEY%\command" /ve /d "%PSEXE% \"& '%PSSCRIPT%' -Action png -Path '%%1'\"" /f >nul 2>&1

:: Submenu: WebP
set "KEY=%DIRBASE%\shell\05_webp"
reg add "%KEY%" /ve /d "Konverter til WebP" /f >nul 2>&1
reg add "%KEY%" /v "Icon" /d "imageres.dll,67" /f >nul 2>&1
reg add "%KEY%\command" /ve /d "%PSEXE% \"& '%PSSCRIPT%' -Action webp -Path '%%1'\"" /f >nul 2>&1

echo Mappe-menu registreret.
echo.

:: ============================================================================
:: Verify installation
:: ============================================================================
echo Verificerer installation...
set "INSTALL_OK=1"

if not exist "%INSTALLDIR%\nemjpg.ps1" (
    echo FEJL: nemjpg.ps1 blev ikke installeret korrekt.
    set "INSTALL_OK=0"
)

reg query "%IMGBASE%" /ve >nul 2>&1
if errorlevel 1 (
    echo FEJL: Billedmenu blev ikke registreret korrekt.
    set "INSTALL_OK=0"
)

reg query "%DIRBASE%" /ve >nul 2>&1
if errorlevel 1 (
    echo FEJL: Mappemenu blev ikke registreret korrekt.
    set "INSTALL_OK=0"
)

if "%INSTALL_OK%"=="0" goto :error

echo Verifikation OK.
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
echo ============================================
echo   Installation fejlede!
echo ============================================
echo.
echo Kontroller at du har rettigheder til at
echo skrive til %LOCALAPPDATA% og registreringsdatabasen.
echo.
pause
exit /b 1
