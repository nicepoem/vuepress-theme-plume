```bat
@echo off
chcp 65001 >nul
setlocal EnableDelayedExpansion

:: ============================================================
:: Git 一键推送脚本
:: 功能：
:: 1. 自动进入脚本所在目录
:: 2. 检查 Git 仓库
:: 3. 检查当前分支
:: 4. 检查远程仓库
:: 5. 自动 git add
:: 6. 有修改才提交
:: 7. 自动生成默认提交信息
:: 8. 推送失败自动重试
:: 9. 区分 SSH / HTTPS 网络错误
:: 10. 防止重复提交
:: ============================================================

title Git 一键推送

:: ------------------------------------------------------------
:: 进入脚本所在目录
:: ------------------------------------------------------------
cd /d "%~dp0"

echo.
echo ========================================
echo          Git 一键推送脚本
echo ========================================
echo.

:: ------------------------------------------------------------
:: 检查 Git 是否安装
:: ------------------------------------------------------------
where git >nul 2>&1

if errorlevel 1 (
    echo [错误] 未检测到 Git！
    echo.
    echo 请先安装 Git，然后重新运行此脚本。
    echo.
    pause
    exit /b 1
)

:: ------------------------------------------------------------
:: 检查当前目录是否为 Git 仓库
:: ------------------------------------------------------------
git rev-parse --is-inside-work-tree >nul 2>&1

if errorlevel 1 (
    echo [错误] 当前目录不是 Git 仓库！
    echo.
    echo 当前目录：
    echo %cd%
    echo.
    echo 如果这是一个新项目，可以执行：
    echo.
    echo     git init
    echo.
    pause
    exit /b 1
)

:: ------------------------------------------------------------
:: 获取当前分支
:: ------------------------------------------------------------
for /f "delims=" %%i in ('git branch --show-current') do (
    set "branch=%%i"
)

if "!branch!"=="" (
    echo [错误] 无法获取当前分支。
    echo.
    echo 当前可能处于 detached HEAD 状态。
    echo.
    pause
    exit /b 1
)

echo [信息] 当前目录: %cd%
echo [信息] 当前分支: !branch!
echo.

:: ------------------------------------------------------------
:: 获取远程仓库
:: ------------------------------------------------------------
for /f "delims=" %%i in ('git remote get-url origin 2^>nul') do (
    set "remote_url=%%i"
)

if "!remote_url!"=="" (
    echo [错误] 未配置 origin 远程仓库！
    echo.
    echo 可以执行：
    echo.
    echo     git remote add origin 仓库地址
    echo.
    echo 查看当前远程仓库：
    echo.
    echo     git remote -v
    echo.
    pause
    exit /b 1
)

echo [信息] 远程仓库: !remote_url!
echo.

:: ------------------------------------------------------------
:: 显示当前状态
:: ------------------------------------------------------------
echo ========================================
echo [1/4] 检查文件状态
echo ========================================
echo.

git status --short

if errorlevel 1 (
    echo.
    echo [错误] 无法获取 Git 状态。
    pause
    exit /b 1
)

echo.

:: ------------------------------------------------------------
:: 添加所有文件
:: ------------------------------------------------------------
echo ========================================
echo [2/4] 添加文件到暂存区
echo ========================================
echo.

git add -A

if errorlevel 1 (
    echo.
    echo [错误] git add 执行失败！
    pause
    exit /b 1
)

echo [完成] 文件已添加到暂存区
echo.

:: ------------------------------------------------------------
:: 判断是否存在需要提交的内容
:: ------------------------------------------------------------
git diff --cached --quiet

if errorlevel 1 (

    echo ========================================
    echo [3/4] 提交更改
    echo ========================================
    echo.

    set "commit_msg="

    set /p "commit_msg=请输入提交信息，直接回车使用默认信息: "

    if "!commit_msg!"=="" (
        for /f "delims=" %%i in ('powershell -NoProfile -Command "Get-Date -Format yyyy-MM-ddTHH\:mm\:ss"') do (
            set "now=%%i"
        )

        set "commit_msg=更新代码 !now!"
    )

    echo.
    echo [信息] 提交信息：
    echo !commit_msg!
    echo.

    git commit -m "!commit_msg!"

    if errorlevel 1 (
        echo.
        echo [错误] Git commit 失败！
        echo.
        pause
        exit /b 1
    )

    echo.
    echo [完成] 提交成功！

) else (

    echo ========================================
    echo [3/4] 提交更改
    echo ========================================
    echo.

    echo [信息] 没有新的文件修改，跳过提交。
)

echo.

:: ------------------------------------------------------------
:: 显示最新 Commit
:: ------------------------------------------------------------
echo [信息] 当前最新提交：

git log -1 --oneline

echo.

:: ------------------------------------------------------------
:: 推送
:: ------------------------------------------------------------
echo ========================================
echo [4/4] 推送到远程仓库
echo ========================================
echo.

echo [信息] 正在推送到 origin/!branch! ...
echo.

git push origin "!branch!"

if not errorlevel 1 (
    goto PUSH_SUCCESS
)

:: ------------------------------------------------------------
:: 第一次推送失败
:: ------------------------------------------------------------
echo.
echo [警告] 第一次推送失败！
echo.

echo ----------------------------------------
echo 正在检查网络连接...
echo ----------------------------------------
echo.

:: ------------------------------------------------------------
:: 判断是否为 GitHub SSH
:: ------------------------------------------------------------
echo "!remote_url!" | findstr /i "github.com" >nul

if not errorlevel 1 (

    echo [检测] 当前远程仓库为 GitHub。

    echo "!remote_url!" | findstr /i "ssh.github.com" >nul

    if not errorlevel 1 (

        echo [检测] 当前使用 GitHub SSH 443 端口。
        echo.
        echo 正在测试 SSH 连接：
        echo ssh.github.com:443
        echo.

        ssh -T -p 443 git@ssh.github.com >nul 2>&1

        if errorlevel 1 (
            echo [错误] GitHub SSH 连接失败！
            echo.
            echo 可能原因：
            echo.
            echo 1. 当前网络无法连接 ssh.github.com:443
            echo 2. 防火墙拦截 SSH
            echo 3. VPN / 代理配置异常
            echo 4. GitHub 网络连接异常
            echo.
            echo 当前远程仓库：
            echo !remote_url!
            echo.
            echo 推荐切换 GitHub HTTPS。
            echo.
            echo 示例：
            echo git remote set-url origin https://github.com/用户名/仓库.git
            echo.
        )
    )
)

:: ------------------------------------------------------------
:: 自动重试一次
:: ------------------------------------------------------------
echo.
echo ----------------------------------------
echo 正在重新尝试推送...
echo ----------------------------------------
echo.

timeout /t 2 /nobreak >nul

git push origin "!branch!"

if not errorlevel 1 (
    goto PUSH_SUCCESS
)

:: ------------------------------------------------------------
:: 推送最终失败
:: ------------------------------------------------------------
echo.
echo ========================================
echo [错误] 推送失败！
echo ========================================
echo.

echo 当前分支：
echo     !branch!
echo.

echo 远程仓库：
echo     !remote_url!
echo.

echo 当前最新 Commit：
git log -1 --oneline

echo.
echo ----------------------------------------
echo 排查建议
echo ----------------------------------------
echo.

echo [1] 查看远程仓库：
echo     git remote -v
echo.

echo [2] 测试 GitHub SSH：
echo     ssh -T -p 443 git@ssh.github.com
echo.

echo [3] 查看 Git 状态：
echo     git status
echo.

echo [4] 如果 SSH 无法连接，可以切换 HTTPS：
echo     git remote set-url origin https://github.com/用户名/仓库.git
echo.

echo [5] 网络恢复后，无需重新 commit，直接执行：
echo     git push origin !branch!
echo.

echo.
echo [重要] 本次提交已经保存在本地，不会丢失！
echo.

pause
exit /b 1


:: ============================================================
:: 推送成功
:: ============================================================
:PUSH_SUCCESS

echo.
echo ========================================
echo        Git 推送成功
echo ========================================
echo.

echo [完成] 已成功推送到远程仓库！
echo.

echo 分支：
echo     !branch!
echo.

echo 远程：
echo     !remote_url!
echo.

echo 最新提交：
git log -1 --oneline

echo.
echo ========================================
echo             操作完成
echo ========================================
echo.

pause
exit /b 0
```
