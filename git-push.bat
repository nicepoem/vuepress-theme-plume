```bat
@echo off
setlocal EnableExtensions EnableDelayedExpansion

:: ============================================================
:: Git 一键发布工具 v4.0
:: GitHub + Gitee
:: ============================================================

title Git 一键发布工具 - vuepress-theme-plume

:: ------------------------------------------------------------
:: 进入脚本所在目录
:: ------------------------------------------------------------
cd /d "%~dp0"

echo.
echo ============================================================
echo             Git 一键发布工具 v4.0
echo             vuepress-theme-plume
echo ============================================================
echo.

:: ------------------------------------------------------------
:: 检查 Git
:: ------------------------------------------------------------
where git >nul 2>nul

if errorlevel 1 (
    echo [错误] 未找到 Git。
    echo.
    echo 请确认 Git 已正确安装，并且 git 已加入 PATH。
    echo.
    pause
    goto :END
)

echo [OK] Git 已安装
echo.

:: ------------------------------------------------------------
:: 检查 Git 仓库
:: ------------------------------------------------------------
git rev-parse --is-inside-work-tree >nul 2>nul

if errorlevel 1 (
    echo [错误] 当前目录不是 Git 仓库。
    echo.
    echo 当前目录：
    echo %CD%
    echo.
    pause
    goto :END
)

echo [OK] Git 仓库检查通过
echo.

:: ------------------------------------------------------------
:: 获取当前分支
:: ------------------------------------------------------------
for /f "delims=" %%i in ('git branch --show-current 2^>nul') do set "BRANCH=%%i"

if not defined BRANCH (
    echo [错误] 无法获取当前 Git 分支。
    echo.
    pause
    goto :END
)

echo 当前分支：%BRANCH%
echo.

:: ------------------------------------------------------------
:: 检查 GitHub
:: ------------------------------------------------------------
git remote get-url origin >nul 2>nul

if errorlevel 1 (
    echo [警告] 未配置 GitHub remote：origin
    set "HAS_GITHUB=0"
) else (
    set "HAS_GITHUB=1"
    for /f "delims=" %%i in ('git remote get-url origin 2^>nul') do set "GITHUB_URL=%%i"
    echo [OK] GitHub：!GITHUB_URL!
)

:: ------------------------------------------------------------
:: 检查 Gitee
:: ------------------------------------------------------------
git remote get-url gitee >nul 2>nul

if errorlevel 1 (
    echo [警告] 未配置 Gitee remote：gitee
    set "HAS_GITEE=0"
) else (
    set "HAS_GITEE=1"
    for /f "delims=" %%i in ('git remote get-url gitee 2^>nul') do set "GITEE_URL=%%i"
    echo [OK] Gitee：!GITEE_URL!
)

echo.
echo ============================================================
echo                         发布目标
echo ============================================================
echo.
echo   [1] GitHub
echo   [2] Gitee
echo   [3] GitHub + Gitee
echo   [0] 退出
echo.

set "CHOICE="
set /p "CHOICE=请选择："

echo.

if "%CHOICE%"=="0" goto :END

if "%CHOICE%"=="1" goto :GITHUB

if "%CHOICE%"=="2" goto :GITEE

if "%CHOICE%"=="3" goto :BOTH

echo [错误] 无效选择。
echo.
pause
goto :END


:: ============================================================
:: Git 状态
:: ============================================================

:CHECK_STATUS

echo ============================================================
echo                     检查本地修改
echo ============================================================
echo.

git status --short

echo.

git diff --quiet
set "DIFF_CODE=%errorlevel%"

git diff --cached --quiet
set "CACHED_CODE=%errorlevel%"

if "%DIFF_CODE%"=="0" if "%CACHED_CODE%"=="0" (
    echo [提示] 当前没有未提交修改。
    echo.
    goto :NO_COMMIT
)

echo [发现] 检测到文件修改。
echo.

echo 添加所有修改...
git add .

if errorlevel 1 (
    echo.
    echo [错误] git add 执行失败。
    echo.
    pause
    goto :END
)

echo [OK] git add 完成
echo.

:: ------------------------------------------------------------
:: 提交
:: ------------------------------------------------------------

set "COMMIT_MSG="

set /p "COMMIT_MSG=请输入提交信息（直接回车使用：更新代码）："

if not defined COMMIT_MSG set "COMMIT_MSG=更新代码"

echo.
echo 提交信息：%COMMIT_MSG%
echo.

git commit -m "%COMMIT_MSG%"

if errorlevel 1 (
    echo.
    echo [错误] git commit 执行失败。
    echo.
    pause
    goto :END
)

echo.
echo [OK] 提交成功
echo.

:NO_COMMIT
goto :EOF


:: ============================================================
:: GitHub
:: ============================================================

:GITHUB

if "%HAS_GITHUB%"=="0" (
    echo [错误] GitHub remote 未配置。
    echo.
    pause
    goto :END
)

call :CHECK_STATUS

echo ============================================================
echo                       推送 GitHub
echo ============================================================
echo.

echo GitHub Remote：
echo !GITHUB_URL!
echo.

echo 正在推送 %BRANCH% ...
echo.

git push origin %BRANCH%

if errorlevel 1 (
    echo.
    echo ========================================================
    echo [失败] GitHub 推送失败
    echo ========================================================
    echo.
    echo 本地提交不会丢失。
    echo 可以稍后重新运行脚本再次推送。
    echo.
    pause
    goto :END
)

echo.
echo ========================================================
echo [成功] GitHub 发布完成
echo ========================================================
echo.

goto :SUCCESS


:: ============================================================
:: Gitee
:: ============================================================

:GITEE

if "%HAS_GITEE%"=="0" (
    echo [错误] Gitee remote 未配置。
    echo.
    pause
    goto :END
)

call :CHECK_STATUS

echo ============================================================
echo                        推送 Gitee
echo ============================================================
echo.

echo Gitee Remote：
echo !GITEE_URL!
echo.

echo 正在推送 %BRANCH% ...
echo.

git push gitee %BRANCH%

if errorlevel 1 (
    echo.
    echo ========================================================
    echo [失败] Gitee 推送失败
    echo ========================================================
    echo.
    echo 本地提交不会丢失。
    echo.
    pause
    goto :END
)

echo.
echo ========================================================
echo [成功] Gitee 发布完成
echo ========================================================
echo.

goto :SUCCESS


:: ============================================================
:: GitHub + Gitee
:: ============================================================

:BOTH

if "%HAS_GITHUB%"=="0" (
    echo [错误] GitHub remote 未配置。
    echo.
    pause
    goto :END
)

if "%HAS_GITEE%"=="0" (
    echo [错误] Gitee remote 未配置。
    echo.
    pause
    goto :END
)

call :CHECK_STATUS

echo ============================================================
echo                  开始双平台发布
echo ============================================================
echo.

:: ------------------------------------------------------------
:: GitHub
:: ------------------------------------------------------------

echo.
echo [1/2] 正在发布到 GitHub...
echo.

git push origin %BRANCH%

if errorlevel 1 (
    echo.
    echo [失败] GitHub 发布失败。
    echo.
    set "GITHUB_RESULT=失败"
) else (
    echo.
    echo [成功] GitHub 发布完成。
    echo.
    set "GITHUB_RESULT=成功"
)

:: ------------------------------------------------------------
:: Gitee
:: ------------------------------------------------------------

echo.
echo [2/2] 正在发布到 Gitee...
echo.

git push gitee %BRANCH%

if errorlevel 1 (
    echo.
    echo [失败] Gitee 发布失败。
    echo.
    set "GITEE_RESULT=失败"
) else (
    echo.
    echo [成功] Gitee 发布完成。
    echo.
    set "GITEE_RESULT=成功"
)

:: ------------------------------------------------------------
:: 最终结果
:: ------------------------------------------------------------

echo.
echo ============================================================
echo                      发布结果
echo ============================================================
echo.
echo   分支：%BRANCH%
echo.
echo   GitHub：%GITHUB_RESULT%
echo   Gitee ：%GITEE_RESULT%
echo.

if "%GITHUB_RESULT%"=="成功" if "%GITEE_RESULT%"=="成功" (
    echo ========================================================
    echo              ✓ GitHub + Gitee 发布成功
    echo ========================================================
) else (
    echo ========================================================
    echo              ! 部分平台发布失败
    echo ========================================================
)

echo.

pause
goto :END


:: ============================================================
:: 单平台成功
:: ============================================================

:SUCCESS

echo ============================================================
echo                         发布成功
echo ============================================================
echo.
echo 当前分支：%BRANCH%
echo.

pause
goto :END


:: ============================================================
:: 结束
:: ============================================================

:END

echo.
echo 按任意键退出...
pause >nul

endlocal
exit /b 0
```
