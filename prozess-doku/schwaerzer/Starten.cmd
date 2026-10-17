@echo off
rem Startet den SAP-Schwaerzer unsichtbar im Hintergrund (Schild-Symbol unten rechts).
rem Eine Skriptsperre der IT per Gruppenrichtlinie gilt trotzdem.
start "" powershell.exe -NoProfile -ExecutionPolicy RemoteSigned -WindowStyle Hidden -File "%~dp0SAP-Schwaerzer.ps1"
