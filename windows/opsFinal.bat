@echo off
:: Ejecutar como administrador
powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process powershell -Verb runAs -ArgumentList '-ExecutionPolicy Bypass -File \"C:\Users\USUARIO\ScriptsBash\ScriptPwsh\osManager.ps1\"'"
