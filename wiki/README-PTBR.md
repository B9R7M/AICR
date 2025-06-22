# Então. Seu dispositivo exige alterações no script...
- Antes de começar, recomendo instalar um ambiente de desenvolvimento (IDE) para facilitar a edição ou modificação dos comandos. Embora não seja propriamente uma IDE, uma ótima sugestão é o [Visual Studio Code](https://code.visualstudio.com/download).
> Está se perguntando o porquê? Você pode modificar este script em um Bloco de Notas, se quiser. No entanto, se for iniciante, isso pode dificultar a modificação. E o motivo é que o Bloco de Notas não possui as ferramentas adequadas para essa tarefa — tanto visuais quanto operacionais.
- Crie um arquivo de execução em lotes (.bat) em qualquer local do seu PC (recomendo a Área de Trabalho). Em seguida, clique com o botão direito do mouse e, no menu de contexto, selecione **“Abrir com o Code”** (Visual Studio Code).
---

### Bloco 1: Estrutura inicial e criação de log
- Só altere algo caso seja necessário ou saiba o que está fazendo.
```batch
@echo off
setlocal enabledelayedexpansion
chcp 65001 > nul

:: Diretório onde os arquivos de log serão salvos
set "logdir=logs"
if not exist "%logdir%" mkdir "%logdir%"

:: Cria timestamp com data e hora atual no formato AAAA-MM-DD_HHMM
set "timestamp=!date:~-4!-!date:~3,2!-!date:~0,2!_!time:~0,2!!time:~3,2!"

:: Caminho do arquivo de log completo
set "log=%logdir%\install-log_!timestamp!.log"
if exist "!log!" del "!log!"

:: Variáveis que serão usadas ao longo do script
set "faltando=0"
set "report_success="
set "report_failed="
```
### Bloco 2: Verificação dos arquivos obrigatórios
```batch
:: Arquivos obrigatórios (adicione ou remova conforme necessário)
set "arquivos=boot.img dtbo.img vendor_boot.img root-boot.img ROM.zip GAPPS.zip magisk.zip KSU.zip"
```
- Funções que o acompanham.
```batch
:: Início do log
call :log "Iniciando processo de flash..."
:: Verifica se todos os arquivos listados em "arquivos" existem
for %%A in (%arquivos%) do (
    if not exist "%%A" (
        call :log "[???] %%A não encontrado!"
        set "faltando=1"
    ) else (
        call :log "[OK] %%A encontrado."
    )
)

:: Se faltar algum arquivo, perguntar ao usuário se deseja continuar mesmo assim
if !faltando! == 1 (
    echo.
    call :log "Um ou mais arquivos estão ausentes. Deseja continuar assim mesmo? (S/N)"
    set /p resposta=
    if /i "!resposta!"=="N" exit /b
)

```
### Bloco 3: Escolha entre instalação completa ou só atualização
```batch
cls
call :log "Você está fazendo uma instalação completa ou apenas uma atualização?"

:: "choice" cria um menu simples onde S = Instalação completa, N = Atualização
choice /c SN /n /m "[S] Instalação completa   [N] Apenas atualização: "
if %errorlevel%==1 goto instalar
if %errorlevel%==2 goto atualizar
```
### Bloco 4: Menu de seleção para flash das imagens de sistema `.img`
```batch
:instalar
cls
call :log "Selecione as imagens que deseja flashar via Fastboot:"

:: Cada variável começa com "n", e o usuário decide se quer mudar pra "S"
set "boot=n"
set "dtbo=n"
set "vendor_boot=n"
set "vendor=n"
set "vbmeta=n"
set "vbmeta_system=n"
set "super_empty=n"

:: Pergunta ao usuário quais imagens ele quer instalar
set /p boot=Flashar boot.img? (S/N): 
set /p dtbo=Flashar dtbo.img? (S/N): 
set /p vendor_boot=Flashar vendor_boot.img? (S/N): 
set /p vendor=Flashar vendor.img? (S/N): 
set /p vbmeta=Flashar vbmeta.img? (S/N): 
set /p vbmeta_system=Flashar vbmeta_system.img? (S/N): 
set /p super_empty=Flashar super_empty.img? (S/N): 
```
### Bloco 5: Flash via Fastboot (executa os comandos conforme escolhas)
- As escolhas feitas no [Bloco 4](https://github.com/B9R7M/AICR/new/main#bloco-4-menu-de-sele%C3%A7%C3%A3o-para-flash-das-imagens-de-sistema-img).
```batch
:: Exemplo com boot.img
if /i "!boot!" == "S" (
    call :log "[FASTBOOT] Flashando boot.img..."
    fastboot flash boot boot.img >> "!log!"
    if errorlevel 1 (
        call :log "[ERRO] Falha ao flashar boot.img"
        set "report_failed=!report_failed!boot.img "
    ) else (
        set "report_success=!report_success!boot.img "
    )
)

:: Repita a estrutura acima para as outras imagens: vendor_boot.img, dtbo.img, etc.
:: (o script original já tem tudo certinho, é só seguir esse mesmo padrão)
```
### Bloco 6: Reboot opcional após flash e redirecionamento para o próximo menu
- Executa comando simples: `fastboot reboot recovery`
```batch
echo.
call :log "Deseja reiniciar para o recovery agora? (S/N)"
set /p reboot_recovery=
if /i "!reboot_recovery!"=="S" (
    call :log "[FASTBOOT] Reiniciando para o recovery..."
    fastboot reboot recovery >> "!log!"
) else (
    call :log "[INFO] Reboot manual para recovery ficará a critério do usuário."
)

goto atualizar
```
### Bloco 7: Seleção de pacotes para instalação via ADB Sideload (`.zip`)
- Aqui segue a mesma lógica de modificação do [Bloco 4](https://github.com/B9R7M/AICR/new/main#bloco-4-menu-de-sele%C3%A7%C3%A3o-para-flash-das-imagens-de-sistema-img) e [Bloco 5](https://github.com/B9R7M/AICR/new/main#bloco-5-flash-via-fastboot-executa-os-comandos-conforme-escolhas).
```batch
:atualizar
cls
call :log "Selecione os pacotes que deseja instalar via sideload:"

:: O usuário escolhe S (sim) ou N (não) para cada um
set "inst_rom=n"
set "inst_gapps=n"
set "inst_magisk=n"
set "inst_ksu=n"

set /p inst_rom=Instalar ROM.zip? (S/N): 
set /p inst_gapps=Instalar GAPPS.zip? (S/N): 
set /p inst_magisk=Instalar Magisk.zip? (S/N): 
set /p inst_ksu=Instalar KSU.zip? (S/N): 

:: Solicita ao usuário ativar o modo ADB sideload no recovery
call :log "[ADB] Ative o modo ADB sideload no recovery."
pause
```
### Bloco 8: Executa o Sideload dos pacotes selecionados
- As escolhas feitas no [Bloco 7](https://github.com/B9R7M/AICR/new/main#bloco-7-sele%C3%A7%C3%A3o-de-pacotes-para-instala%C3%A7%C3%A3o-via-adb-sideload-zip).
```batch
:: Exemplo com ROM.zip
if /i "!inst_rom!" == "S" (
    call :verificar_adb
    call :log "[ADB] Instalando ROM.zip via sideload..."
    adb sideload ROM.zip >> "!log!"
    call :confirm_success "ROM"
)
:: Repita a estrutura acima para as outros arquivos: GAPPS.zip, KSU.zip, etc.
:: (assim como comentado anteriormente, o script original já tem tudo certinho, é só seguir esse mesmo padrão)
```
### Bloco 9: Flash do [root-boot.img](https://github.com/B9R7M/AICR?tab=readme-ov-file#what-can-this-script-do) (Se disponível).
- Só altere caso seja necessário.
```batch
call :log "Deseja flashar root-boot.img? (S/N)"
set /p resposta=

if /i "!resposta!" == "S" (
    call :log "[ADB] Rebootando para bootloader..."
    adb reboot bootloader
    timeout /t 7 > nul

    call :log "[FASTBOOT] Flashando root-boot.img..."
    fastboot flash boot root-boot.img >> "!log!"

    if errorlevel 1 (
        call :log "[ERRO] Falha ao flashar root-boot.img"
        set "report_failed=!report_failed!root-boot.img "
    ) else (
        set "report_success=!report_success!root-boot.img "
    )

    fastboot reboot recovery >> "!log!"
)
```
### Bloco 10: Finalização e resumo dos resultados
- Só altere caso saiba o que está fazendo.
```batch
call :log "[FINALIZADO] Processo concluído."
call :log "--- RESUMO DA INSTALAÇÃO ---"
call :log "Sucesso: !report_success!"
call :log "Falhas: !report_failed!"
pause
exit
```
### Bloco 11: Funções auxiliares
- Essas funções ajudam a manter o código limpo e organizado, e são chamadas ao longo do script.
- Mais uma vez, só altere caso saiba o que está fazendo.
```batch
:log
set "ts=%time:~0,2%:%time:~3,2%:%time:~6,2%"
echo [%ts%] %~1
echo [%ts%] %~1 >> "!log!"
goto :eof

:confirm_success
set "pkg=%~1"
call :log "[CONFIRMAÇÃO] O sideload de %pkg%.zip foi concluído? (S/N)"
set /p resposta=
if /i "!resposta!"=="N" (
    call :log "[ABORTADO] %pkg%.zip falhou. Abortando processo."
    set "report_failed=!report_failed!%pkg%.zip "
    exit /b
) else (
    call :log "[SUCESSO] %pkg%.zip instalado com sucesso."
    set "report_success=!report_success!%pkg%.zip "
    call :log "Ative novamente o modo sideload para o próximo pacote."
    pause
)
goto :eof
```
```batch
:verificar_adb
call :log "[VERIFICAÇÃO] Checando se o dispositivo está visível via ADB..."
adb start-server > nul
adb devices | findstr /R /C:"device$" > nul
if errorlevel 1 (
    call :log "[ERRO] Nenhum dispositivo ADB detectado."
    echo.
    echo Nenhum dispositivo detectado. Deseja tentar novamente? (S/N)
    set /p tentativa=
    if /i "!tentativa!"=="S" goto verificar_adb
    call :log "[ABORTADO] Usuário cancelou por falta de ADB."
    exit /b
) else (
    call :log "[OK] Dispositivo ADB detectado com sucesso."
    goto :eof
)
```
