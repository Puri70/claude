@echo off
rem Startet die Prozessablage (Prozesshandbuch mit Freigaben).
start "" powershell.exe -NoProfile -ExecutionPolicy RemoteSigned -WindowStyle Hidden -File "%~dp0Prozessablage.ps1"
