@echo off

where /q powershell
if ERRORLEVEL == 1 (
  echo Powershell not found
  pause
) else (
  powershell .\install.ps1 %*
)