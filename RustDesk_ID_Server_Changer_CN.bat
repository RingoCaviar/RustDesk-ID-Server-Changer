
	:: INFO:
	:: RustDesk Github: https://github.com/rustdesk/rustdesk
	:: RustDesk ID Changer Github: https://github.com/abdullah-erturk/RustDesk-ID-Changer

::===============================================================================================================
@echo off
chcp 936 >nul
mode con:cols=90 lines=45
title RustDesk ID 和服务器修改工具 v3

:: Language check via Get-UICulture (Display Language)
for /f "delims=" %%a in ('powershell -NoProfile -Command "(Get-UICulture).TwoLetterISOLanguageName"') do set OS_LANG=%%a
set LANG_TR=0
:: 中文版固定使用中文界面

net file 1>nul 2>nul && goto :Main || powershell -ex unrestricted -Command "Start-Process -Verb RunAs -FilePath '%comspec%' -ArgumentList '/c ""%~fnx0""""'"
goto :eof
::===============================================================================================================
:Main
cls
set "RUSTDESK_EXE="
set "RUSTDESK_DIR="
set "RUSTDESK_CONFIG_DIR="
set "RUSTDESK_SERVICE=0"

:: Locate installed RustDesk from the uninstall registry entries first, then common paths.
for /f "delims=" %%i in ('powershell -NoProfile -ExecutionPolicy Bypass -Command "$paths=@('HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*','HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*'); $p=Get-ItemProperty $paths -ErrorAction SilentlyContinue | Where-Object {$_.DisplayName -eq 'RustDesk'} | Select-Object -First 1; $c=@(); if($p.InstallLocation){$c+=[IO.Path]::Combine($p.InstallLocation,'rustdesk.exe')}; if($p.DisplayIcon){$c+=($p.DisplayIcon -replace [char]34,'' -replace ',\d+$','')}; $c+='C:\Program Files\RustDesk\rustdesk.exe'; $c+='C:\Program Files (x86)\RustDesk\rustdesk.exe'; $drives=Get-PSDrive -PSProvider FileSystem; foreach($d in $drives){$c+=Join-Path $d.Root 'Program Files\RustDesk\rustdesk.exe'; $c+=Join-Path $d.Root 'Program Files (x86)\RustDesk\rustdesk.exe'}; foreach($x in $c){if(Test-Path -LiteralPath $x){$x; break}}"') do set "RUSTDESK_EXE=%%i"

if not defined RUSTDESK_EXE (
    echo 未找到 RustDesk。
    echo 已检查 RustDesk 卸载注册表项和常见安装路径。
    pause >nul
    exit /b 1
)

for %%i in ("%RUSTDESK_EXE%") do set "RUSTDESK_DIR=%%~dpi"
set "RUSTDESK_DIR=%RUSTDESK_DIR:~0,-1%"
sc query RustDesk >nul 2>&1 && set "RUSTDESK_SERVICE=1"
if "%RUSTDESK_SERVICE%"=="1" (
    set "RUSTDESK_CONFIG_DIR=C:\Windows\ServiceProfiles\LocalService\AppData\Roaming\RustDesk\config"
) else (
    set "RUSTDESK_CONFIG_DIR=%APPDATA%\RustDesk\config"
)
if exist "%RUSTDESK_EXE%" (
cd /d "%RUSTDESK_DIR%"
for /f "delims=" %%i in ('"%RUSTDESK_EXE%" --get-id ^| more') do set rustdesk_id=%%i
goto :Run
) else (
echo.
if %LANG_TR%==1 (
echo RustDesk kurulu de§il, ?nce RustDesk'i kurun.
echo.
echo ??k?? i?in herhangi bir tu?a bas?n.
) else (
echo 未安装 RustDesk，请先安装 RustDesk。
echo.
echo 按任意键退出。
)
pause >nul
exit
)
:Run
pushd %temp% >nul 2>&1
echo.
echo ==========================================================================================
echo.
if %LANG_TR%==1 goto Menu_TR
goto Menu_EN

:Menu_TR
echo			  RustDesk ID ^& Server Changer by Abdullah ERT?RK
echo.
echo.		github.com/abdullah-erturk ^| erturk-dev.netlify.app
echo.
echo.
echo	 	  1 - RustDesk ID'sini bilgisayar ad?yla de§istir : "%computername%"
echo.
echo	 	  2 - RustDesk ID'sini 9 haneli rastgele say?larla de§istir
echo.
echo	 	  3 - RustDesk ID'sini belirtti§iniz de§ere ayarlay?n.
echo.
echo.	-----------------------------------------------------------------
echo.
echo	 	  4 - Public Sunucuya Ge? (Private Sunucu Bilgisini Temizle)
echo.
echo	 	  5 - Private Sunucuya Ge? (Private Sunucu Bilgisini Uygula)
echo.
echo	 	  6 - Yeni Private Sunucu Tan?mla 
echo.
echo	 	  7 - Private Sunucu Yedeklerini Sil 
echo.
echo	 	  8 - ?IKI?
echo.
echo ==========================================================================================
echo.
choice /c 12345678 /cs /n /m "Se?iminiz [1-2-3-4-5-6-7-8] : "
goto Menu_Choice

:Menu_EN
echo			  RustDesk ID 和服务器修改工具
echo.
echo.		github.com/abdullah-erturk ^| erturk-dev.netlify.app
echo.
echo.
echo	 	  1 - 使用计算机名设置 RustDesk ID : "%computername%"
echo.
echo	 	  2 - 使用 9 位随机数字设置 RustDesk ID
echo.
echo	 	  3 - 设置为指定的 RustDesk ID
echo.
echo.	-----------------------------------------------------------------
echo.
echo	 	  4 - 切换到公共服务器（清除自定义服务器信息）
echo.
echo	 	  5 - 切换到私有服务器（应用自定义服务器信息）
echo.
echo	 	  6 - 设置新的私有服务器
echo.
echo	 	  7 - 删除自定义服务器备份
echo.
echo	 	  8 - 退出
echo.
echo ==========================================================================================
echo.
choice /c 12345678 /cs /n /m "请选择 [1-2-3-4-5-6-7-8]："
goto Menu_Choice

:Menu_Choice
echo.
if errorlevel 8 Exit
if errorlevel 7 goto :Delete_Backups
if errorlevel 6 goto :Server_Private_New
if errorlevel 5 goto :Server_Private
if errorlevel 4 goto :Server_Public
if errorlevel 3 goto :ID_UserDefined
if errorlevel 2 goto :ID_Random
if errorlevel 1 goto :ID_Host
echo.
::===============================================================================================================
:ID_Host
echo.
echo $svc = Get-Service -Name RustDesk -ErrorAction SilentlyContinue > RustDesk_ID_Host.ps1
echo $id = Get-Content "%RUSTDESK_CONFIG_DIR%\RustDesk.toml" ^| Select-Object -Index 0 >> RustDesk_ID_Host.ps1
echo $hostname = hostname >> RustDesk_ID_Host.ps1
echo Write-Host "当前 ID： %rustdesk_id%" >> RustDesk_ID_Host.ps1
echo $newId = "id = '$hostname'" >> RustDesk_ID_Host.ps1
echo Write-Host "新 ID： $newId" >> RustDesk_ID_Host.ps1
echo $fileContent = Get-Content -Path "%RUSTDESK_CONFIG_DIR%\RustDesk.toml" >> RustDesk_ID_Host.ps1
echo $newContent = $fileContent -replace [regex]::Escape($id), $newId >> RustDesk_ID_Host.ps1
echo $newContent ^| Set-Content -Path "%RUSTDESK_CONFIG_DIR%\RustDesk.toml" >> RustDesk_ID_Host.ps1
echo if ($svc) { Stop-Service -Name RustDesk -Force -ErrorAction SilentlyContinue; Start-Sleep -Seconds 1 } >> RustDesk_ID_Host.ps1
echo else { Stop-Process -Name "rustdesk" -Force -ErrorAction SilentlyContinue; Start-Sleep -Seconds 1 } >> RustDesk_ID_Host.ps1
echo if ($svc) { Start-Service -Name RustDesk -ErrorAction SilentlyContinue } >> RustDesk_ID_Host.ps1
powershell.exe -ExecutionPolicy Bypass -File RustDesk_ID_Host.ps1
start "" "%RUSTDESK_EXE%" --tray
goto :done
::===============================================================================================================
:ID_Random
echo.
echo $svc = Get-Service -Name RustDesk -ErrorAction SilentlyContinue > RustDesk_ID_Random.ps1
echo $randomId = -join ((48..57) ^| Get-Random -Count 9 ^| ForEach-Object {[char]$_}) >> RustDesk_ID_Random.ps1
echo $id = Get-Content "%RUSTDESK_CONFIG_DIR%\RustDesk.toml" ^| Select-Object -Index 0 >> RustDesk_ID_Random.ps1
echo Write-Host "当前 ID： %rustdesk_id%" >> RustDesk_ID_Random.ps1
echo $newId = "id = '$randomId'" >> RustDesk_ID_Random.ps1
echo Write-Host "新 ID： $newId" >> RustDesk_ID_Random.ps1
echo $fileContent = Get-Content -Path "%RUSTDESK_CONFIG_DIR%\RustDesk.toml" >> RustDesk_ID_Random.ps1
echo $newContent = $fileContent -replace [regex]::Escape($id), $newId >> RustDesk_ID_Random.ps1
echo $newContent ^| Set-Content -Path "%RUSTDESK_CONFIG_DIR%\RustDesk.toml" >> RustDesk_ID_Random.ps1
echo if ($svc) { Stop-Service -Name RustDesk -Force -ErrorAction SilentlyContinue; Start-Sleep -Seconds 1 } >> RustDesk_ID_Random.ps1
echo else { Stop-Process -Name "rustdesk" -Force -ErrorAction SilentlyContinue; Start-Sleep -Seconds 1 } >> RustDesk_ID_Random.ps1
echo if ($svc) { Start-Service -Name RustDesk -ErrorAction SilentlyContinue } >> RustDesk_ID_Random.ps1
powershell.exe -ExecutionPolicy Bypass -File RustDesk_ID_Random.ps1
start "" "%RUSTDESK_EXE%" --tray
goto :done
::===============================================================================================================
:ID_UserDefined
echo.
ver | findstr /c:"Version 10." >nul
if errorlevel 1 (
    echo 此选项仅支持 Windows 10 及更高版本。
    timeout /t 5 >nul
    goto :Main
)
set "RUSTDESK_NEW_ID="
:Ask_ID_CN
set /p RUSTDESK_NEW_ID="请输入 RustDesk ID（至少 6 个字符）："
if not defined RUSTDESK_NEW_ID (
    echo 错误：ID 不能为空。
    echo.
    goto Ask_ID_CN
)
if "%RUSTDESK_NEW_ID:~5,1%"=="" (
    echo 错误：ID 至少需要 6 个字符。
    echo.
    goto Ask_ID_CN
)
echo $svc = Get-Service -Name RustDesk -ErrorAction SilentlyContinue > RustDesk_ID_UserDefined.ps1
echo $id = Get-Content "%RUSTDESK_CONFIG_DIR%\RustDesk.toml" ^| Select-Object -Index 0 >> RustDesk_ID_UserDefined.ps1
echo Write-Host "当前 ID： %rustdesk_id%" >> RustDesk_ID_UserDefined.ps1
echo $newId = "id = '%RUSTDESK_NEW_ID%'" >> RustDesk_ID_UserDefined.ps1
echo Write-Host "新 ID： $newId" >> RustDesk_ID_UserDefined.ps1
echo $fileContent = Get-Content -Path "%RUSTDESK_CONFIG_DIR%\RustDesk.toml" >> RustDesk_ID_UserDefined.ps1
echo $newContent = $fileContent -replace [regex]::Escape($id), $newId >> RustDesk_ID_UserDefined.ps1
echo $newContent ^| Set-Content -Path "%RUSTDESK_CONFIG_DIR%\RustDesk.toml" >> RustDesk_ID_UserDefined.ps1
echo if ($svc) { Stop-Service -Name RustDesk -Force -ErrorAction SilentlyContinue; Start-Sleep -Seconds 1 } >> RustDesk_ID_UserDefined.ps1
echo else { Stop-Process -Name "rustdesk" -Force -ErrorAction SilentlyContinue; Start-Sleep -Seconds 1 } >> RustDesk_ID_UserDefined.ps1
echo if ($svc) { Start-Service -Name RustDesk -ErrorAction SilentlyContinue } >> RustDesk_ID_UserDefined.ps1
powershell.exe -ExecutionPolicy Bypass -File RustDesk_ID_UserDefined.ps1
start "" "%RUSTDESK_EXE%" --tray
goto :done
::===============================================================================================================
:Server_Public
echo.
echo $isPublic = $true > check_public.ps1
echo $paths = @("%RUSTDESK_CONFIG_DIR%\RustDesk2.toml") >> check_public.ps1
echo foreach ($path in $paths) { if (Test-Path $path) { $content = Get-Content $path; if (($content -match "^custom-rendezvous-server") -or ($content -match "^api-server") -or ($content -match "^custom-rs-server")) { $isPublic = $false } } } >> check_public.ps1
echo if ($isPublic) { exit 1 } else { exit 0 } >> check_public.ps1
powershell.exe -ExecutionPolicy Bypass -File check_public.ps1
if errorlevel 1 (
    del check_public.ps1 >nul 2>&1
    if %LANG_TR%==1 (
        echo Zaten Public Sunucu kullan?yorsunuz. ??lem yap?lmad?.
    ) else (
        echo 当前已经在使用公共服务器，无需操作。
    )
    goto :done
)
del check_public.ps1 >nul 2>&1

echo $svc = Get-Service -Name RustDesk -ErrorAction SilentlyContinue > RustDesk_Server_Public.ps1
echo $paths = @("%RUSTDESK_CONFIG_DIR%\RustDesk2.toml") >> RustDesk_Server_Public.ps1
echo foreach ($path in $paths) { >> RustDesk_Server_Public.ps1
echo     if (Test-Path $path) { >> RustDesk_Server_Public.ps1
echo         $content = Get-Content $path >> RustDesk_Server_Public.ps1
echo         $hasCustom = ($content -match "^custom-rendezvous-server" -or $content -match "^api-server" -or $content -match "^custom-rs-server") >> RustDesk_Server_Public.ps1
echo         if ($hasCustom) { Copy-Item -Path $path -Destination "$path.backup" -Force; if (-not (Test-Path "$path.backup")) { exit 3 } } >> RustDesk_Server_Public.ps1
echo         $newContent = $content -replace "^custom-rendezvous-server.*", "" >> RustDesk_Server_Public.ps1
echo         $newContent = $newContent -replace "^custom-rs-server.*", "" >> RustDesk_Server_Public.ps1
echo         $newContent = $newContent -replace "^api-server.*", "" >> RustDesk_Server_Public.ps1
echo         $newContent = $newContent -replace "^custom-api-server.*", "" >> RustDesk_Server_Public.ps1
echo         $newContent = $newContent -replace "^key.*", "" >> RustDesk_Server_Public.ps1
echo         $newContent = $newContent ^| Where-Object { $_.Trim() -ne "" } >> RustDesk_Server_Public.ps1
echo         $newContent ^| Set-Content $path >> RustDesk_Server_Public.ps1
echo     } >> RustDesk_Server_Public.ps1
echo } >> RustDesk_Server_Public.ps1
echo if ($svc) { Stop-Service -Name RustDesk -Force -ErrorAction SilentlyContinue; Start-Sleep -Seconds 1 } >> RustDesk_Server_Public.ps1
echo else { Stop-Process -Name "rustdesk" -Force -ErrorAction SilentlyContinue; Start-Sleep -Seconds 1 } >> RustDesk_Server_Public.ps1
echo if ($svc) { Start-Service -Name RustDesk -ErrorAction SilentlyContinue } >> RustDesk_Server_Public.ps1
powershell.exe -ExecutionPolicy Bypass -File RustDesk_Server_Public.ps1
if errorlevel 3 (
    if %LANG_TR%==1 (
        echo Yedekleme s?ras?nda bir hata olustu. ?zinleri kontrol edin. ??leme devam edilemedi.
    ) else (
        echo 备份时发生错误，请检查权限，操作已中止。
    )
    goto :done
)
start "" "%RUSTDESK_EXE%" --tray
echo.
if %LANG_TR%==1 (
echo Mevcut private sunucu ayarlar? yedeklendi ve Public sunucuya ge?ildi.
) else (
echo 当前自定义服务器设置已备份，并已切换到公共服务器。
)
goto :done
::===============================================================================================================
:Server_Private
echo.
echo $isPrivate = $false > check_private.ps1
echo $hasBackup = $false >> check_private.ps1
echo $paths = @("%RUSTDESK_CONFIG_DIR%\RustDesk2.toml") >> check_private.ps1
echo foreach ($path in $paths) { if (Test-Path $path) { $content = Get-Content $path; if (($content -match "^custom-rendezvous-server") -or ($content -match "^api-server") -or ($content -match "^custom-rs-server")) { $isPrivate = $true } } ; if (Test-Path "$path.backup") { $hasBackup = $true } } >> check_private.ps1
echo if ($isPrivate) { exit 1 } elseif (-not $hasBackup) { exit 2 } else { exit 0 } >> check_private.ps1
powershell.exe -ExecutionPolicy Bypass -File check_private.ps1
if errorlevel 2 (
    del check_private.ps1 >nul 2>&1
    if %LANG_TR%==1 (
        echo Sistemde kay?tl? bir Private Sunucu yede§i bulunamad?.
        echo L?tfen ?nce RustDesk ?zerinden Private Sunucu bilgilerinizi girip ba§lan?n.
    ) else (
        echo 系统中未找到私有服务器备份。
        echo 请先在 RustDesk 中配置私有服务器。
    )
    goto :done
)
if errorlevel 1 (
    del check_private.ps1 >nul 2>&1
    if %LANG_TR%==1 (
        echo Zaten Private Sunucu kullan?yorsunuz. ??lem yap?lmad?.
    ) else (
        echo 当前已经在使用私有服务器，无需操作。
    )
    goto :done
)
del check_private.ps1 >nul 2>&1

echo $svc = Get-Service -Name RustDesk -ErrorAction SilentlyContinue > RustDesk_Server_Private.ps1
echo $paths = @("%RUSTDESK_CONFIG_DIR%\RustDesk2.toml") >> RustDesk_Server_Private.ps1
echo foreach ($path in $paths) { >> RustDesk_Server_Private.ps1
echo     $backupPath = "$path.backup" >> RustDesk_Server_Private.ps1
echo     if (Test-Path $backupPath) { Copy-Item -Path $backupPath -Destination $path -Force } >> RustDesk_Server_Private.ps1
echo } >> RustDesk_Server_Private.ps1
echo if ($svc) { Stop-Service -Name RustDesk -Force -ErrorAction SilentlyContinue; Start-Sleep -Seconds 1 } >> RustDesk_Server_Private.ps1
echo else { Stop-Process -Name "rustdesk" -Force -ErrorAction SilentlyContinue; Start-Sleep -Seconds 1 } >> RustDesk_Server_Private.ps1
echo if ($svc) { Start-Service -Name RustDesk -ErrorAction SilentlyContinue } >> RustDesk_Server_Private.ps1
powershell.exe -ExecutionPolicy Bypass -File RustDesk_Server_Private.ps1
start "" "%RUSTDESK_EXE%" --tray
echo.
if %LANG_TR%==1 (
echo Yedeklenen Private Sunucu ayarlar? geri y?klendi.
) else (
echo 已恢复备份的自定义服务器设置。
)
goto :done
::===============================================================================================================
:Server_Private_New
echo.
echo $isPrivate = $false > check_private_new.ps1
echo $paths = @("%RUSTDESK_CONFIG_DIR%\RustDesk2.toml") >> check_private_new.ps1
echo foreach ($path in $paths) { if (Test-Path $path) { $content = Get-Content $path; if (($content -match "^custom-rendezvous-server") -or ($content -match "^api-server") -or ($content -match "^custom-rs-server")) { $isPrivate = $true } } } >> check_private_new.ps1
echo if ($isPrivate) { exit 1 } else { exit 0 } >> check_private_new.ps1
powershell.exe -ExecutionPolicy Bypass -File check_private_new.ps1
if errorlevel 1 (
    del check_private_new.ps1 >nul 2>&1
    if %LANG_TR%==1 (
        echo Private Sunucu zaten yap?land?r?lm?? durumda. L?tfen ?nce genel sunucuya ge?mek ve mevcut ayarlar? yedeklemek i?in 4. se?ene§i kullan?n.
    ) else (
        echo 已经配置了私有服务器，请先使用选项 4 切换到公共服务器并备份现有设置。
    )
    goto :done
)
del check_private_new.ps1 >nul 2>&1

if %LANG_TR%==1 goto Server_Private_New_TR
goto Server_Private_New_EN

:Server_Private_New_TR
echo L?tfen yeni Private Sunucu (Rendezvous Server) IP veya Host adresini girin.
set /p RS_HOST="Sunucu Adresi (Orn: 192.168.1.100 veya hb.sunucum.com): "
echo.
echo L?tfen Key (?ifre) bilgisini girin. E§er key yoksa bos b?rak?p ENTER'a basin.
set /p RS_KEY="Key (Opsiyonel): "
goto Server_Private_New_Proceed

:Server_Private_New_EN
echo 请输入新的私有服务器（Rendezvous Server）IP 或主机地址。
set /p RS_HOST="服务器地址（例如 192.168.1.100 或 hb.example.com）："
echo.
echo 请输入 Key。如果不需要 Key，请直接按回车。
set /p RS_KEY="Key（可选）："
goto Server_Private_New_Proceed

:Server_Private_New_Proceed
echo.
echo $svc = Get-Service -Name RustDesk -ErrorAction SilentlyContinue > RustDesk_Server_Private_New.ps1
echo $paths = @("%RUSTDESK_CONFIG_DIR%\RustDesk2.toml") >> RustDesk_Server_Private_New.ps1
echo foreach ($path in $paths) { >> RustDesk_Server_Private_New.ps1
echo     if (Test-Path $path) { >> RustDesk_Server_Private_New.ps1
echo         $newContent = Get-Content $path >> RustDesk_Server_Private_New.ps1
echo         $newContent = $newContent ^| Where-Object { $_.Trim() -ne "" } >> RustDesk_Server_Private_New.ps1
echo         $newContent += "custom-rendezvous-server = '%RS_HOST%'" >> RustDesk_Server_Private_New.ps1
echo         $newContent += "key = '%RS_KEY%'" >> RustDesk_Server_Private_New.ps1
echo         $newContent ^| Set-Content $path >> RustDesk_Server_Private_New.ps1
echo     } >> RustDesk_Server_Private_New.ps1
echo } >> RustDesk_Server_Private_New.ps1
echo if ($svc) { Stop-Service -Name RustDesk -Force -ErrorAction SilentlyContinue; Start-Sleep -Seconds 1 } >> RustDesk_Server_Private_New.ps1
echo else { Stop-Process -Name "rustdesk" -Force -ErrorAction SilentlyContinue; Start-Sleep -Seconds 1 } >> RustDesk_Server_Private_New.ps1
echo if ($svc) { Start-Service -Name RustDesk -ErrorAction SilentlyContinue } >> RustDesk_Server_Private_New.ps1
powershell.exe -ExecutionPolicy Bypass -File RustDesk_Server_Private_New.ps1
start "" "%RUSTDESK_EXE%" --tray
echo.
if %LANG_TR%==1 (
echo Yeni Private Sunucu ba?ar?yla tan?mland? ve RustDesk yeniden ba?lat?ld?.
) else (
echo 新的私有服务器配置成功，RustDesk 已重新启动。
)
goto :done
::===============================================================================================================
:Delete_Backups
echo.
del /f /q "%RUSTDESK_CONFIG_DIR%\RustDesk2.toml.backup" >nul 2>&1
if %LANG_TR%==1 (
echo Private Sunucu yedekleri ba?ar?yla silindi!
) else (
echo 自定义服务器备份已成功删除！
)
goto :done
::===============================================================================================================
:done
del RustDesk_ID_Host.ps1 >nul 2>&1
del RustDesk_ID_Random.ps1 >nul 2>&1
del RustDesk_ID_UserDefined.ps1 >nul 2>&1
del RustDesk_Server_Public.ps1 >nul 2>&1
del RustDesk_Server_Private.ps1 >nul 2>&1
del RustDesk_Server_Private_New.ps1 >nul 2>&1
echo.
if %LANG_TR%==1 (
echo	 ??LEM TAMAMLANDI
echo.
choice /C:MX /N /M "ANA MEN? icin M, ?IKI? icin X tu?una bas?n: "
) else (
echo	 操作完成
echo.
choice /C:MX /N /M "按 M 返回主菜单，按 X 退出："
)
if errorlevel 2 Exit
if errorlevel 1 goto :Main
::===============================================================================================================