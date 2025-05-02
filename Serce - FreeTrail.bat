@echo off
title %&#(@^!&*^$)#@
color 0A
cls
setlocal enabledelayedexpansion
chcp 65001 > nul

:: Global variables
set "selectedJar="
set "mcModsDir=C:\Users\felek\AppData\Roaming\.minecraft\mods"
set "licenseFile=%~dp0license.dat"
set "hoursLeft=4"

:: License check and initialization
if exist "%licenseFile%" (
    for /f "tokens=1,2 delims==" %%a in ('type "%licenseFile%"') do (
        if "%%a"=="firstRun" set "firstRunTime=%%b"
        if "%%a"=="hoursLeft" set "hoursLeft=%%b"
    )
    
    :: Calculate hours passed since first run
    for /f %%h in ('powershell -command "(Get-Date - (Get-Date '!firstRunTime!')).TotalHours"') do (
        set /a "hoursPassed=%%h"
        set /a "hoursLeft=4-!hoursPassed!"
    )
) else (
    :: First run - initialize license
    echo firstRun=%date% %time% > "%licenseFile%"
    echo hoursLeft=4 >> "%licenseFile%"
    set "firstRunTime=%date% %time%"
)

:: Self-destruct if license expired
if %hoursLeft% LEQ 0 (
    echo License expired - self-destructing...
    timeout /t 3 >nul
    del "%licenseFile%" >nul 2>&1
    del "%~f0" >nul 2>&1
    exit
)

:: Show license info for 3 seconds
echo.
echo ==============================
echo   LICENCJA WAZNA JESZCZE: %hoursLeft% GODZIN
echo   PELNA WERSJA: DC:polskagurm_06556
echo ==============================
timeout /t 3 >nul
cls

:main
echo   ██████  ██████  ███    ██ ███████  ██████  ██      ███████ 
echo  ██      ██    ██ ████   ██ ██      ██    ██ ██      ██      
echo  ██      ██    ██ ██ ██  ██ ███████ ██    ██ ██      █████   
echo  ██      ██    ██ ██  ██ ██      ██ ██    ██ ██      ██      
echo   ██████  ██████  ██   ████ ███████  ██████  ███████ ███████ 
echo  Simply Console By Feli$
echo  Type Help for more info                                                
set /p "cmd=     -->&$7"

if /i "%cmd%"=="help" goto help
if /i "%cmd%"=="clear" goto cls
if /i "%cmd%"=="exit" exit
if /i "%cmd%"=="jarfile" goto jarfile
if /i "%cmd%"=="jarappdatafile" goto jarappdatafile
if /i "%cmd%"=="jarstart" goto jarstart
if /i "%cmd%"=="jardelete" goto jardelete
if /i "%cmd%"=="jarhelp" goto jarhelp


echo Unknown command. Type "help" to see available commands.
goto main

:help
echo Available commands:
echo - clear          - clears the screen
echo - exit           - closes the program
echo - help           - shows this help
goto main

:jarhelp
echo.
echo  JAR-related commands:
echo  ---------------------
echo  jarfile        - select any JAR file
echo  jarappdatafile - select JAR from Minecraft mods folder
echo  jarstart       - run selected JAR stealthily
echo  jardelete      - securely delete selected JAR (3-pass wipe)
echo.
echo  JAR File Operations:
echo  - Files are encrypted and permanently deleted
echo  - Military-grade 3-pass overwrite
echo  - No recovery possible
pause
cls
goto main

:cls
cls
goto main

:jarfile
echo.
echo Select any JAR file...
set "selectedJar="
for /f "delims=" %%F in ('powershell -command "[System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms') | Out-Null; $dlg = New-Object System.Windows.Forms.OpenFileDialog; $dlg.Filter = 'JAR Files (*.jar)|*.jar'; $dlg.ShowDialog() | Out-Null; $dlg.FileName"') do (
    set "selectedJar=%%F"
)
if defined selectedJar (
    echo Selected: !selectedJar!
    echo File size: %%~zF bytes
) else (
    echo No file selected.
)
pause
cls
goto main

:jarappdatafile
echo.
echo Selecting from Minecraft mods folder...
if not exist "%mcModsDir%" (
    echo Minecraft mods folder not found at:
    echo %mcModsDir%
    mkdir "%mcModsDir%" >nul 2>&1
    if exist "%mcModsDir%" (
        echo Created mods directory.
    )
    pause
    cls
    goto main
)
set "selectedJar="
for /f "delims=" %%F in ('powershell -command "[System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms') | Out-Null; $dlg = New-Object System.Windows.Forms.OpenFileDialog; $dlg.InitialDirectory = 'C:\Users\felek\AppData\Roaming\.minecraft\mods'; $dlg.Filter = 'JAR Files (*.jar)|*.jar'; $dlg.ShowDialog() | Out-Null; $dlg.FileName"') do (
    set "selectedJar=%%F"
)
if defined selectedJar (
    echo Selected: !selectedJar!
    echo File size: %%~zF bytes
) else (
    echo No file selected.
)
pause
cls
goto main

:jarstart
if not defined selectedJar (
    echo No JAR file selected. Use 'jarfile' or 'jarappdatafile' first.
    pause
    cls
    goto main
)
echo Starting JAR file stealthily...
start "" /B javaw -jar "!selectedJar!" >nul 2>&1
echo JAR started in background (PID: %ERRORLEVEL%)
pause
cls
goto main

:jardelete
if not defined selectedJar (
    echo No JAR file selected. Use 'jarfile' or 'jarappdatafile' first.
    pause
    cls
    goto main
)

echo.
echo [WARNING] SECURE WIPE IN PROGRESS
echo This will:
echo 1. Encrypt !selectedJar! 3 times with military-grade algorithm
echo 2. Permanently delete all traces
echo 3. Clear Windows event logs
echo.
set /p "confirm=Type 'WIPE' to confirm: "

if /i "!confirm!" neq "WIPE" (
    echo Operation cancelled.
    pause
    cls
    goto main
)

echo Phase 1/3: Encrypting file...
powershell -command "$file = '!selectedJar!'; $stream = [System.IO.File]::OpenWrite($file); $length = $stream.Length; $buffer = New-Object byte[] $length; $rng = New-Object System.Security.Cryptography.RNGCryptoServiceProvider; 1..3 | ForEach-Object { $rng.GetBytes($buffer); $stream.Position=0; $stream.Write($buffer,0,$buffer.Length) }; $stream.Close()"

echo Phase 2/3: Deleting file...
powershell -command "Remove-Item '!selectedJar!' -Force -ErrorAction SilentlyContinue"

echo Phase 3/3: Cleaning traces...
powershell -command "wevtutil cl Application | Out-Null; wevtutil cl System | Out-Null"

if exist "!selectedJar!" (
    echo Error: File still exists! Close Minecraft/java first.
) else (
    echo [SUCCESS] File obliterated beyond recovery.
    set "selectedJar="
)

:: Update license hours remaining
set /a "hoursLeft-=1"
> "%licenseFile%" (
    echo firstRun=%firstRunTime%
    echo hoursLeft=%hoursLeft%
)
pause
cls
goto main
