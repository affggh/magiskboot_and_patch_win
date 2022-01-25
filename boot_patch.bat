@echo off
setlocal enabledelayedexpansion

if "%1"=="" call :Usage & exit /b 1
if "%1"=="-h" call :Usage & exit /b 0
if "%1"=="--help" call :Usage & exit /b 0

set "Path=%~dp0bin;%Path%"

if not exist "%1" busybox printf "\033[031mError File [%1] not found...\033[0m\nPlease check your path if correct...\n" & exit /b 1
set "filepath=%1"
set filepath=%filepath:/=\%

if "%2"=="" set IS64BIT=true
if "%2"=="false" set IS64BIT=false
if "%3"=="" set KEEPVERITY=false
if "%4"=="" set KEEPFORCEENCRYPT=false
if "%5"=="" set "default=Magisk-23.0"

for /f "tokens=2 delims=-." %%i in ("%5") do set ver=%%i

busybox printf "\033[1;45;33mWorking on [%%s] image\033[0m\n" "%filepath%"
busybox printf "\033[1;45;33mPatch with config:\033[0m\n"
busybox printf "\033[1;45;33m     IS64BIT=[%%s]\033[0m\n" "%2"
busybox printf "\033[1;45;33m     KEEPVERITY=[%%s]\033[0m\n" "%3"
busybox printf "\033[1;45;33m     KEEPFORCEENCRYPT=[%%s]\033[0m\n" "%4"
busybox sleep 2

if not "%5"=="custom" (
	if not exist "prebuilt\%5\" ( 
		busybox printf "\033[1;45;33mMagisk version not found...\033[0m\n"
		exit /b 1
	)
)

busybox printf "\033[1;45;33mCopy prebuilt binary files...\033[0m\n"
if not "%5"=="custom" (
	if not "!ver!" LSS "22" (
		busybox printf "\033[1;45;33mTarget Magisk version is [%%s]...\033[0m\n" "%5"
		copy "%~dp0prebuilt\%5\libmagiskinit.so" .\magiskinit
		copy "%~dp0prebuilt\%5\libmagisk32.so" .\magisk32
		copy "%~dp0prebuilt\%5\libmagisk64.so" .\magisk64
	) else (
		busybox printf "\033[1;45;33mTarget Magisk version is [%%s]...\033[0m\n" "%5"
		if "%IS64BIT%"=="true" (
			copy "%~dp0prebuilt\%5\magiskinit64" .\magiskinit
		) else (
			copy "%~dp0prebuilt\%5\magiskinit" .\magiskinit
		)
	)
) else (
	busybox printf "\033[1;45;33mUse custom build...\033[0m\n" "%5"
	if not exist "%~dp0custom\libmagiskinit.so" (
		busybox printf "\033[1;45;33mlibmagiskinit.so is missing...\033[0m\n"
	) else (
		copy "%~dp0custom\libmagiskinit.so" ".\magiskinit"
	)
	if exist "%~dp0custom\libmagisk32.so" ( copy "%~dp0custom\libmagisk32.so" .\magisk32
	) else (
		echo Warning magisk32 not found
	)
	if exist "%~dp0custom\libmagisk64.so" ( copy "%~dp0custom\libmagisk64.so" .\magisk32
	) else (
		echo Warning magisk32 not found
	)
	if not exist ".\magisk32" (
		if not exist ".\magisk64" (
			busybox printf "\033[1;45;33mThis is old type magisk which is not support anymore...\033[0m\n"
		)
	)
	if exist ".\magisk32" (
		if not exist ".\magisk64" (
			if "%IS64BIT%"=="true" (
				busybox printf "\033[1;45;33mType of IS64BIT is wrong...\033[0m\n"
				exit /b 1
			)
		)
	)
	if exist ".\magisk64" (
		if "%IS64BIT%"=="false" (
			busybox printf "\033[1;45;33mType of IS64BIT is wrong...\033[0m\n"
			exit /b 1
		)
	)
)

if "%5"=="custom" (
	set ver=23
	busybox printf "\033[1;45;33mUse Custom script...\033[0m\n"
	if exist "%~dp0custom\boot_patch.sh" (
		busybox ash "%~dp0custom\boot_patch.sh" %filepatch% %2 %3 %4
	) else (
		busybox printf "\033[1;45;33mError custom patch script not found...\033[0m\n"
	)
)
if not "%5"=="custom" (
	if "!ver!" LSS "22" (
		busybox printf "\033[1;45;33mUse old script...\033[0m\n"
		if "%IS64BIT%"=="true" (
			busybox ash %~dp0bin\boot_patch_old.sh %filepath% true %3 %4
		) else (
			busybox ash %~dp0bin\boot_patch_old.sh %filepath% false %3 %4
		)
	) else (
		if "%IS64BIT%"=="true" (
			busybox ash %~dp0bin\boot_patch.sh %filepath% true %3 %4
		) else (
			busybox ash %~dp0bin\boot_patch.sh %filepath% false %3 %4
		)
	)
)
busybox printf "\033[1;45;33mcleanup...\033[0m\n"
if exist ".\magiskinit" del /q ".\magiskinit"
if exist ".\magisk32" del /q ".\magisk32"
if exist ".\magisk64" del /q ".\magisk64"
magiskboot cleanup
pause
if exist "new-boot.img" ( 
	busybox printf "\033[1;45;33mSuccess...\033[0m\n"
	exit /b 0
) else (
	busybox printf "\033[1;45;33mFailed...\033[0m\n"
	exit /b 1
)

:Usage
echo  Usage:
echo  %~nx0 ^<boot image^> ^<is 64 bit^> ^<keepverity^> ^<keepforceencrypt^>
echo      You can just provide boot.img
echo      But if you want different patch just provide more args
echo  Example:
echo  %~nx0 boot.img true true true Magisk-23.0
echo  Explain:
echo      Is64Bit : if your device is 64 bit device set arg2 is true default is [true]
echo      KEEPVERITY : if you want keep verity like dm-verity avb-verity in fstab or dt file
echo      KEEPFORCEENCRYPT : As it says keep force encrypt
echo.
goto:eof