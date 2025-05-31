@echo off
setlocal enabledelayedexpansion

REM C1 - Garante que o console mostre caracteres especiais corretamente
chcp 65001 > nul

echo Iniciando...
echo.

timeout /t 4
echo.
cls

REM C2 - Inicializa variáveis
set "faltando=0"
set "log=missing-files.log"
set "arquivos=boot.img dtbo.img vendor_boot.img root-boot.img ROM.zip GAPPS.zip magisk.zip KSU.zip"

REM C3 - Limpa o arquivo de log, se existir um
if exist %log% del %log%

echo Verificando a existência de todos os arquivos necessários, para a execução da instalação sem erros:
echo.

REM C4 - Verifica a existência de cada arquivo na lista
for %%A in (%arquivos%) do (
    if not exist %%A (
        echo ???: O arquivo %%A não foi encontrado.
        echo %%A não encontrado. >> %log%
        set "faltando=1"
    ) else (
        echo OK: O arquivo %%A foi encontrado.
    )
)
echo.

REM C5 - Se algum arquivo estiver faltando, ele será exibido no log de erros "mising-files.log"
if %faltando%==1 (
    echo Um ou mais arquivos estão ausentes. Veja os detalhes em %log%.
    echo.
    echo Continuar mesmo assim? (S/N)
    set /p resposta=
    if /i "%resposta%"=="N" (
        echo Saindo do script.
        timeout /t 3
        pause
        exit /b 1
    )
    echo Ok, continuando...
) else (
)
cls

REM C6 - Verifica se você deseja atualizar sua Custom ROM. Se sim, ele pula os comandos Fastboot e segue para a instalação via ADB Sideload; caso contrário, continua normalmente.
echo.
echo Você está iniciando uma primeira instalação?
echo.
echo [S] SIM
echo [N] NÃO, quero apenas atualizar minha Custom ROM.
echo.
choice /c SN /n /m "Escolha uma opção:"
if %errorlevel%==1 goto instalar
if %errorlevel%==2 goto atualizar

:instalar
cls
echo.
echo Iniciando instalação via fastboot...
timeout /t 3
echo.

REM C7 - Executa os comandos fastboot inicias, exceto o de reinicialização, para verificar se algum erro será detectado

fastboot flash boot boot.img
echo.
fastboot flash dtbo dtbo.img
echo.
fastboot flash vendor_boot vendor_boot.img
echo.

echo Todos os comandos foram executados. Por favor, verifique se o processo foi bem-sucedido.
echo.
choice /c SN /n /m "Foi bem-sucedido?:"

if %errorlevel%==2 (
    echo Você optou por encerrar o script devido à detecção de uma falha no processo de flash certo? Feche esta janela, corrija o erro e reinicie o processo.
    echo.
    pause
    exit /b 1
)

REM C8 - Reinicia no recovery
if %errorlevel%==1 (
    echo Iniciando no modo recovery...
    echo.
    timeout /t 3
    echo.
    REM C9 - Comando de reinicialização aqui
    fastboot reboot recovery
    echo.
    echo Processo concluído com sucesso!
    cls
)

:atualizar
cls
echo.
echo Iniciando instalação da ROM pelo recovery via adb sideload.
echo.

echo Aguardando ativação do modo ADB sideload...
echo.

echo Dica: Ativar o modo ADB em ^'Install update ^> ADB sideload^' ou ^'Apply update ^> Apply from ADB^' 
echo é necessário para executar a instalação da Custom ROM. Ative-o antes de continuar.
echo.

echo Não se esqueça de formatar seu dispositivo em ^'Factory reset^'
echo.
timeout /t 5
echo.

pause
echo.
cls

REM C11 - Verificação de dispositivo conectado via adb no PC
:checkDevice
echo.
echo Verificando dispositivos conectados...
echo.

REM C12 - Verifica dispositivos conectados...
adb devices
echo.

choice /M "Você está vendo algum dispositivo listado na saída acima?"
if errorlevel 2 (
    echo.
    echo Tentando resolver problemas de conexão...
    echo.
    echo Verificando as configurações de depuração USB...
    echo.

    echo Reiniciando o servidor ADB...
    echo.

    REM C13 - Mata e reinicia servidor ADB
    adb kill-server
    adb start-server
    echo.

    echo Verificando dispositivos conectados novamente...
    echo.

    REM C14 - Segunda tentativa pra verificar dispositivos conectados
    adb devices
    echo.

    choice /M "Você vê o dispositivo listado na saída agora?"
    if errorlevel 2 (
        echo.
        echo Saindo do script.
        echo.
        pause
        exit /b 1
    ) else (
        echo Continuando com a instalação da ROM...
        echo.
        choice /M "Executar instalação agora?"
        echo.
        if errorlevel 2 (
            echo Prosseguindo sem instalar a ROM...
            echo.
        ) else (
            REM C15 - Primeiro comando de instalação da ROM
            adb -d sideload ROM.zip
            echo.

            choice /M "O sideload foi bem-sucedido?"
            echo.
            if errorlevel 2 (
                echo Tentando o sideload novamente...
                echo.
                REM C16 - Segundo comando de instalação da ROM
                adb -d sideload ROM.zip
                echo.

                choice /M "O sideload foi bem-sucedido agora?"
                echo.
                if errorlevel 2 (
                    echo Saindo do script.
                    echo.
                    pause
                    exit /b 1
                )
            )
        )
    )

) else (
    echo Continuando com a instalação da ROM...
    echo.
    choice /M "Executar instalação agora?"
    echo.
    if errorlevel 2 (
        echo Prosseguindo sem instalar ROM...
        echo.
    ) else (
        REM C17 - Terceiro comando de instalação da ROM
        adb -d sideload ROM.zip
        echo.

        choice /M "O sideload foi bem-sucedido"
        echo.
        if errorlevel 2 (
            echo Tentando o sideload novamente...
            echo.
            REM C18 - Quarto comando de instalação da ROM
            adb -d sideload ROM.zip
            echo.

            choice /M "O sideload foi bem-sucedido agora?"
            echo.
            if errorlevel 2 (
                echo Saindo do script.
                echo.
                pause
                exit /b 1
            )
        )
    )
)

echo.
echo Instalação da ROM concluída.
echo.
cls

REM C19 - Pergunta sobre os GAPPS
echo.
choice /M "Você tem GAPPS disponível pra instalação?"
echo.
if errorlevel 2 (
    echo GAPPS não disponível, prosseguindo para a próxima etapa...
    echo.
) else (
    choice /M "Executar instalação agora?"
    echo.
    if errorlevel 2 (
        echo Prosseguindo para a próxima etapa...
        echo.
    ) else (
        REM C20 - Primeiro comando de instalação dos GAPPS
        adb -d sideload GAPPS.zip
        echo.

        choice /M "A instalação foi bem-sucedida?"
        echo.
        if errorlevel 2 (
            choice /M "Você quer tentar novamente?"
            echo.
            if errorlevel 2 (
                echo Prosseguindo para a próxima etapa...
                echo.
            ) else (
                REM C21 - Segundo comando de instalação dos GAPPS
                adb -d sideload GAPPS.zip
                echo.

                choice /M "A instalação foi bem-sucedida agora?"
                echo.
                if errorlevel 2 (
                    echo Prosseguindo para a próxima etapa...
                    echo.
                )
            )
        )
    )
)
cls

REM C22 - Pergunta sobre o arquivo flashável do MAGISK
echo.
choice /M "Você tem arquivo flashável do Magisk disponível para instalação?"
echo.
if errorlevel 2 (
    echo Magisk não disponível, prosseguindo para a próxima pergunta...
    echo.
) else (
    choice /M "Executar instalação agora?"
    echo.
    if errorlevel 2 (
        echo Prosseguindo para a próxima pergunta...
        echo.
    ) else (
        REM C23 - Primeiro comando de instalação do MAGISK
        adb -d sideload magisk.zip
        echo.

        choice /M "A instalação foi bem-sucedida?"
        echo.
        if errorlevel 2 (
            choice /M "Você quer tentar novamente?"
            echo.
            if errorlevel 2 (
                echo Prosseguindo para a próxima etapa...
                echo.
            ) else (
                REM C24 - Segundo comando de instalação do MAGISK
                adb -d sideload magisk.zip
                echo.

                choice /M "A instalação foi bem-sucedida agora?"
                echo.
                if errorlevel 2 (
                    echo Prosseguindo para a próxima etapa...
                    echo.
                )
            )
        )
    )
)
cls

REM C25 - Pergunta sobre o arquivo flashável do KernelSU
echo.
choice /M "Você tem arquivo flashável do KernelSU disponível para instalação?"
echo.
if errorlevel 2 (
    echo KernelSU não disponível, prosseguindo para a próxima etapa...
    echo.
) else (
    choice /M "Executar instalação agora?"
    echo.
    if errorlevel 2 (
        echo Prosseguindo para a próxima etapa...
        echo.
    ) else (
        REM C26 - Primeiro comando de instalação do KernelSU
        adb -d sideload KSU.zip
        echo.

        choice /M "A instalação foi bem-sucedida?"
        echo.
        if errorlevel 2 (
            choice /M "Você quer tentar novamente?"
            echo.
            if errorlevel 2 (
                echo Prosseguindo para a próxima etapa...
                echo.
            ) else (
                REM C27 - Segundo comando de instalação do KernelSU
                adb -d sideload KSU.zip
                echo.

                choice /M "A instalação foi bem-sucedida agora?"
                echo.
                if errorlevel 2 (
                    echo Prosseguindo para a próxima etapa...
                    echo.
                )
            )
        )
    )
)
cls

REM C28 - Pergunta sobre a 'boot.img' corrigida via APATCH ou MAGISK
echo.
choice /M "Você tem uma 'boot.img' corrigida com MAGISK ou APATCH disponível pra instalação?"
echo.
if errorlevel 2 (
    echo Encerrando...
    echo.
    pause
    exit /b 0
) else (
    choice /M "Executar instalação agora?"
    echo.
    if errorlevel 2 (
        echo Encerrando...
        echo.
        pause
        exit /b 0
    ) else (
        echo Reinicie pro modo fastboot pra prosseguir com a instalação da GKI corrigida.
        echo.
        timeout /t 3
        echo.
        REM C29 - Primeiro comando de instalação da GKI
        fastboot flash boot root-boot.img
        echo.

        choice /M "A instalação foi bem-sucedida?"
        echo.
        if errorlevel 2 (
            choice /M "Você quer tentar novamente?"
            echo.
            if errorlevel 2 (
                echo Encerrando...
                echo.
                pause
                exit /b 0
            ) else (
                REM C30 - Segundo comando de instalação da GKI
                fastboot flash boot root-boot.img
                echo.

                choice /M "A instalação foi bem-sucedida agora?"
                echo.
                if errorlevel 2 (
                    echo Encerrando...
                    echo.
                    pause
                    exit /b 0
                )
            )
        )
        
        echo.
        REM C31 - Reinicia mais uma vez no recovery
        fastboot reboot recovery
        echo.
        timeout /t 5
        echo.
        cls

        echo Formate seu dispositivo no modo recovery, caso ainda não tenha feito isso.
        echo Essa ação é necessária para descriptografar o dispositivo e evitar bootloops.
        echo Se você estiver apenas atualizando sua ROM, ignore esta mensagem.
        echo.

        echo Instalação concluída. Encerrando serviço.
        echo.
        pause
    )
)
