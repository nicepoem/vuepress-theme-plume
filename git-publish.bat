```bat
@echo off
setlocal EnableExtensions EnableDelayedExpansion

cd /d "%~dp0"

title Git Publish Tool

set "BRANCH=main"
set "GITHUB_REMOTE=origin"
set "GITEE_REMOTE=gitee"

:START
cls

echo.
echo ============================================================
echo                    Git Publish Tool
echo ============================================================
echo.
echo Project:
echo %CD%
echo.
echo Branch: %BRANCH%
echo.

where git >nul 2>nul

if errorlevel 1 (
    echo [ERROR] Git was not found.
    echo.
    pause
    exit /b 1
)

git rev-parse --is-inside-work-tree >nul 2>nul

if errorlevel 1 (
    echo [ERROR] This folder is not a Git repository.
    echo.
    pause
    exit /b 1
)

echo [OK] Git environment is ready.
echo [OK] Git repository detected.
echo.

:MENU

echo.
echo ============================================================
echo                         MENU
echo ============================================================
echo.
echo   [1] Publish to GitHub
echo   [2] Publish to Gitee
echo   [3] Publish to GitHub + Gitee
echo.
echo   [4] Git status
echo   [5] Git remotes
echo   [6] Test GitHub SSH
echo   [7] Test Gitee
echo.
echo   [0] Exit
echo.
echo ============================================================
echo.

set "CHOICE="
set /p "CHOICE=Select option: "

if "%CHOICE%"=="1" goto PUBLISH_GITHUB
if "%CHOICE%"=="2" goto PUBLISH_GITEE
if "%CHOICE%"=="3" goto PUBLISH_BOTH
if "%CHOICE%"=="4" goto SHOW_STATUS
if "%CHOICE%"=="5" goto SHOW_REMOTE
if "%CHOICE%"=="6" goto TEST_GITHUB
if "%CHOICE%"=="7" goto TEST_GITEE
if "%CHOICE%"=="0" goto EXIT

echo.
echo [ERROR] Invalid option.
pause
goto MENU


:PUBLISH_GITHUB

cls

echo.
echo ============================================================
echo                    PUBLISH GITHUB
echo ============================================================
echo.

call :CHECK_CHANGES

echo.
echo ============================================================
echo                    PUSH GITHUB
echo ============================================================
echo.

call :PUSH_GITHUB

echo.
pause
goto MENU


:PUBLISH_GITEE

cls

echo.
echo ============================================================
echo                     PUBLISH GITEE
echo ============================================================
echo.

call :CHECK_CHANGES

echo.
echo ============================================================
echo                     PUSH GITEE
echo ============================================================
echo.

call :PUSH_GITEE

echo.
pause
goto MENU


:PUBLISH_BOTH

cls

echo.
echo ============================================================
echo                 PUBLISH GITHUB + GITEE
echo ============================================================
echo.

call :CHECK_CHANGES

echo.
echo ============================================================
echo                    PUSH GITHUB
echo ============================================================
echo.

call :PUSH_GITHUB

echo.
echo ============================================================
echo                     PUSH GITEE
echo ============================================================
echo.

call :PUSH_GITEE

echo.
echo ============================================================
echo                    PUBLISH FINISHED
echo ============================================================
echo.

pause
goto MENU


:CHECK_CHANGES

git status --porcelain > "%TEMP%\git_publish_status.txt"

set "HAS_CHANGES=0"

for /f "usebackq delims=" %%A in ("%TEMP%\git_publish_status.txt") do (
    set "HAS_CHANGES=1"
)

del "%TEMP%\git_publish_status.txt" >nul 2>nul

if "%HAS_CHANGES%"=="1" goto COMMIT

echo.
echo [INFO] Working tree is clean.
echo [INFO] No new commit will be created.
echo.

exit /b 0


:COMMIT

echo.
echo ============================================================
echo                       COMMIT
echo ============================================================
echo.

git status --short

echo.

git add .

if errorlevel 1 (
    echo.
    echo [ERROR] git add failed.
    echo.
    exit /b 1
)

echo.
echo [OK] git add completed.
echo.

set "COMMIT_MESSAGE="

set /p "COMMIT_MESSAGE=Commit message: "

if "%COMMIT_MESSAGE%"=="" (
    set "COMMIT_MESSAGE=Update code"
)

echo.
echo Commit message:
echo %COMMIT_MESSAGE%
echo.

git commit -m "%COMMIT_MESSAGE%"

if errorlevel 1 (
    echo.
    echo [ERROR] git commit failed.
    echo.
    exit /b 1
)

echo.
echo [OK] Commit created.
echo.

exit /b 0


:PUSH_GITHUB

git remote get-url %GITHUB_REMOTE% >nul 2>nul

if errorlevel 1 (
    echo [ERROR] GitHub remote does not exist.
    exit /b 1
)

set "RETRY=1"

:PUSH_GITHUB_RETRY

echo.
echo [GitHub] Push attempt %RETRY% of 3.
echo.

git push %GITHUB_REMOTE% %BRANCH%

if not errorlevel 1 (
    echo.
    echo [GitHub] Push successful.
    echo.
    exit /b 0
)

echo.
echo [GitHub] Push failed.

if "%RETRY%"=="3" (
    echo.
    echo [GitHub] 3 attempts failed.
    echo [GitHub] Your local commit is safe.
    echo.
    exit /b 1
)

set /a RETRY+=1

echo.
echo Retrying in 5 seconds...
timeout /t 5 /nobreak >nul

goto PUSH_GITHUB_RETRY


:PUSH_GITEE

git remote get-url %GITEE_REMOTE% >nul 2>nul

if errorlevel 1 (
    echo [ERROR] Gitee remote does not exist.
    exit /b 1
)

set "RETRY=1"

:PUSH_GITEE_RETRY

echo.
echo [Gitee] Push attempt %RETRY% of 3.
echo.

git push %GITEE_REMOTE% %BRANCH%

if not errorlevel 1 (
    echo.
    echo [Gitee] Push successful.
    echo.
    exit /b 0
)

echo.
echo [Gitee] Push failed.

if "%RETRY%"=="3" (
    echo.
    echo [Gitee] 3 attempts failed.
    echo [Gitee] Your local commit is safe.
    echo.
    exit /b 1
)

set /a RETRY+=1

echo.
echo Retrying in 5 seconds...
timeout /t 5 /nobreak >nul

goto PUSH_GITEE_RETRY


:SHOW_STATUS

cls

echo.
echo ============================================================
echo                       GIT STATUS
echo ============================================================
echo.

git status

echo.
pause
goto MENU


:SHOW_REMOTE

cls

echo.
echo ============================================================
echo                       GIT REMOTES
echo ============================================================
echo.

git remote -v

echo.
pause
goto MENU


:TEST_GITHUB

cls

echo.
echo ============================================================
echo                   TEST GITHUB SSH
echo ============================================================
echo.

echo GitHub remote:
git remote get-url origin

echo.
echo Testing GitHub SSH...
echo.

git ls-remote origin

if not errorlevel 1 (
    echo.
    echo [OK] GitHub SSH connection works.
) else (
    echo.
    echo [ERROR] GitHub SSH connection failed.
)

echo.
pause
goto MENU


:TEST_GITEE

cls

echo.
echo ============================================================
echo                     TEST GITEE
echo ============================================================
echo.

echo Gitee remote:
git remote get-url gitee

echo.
echo Testing Gitee...
echo.

git ls-remote gitee

if not errorlevel 1 (
    echo.
    echo [OK] Gitee connection works.
) else (
    echo.
    echo [INFO] Gitee returned no remote branch.
    echo.
    echo If this is a new empty repository,
    echo you can select option 2 to push the main branch.
)

echo.
pause
goto MENU


:EXIT

cls

echo.
echo ============================================================
echo                    Git Publish Tool
echo ============================================================
echo.
echo Exit.
echo.

pause

exit /b 0
```
