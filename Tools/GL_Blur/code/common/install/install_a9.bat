@echo off

cd ..\..\..\

call subst_S.bat

start S:\Blur_Framework\BlurOffline_python26_2013-01-28_install_13200_64.exe
pause

python S:\install_gl_environment.pyw
python S:\code\common\install\Install_A9_scripts.py

pause