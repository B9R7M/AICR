# CMD-AICR
CMD-AICR is a batch automation script developed to partially simplify the installation of Custom ROMs on devices using Fastboot/Bootloader. Depending on the device model, it will not be necessary to manually input commands, as the entire process is carried out automatically.

---

### Disclaimer

- I am not responsible for any damage to your device when using this script. The responsibility is entirely yours. Be aware of this and proceed at your own risk.

### Important Notice!

- This script was developed based on the Custom ROM installation process of a [**Motorola Edge 20 Pro**](https://wiki.lineageos.org/devices/pstar/install/#) _(my personal device)_. It is important to note that, depending on your device, there may be specific differences in the commands, requiring you to modify them manually in the script. If that's the case, click [here](#important-notes) to learn how to modify it more easily.

---

### What can this script do?

   - Verifies the necessary files for installation
   - Installs images (.img or .bin) via Fastboot
   - Automatically reboots into recovery
   - Installs the ROM file via ADB Sideload
   - Installs the GAPPS
   - Installs ROOT files
   - Installs a patched "boot.img" via a ROOT manager or prebuilt Kernels already built into the **boot** or **init_boot** partition if you modify such a command
   - Automatically reboots into recovery again at the end of the installation

### Requirements

- A PC with Windows 10 or higher
- Your device's bootloader unlocked
- Specific drivers for your device _(Your PC might have trouble recognizing it without them)_
- Necessary files for the Custom ROM installation _(check your device's wiki)_
- **CMD-AICR.bat** in the same folder as the ROM files and SDK Platform-Tools

### Preparation and How to Use

- Download and unzip the file available in the [**Releases**](https://github.com/B9R7M/CMD-AICR/releases) tab. _([SDK Platform-Tools](https://developer.android.com/tools/releases/platform-tools?hl=en) included)._
- Rename the files to be used for the ROM installation:

    - **Custom ROM.zip** to `ROM.zip`
    - **NikGapps.zip** to `GAPPS.zip`
    - **Magisk-v28.zip** to `magisk.zip`
    - **KernelSU.zip** to `KSU.zip`
    - **boot.img**, **dtbo.img**, **vendor_boot.img** _(if it has a different name)_
    - Patched GKI via a ROOT manager or prebuilt kernel (**boot.img**) to `rootboot.img`

- After renaming the files, paste all of them into the same folder where the **CMD-AICR.bat** file is located

- Run **CMD-AICR.bat** and follow the script instructions

_The file names mentioned above are just examples_

---

### Important Notes

- This script executes the following commands by default:

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

- My device requires command changes. How to modify them?

    - First, I recommend installing a **development environment** _(IDE)_ to simplify editing or modifying the commands. A great suggestion is [Visual Studio Code](https://code.visualstudio.com/download). I recommend this option because the instructions described below are based on this **IDE**
    - I have included comments throughout the script with specific markings to easily identify the points where changes can be made. There are 31 markings in total: **C1**, **C2**, **C3**, **C4**, etc. Only the essential points are mentioned here, but you can explore the others as needed.
    - Use "`%`" to search for comments in the script. Example: "`%C1`"

- Modifying FASTBOOT Commands

    - In the upper search bar of **VS Code**, search for: `%C7`. This will take you directly to the section where the first **FASTBOOT commands** are executed.


Example:

```Batch
   REM C7 - Executes initial fastboot commands, except for reboot, to check for errors

   fastboot flash boot boot.img
   fastboot flash dtbo dtbo.img
   fastboot flash vendor_boot vendor_boot.img

```


Example with modifications:

```Batch
   REM C7 - Executes initial fastboot commands, except for reboot, to check for errors

   fastboot flash boot boot.img
   fastboot flash dtbo dtbo.img
   fastboot flash vendor_boot vendor_boot.img
   fastboot flash init_boot init_boot.img

```


- FASTBOOT Reboot Command

     - Search for: `%C9` or/and `%C31`


Examples:

```Batch
   REM C9 - Reboot command here
   fastboot reboot recovery
   echo Process successfully completed!
   cls

```
```Batch
   REM C31 - Reboots again into recovery
   fastboot reboot recovery
   echo.

```


- ADB Sideload Installation Commands

     - Search for: `%C15`, `%C16`, `%C17`, and `%C18` for ROM installation. Since the script offers multiple choice options, the commands are repeated.


Examples:

```Batch
   REM C15 - First ROM installation command
   adb -d sideload ROM.zip
   echo.

```
```Batch
   REM C16 - Second ROM installation command
   adb -d sideload ROM.zip
   echo.

```
```Batch
   REM C17 - Third ROM installation command
   adb -d sideload ROM.zip
   echo.

```
```Batch
   REM C18 - Fourth ROM installation command
   adb -d sideload ROM.zip
   echo.

```


- GAPPS Installation Commands

     - Search for: `%C20` and `%C21`


Examples:

```Batch
   REM C20 - First GAPPS installation command
   adb -d sideload GAPPS.zip
   echo.

```
```Batch
   REM C21 - Second GAPPS installation command
   adb -d sideload GAPPS.zip
   echo.

```

 - Installation Commands for Flashable ROOT or Kernel Files

     - **(MAGISK)** search for: `%C23` and `%C24`
     - **(KernelSU)** search for: `%C26` and `%C27`


Examples:

```Batch
   REM C23 - First MAGISK installation command
   adb -d sideload magisk.zip
   echo.

```
```Batch
   REM C24 - Second MAGISK installation command
   adb -d sideload magisk.zip
   echo.

```
```Batch
   REM C26 - First KernelSU installation command
   adb -d sideload KSU.zip
   echo.

```
```Batch
   REM C27 - Second KernelSU installation command
   adb -d sideload KSU.zip
   echo.

```

- Patched "boot.img" Installation Command

     - Search for: `%C29` and `%C30`


Examples:

```Batch
   REM C29 - First boot.img installation command
   fastboot flash boot rootboot.img
   echo.

```
```Batch
   REM C30 - Second boot.img installation command
   fastboot flash boot rootboot.img
   echo.

```


---


### Donation

- This project was developed without profit, but if you liked it and want to thank me, consider making a donation!

- **PayPal**:`joiltonsilvasec3@gmail.com`
- **PIX**:`638b0462-a480-4e07-835a-23d15fd56f44` / `256f1867-fbe0-4c14-9ed4-44307e5057a6`

---

### License

- This project is licensed under the [MIT License](https://github.com/B9R7M/CMD-AICR/blob/main/LICENSE)

---
