@echo off
setlocal enabledelayedexpansion
chcp 65001 > nul

set "faltando=0"
set "log=install-log.txt"
set "arquivos=boot.img dtbo.img vendor_boot.img root-boot.img ROM.zip GAPPS.zip magisk.zip KSU.zip"

if exist %log% del %log%

call :log "Iniciando verificação de arquivos necessários..."

for %%A in (%arquivos%) do (
    if not exist %%A (
        call :log "[FALTA] %%A não encontrado."
        set "faltando=1"
    ) else (
        call :log "[OK] %%A localizado."
    )
)

if %faltando%==1 (
    call :log "Um ou mais arquivos estão ausentes. Verifique %log%."
    set /p resposta="Deseja continuar mesmo assim? (S/N): "
    if /i "!resposta!"=="N" goto fim
)

cls
call :log "Você está fazendo uma primeira instalação ou apenas atualizando a ROM?"
choice /c SN /n /m "[S] Instalação completa [N] Apenas atualização: "
if %errorlevel%==1 goto instalar
if %errorlevel%==2 goto atualizar

:instalar
cls
call :log "Iniciando instalação via fastboot..."
call :exec "fastboot flash boot boot.img"
call :exec "fastboot flash dtbo dtbo.img"
call :exec "fastboot flash vendor_boot vendor_boot.img"

choice /c SN /n /m "Os comandos acima foram executados com sucesso? "
if %errorlevel%==2 goto fim
call :exec "fastboot reboot recovery"

goto atualizar

:atualizar
cls
call :log "Instalação via ADB sideload iniciada..."
call :log "Ative o modo ADB sideload no recovery do dispositivo."
pause

:verifica_adb
call :exec "adb devices"
choice /M "Você vê o dispositivo listado?"
if errorlevel 2 (
    call :exec "adb kill-server"
    call :exec "adb start-server"
    goto verifica_adb
)

call :sideload "ROM.zip"
call :sideload "GAPPS.zip"
call :sideload "magisk.zip"
call :sideload "KSU.zip"

choice /M "Você deseja instalar a boot.img modificada (APatch/Magisk)?"
if errorlevel 2 goto fim
call :log "Reinicie para fastboot e pressione qualquer tecla para continuar..."
pause
call :exec "fastboot flash boot root-boot.img"
call :exec "fastboot reboot recovery"

:fim
call :log "Instalação finalizada. Formate o dispositivo se necessário."
pause
exit /b

:sideload
call :log "Instalando %1 via ADB sideload..."
call :exec "adb -d sideload %1"
choice /M "A instalação foi bem-sucedida?"
if errorlevel 2 (
    choice /M "Deseja tentar novamente?"
    if errorlevel 1 call :exec "adb -d sideload %1"
)
exit /b

:exec
set "cmd=%~1"
for /f "delims=" %%i in ('cmd /c "%cmd% 2>&1"') do (
    echo %%i
    echo %%i >> %log%
)
exit /b

:log
echo %~1
echo %~1 >> %log%
exit /b
