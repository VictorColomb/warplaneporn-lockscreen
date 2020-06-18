@echo off
powershell -Command "Start cmd -Verb runas -ArgumentList (""""/c cd """"""""{0}"""""""" && powershell -ExecutionPolicy Bypass -File .\install.ps1"""" -f (Get-Location).path)"
if ERRORLEVEL 1 ( echo Powershell not found or admin rights not granted & pause )