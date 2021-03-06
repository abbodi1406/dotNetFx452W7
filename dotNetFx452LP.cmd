@echo off
%windir%\system32\reg.exe query "HKU\S-1-5-19" >nul 2>&1 || (
echo ==== ERROR ====
echo This script require administrator privileges.
echo To do so, right click on this script and select 'Run as administrator'
echo.
echo Press any key to exit...
pause >nul
goto :eof
)
cd /d "%~dp0"
if not exist "BIN\7z.exe" (
echo ==== ERROR ====
echo Required binary files are missing.
echo.
echo Press any key to exit...
pause >nul
goto :eof
)
if not exist "BIN\NDP\LP\*.vbs" (
echo ==== ERROR ====
echo Required work files are missing.
echo.
echo Press any key to exit...
pause >nul
goto :eof
)
if not exist "LP\*NDP*.exe" (
echo ==== ERROR ====
echo NDP*.exe files are not detected.
echo.
echo Press any key to exit...
pause >nul
goto :eof
)
setlocal EnableExtensions EnableDelayedExpansion
set MUI=(ARA,CHS,CHT,CSY,DAN,DEU,ELL,ESN,FIN,FRA,HEB,HUN,ITA,JPN,KOR,NLD,NOR,PLK,PTB,PTG,RUS,SVE,TRK)
for /f "tokens=1 delims=-" %%i in ('dir /b LP\*NDP*.exe') do set "ndpver=%%iLP"
for %%b in (D,N,P) do set ndpver=!ndpver:%%b=%%b!
xcopy /criy BIN\NDP\LP\* %ndpver%\ >nul
cd %ndpver%
echo.
echo Processing LangPacks . . .
echo.
for %%a in %MUI% do if exist "%~dp0LP\*NDP*%%a*.exe" if not exist "netfx_FullLP_LDR_x86_%%a.msi" (
echo %%a
..\BIN\7z.exe e ..\LP\*%%a*.exe -otemp netfx_FullLP_LDR_x64.msi netfx_FullLP_LDR_x86.msi netfx_FullLP_LDR.mzz -aoa >nul
cscript //B slim%%a.vbs temp\netfx_FullLP_LDR_x86.msi
cscript //B slim%%a.vbs temp\netfx_FullLP_LDR_x64.msi
start /wait msiexec /a temp\netfx_FullLP_LDR_x86.msi TARGETDIR="%cd%" /quiet
start /wait msiexec /a temp\netfx_FullLP_LDR_x64.msi TARGETDIR="%cd%" /quiet
ren netfx_FullLP_LDR_x86.msi netfx_FullLP_LDR_x86_%%a.msi
ren netfx_FullLP_LDR_x64.msi netfx_FullLP_LDR_x64_%%a.msi
)
echo.
echo Cleanup . . .
del /f /q *.vbs *.ico
rd /s /q temp\
echo.
echo Done.
echo Press any key to exit.
pause >nul
goto :eof
