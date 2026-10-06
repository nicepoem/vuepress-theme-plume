@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

cd /d "%~dp0"

echo ========================================
echo        Git 一键推送脚本
echo ========================================
echo.

git rev-parse --is-inside-work-tree >nul 2>&1
if errorlevel 1 (
    echo [错误] 当前目录不是Git仓库！
    echo 请先运行 git init 初始化仓库
    pause
    exit /b 1
)

for /f "delims=" %%i in ('git branch --show-current') do set "branch=%%i"
if "%branch%"=="" (
    echo [错误] 无法获取当前分支
    pause
    exit /b 1
)

echo [信息] 当前分支: %branch%
echo.

echo [1/4] 检查文件状态...
git status --short
echo.

echo [2/4] 添加所有更改到暂存区...
git add -A
if errorlevel 1 (
    echo [错误] git add 失败
    pause
    exit /b 1
)
echo [完成] 已添加所有更改
echo.

git diff --cached --quiet
if errorlevel 1 (
    set /p commit_msg="请输入提交信息 (直接回车使用默认信息): "
    if "!commit_msg!"=="" (
        for /f "delims=" %%i in ('powershell -NoProfile -Command "Get-Date -Format yyyy-MM-ddTHH:mm:ss"') do set "now=%%i"
        set "commit_msg=更新代码 !now!"
    )

    echo [3/4] 提交更改...
    git commit -m "!commit_msg!"
    if errorlevel 1 (
        echo [错误] 提交失败
        pause
        exit /b 1
    )
    echo [完成] 提交成功
) else (
    echo [3/4] 工作区干净，没有新的暂存变更，跳过提交
)
echo.

echo [4/4] 推送到远程仓库...
git push origin %branch%
if errorlevel 1 (
    echo [错误] 推送失败！
    echo 请检查:
    echo 1. 是否设置了远程仓库 (git remote -v)
    echo 2. 是否有推送权限
    echo 3. 网络连接是否正常
    pause
    exit /b 1
)
echo [完成] 推送成功！
echo.

echo ========================================
echo 操作完成！
echo ========================================
pause
