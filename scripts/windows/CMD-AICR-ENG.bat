@echo off
setlocal enabledelayedexpansion
REM C1 - Ensures the console displays special characters correctly
chcp 65001 > nul
echo Starting...
echo.
timeout /t 4
echo.
cls
REM C2 - Initializes variables
set "missing=0"
set "log=missing-files.log"
set "files=boot.img dtbo.img vendor_boot.img root-boot.img ROM.zip GAPPS.zip magisk.zip KSU.zip"
REM C3 - Clears the log file if it exists
if exist %log% del %log%
echo Checking the existence of all necessary files to ensure installation runs smoothly:
echo.
REM C4 - Checks for each file in the list
for %%A in (%files%) do (
    if not exist %%A (
        echo ???: The file %%A was not found.
        echo %%A not found. >> %log%
        set "missing=1"
    ) else (
        echo OK: The file %%A was found.
    )
)
echo.
REM C5 - If any files are missing, they will be logged in "missing-files.log"
if %missing%==1 (
    echo One or more files are missing. See details in %log%.
    echo.
    echo Continue anyway? (Y/N)
    set /p response=
    if /i "%response%"=="N" (
        timeout /t 3
        goto end1
    )
    echo Ok, continuing...
) else (
)
cls
REM C6 - Checks if you want to update your Custom ROM. If yes, it skips Fastboot and proceeds with ADB Sideload; otherwise, it continues normally.
echo.
echo Are you performing a first-time installation?
echo.
echo [Y] YES
echo [N] NO, I just want to update my Custom ROM.
echo.
choice /c YN /n /m "Choose an option:"
if %errorlevel%==1 goto install
if %errorlevel%==2 goto update
:install
cls
echo.
echo Starting installation via Fastboot...
timeout /t 3
echo.
REM C7 - Executes the initial fastboot commands, except for reboot, to check for any errors
fastboot flash boot boot.img
echo.
fastboot flash dtbo dtbo.img
echo.
fastboot flash vendor_boot vendor_boot.img
echo.
echo All commands have been executed. Please check if the process was successful.
echo.
choice /c YN /n /m "Was it successful?:"
if %errorlevel%==2 (
    echo You chose to exit the script due to a detected failure in the flashing process, right? Close this window, fix the error, and restart the process.
    echo.
    pause
    exit /b 1
)
REM C8 - Reboots into recovery
if %errorlevel%==1 (
    echo Booting into recovery mode...
    echo.
    timeout /t 3
    echo.
    REM C9 - Reboot command here
    fastboot reboot recovery
    echo.
    echo Process successfully completed!
    cls
)
:update
cls
echo.
echo Starting ROM installation via recovery using ADB sideload.
echo.
echo Waiting for ADB sideload mode activation...
echo.
echo Tip: Enabling ADB mode in ^'Install update ^> ADB sideload^' or ^'Apply update ^> Apply from ADB^' 
echo is necessary to install the Custom ROM. Enable it before proceeding.
echo.
echo Don't forget to format your device under ^'Factory reset^'
echo.
timeout /t 5
echo.
pause
echo.
cls
REM C11 - Check for a connected device via ADB on PC
:checkDevice
echo.
echo Checking connected devices...
echo.
REM C12 - List connected devices
adb devices
echo.
choice /M "Do you see any device listed in the output above?"
if errorlevel 2 (
    echo.
    echo Trying to resolve connection issues...
    echo.
    echo Checking USB debugging settings...
    echo.
    echo Restarting ADB server...
    echo.
    REM C13 - Kill and restart ADB server
    adb kill-server
    echo.
    adb start-server
    echo.
    echo Checking connected devices again...
    echo.
    REM C14 - Second attempt to check connected devices
    adb devices
    echo.
    choice /M "Do you see the device listed now?"
    if errorlevel 2 (
        timeout /t 3
        goto end1
    ) else (
        echo Continuing with ROM installation...
        echo.
        choice /M "Execute installation now?"
        echo.
        if errorlevel 2 (
            echo Proceeding without installing the ROM...
            echo.
        ) else (
            REM C15 - First ROM installation command
            adb -d sideload ROM.zip
            echo.
            choice /M "Was the sideload successful?"
            echo.
            if errorlevel 2 (
                echo Trying sideload again...
                echo.
                REM C16 - Second ROM installation command
                adb -d sideload ROM.zip
                echo.
                choice /M "Was the sideload successful now?"
                echo.
                if errorlevel 2 (
                    timeout /t 3
                    goto end1
                )
            )
        )
    )
) else (
    echo Continuing with ROM installation...
    echo.
    choice /M "Execute installation now?"
    echo.
    if errorlevel 2 (
        echo Proceeding without installing ROM...
        echo.
    ) else (
        REM C17 - Third ROM installation command
        adb -d sideload ROM.zip
        echo.
        choice /M "Was the sideload successful?"
        echo.
        if errorlevel 2 (
            echo Trying sideload again...
            echo.
            REM C18 - Fourth ROM installation command
            adb -d sideload ROM.zip
            echo.
            choice /M "Was the sideload successful now?"
            echo.
            if errorlevel 2 (
                timeout /t 3
                goto end1
            )
        )
    )
)
echo.
echo ROM installation completed.
echo.
cls
REM C19 - Ask about GAPPS
echo.
choice /M "Do you have GAPPS available for installation?"
echo.
if errorlevel 2 (
    echo GAPPS not available, proceeding to the next step...
    echo.
) else (
    choice /M "Execute installation now?"
    echo.
    if errorlevel 2 (
        echo Proceeding to the next step...
        echo.
    ) else (
        REM C20 - First GAPPS installation command
        adb -d sideload GAPPS.zip
        echo.
        choice /M "Was the installation successful?"
        echo.
        if errorlevel 2 (
            choice /M "Do you want to try again?"
            echo.
            if errorlevel 2 (
                echo Proceeding to the next step...
                echo.
            ) else (
                REM C21 - Second GAPPS installation command
                adb -d sideload GAPPS.zip
                echo.
                choice /M "Was the installation successful now?"
                echo.
                if errorlevel 2 (
                    echo Proceeding to the next step...
                    echo.
                )
            )
        )
    )
)
cls
REM C22 - Ask about Magisk flashable file
echo.
choice /M "Do you have a flashable Magisk file available for installation?"
echo.
if errorlevel 2 (
    echo Magisk not available, proceeding to the next question...
    echo.
) else (
    choice /M "Execute installation now?"
    echo.
    if errorlevel 2 (
        echo Proceeding to the next question...
        echo.
    ) else (
        REM C23 - First Magisk installation command
        adb -d sideload magisk.zip
        echo.
        choice /M "Was the installation successful?"
        echo.
        if errorlevel 2 (
            choice /M "Do you want to try again?"
            echo.
            if errorlevel 2 (
                echo Proceeding to the next step...
                echo.
            ) else (
                REM C24 - Second Magisk installation command
                adb -d sideload magisk.zip
                echo.
                choice /M "Was the installation successful now?"
                echo.
                if errorlevel 2 (
                    echo Proceeding to the next step...
                    echo.
                )
            )
        )
    )
)
cls
REM C25 - Ask about KernelSU flashable file
echo.
choice /M "Do you have a flashable KernelSU file available for installation?"
echo.
if errorlevel 2 (
    echo KernelSU not available, proceeding to the next step...
    echo.
) else (
    choice /M "Execute installation now?"
    echo.
    if errorlevel 2 (
        echo Proceeding to the next step...
        echo.
    ) else (
        REM C26 - First KernelSU installation command
        adb -d sideload KSU.zip
        echo.
        choice /M "Was the installation successful?"
        echo.
        if errorlevel 2 (
            choice /M "Do you want to try again?"
            echo.
            if errorlevel 2 (
                echo Proceeding to the next step...
                echo.
            ) else (
                REM C27 - Second KernelSU installation command
                adb -d sideload KSU.zip
                echo.
                choice /M "Was the installation successful now?"
                echo.
                if errorlevel 2 (
                    echo Proceeding to the next step...
                    echo.
                )
            )
        )
    )
)
cls
REM C28 - Ask about patched 'boot.img' via APATCH or MAGISK
echo.
choice /M "Do you have a 'boot.img' patched with MAGISK or APATCH available for installation?"
echo.
if errorlevel 2 (
    cls
    goto end2
) else (
    choice /M "Execute installation now?"
    echo.
    if errorlevel 2 (
        cls
        goto end2
    ) else (
        echo Restart into fastboot mode to proceed with the patched GKI installation.
        echo.
        timeout /t 3
        echo.
        REM C29 - First GKI installation command
        fastboot flash boot root-boot.img
        echo.
        choice /M "Was the installation successful?"
        echo.
        if errorlevel 2 (
            choice /M "Do you want to try again?"
            echo.
            if errorlevel 2 (
                timeout /t 3
               goto end1
            ) else (
                REM C30 - Second GKI installation command
                fastboot flash boot root-boot.img
                echo.
                choice /M "Was the installation successful now?"
                echo.
                if errorlevel 2 (
                goto end1
                timeout /t 3
                )
            )
        )
        echo.
        REM C31 - Reboot into recovery again
        fastboot reboot recovery
        echo.
        timeout /t 5
        echo.
        cls
        :end2
        echo Format your device in recovery mode if you haven't done so yet.
        echo This action is necessary to decrypt the device and prevent bootloops.
        echo If you are just updating your ROM, ignore this message.
        echo.
        echo Installation complete. Exiting service.
        echo.
        pause
        exit
    )
)
:end1
echo.
echo It looks like something is wrong. The script will be terminated. Please correct the error and try again.
echo.
pause
