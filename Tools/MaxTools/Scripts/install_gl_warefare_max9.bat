echo off
set FIND_SET="C:\3ds Max 9", "D:\Dev\3ds Max 9","D:\3ds Max 9","C:\Program Files\3ds Max 9","C:\Program Files\Autodesk\3ds Max 9","C:\Progra~2\Autodesk\3ds Max 9"
set MAX_PATH=
for %%p in (%FIND_SET%) do (
	if exist "%%~p" (set MAX_PATH=%%~p)
)

if "%MAX_PATH%"=="" (
	echo 3dsMax9 not found !!!
	pause
) else (
	echo 3dsMax9 found at: %MAX_PATH%
)

xcopy .\GL_Warfare\max9\*.* "%MAX_PATH%" /s /q /y