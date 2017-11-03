@rem Put this file and vpnca.crt.der in the same directory, run it as Administrator.
@echo off
echo Windows Registry Editor Version 5.00 >t1.reg 
echo. 
echo [HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\RasMan\Parameters\] >>t1.reg 
echo "DisableIKENameEkuCheck"=dword:1 >>t1.reg
regedit /s t1.reg
del /q t1.reg
@setlocal enableextensions
@set current_dir="%~dp0"
@cd /d "%current_dir%"
@echo %current_dir%
@certutil -addstore root vpnca360.crt.der
if %ERRORLEVEL% EQU 0 @echo not ok
pause
