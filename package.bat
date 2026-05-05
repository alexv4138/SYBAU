@echo off
setlocal

set "ADDON=SYBAU"
set "ROOT=%~dp0"
for %%I in ("%ROOT%..") do set "PARENT=%%~fI"
set "ZIP=%PARENT%\%ADDON%.zip"

if exist "%ZIP%" del "%ZIP%"

powershell -NoProfile -ExecutionPolicy Bypass -Command "Compress-Archive -Path '%PARENT%\%ADDON%' -DestinationPath '%ZIP%' -Force"
if errorlevel 1 (
    echo Package failed.
    pause
    exit /b 1
)

echo Created "%ZIP%"
pause
