@echo off
rem ============================================================
rem  ZY Action Platform - WorkBuddy skill package packer
rem  Output: dist\zy-action-platform-v<version>.zip
rem  Zip top level is the skill dir zy-action-platform/ (SKILL.md inside).
rem  Uses Windows built-in PowerShell Compress-Archive, because GNU tar
rem  on Git Bash would produce a tar archive despite the .zip extension.
rem  NOTE: keep this file ASCII-only (no Chinese), safe under any codepage.
rem ============================================================
setlocal
cd /d "%~dp0"

if not exist skills\zy-action-platform\SKILL.md (
  echo [ERROR] skills\zy-action-platform\SKILL.md not found. Run inside products\workbuddy.
  exit /b 1
)

rem Read version: from SKILL.md frontmatter
set "VER="
for /f "usebackq tokens=2 delims= " %%V in (`findstr /b "version:" skills\zy-action-platform\SKILL.md`) do set "VER=%%V"
if "%VER%"=="" set "VER=1.0.0"

if exist dist rmdir /s /q dist
mkdir dist

powershell -NoProfile -ExecutionPolicy Bypass -Command "Compress-Archive -Path 'skills\zy-action-platform' -DestinationPath 'dist\zy-action-platform.zip' -Force"
if errorlevel 1 (
  echo [ERROR] Compress-Archive failed.
  exit /b 1
)

echo [OK] dist\zy-action-platform.zip created
rem Verify entries (top level should be zy-action-platform/)
powershell -NoProfile -Command "Add-Type -AssemblyName System.IO.Compression.FileSystem; $p=(Resolve-Path 'dist\zy-action-platform.zip').Path; $z=[System.IO.Compression.ZipFile]::OpenRead($p); $z.Entries.FullName | Select-Object -First 12; $z.Dispose()"
endlocal
