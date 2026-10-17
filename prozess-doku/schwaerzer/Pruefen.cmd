@echo off
rem Prueft, ob alle Voraussetzungen fuer den SAP-Schwaerzer erfuellt sind.
powershell.exe -NoProfile -ExecutionPolicy RemoteSigned -File "%~dp0SAP-Schwaerzer.ps1" -Pruefen
echo.
pause
