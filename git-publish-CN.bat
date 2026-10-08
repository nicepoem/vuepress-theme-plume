```bat
@echo off
chcp 65001 >nul
setlocal EnableExtensions EnableDelayedExpansion

cd /d "%~dp0"

title Git 多平台发布工具

:: ============================================================
:: 基础配置
:: ============================================================

set "BRANCH=main"

set "GITHUB_REMOTE=origin"
set "GITEE_REMOTE=gitee"
set "GITCODE_REMOTE=gitcode"

:: ============================================================
:: 启动检查
:: ============================================================

:START

cls

echo.
echo ============================================================
echo                    Git 多平台发布工具
echo ============================================================
echo.
echo 当前项目：
echo %CD%
echo.
echo 当前分支：%BRANCH%
echo.

where git >nul 2>nul

if errorlevel 1 (
    echo [错误] 未检测到 Git。
    echo.
    echo 请先安装 Git。
    echo.
    pause
    exit /b 1
)

git rev-parse --is-inside-work-tree >nul 2>nul

if errorlevel 1 (
    echo [错误] 当前目录不是 Git 仓库。
    echo.
    pause
    exit /b 1
)

echo [成功] Git 环境正常。
echo [成功] Git 仓库检测通过。
echo.

:: ============================================================
:: 主菜单
:: ============================================================

:MENU

echo.
echo ============================================================
echo                         主菜单
echo ============================================================
echo.
echo   [1] 发布到 GitHub
echo   [2] 发布到 Gitee
echo   [3] 发布到 GitCode
echo   [4] GitHub + Gitee + GitCode 同时发布
echo.
echo   [5] 查看 Git 状态
echo   [6] 查看远程仓库
echo   [7] 测试 GitHub SSH
echo   [8] 测试 Gitee
echo   [9] 测试 GitCode
echo.
echo   [0] 退出
echo.
echo ============================================================
echo.

set "CHOICE="
set /p "CHOICE=请输入选项："

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
echo [错误] 无效选项，请重新输入。
echo.

pause
goto MENU


:: ============================================================
:: 发布到 GitHub
:: ============================================================

:PUBLISH_GITHUB

cls

echo.
echo ============================================================
echo                     发布到 GitHub
echo ============================================================
echo.

call :PREPARE_COMMIT

echo.
echo ============================================================
echo                     推送 GitHub
echo ============================================================
echo.

call :PUSH_GITHUB

echo.
pause
goto MENU


:: ============================================================
:: 发布到 Gitee
:: ============================================================

:PUBLISH_GITEE

cls

echo.
echo ============================================================
echo                      发布到 Gitee
echo ============================================================
echo.

call :PREPARE_COMMIT

echo.
echo ============================================================
echo                      推送 Gitee
echo ============================================================
echo.

call :PUSH_GITEE

echo.
pause
goto MENU


:: ============================================================
:: 发布到 GitCode
:: ============================================================

:PUBLISH_GITCODE

cls

echo.
echo ============================================================
echo                     发布到 GitCode
echo ============================================================
echo.

call :PREPARE_COMMIT

echo.
echo ============================================================
echo                     推送 GitCode
echo ============================================================
echo.

call :PUSH_GITCODE

echo.
pause
goto MENU


:: ============================================================
:: GitHub + Gitee + GitCode
:: ============================================================

:PUBLISH_ALL

cls

echo.
echo ============================================================
echo             GitHub + Gitee + GitCode 同时发布
echo ============================================================
echo.

call :PREPARE_COMMIT

echo.
echo ============================================================
echo                     推送 GitHub
echo ============================================================
echo.

call :PUSH_GITHUB

echo.
echo ============================================================
echo                      推送 Gitee
echo ============================================================
echo.

call :PUSH_GITEE

echo.
echo ============================================================
echo                     推送 GitCode
echo ============================================================
echo.

call :PUSH_GITCODE

echo.
echo ============================================================
echo                       发布完成
echo ============================================================
echo.

pause
goto MENU


:: ============================================================
:: 检查修改并创建 Commit
:: ============================================================

:PREPARE_COMMIT

git status --porcelain > "%TEMP%\git_publish_status.txt"

set "HAS_CHANGES=0"

for /f "usebackq delims=" %%A in ("%TEMP%\git_publish_status.txt") do (
    set "HAS_CHANGES=1"
)

del "%TEMP%\git_publish_status.txt" >nul 2>nul

if "%HAS_CHANGES%"=="0" goto NO_CHANGES

echo.
echo [提示] 检测到文件修改。
echo.

git status --short

echo.
echo ============================================================
echo                       提交代码
echo ============================================================
echo.

git add .

if errorlevel 1 (
    echo.
    echo [错误] git add 执行失败。
    echo.
    exit /b 1
)

echo [成功] 文件已经加入暂存区。
echo.

set "COMMIT_MESSAGE="

set /p "COMMIT_MESSAGE=请输入 Commit 信息："

if "%COMMIT_MESSAGE%"=="" (
    set "COMMIT_MESSAGE=更新代码"
)

echo.
echo Commit 信息：
echo %COMMIT_MESSAGE%
echo.

git commit -m "%COMMIT_MESSAGE%"

if errorlevel 1 (
    echo.
    echo [错误] Commit 创建失败。
    echo.
    exit /b 1
)

echo.
echo [成功] Commit 创建成功。
echo.

exit /b 0


:NO_CHANGES

echo.
echo [提示] 当前没有未提交的文件修改。
echo [提示] 不创建新的 Commit。
echo.

exit /b 0


:: ============================================================
:: 推送 GitHub
:: ============================================================

:PUSH_GITHUB

git remote get-url %GITHUB_REMOTE% >nul 2>nul

if errorlevel 1 (
    echo [错误] 未找到 GitHub 远程仓库。
    echo.
    exit /b 1
)

echo GitHub 远程仓库：
git remote get-url %GITHUB_REMOTE%

echo.

set "RETRY=1"

:PUSH_GITHUB_RETRY

echo [GitHub] 正在推送，第 %RETRY% 次尝试...
echo.

git push %GITHUB_REMOTE% %BRANCH%

if not errorlevel 1 goto GITHUB_SUCCESS

echo.
echo [GitHub] 推送失败。

if "%RETRY%"=="3" goto GITHUB_FAILED

set /a RETRY+=1

echo.
echo [提示] 5 秒后重新尝试。
timeout /t 5 /nobreak >nul

goto PUSH_GITHUB_RETRY


:GITHUB_SUCCESS

echo.
echo [成功] GitHub 推送完成。
echo.

exit /b 0


:GITHUB_FAILED

echo.
echo [失败] GitHub 已连续失败 3 次。
echo [提示] 本地 Commit 不会丢失。
echo.

exit /b 1


:: ============================================================
:: 推送 Gitee
:: ============================================================

:PUSH_GITEE

git remote get-url %GITEE_REMOTE% >nul 2>nul

if errorlevel 1 (
    echo [错误] 未找到 Gitee 远程仓库。
    echo.
    exit /b 1
)

echo Gitee 远程仓库：
git remote get-url %GITEE_REMOTE%

echo.

set "RETRY=1"

:PUSH_GITEE_RETRY

echo [Gitee] 正在推送，第 %RETRY% 次尝试...
echo.

git push %GITEE_REMOTE% %BRANCH%

if not errorlevel 1 goto GITEE_SUCCESS

echo.
echo [Gitee] 推送失败。

if "%RETRY%"=="3" goto GITEE_FAILED

set /a RETRY+=1

echo.
echo [提示] 5 秒后重新尝试。
timeout /t 5 /nobreak >nul

goto PUSH_GITEE_RETRY


:GITEE_SUCCESS

echo.
echo [成功] Gitee 推送完成。
echo.

exit /b 0


:GITEE_FAILED

echo.
echo [失败] Gitee 已连续失败 3 次。
echo [提示] 本地 Commit 不会丢失。
echo.

exit /b 1


:: ============================================================
:: 推送 GitCode
:: ============================================================

:PUSH_GITCODE

git remote get-url %GITCODE_REMOTE% >nul 2>nul

if errorlevel 1 (
    echo [错误] 未找到 GitCode 远程仓库。
    echo.
    exit /b 1
)

echo GitCode 远程仓库：
git remote get-url %GITCODE_REMOTE%

echo.

set "RETRY=1"

:PUSH_GITCODE_RETRY

echo [GitCode] 正在推送，第 %RETRY% 次尝试...
echo.

git push %GITCODE_REMOTE% %BRANCH%

if not errorlevel 1 goto GITCODE_SUCCESS

echo.
echo [GitCode] 推送失败。

if "%RETRY%"=="3" goto GITCODE_FAILED

set /a RETRY+=1

echo.
echo [提示] 5 秒后重新尝试。
timeout /t 5 /nobreak >nul

goto PUSH_GITCODE_RETRY


:GITCODE_SUCCESS

echo.
echo [成功] GitCode 推送完成。
echo.

exit /b 0


:GITCODE_FAILED

echo.
echo [失败] GitCode 已连续失败 3 次。
echo [提示] 本地 Commit 不会丢失。
echo.

exit /b 1


:: ============================================================
:: 查看 Git 状态
:: ============================================================

:SHOW_STATUS

cls

echo.
echo ============================================================
echo                       Git 状态
echo ============================================================
echo.

git status

echo.
echo ============================================================
echo.

pause
goto MENU


:: ============================================================
:: 查看远程仓库
:: ============================================================

:SHOW_REMOTE

cls

echo.
echo ============================================================
echo                     远程仓库
echo ============================================================
echo.

git remote -v

echo.
echo ============================================================
echo.

pause
goto MENU


:: ============================================================
:: 测试 GitHub SSH
:: ============================================================

:TEST_GITHUB

cls

echo.
echo ============================================================
echo                   测试 GitHub SSH
echo ============================================================
echo.

echo GitHub 地址：
git remote get-url %GITHUB_REMOTE%

echo.
echo 正在测试 GitHub SSH...
echo.

git ls-remote %GITHUB_REMOTE%

if not errorlevel 1 goto GITHUB_TEST_SUCCESS

echo.
echo [失败] GitHub SSH 连接失败。
echo.

pause
goto MENU


:GITHUB_TEST_SUCCESS

echo.
echo [成功] GitHub SSH 连接正常。
echo.

pause
goto MENU


:: ============================================================
:: 测试 Gitee
:: ============================================================

:TEST_GITEE

cls

echo.
echo ============================================================
echo                     测试 Gitee
echo ============================================================
echo.

echo Gitee 地址：
git remote get-url %GITEE_REMOTE%

echo.
echo 正在测试 Gitee...
echo.

git ls-remote %GITEE_REMOTE%

if not errorlevel 1 goto GITEE_TEST_SUCCESS

echo.
echo [提示] Gitee 没有返回远程分支。
echo.
echo 如果这是刚创建的空仓库，
echo 可以直接使用 [2] 发布到 Gitee。
echo.

pause
goto MENU


:GITEE_TEST_SUCCESS

echo.
echo [成功] Gitee 连接正常。
echo.

pause
goto MENU


:: ============================================================
:: 测试 GitCode
:: ============================================================

:TEST_GITCODE

cls

echo.
echo ============================================================
echo                    测试 GitCode
echo ============================================================
echo.

echo GitCode 地址：
git remote get-url %GITCODE_REMOTE%

echo.
echo 正在测试 GitCode...
echo.

git ls-remote %GITCODE_REMOTE%

if not errorlevel 1 goto GITCODE_TEST_SUCCESS

echo.
echo [提示] GitCode 没有返回远程分支。
echo.
echo 如果这是刚创建的空仓库，
echo 可以直接使用 [3] 发布到 GitCode。
echo.

pause
goto MENU


:GITCODE_TEST_SUCCESS

echo.
echo [成功] GitCode 连接正常。
echo.

pause
goto MENU


:: ============================================================
:: 退出
:: ============================================================

:EXIT

cls

echo.
echo ============================================================
echo                    Git 发布工具
echo ============================================================
echo.
echo 程序已退出。
echo.

pause

exit /b 0
```
