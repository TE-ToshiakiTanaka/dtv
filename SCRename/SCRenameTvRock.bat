@echo off
setlocal

rem SCRename.vbs ���C���X�g�[�������p�X��ݒ�
set SCRPATH=%~dp0

for /F "usebackq delims=" %%I in (`cscript //nologo "%SCRPATH%\SCRename.vbs" "%~1" "$SCtitle$ $SCpart$��$SCnumber$�b �u$SCsubtitle$�v ($SCservice$)" %2 %3`) do set SCRTARGET=%%~I

rem �ݒ��
rem call encode.bat "%SCRTARGET%"
endlocal
