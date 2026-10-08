```bat
@echo off
chcp 65001 >nul
setlocal EnableExtensions EnableDelayedExpansion

:: ============================================================
:: Git 一键发布工具
:: ------------------------------------------------------------
:: 功能：
::   1. 自动进入脚本目录
::   2. 检查 Git 环境
::   3. 检查 Git 仓库
::   4. 检查当前分支
::   5. 检查远程仓库
::   6. 检查工作区
::   7. 自动 git add
::   8. 自动 commit
::   9. 检查远程是否领先
::  10. 必要时自动 pull --rebase
::  11. push 自动重试
::  12. 检测 GitHub SSH 连接
::  13. push 失败给出详细诊断
::  14. 防止重复 commit
::  15. 保证本地 commit 不因网络问题丢失
:: ============================================================


:: ============================================================
:: 基础配置
:: ============================================================

set "SCRIPT_VERSION=2.0.0"
set "MAX_PUSH_RETRY=3"
set "RETRY_WAIT=3"

:: 进入脚本所在目录
cd /d "%~dp0"


:: ============================================================
:: 标题
:: ============================================================

title Git 一键发布 v%SCRIPT_VERSION%

cls

echo.
echo ============================================================
echo                    Git 一键发布工具
echo ============================================================
echo.
echo  Version : %SCRIPT_VERSION%
echo  Path    : %cd%
echo.
echo ============================================================
echo.


:: ============================================================
:: [1] 检查 Git
:: ============================================================

echo [1/10] 检查 Git 环境...
echo.

where git >nul 2>&1

if errorlevel 1 (
    echo [错误] 未检测到 Git。
    echo.
    echo 请先安装 Git：
    echo https://git-scm.com/
    echo.
    goto FAILED
)

for /f "delims=" %%i in ('git --version') do (
    set "GIT_VERSION=%%i"
)

echo [完成] !GIT_VERSION!
echo.


:: ============================================================
:: [2] 检查 Git 仓库
:: ============================================================

echo [2/10] 检查 Git 仓库...
echo.

git rev-parse --is-inside-work-tree >nul 2>&1

if errorlevel 1 (
    echo [错误] 当前目录不是 Git 仓库。
    echo.
    echo 当前目录：
    echo %cd%
    echo.
    echo 如果这是一个新项目，可以执行：
    echo.
    echo     git init
    echo.
    goto FAILED
)

echo [完成] 当前目录是 Git 仓库。
echo.


:: ============================================================
:: [3] 获取当前分支
:: ============================================================

echo [3/10] 检查当前分支...
echo.

set "BRANCH="

for /f "delims=" %%i in ('git branch --show-current') do (
    set "BRANCH=%%i"
)

if "!BRANCH!"=="" (
    echo [错误] 无法获取当前分支。
    echo.
    echo 当前可能处于 detached HEAD 状态。
    echo.
    echo 请先切换到正常分支，例如：
    echo.
    echo     git switch main
    echo.
    goto FAILED
)

echo [完成] 当前分支：!BRANCH!
echo.


:: ============================================================
:: [4] 检查远程仓库
:: ============================================================

echo [4/10] 检查远程仓库...
echo.

set "REMOTE_URL="

for /f "delims=" %%i in ('git remote get-url origin 2^>nul') do (
    set "REMOTE_URL=%%i"
)

if "!REMOTE_URL!"=="" (
    echo [错误] 未配置 origin 远程仓库。
    echo.
    echo 当前远程仓库：
    git remote -v
    echo.
    echo 可以使用：
    echo.
    echo     git remote add origin 仓库地址
    echo.
    goto FAILED
)

echo [完成] origin
echo.
echo       !REMOTE_URL!
echo.


:: ============================================================
:: [5] 检查工作区
:: ============================================================

echo [5/10] 检查工作区...
echo.

set "HAS_CHANGE=0"

git status --porcelain > "%TEMP%\git_publish_status.txt"

for %%A in ("%TEMP%\git_publish_status.txt") do (
    if %%~zA GTR 0 set "HAS_CHANGE=1"
)

if "!HAS_CHANGE!"=="1" (

    echo [信息] 检测到文件变化：
    echo.

    type "%TEMP%\git_publish_status.txt"

    echo.

) else (

    echo [完成] 工作区没有新的文件修改。
)

del "%TEMP%\git_publish_status.txt" >nul 2>&1

echo.


:: ============================================================
:: [6] 添加并提交
:: ============================================================

echo [6/10] 处理本地提交...
echo.

if "!HAS_CHANGE!"=="1" (

    echo 正在添加文件...
    git add -A

    if errorlevel 1 (
        echo.
        echo [错误] git add 失败。
        goto FAILED
    )

    echo [完成] 文件已添加到暂存区。
    echo.

    :: 检查暂存区
    git diff --cached --quiet

    if errorlevel 1 (

        echo ----------------------------------------
        echo 创建 Git Commit
        echo ----------------------------------------
        echo.

        set "COMMIT_MSG="

        set /p "COMMIT_MSG=请输入提交信息，直接回车使用默认信息: "

        if "!COMMIT_MSG!"=="" (

            for /f "delims=" %%i in ('powershell -NoProfile -Command "Get-Date -Format yyyy-MM-ddTHH\:mm\:ss"') do (
                set "NOW=%%i"
            )

            set "COMMIT_MSG=更新代码 !NOW!"
        )

        echo.
        echo [信息] Commit：
        echo !COMMIT_MSG!
        echo.

        git commit -m "!COMMIT_MSG!"

        if errorlevel 1 (
            echo.
            echo [错误] Commit 创建失败。
            goto FAILED
        )

        echo.
        echo [完成] Commit 创建成功。

    ) else (

        echo [信息] 暂存区没有实际变化，跳过 Commit。
    )

) else (

    echo [信息] 没有新的文件需要提交。
)

echo.


:: ============================================================
:: 显示最新 Commit
:: ============================================================

echo ----------------------------------------
echo 当前最新 Commit
echo ----------------------------------------
echo.

git log -1 --oneline

echo.


:: ============================================================
:: [7] 获取远程信息
:: ============================================================

echo [7/10] 检查远程仓库状态...
echo.

echo 正在获取远程最新信息...

git fetch origin

if errorlevel 1 (

    echo.
    echo [警告] git fetch 失败。
    echo.
    echo 这通常是网络连接问题。
    echo.
    echo 由于本地 Commit 已经存在，
    echo 不会删除或回滚你的代码。
    echo.
    echo 后续仍然可以直接 push。
    echo.

) else (

    echo [完成] 远程信息获取成功。
)

echo.


:: ============================================================
:: [8] 判断本地 / 远程关系
:: ============================================================

echo [8/10] 分析本地与远程分支...
echo.

set "AHEAD=0"
set "BEHIND=0"

for /f "tokens=1,2" %%a in (
    'git rev-list --left-right --count origin/!BRANCH!...!BRANCH! 2^>nul'
) do (
    set "BEHIND=%%a"
    set "AHEAD=%%b"
)

echo [信息] 远程领先：!BEHIND! 个提交
echo [信息] 本地领先：!AHEAD! 个提交
echo.


:: ============================================================
:: 如果远程领先，自动 rebase
:: ============================================================

if "!BEHIND!" GTR "0" (

    echo ----------------------------------------
    echo 远程仓库存在新的提交
    echo ----------------------------------------
    echo.

    echo [操作] 正在执行：
    echo.
    echo     git pull --rebase origin !BRANCH!
    echo.

    git pull --rebase origin "!BRANCH!"

    if errorlevel 1 (

        echo.
        echo ====================================================
        echo [错误] 自动 Rebase 失败
        echo ====================================================
        echo.
        echo 可能存在代码冲突。
        echo.
        echo 请手动执行：
        echo.
        echo     git status
        echo.
        echo 解决冲突后：
        echo.
        echo     git add .
        echo     git rebase --continue
        echo.
        echo 如果不想继续 Rebase：
        echo.
        echo     git rebase --abort
        echo.
        goto FAILED
    )

    echo.
    echo [完成] 远程代码已 Rebase。
    echo.
)


:: ============================================================
:: [9] Push
:: ============================================================

echo [9/10] 推送到远程仓库...
echo.

set "PUSH_SUCCESS=0"
set "PUSH_COUNT=0"

:PUSH_RETRY

set /a PUSH_COUNT+=1

echo ----------------------------------------
echo Push 第 !PUSH_COUNT! / %MAX_PUSH_RETRY% 次
echo ----------------------------------------
echo.

git push origin "!BRANCH!"

if not errorlevel 1 (
    set "PUSH_SUCCESS=1"
    goto PUSH_OK
)

if !PUSH_COUNT! GEQ %MAX_PUSH_RETRY% (
    goto PUSH_FAILED
)

echo.
echo [警告] Push 失败。
echo.
echo %RETRY_WAIT% 秒后自动重试...
echo.

timeout /t %RETRY_WAIT% /nobreak >nul

goto PUSH_RETRY


:: ============================================================
:: Push 成功
:: ============================================================

:PUSH_OK

echo.
echo ============================================================
echo                    发布成功
echo ============================================================
echo.

echo [完成] Git Push 成功！
echo.

echo 项目目录：
echo     %cd%
echo.

echo 当前分支：
echo     !BRANCH!
echo.

echo 远程仓库：
echo     !REMOTE_URL!
echo.

echo 最新 Commit：
git log -1 --oneline

echo.

echo 发布状态：
echo     ✓ 工作区检查
echo     ✓ Commit
echo     ✓ Remote 同步
echo     ✓ Push
echo.

echo ============================================================
echo                    操作完成
echo ============================================================
echo.

pause
exit /b 0


:: ============================================================
:: Push 失败
:: ============================================================

:PUSH_FAILED

echo.
echo ============================================================
echo                    发布失败
echo ============================================================
echo.

echo [错误] Push 连续 %MAX_PUSH_RETRY% 次失败。
echo.

echo ----------------------------------------
echo 当前状态
echo ----------------------------------------
echo.

echo 分支：
echo     !BRANCH!
echo.

echo 远程：
echo     !REMOTE_URL!
echo.

echo 最新 Commit：
git log -1 --oneline

echo.

:: ------------------------------------------------------------
:: GitHub SSH 检测
:: ------------------------------------------------------------

echo ----------------------------------------
echo GitHub SSH 网络检测
echo ----------------------------------------
echo.

echo "!REMOTE_URL!" | findstr /i "github.com" >nul

if not errorlevel 1 (

    echo [检测] 当前远程仓库属于 GitHub。
    echo.

    echo "!REMOTE_URL!" | findstr /i "ssh.github.com" >nul

    if not errorlevel 1 (

        echo [检测] 使用 GitHub SSH 443。
        echo.
        echo 正在测试：
        echo     ssh.github.com:443
        echo.

        ssh -T -p 443 git@ssh.github.com

        if errorlevel 1 (
            echo.
            echo [诊断] GitHub SSH 连接失败。
            echo.
            echo 建议切换 HTTPS：
            echo.
            echo     git remote set-url origin https://github.com/用户名/仓库.git
            echo.
        )
    )
)

:: ------------------------------------------------------------
:: 判断是否可能是远程领先
:: ------------------------------------------------------------

echo.
echo ----------------------------------------
echo 检查远程状态
echo ----------------------------------------
echo.

git fetch origin >nul 2>&1

if not errorlevel 1 (

    set "REMOTE_BEHIND=0"
    set "REMOTE_AHEAD=0"

    for /f "tokens=1,2" %%a in (
        'git rev-list --left-right --count origin/!BRANCH!...!BRANCH! 2^>nul'
    ) do (
        set "REMOTE_BEHIND=%%a"
        set "REMOTE_AHEAD=%%b"
    )

    echo 远程领先：!REMOTE_BEHIND!
    echo 本地领先：!REMOTE_AHEAD!

    if "!REMOTE_BEHIND!" GTR "0" (
        echo.
        echo [提示] 远程存在新的提交。
        echo.
        echo 建议执行：
        echo.
        echo     git pull --rebase origin !BRANCH!
        echo.
    )
)

echo.
echo ============================================================
echo                     重要提示
echo ============================================================
echo.

echo 本地 Commit 已经保存。
echo.
echo 即使 Push 失败，你的代码也不会因为本脚本而丢失。
echo.
echo 网络恢复后可以直接执行：
echo.
echo     git push origin !BRANCH!
echo.

echo ============================================================
echo.

pause
exit /b 1


:: ============================================================
:: 通用失败
:: ============================================================

:FAILED

echo.
echo ============================================================
echo                    操作失败
echo ============================================================
echo.

echo [提示] 脚本没有删除你的代码。
echo [提示] 已经创建的 Commit 仍然保存在本地。
echo.

echo 当前 Git 状态：
echo.

git status

echo.
echo ============================================================
echo.

pause
exit /b 1
```
