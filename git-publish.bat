```bat
@echo off
setlocal EnableExtensions EnableDelayedExpansion

cd /d "%~dp0"

title Git Multi-Platform Publisher

set "BRANCH=main"

set "GITHUB_REMOTE=origin"
set "GITEE_REMOTE=gitee"
set "GITCODE_REMOTE=gitcode"

set "GITHUB_RESULT=SKIP"
set "GITEE_RESULT=SKIP"
set "GITCODE_RESULT=SKIP"

:START

cls

echo.
echo ============================================================
echo              Git Multi-Platform Publisher
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
    echo Please install Git first.
    echo.
    pause
    exit /b 1
)

git rev-parse --is-inside-work-tree >nul 2>nul

if errorlevel 1 (
    echo [ERROR] Current directory is not a Git repository.
    echo.
    pause
    exit /b 1
)

echo [OK] Git environment detected.
echo [OK] Git repository detected.
echo.

:MENU

echo.
echo ============================================================
echo                         MAIN MENU
echo ============================================================
echo.
echo   [1] Publish to GitHub
echo   [2] Publish to Gitee
echo   [3] Publish to GitCode
echo   [4] Publish to GitHub + Gitee + GitCode
echo.
echo   [5] Git Status
echo   [6] Git Remotes
echo   [7] Test GitHub SSH
echo   [8] Test Gitee
echo   [9] Test GitCode SSH
echo.
echo   [0] Exit
echo.
echo ============================================================
echo.

set "CHOICE="
set /p "CHOICE=Select option: "

if "%CHOICE%"=="1" goto PUBLISH_GITHUB
if "%CHOICE%"=="2" goto PUBLISH_GITEE
if "%CHOICE%"=="3" goto PUBLISH_GITCODE
if "%CHOICE%"=="4" goto PUBLISH_ALL

if "%CHOICE%"=="5" goto SHOW_STATUS
if "%CHOICE%"=="6" goto SHOW_REMOTE
if "%CHOICE%"=="7" goto TEST_GITHUB
if "%CHOICE%"=="8" goto TEST_GITEE
if "%CHOICE%"=="9" goto TEST_GITCODE

if "%CHOICE%"=="0" goto EXIT

echo.
echo [ERROR] Invalid option.
echo.

pause
goto MENU


:PUBLISH_GITHUB

cls

echo.
echo ============================================================
echo                    PUBLISH TO GITHUB
echo ============================================================
echo.

call :PREPARE_COMMIT

if errorlevel 1 (
    echo.
    echo [ERROR] Commit preparation failed.
    echo [INFO] Push operation cancelled.
    echo.
    pause
    goto MENU
)

echo.
echo ============================================================
echo                       PUSH GITHUB
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
echo                     PUBLISH TO GITEE
echo ============================================================
echo.

call :PREPARE_COMMIT

if errorlevel 1 (
    echo.
    echo [ERROR] Commit preparation failed.
    echo [INFO] Push operation cancelled.
    echo.
    pause
    goto MENU
)

echo.
echo ============================================================
echo                        PUSH GITEE
echo ============================================================
echo.

call :PUSH_GITEE

echo.
pause
goto MENU


:PUBLISH_GITCODE

cls

echo.
echo ============================================================
echo                    PUBLISH TO GITCODE
echo ============================================================
echo.

call :PREPARE_COMMIT

if errorlevel 1 (
    echo.
    echo [ERROR] Commit preparation failed.
    echo [INFO] Push operation cancelled.
    echo.
    pause
    goto MENU
)

echo.
echo ============================================================
echo                       PUSH GITCODE
echo ============================================================
echo.

call :PUSH_GITCODE

echo.
pause
goto MENU


:PUBLISH_ALL

cls

echo.
echo ============================================================
echo          PUBLISH TO GITHUB + GITEE + GITCODE
echo ============================================================
echo.

set "GITHUB_RESULT=SKIP"
set "GITEE_RESULT=SKIP"
set "GITCODE_RESULT=SKIP"

call :PREPARE_COMMIT

if errorlevel 1 (
    echo.
    echo [ERROR] Commit preparation failed.
    echo [INFO] All push operations cancelled.
    echo.
    pause
    goto MENU
)

echo.
echo ============================================================
echo                       PUSH GITHUB
echo ============================================================
echo.

call :PUSH_GITHUB

echo.
echo ============================================================
echo                        PUSH GITEE
echo ============================================================
echo.

call :PUSH_GITEE

echo.
echo ============================================================
echo                       PUSH GITCODE
echo ============================================================
echo.

call :PUSH_GITCODE

echo.
echo ============================================================
echo                       PUSH SUMMARY
echo ============================================================
echo.

echo GitHub : %GITHUB_RESULT%
echo Gitee  : %GITEE_RESULT%
echo GitCode: %GITCODE_RESULT%

echo.
echo ============================================================
echo.

pause
goto MENU


:PREPARE_COMMIT

set "STATUS_FILE=%TEMP%\git_publish_status.txt"

git status --porcelain > "%STATUS_FILE%"

set "HAS_CHANGES=0"

for /f "usebackq delims=" %%A in ("%STATUS_FILE%") do (
    set "HAS_CHANGES=1"
)

del "%STATUS_FILE%" >nul 2>nul

if "%HAS_CHANGES%"=="0" goto NO_CHANGES

echo.
echo [INFO] Changes detected.
echo.

git status --short

echo.
echo ============================================================
echo                       CREATE COMMIT
echo ============================================================
echo.

git add .

if errorlevel 1 (
    echo.
    echo [ERROR] git add failed.
    echo.
    exit /b 1
)

echo [OK] Files staged.
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
    echo [ERROR] Commit failed.
    echo.
    exit /b 1
)

echo.
echo [OK] Commit created.
echo.

exit /b 0


:NO_CHANGES

echo.
echo [INFO] No uncommitted changes found.
echo [INFO] No new commit will be created.
echo.

exit /b 0


:PUSH_GITHUB

git remote get-url %GITHUB_REMOTE% >nul 2>nul

if errorlevel 1 (
    echo [ERROR] GitHub remote not found.
    set "GITHUB_RESULT=FAILED"
    exit /b 1
)

echo GitHub remote:
git remote get-url %GITHUB_REMOTE%

echo.

set "RETRY=1"

:PUSH_GITHUB_RETRY

echo [GitHub] Push attempt %RETRY% of 3...
echo.

git push %GITHUB_REMOTE% %BRANCH%

if not errorlevel 1 goto GITHUB_SUCCESS

echo.
echo [GitHub] Push failed.

if "%RETRY%"=="3" goto GITHUB_FAILED

set /a RETRY+=1

echo.
echo [INFO] Retrying in 5 seconds...
timeout /t 5 /nobreak >nul

goto PUSH_GITHUB_RETRY


:GITHUB_SUCCESS

echo.
echo [OK] GitHub push completed.
set "GITHUB_RESULT=SUCCESS"
echo.

exit /b 0


:GITHUB_FAILED

echo.
echo [FAILED] GitHub push failed after 3 attempts.
echo [INFO] Local commit is safe.
set "GITHUB_RESULT=FAILED"
echo.

exit /b 1


:PUSH_GITEE

git remote get-url %GITEE_REMOTE% >nul 2>nul

if errorlevel 1 (
    echo [ERROR] Gitee remote not found.
    set "GITEE_RESULT=FAILED"
    exit /b 1
)

echo Gitee remote:
git remote get-url %GITEE_REMOTE%

echo.

set "RETRY=1"

:PUSH_GITEE_RETRY

echo [Gitee] Push attempt %RETRY% of 3...
echo.

git push %GITEE_REMOTE% %BRANCH%

if not errorlevel 1 goto GITEE_SUCCESS

echo.
echo [Gitee] Push failed.

if "%RETRY%"=="3" goto GITEE_FAILED

set /a RETRY+=1

echo.
echo [INFO] Retrying in 5 seconds...
timeout /t 5 /nobreak >nul

goto PUSH_GITEE_RETRY


:GITEE_SUCCESS

echo.
echo [OK] Gitee push completed.
set "GITEE_RESULT=SUCCESS"
echo.

exit /b 0


:GITEE_FAILED

echo.
echo [FAILED] Gitee push failed after 3 attempts.
echo [INFO] Local commit is safe.
set "GITEE_RESULT=FAILED"
echo.

exit /b 1


:PUSH_GITCODE

git remote get-url %GITCODE_REMOTE% >nul 2>nul

if errorlevel 1 (
    echo [ERROR] GitCode remote not found.
    echo.
    echo Add GitCode remote with:
    echo.
    echo git remote add gitcode git@gitcode.com:nicepoem/vuepress-theme-plume.git
    echo.
    set "GITCODE_RESULT=FAILED"
    exit /b 1
)

echo GitCode remote:
git remote get-url %GITCODE_REMOTE%

echo.

set "RETRY=1"

:PUSH_GITCODE_RETRY

echo [GitCode] Push attempt %RETRY% of 3...
echo.

git push %GITCODE_REMOTE% %BRANCH%

if not errorlevel 1 goto GITCODE_SUCCESS

echo.
echo [GitCode] Push failed.

if "%RETRY%"=="3" goto GITCODE_FAILED

set /a RETRY+=1

echo.
echo [INFO] Retrying in 5 seconds...
timeout /t 5 /nobreak >nul

goto PUSH_GITCODE_RETRY


:GITCODE_SUCCESS

echo.
echo [OK] GitCode push completed.
set "GITCODE_RESULT=SUCCESS"
echo.

exit /b 0


:GITCODE_FAILED

echo.
echo [FAILED] GitCode push failed after 3 attempts.
echo [INFO] Local commit is safe.
echo.
set "GITCODE_RESULT=FAILED"

exit /b 1


:SHOW_STATUS

cls

echo.
echo ============================================================
echo                       GIT STATUS
echo ============================================================
echo.

git status

echo.
echo ============================================================
echo.

pause
goto MENU


:SHOW_REMOTE

cls

echo.
echo ============================================================
echo                      GIT REMOTES
echo ============================================================
echo.

git remote -v

echo.
echo ============================================================
echo.

pause
goto MENU


:TEST_GITHUB

cls

echo.
echo ============================================================
echo                    TEST GITHUB SSH
echo ============================================================
echo.

git remote get-url %GITHUB_REMOTE%

echo.
echo Testing GitHub SSH...
echo.

git ls-remote %GITHUB_REMOTE%

if not errorlevel 1 goto GITHUB_TEST_SUCCESS

echo.
echo [FAILED] GitHub SSH connection failed.
echo.

pause
goto MENU


:GITHUB_TEST_SUCCESS

echo.
echo [OK] GitHub SSH connection works.
echo.

pause
goto MENU


:TEST_GITEE

cls

echo.
echo ============================================================
echo                       TEST GITEE
echo ============================================================
echo.

git remote get-url %GITEE_REMOTE%

echo.
echo Testing Gitee...
echo.

git ls-remote %GITEE_REMOTE%

if not errorlevel 1 goto GITEE_TEST_SUCCESS

echo.
echo [INFO] Gitee returned no remote branch.
echo.
echo If the repository is empty, this is normal.
echo You can use option [2] to publish.
echo.

pause
goto MENU


:GITEE_TEST_SUCCESS

echo.
echo [OK] Gitee connection works.
echo.

pause
goto MENU


:TEST_GITCODE

cls

echo.
echo ============================================================
echo                     TEST GITCODE SSH
echo ============================================================
echo.

git remote get-url %GITCODE_REMOTE%

echo.
echo Testing GitCode SSH...
echo.

git ls-remote %GITCODE_REMOTE%

if not errorlevel 1 goto GITCODE_TEST_SUCCESS

echo.
echo [FAILED] GitCode SSH connection failed.
echo.
echo Check:
echo.
echo 1. GitCode SSH key configuration
echo 2. GitCode remote URL
echo 3. SSH authentication
echo.

pause
goto MENU


:GITCODE_TEST_SUCCESS

echo.
echo [OK] GitCode SSH connection works.
echo.

pause
goto MENU


:EXIT

cls

echo.
echo ============================================================
echo                  Git Publisher
echo ============================================================
echo.
echo Program exited.
echo.

pause

exit /b 0
```
