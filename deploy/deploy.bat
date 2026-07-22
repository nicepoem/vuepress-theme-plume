@echo off
setlocal EnableExtensions
cd /d "%~dp0"

title VuePress Deploy

if not exist ".env.deploy" goto missing_config

where pnpm >nul 2>&1
if errorlevel 1 goto missing_pnpm

where powershell >nul 2>&1
if errorlevel 1 goto missing_ps

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0deploy.ps1"
if errorlevel 1 goto failed

goto end

:missing_config
echo [ERR] Missing file: deploy\.env.deploy
echo Copy deploy\.env.deploy.example to deploy\.env.deploy
goto failed

:missing_pnpm
echo [ERR] pnpm not found. Install Node.js and pnpm first.
goto failed

:missing_ps
echo [ERR] PowerShell not found.
goto failed

:failed
echo.
pause
exit /b 1

:end
pause
exit /b 0
