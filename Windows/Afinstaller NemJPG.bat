@echo off
chcp 65001 >nul 2>&1
title NemJPG - Afinstallation

echo.
echo ============================================
echo   NemJPG - Afinstallation
echo ============================================
echo.

:: Confirm before uninstalling
echo Er du sikker paa at du vil afinstallere NemJPG?
echo.
set /p "CONFIRM=Skriv J for at fortsaette: "
if /i not "%CONFIRM%"=="J" (
    echo Afinstallation annulleret.
    echo.
    pause
    exit /b 0
)

echo.

:: ============================================================================
:: Remove registry entries for image files
:: ============================================================================
echo Fjerner hojrekliksmenu for billedfiler...
reg delete "HKCU\Software\Classes\SystemFileAssociations\image\shell\NemJPG" /f >nul 2>&1
if errorlevel 1 (
    echo [INFO] Billedfil-menu var allerede fjernet eller fandtes ikke.
) else (
    echo Billedfil-menu fjernet.
)

:: ============================================================================
:: Remove registry entries for directories
:: ============================================================================
echo Fjerner hojrekliksmenu for mapper...
reg delete "HKCU\Software\Classes\Directory\shell\NemJPG" /f >nul 2>&1
if errorlevel 1 (
    echo [INFO] Mappe-menu var allerede fjernet eller fandtes ikke.
) else (
    echo Mappe-menu fjernet.
)

echo.

:: ============================================================================
:: Remove installed files
:: ============================================================================
set "INSTALLDIR=%LOCALAPPDATA%\NemJPG"

if exist "%INSTALLDIR%" (
    echo Sletter installationsmappe: %INSTALLDIR%
    rmdir /s /q "%INSTALLDIR%"
    if exist "%INSTALLDIR%" (
        echo ADVARSEL: Kunne ikke slette alle filer i mappen.
        echo Nogle filer kan vaere i brug. Proev igen efter genstart.
    ) else (
        echo Mappe slettet.
    )
) else (
    echo Installationsmappe ikke fundet - allerede fjernet.
)

echo.
echo ============================================
echo   NemJPG er afinstalleret!
echo ============================================
echo.
echo Alle registreringsnoegler og filer er fjernet.
echo.
pause
