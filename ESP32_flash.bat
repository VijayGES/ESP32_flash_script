@echo off
title Flash ESP32

REM === Display header ===
echo ========================================
echo === flash_ESP32 ===
echo ========================================
echo.

REM === List available COM ports using PowerShell ===
echo Available COM ports:
powershell -Command "([System.IO.Ports.SerialPort]::GetPortNames()) -join '  '" 
echo.

REM Set default COM port
set DEFAULT_PORT=COM3

REM Prompt user
set /p PORT=Enter the COM port (e.g., COM3) [Default: %DEFAULT_PORT%]: 

REM Use default if input is empty
if "%PORT%"=="" set PORT=%DEFAULT_PORT%

REM Check if COM port exists using PowerShell
powershell -Command ^
  "$ports = [System.IO.Ports.SerialPort]::GetPortNames(); if (-not $ports -or -not $ports.Contains('%PORT%')) { Write-Host 'ERROR: Port %PORT% not found.'; exit 1 }"

IF ERRORLEVEL 1 (
    echo.
    echo Aborting. Port %PORT% is not available.
    pause
    exit /b 1
)

REM Set other config
set ESPTOOL=esptool.exe
set BAUD=460800

REM Change these file names if needed
set BOOTLOADER=embESP.ino.bootloader.bin
set PARTITIONS=embESP.ino.partitions.bin
set APP=embESP.ino.bin

echo.
echo Flashing ESP32 on %PORT%...
echo.

%ESPTOOL% --chip esp32 --port %PORT% --baud %BAUD% --before default_reset --after hard_reset write_flash -z ^
  0x1000 %BOOTLOADER% ^
  0x8000 %PARTITIONS% ^
  0x10000 %APP%

echo.
pause
