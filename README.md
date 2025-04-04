# CMD-AICR
CMD-AICR é um script de automação desenvolvido em batch, criado para simplificar, de forma parcial, a instalação de Custom ROMs em dispositivos que utilizam Fastboot/Bootloader. Dependendo do modelo do dispositivo, não será necessário inserir comandos manualmente, pois todo o processo é realizado automaticamente.

---

### Isenção de responsabilidade. 

- Não me responsabilizo por quaisquer danos ao seu dispositivo ao utilizar este script. A responsabilidade é inteiramente sua. Esteja ciente disso e prossiga por sua conta e risco.

### Aviso Importante! 

- Este script foi desenvolvido com base no processo de instalação de Custom ROMs de um [**Motorola Edge 20 Pro**](https://wiki.lineageos.org/devices/pstar/install/#) _(meu dispositivo pessoal)_. É importante observar que, dependendo do seu dispositivo, podem haver diferenças específicas nos comandos, sendo necessário modificá-los manualmente no script. Se esse for o seu caso, clique [aqui](#notas-importantes) pra aprender a modificá-lo de forma mais simples.

---

### O que esse script é capaz de fazer? 

   - Verifica os arquivos necessários pra instalação.
   - Instala GKIs via Fastboot.
   - Reinicializa automaticamente no recovery.
   - Instala o arquivo da ROM via ADB Sideload.
   - Instala os GAPPS.
   - Instala arquivos de ROOT.
   - Instala GKI corrigida por algum gerenciador de ROOT ou Kernels já construidos na partição **boot** ou **init_boot** caso você modifique tal comando.
   - Reinicializa automaticamente no recovery novamente no final da instalação.

### Requisitos

- Um PC com Windows 10 ou superior.
- Bootloader do seu dispositivo desbloqueado.
- Drivers específicos para o seu dispositivo _(Talvez seu PC tenha problemas em reconhecê-lo sem eles)_.
- Arquivos necessários para a instalação da Custom ROM _(consulte a wiki do seu dispositivo)_.
- **CMD-AICR.bat** na mesma pasta que os arquivos da ROM e SDK Plataform-Tools.

### Preparação e como usar

- Baixe e descompacte o arquivo disponível na aba [**Releases**](https://github.com/B9R7M/CMD-AICR/releases). _([SDK Platform-Tools](https://developer.android.com/tools/releases/platform-tools?hl=pt-br) já incluso)._
- Renomeie os arquivos que serão utilizados na instalação da ROM:

    - **Custom ROM.zip** para `ROM.zip`
    - **NikGapps.zip** para `GAPPS.zip`
    - **Magisk-v28.zip** para `magisk.zip`
    - **KernelSU.zip** para `KSU.zip`
    - `boot.img` _(caso esteja com um nome diferente)_
    - `dtbo.img` _(caso esteja com um nome diferente)_
    - `vendor_boot.img` _(caso esteja com um nome diferente)_
    - GKI corrigida por algum gerenciador de ROOT ou kernel já modificado (**boot.img**) para `rootboot.img`

- Após renomear os arquivos, cole todos na mesma pasta onde o arquivo **CMD-AICR.bat** está localizado.

- Execute **CMD-AICR.bat** e siga as instruções do script.

_Os nomes dos arquivos mencionados acima são apenas exemplos._

---

### Notas importantes

- Este script executa os seguintes comandos por padrão: 

 ```
       fastboot flash boot boot.img
       fastboot flash dtbo dtbo.img
       fastboot flash vendor_boot.img
       fastboot reboot recovery
       adb devices
       adb -d sideload ROM.zip
       adb -d sideload GAPPS.zip
       adb -d sideload magisk.zip
       adb -d sideload KSU.zip
       fastboot flash boot rootboot.img
       fastboot reboot recovery
```

- Meu dispositivo exige alterações nos comandos. Como modificá-los?

    - Primeiramente, recomendo instalar um **ambiente de desenvolvimento** _(IDE)_ para simplificar a edição ou modificação dos comandos. Uma excelente sugestão é o [Visual Studio Code](https://code.visualstudio.com/download). Recomendo essa opção porque as instruções descritas abaixo foram elaboradas com base nessa **IDE**.
    - Incluí comentários ao longo do script com marcações específicas para identificar facilmente os pontos onde podem ser feitas alterações no script. No total, há 30 marcações: **C1**, **C2**, **C3**, **C4**,... **C27**, **C28**, **C29**, **C30**. Apenas os pontos essenciais serão citados aqui, mas você pode explorar os demais conforme achar necessário.
     - Use "`%`" pra buscar comentários no script. Exemplo: "`%C1`".

- Modificando comandos FASTBOOT

    - Na barra de busca superior do **VS Code**, busque por: `%C6`. Isso levará você diretamente à seção onde os primeiros **comandos fastboot** serão executados.


Exemplo:

```Batch
   REM C6 - Executa os comandos fastboot iniciais, exceto o de reinicialização, para verificar se algum erro será detectado

   fastboot flash boot boot.img
   fastboot flash dtbo dtbo.img
   fastboot flash vendor_boot vendor_boot.img

```


Exemplo com modificações:

```Batch
   REM C6 - Executa os comandos fastboot iniciais, exceto o de reinicialização, para verificar se algum erro será detectado

   fastboot flash boot boot.img
   fastboot flash dtbo dtbo.img
   fastboot flash vendor_boot vendor_boot.img
   fastboot flash init_boot init_boot.img

```


- Comando FASTBOOT de reinicialização 

     - Busque por: `%C8` ou/e `%C30`.


Exemplos:

```Batch
   REM C8 - Comando de reinicialização aqui
   fastboot reboot recovery
   echo Processo concluído com sucesso!
   cls

```
```Batch
   REM C30 - Reinicializa mais uma vez no recovery
   fastboot reboot recovery
   echo.

```


- Comandos de instalação via ADB Sideload

     - Busque por: `%C14`, `%C15`, `%C16` e `%C17` para a instalação da ROM. Como o script oferece a opção de múltiplas escolhas, os comandos são repetidos.


Exemplos:

```Batch
   REM C14 - Primeiro comando de instalação da ROM
   adb -d sideload ROM.zip
   echo.

```
```Batch
   REM C15 - Segundo comando de instalação da ROM
   adb -d sideload ROM.zip
   echo.

```
```Batch
   REM C16 - Terceiro comando de instalação da ROM
   adb -d sideload ROM.zip
   echo.

```
```Batch
   REM C17 - Quarto comando de instalação da ROM
   adb -d sideload ROM.zip
   echo.

```


- Comandos de instalação dos GAPPS

     - Busque por: `%C19` e `%C20`


Exemplos:

```Batch
   REM C19 - Primeiro comando de instalação dos GAPPS
   adb -d sideload GAPPS.zip
   echo.

```
```Batch
   REM C20 - Segundo comando de instalação dos GAPPS
   adb -d sideload GAPPS.zip
   echo.

```

 - Comandos de instalação dos arquivos fleshavéis de ROOT ou/e Kernels

     - **(MAGISK)** busque por: `%C22` e `%C23`
     - **(KernelSU)** busque por: `%C25` e `%C26`


Exemplos:

```Batch
   REM C22 - Primeiro comando de instalação do MAGISK
   adb -d sideload magisk.zip
   echo.

```
```Batch
   REM C23 - Segundo comando de instalação do MAGISK 
   adb -d sideload magisk.zip
   echo.

```
```Batch
   REM C25 - Primeiro comando de instalação do KernelSU
   adb -d sideload KSU.zip
   echo.

```
```Batch
   REM C26 - Segundo comando de instalação do KernelSU
   adb -d sideload KSU.zip
   echo.

```

- Comando de instalação da GKI corrigida

     - Busque por: `%C28` e `%C29`


Exemplos:

```Batch
   REM C28 - Primeiro comando de instalação da GKI
   fastboot flash boot rootboot.img
   echo.

```
```Batch
    REM C29 - Segundo comando de instalação da GKI
    fastboot flash boot rootboot.img
    echo.

```


---


### Comissão

- Este projeto foi desenvolvido sem fins lucrativos, mas, se você gostou e deseja me agradecer, considere fazer uma doação!

- **Chave PIX**: `256f1867-fbe0-4c14-9ed4-44307e5057a6`
- **PayPal**: `joiltonsilvasec3@gmail.com`
