@echo off
chcp 936 >nul
title RustDesk Config Tool
setlocal EnableExtensions EnableDelayedExpansion

rem Configure these three ASCII-value lines before distribution.
set "ID_SERVER=YOUR_ID_SERVER:21116"
set "RELAY_SERVER=YOUR_RELAY_SERVER:21117"
set "PUBLIC_KEY=YOUR_PUBLIC_KEY"

rem Request administrator permission for the installed RustDesk service.
net session >nul 2>&1
if errorlevel 1 (
    echo 正在请求管理员权限...
    powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b 0
)

echo ================================================
echo          RustDesk 服务器配置工具
echo ================================================
echo.
if "%ID_SERVER%"=="YOUR_ID_SERVER:21116" (
    echo 错误：请先在脚本顶部填写 ID_SERVER。
    pause
    exit /b 1
)
if "%PUBLIC_KEY%"=="YOUR_PUBLIC_KEY" (
    echo 错误：请先在脚本顶部填写 PUBLIC_KEY。
    pause
    exit /b 1
)

echo 目标ID服务器：%ID_SERVER%
if defined RELAY_SERVER echo 目标中转服务器：%RELAY_SERVER%
echo.
echo 正在自动配置，请稍候...

set "USER_CONFIG=%APPDATA%\RustDesk\config\RustDesk2.toml"
set "SERVICE_CONFIG=%SystemRoot%\ServiceProfiles\LocalService\AppData\Roaming\RustDesk\config\RustDesk2.toml"

echo 正在关闭 RustDesk...
taskkill /f /im RustDesk.exe >nul 2>&1
timeout /t 2 /nobreak >nul

call :write_config "%USER_CONFIG%"
call :write_config "%SERVICE_CONFIG%"

if not exist "%USER_CONFIG%" if not exist "%SERVICE_CONFIG%" (
    echo 错误：配置文件写入失败。
    pause
    exit /b 1
)

findstr /L /C:"custom-rendezvous-server = '%ID_SERVER%'" "%USER_CONFIG%" "%SERVICE_CONFIG%" >nul
if errorlevel 1 (
    echo [失败] ID服务器校验失败，配置未生效。
    echo 配置文件：%USER_CONFIG%
    echo 配置文件：%SERVICE_CONFIG%
    pause
    exit /b 1
)
findstr /L /C:"key = '%PUBLIC_KEY%'" "%USER_CONFIG%" "%SERVICE_CONFIG%" >nul
if errorlevel 1 (
    echo [失败] 公钥校验失败，配置未生效。
    echo 配置文件：%USER_CONFIG%
    echo 配置文件：%SERVICE_CONFIG%
    pause
    exit /b 1
)
if defined RELAY_SERVER (
    findstr /L /C:"relay-server = '%RELAY_SERVER%'" "%USER_CONFIG%" "%SERVICE_CONFIG%" >nul
    if errorlevel 1 (
        echo [失败] 中转服务器校验失败，配置未生效。
        echo 配置文件：%USER_CONFIG%
        echo 配置文件：%SERVICE_CONFIG%
        pause
        exit /b 1
    )
)

echo.
echo ================================================
echo [成功] RustDesk服务器配置已写入并校验通过！
echo ID服务器：%ID_SERVER%
if defined RELAY_SERVER echo 中转服务器：%RELAY_SERVER%
echo 用户配置：%USER_CONFIG%
echo 服务配置：%SERVICE_CONFIG%
echo ================================================
echo 正在重启 RustDesk 服务...
net stop RustDesk /y >nul 2>&1
net start RustDesk >nul 2>&1
echo 正在启动 RustDesk...
set "RUSTDESK_EXE="
for %%P in ("%ProgramFiles%\RustDesk\RustDesk.exe" "%ProgramFiles(x86)%\RustDesk\RustDesk.exe" "%LOCALAPPDATA%\Programs\RustDesk\RustDesk.exe") do (
    if not defined RUSTDESK_EXE if exist "%%~P" set "RUSTDESK_EXE=%%~P"
)
if defined RUSTDESK_EXE (
    start "" "%RUSTDESK_EXE%"
    echo RustDesk已启动。
) else (
    echo 未找到RustDesk程序，请手动启动RustDesk使配置生效。
)

echo 配置完成。
pause
endlocal
exit /b 0

:write_config
set "TARGET_FILE=%~1"
set "TARGET_DIR=%~dp1"
if not exist "%TARGET_DIR%" mkdir "%TARGET_DIR%" >nul 2>&1
if exist "%TARGET_FILE%" copy /y "%TARGET_FILE%" "%TARGET_FILE%.bak" >nul
>"%TARGET_FILE%" echo rendezvous_server = '%ID_SERVER%'
>>"%TARGET_FILE%" echo nat_type = 1
>>"%TARGET_FILE%" echo serial = 0
>>"%TARGET_FILE%" echo.
>>"%TARGET_FILE%" echo [options]
>>"%TARGET_FILE%" echo custom-rendezvous-server = '%ID_SERVER%'
if defined RELAY_SERVER >>"%TARGET_FILE%" echo relay-server = '%RELAY_SERVER%'
>>"%TARGET_FILE%" echo key = '%PUBLIC_KEY%'
exit /b 0
