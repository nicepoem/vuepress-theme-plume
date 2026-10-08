```bat
@echo off
setlocal EnableExtensions EnableDelayedExpansion

chcp 65001 >nul
cd /d "%~dp0"

title VuePress Git 发布工具

:: ============================================================
:: 基础配置
:: ============================================================

set "BRANCH=main"
set "GITHUB_REMOTE=origin"
set "GITEE_REMOTE=gitee"

:: ============================================================
:: 启动检查
:: ============================================================

:START
cls

echo.
echo ============================================================
echo                  VuePress Git 发布工具
echo ============================================================
echo.
echo 当前目录：
echo %CD%
echo.
echo 当前分支：%BRANCH%
echo.

where git >nul 2>nul

if errorlevel 1 (
    echo [错误] 未找到 Git。
    echo.
    echo 请先安装 Git：
    echo https://git-scm.com/
    echo.
    pause
    exit /b 1
)

git rev-parse --is-inside-work-tree >nul 2>nul

if errorlevel 1 (
    echo [错误] 当前目录不是 Git 仓库。
    echo.
    echo 当前目录：
    echo %CD%
    echo.
    pause
    exit /b 1
)

echo [成功] Git 环境正常。
echo [成功] 当前目录是 Git 仓库。
echo.

:: ============================================================
:: 菜单
:: ============================================================

:MENU
echo.
echo ============================================================
echo                         主菜单
echo ============================================================
echo.
echo   [1] 发布到 GitHub
echo   [2] 发布到 Gitee
echo   [3] GitHub + Gitee 同时发布
echo.
echo   [4] 查看 Git 状态
echo   [5] 查看远程仓库
echo   [6] 测试 GitHub SSH
echo   [7] 测试 Gitee
echo.
echo   [0] 退出
echo.
echo ============================================================
echo.

set "CHOICE="
set /p "CHOICE=请输入选项："

if "%CHOICE%"=="1" goto PUBLISH_GITHUB
if "%CHOICE%"=="2" goto PUBLISH_GITEE
if "%CHOICE%"=="3" goto PUBLISH_BOTH
if "%CHOICE%"=="4" goto SHOW_STATUS
if "%CHOICE%"=="5" goto SHOW_REMOTE
if "%CHOICE%"=="6" goto TEST_GITHUB
if "%CHOICE%"=="7" goto TEST_GITEE
if "%CHOICE%"=="0" goto EXIT

echo.
echo [错误] 无效选项。
pause
goto MENU


:: ============================================================
:: 检查是否存在修改
:: ============================================================

:CHECK_CHANGES

git status --porcelain > "%TEMP%\git_publish_status.txt"

set "HAS_CHANGES=0"

for /f "usebackq delims=" %%A in ("%TEMP%\git_publish_status.txt") do (
    set "HAS_CHANGES=1"
)

del "%TEMP%\git_publish_status.txt" >nul 2>nul

if "%HAS_CHANGES%"=="1" (
    echo.
    echo [提示] 检测到文件修改。
    echo.
    git status --short
    echo.
    goto COMMIT
)

echo.
echo [提示] 当前没有未提交修改。
echo [提示] 不创建新的 Commit。
echo.
goto :eof


:: ============================================================
:: Commit
:: ============================================================

:COMMIT

echo.
echo ============================================================
echo                      提交代码
echo ============================================================
echo.

git add .

if errorlevel 1 (
    echo.
    echo [错误] git add 执行失败。
    echo.
    pause
    goto MENU
)

echo.
echo [成功] git add 完成。
echo.

set "COMMIT_MESSAGE="

set /p "COMMIT_MESSAGE=请输入 Commit 信息（直接回车使用默认信息）："

if "%COMMIT_MESSAGE%"=="" (
    set "COMMIT_MESSAGE=更新代码 %date% %time%"
)

echo.
echo Commit 信息：
echo %COMMIT_MESSAGE%
echo.

git commit -m "%COMMIT_MESSAGE%"

if errorlevel 1 (
    echo.
    echo [错误] git commit 执行失败。
    echo.
    pause
    goto MENU
)

echo.
echo [成功] Commit 创建成功。
echo.

goto :eof


:: ============================================================
:: GitHub 发布
:: ============================================================

:PUBLISH_GITHUB

cls

echo.
echo ============================================================
echo                    发布到 GitHub
echo ============================================================
echo.

echo 当前分支：
git branch --show-current

echo.

call :CHECK_CHANGES

echo.
echo ============================================================
echo                  开始推送 GitHub
echo ============================================================
echo.

call :PUSH_GITHUB

echo.
pause
goto MENU


:: ============================================================
:: Gitee 发布
:: ============================================================

:PUBLISH_GITEE

cls

echo.
echo ============================================================
echo                     发布到 Gitee
echo ============================================================
echo.

echo 当前分支：
git branch --show-current

echo.

call :CHECK_CHANGES

echo.
echo ============================================================
echo                   开始推送 Gitee
echo ============================================================
echo.

call :PUSH_GITEE

echo.
pause
goto MENU


:: ============================================================
:: GitHub + Gitee
:: ============================================================

:PUBLISH_BOTH

cls

echo.
echo ============================================================
echo                 GitHub + Gitee 同时发布
echo ============================================================
echo.

echo 当前分支：
git branch --show-current

echo.

call :CHECK_CHANGES

echo.
echo ============================================================
echo                      推送 GitHub
echo ============================================================
echo.

call :PUSH_GITHUB

echo.
echo ============================================================
echo                       推送 Gitee
echo ============================================================
echo.

call :PUSH_GITEE

echo.
echo ============================================================
echo                      发布完成
echo ============================================================
echo.

pause
goto MENU


:: ============================================================
:: 推送 GitHub
:: ============================================================

:PUSH_GITHUB

echo.
echo [GitHub] 检查远程仓库...

git remote get-url %GITHUB_REMOTE% >nul 2>nul

if errorlevel 1 (
    echo.
    echo [GitHub] [错误] 未找到远程仓库：%GITHUB_REMOTE%
    echo.
    echo 当前远程仓库：
    git remote -v
    echo.
    exit /b 1
)

echo [GitHub] 远程仓库正常。
echo.

set "RETRY=1"

:PUSH_GITHUB_RETRY

echo [GitHub] 正在推送，第 %RETRY% 次尝试...
echo.

git push %GITHUB_REMOTE% %BRANCH%

if not errorlevel 1 (
    echo.
    echo [GitHub] 推送成功。
    echo.
    exit /b 0
)

echo.
echo [GitHub] 推送失败。

if "%RETRY%"=="3" (
    echo.
    echo [GitHub] 已重试 3 次，仍然失败。
    echo [GitHub] 本地 Commit 不会丢失。
    echo.
    exit /b 1
)

set /a RETRY+=1

echo [GitHub] 5 秒后重试...
timeout /t 5 /nobreak >nul

goto PUSH_GITHUB_RETRY


:: ============================================================
:: 推送 Gitee
:: ============================================================

:PUSH_GITEE

echo.
echo [Gitee] 检查远程仓库...

git remote get-url %GITEE_REMOTE% >nul 2>nul

if errorlevel 1 (
    echo.
    echo [Gitee] [错误] 未找到远程仓库：%GITEE_REMOTE%
    echo.
    echo 当前远程仓库：
    git remote -v
    echo.
    exit /b 1
)

echo [Gitee] 远程仓库正常。
echo.

set "RETRY=1"

:PUSH_GITEE_RETRY

echo [Gitee] 正在推送，第 %RETRY% 次尝试...
echo.

git push %GITEE_REMOTE% %BRANCH%

if not errorlevel 1 (
    echo.
    echo [Gitee] 推送成功。
    echo.
    exit /b 0
)

echo.
echo [Gitee] 推送失败。

if "%RETRY%"=="3" (
    echo.
    echo [Gitee] 已重试 3 次，仍然失败。
    echo [Gitee] 本地 Commit 不会丢失。
    echo.
    exit /b 1
)

set /a RETRY+=1

echo [Gitee] 5 秒后重试...
timeout /t 5 /nobreak >nul

goto PUSH_GITEE_RETRY


:: ============================================================
:: Git 状态
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
echo                     Git 远程仓库
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
echo                    测试 GitHub SSH
echo ============================================================
echo.

echo 当前 GitHub Remote：
git remote get-url origin

echo.
echo 正在测试 GitHub SSH...
echo.

git ls-remote origin

if not errorlevel 1 (
    echo.
    echo [成功] GitHub SSH 连接正常。
) else (
    echo.
    echo [失败] GitHub SSH 连接失败。
    echo.
    echo 请检查：
    echo 1. SSH Key 是否配置
    echo 2. GitHub SSH Key 是否添加
    echo 3. origin 是否使用 git@github.com 地址
)

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

echo 当前 Gitee Remote：
git remote get-url gitee

echo.
echo 正在测试 Gitee...
echo.

git ls-remote gitee

if not errorlevel 1 (
    echo.
    echo [成功] Gitee 连接正常。
) else (
    echo.
    echo [失败] Gitee 连接失败，或者仓库暂时没有远程分支。
    echo.
    echo 如果这是一个刚创建的空 Gitee 仓库，
    echo 可以直接选择菜单 [2] 推送到 Gitee。
)

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
echo 已退出。
echo.
echo ============================================================
echo.

exit /b 0
```
