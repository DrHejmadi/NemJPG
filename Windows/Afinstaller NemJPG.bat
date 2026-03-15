@echo off
chcp 65001 >nul 2>&1
title NemJPG - Afinstallation

echo.
echo ============================================
echo   NemJPG - Afinstallation
echo ============================================
echo.

:: ============================================================================
:: Remove registry entries for image files
:: ============================================================================
echo Fjerner hojrekliksmenu for billedfiler...
reg delete "HKCU\Software\Classes\SystemFileAssociations\image\shell\NemJPG" /f >nul 2>&1
echo Billedfil-menu fjernet.

:: ============================================================================
:: Remove registry entries for directories
:: ============================================================================
echo Fjerner hojrekliksmenu for mapper...
reg delete "HKCU\Software\Classes\Directory\shell\NemJPG" /f >nul 2>&1
echo Mappe-menu fjernet.

echo.

:: ============================================================================
:: Remove installed files
:: ============================================================================
set "INSTALLDIR=%LOCALAPPDATA%\NemJPG"

if exist "%INSTALLDIR%" (
    echo Sletter installationsmappe: %INSTALLDIR%
    rmdir /s /q "%INSTALLDIR%"
    echo Mappe slettet.
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
