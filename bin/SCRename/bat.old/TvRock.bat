@ECHO OFF
REM %1=�t�@�C�����̃t���p�X,%2=�W������,%3=�I�v�V����

REM ���ϐ�(�s����\�͕s�v)
SET SCRPATH=C:\SCRename
SET SCRIPTSPATH=C:\SCRename\bat\Scripts

REM ����
SET GENRE=%~2
SET OPTION=%~3

REM �W������
REM �W���������Ȃ��ꍇ
IF "%GENRE%"=="" SET GENRE=�s��
REM �Ō�̔��p�X�y�[�X������
IF "%GENRE:~-1%"==" " SET GENRE=%GENRE:~0,-1%
REM �W���������ύX Start
IF "%GENRE%"=="�A�j���^���B" SET GENRE=�A�j��
IF "%GENRE%"=="�j���[�X�^��" SET GENRE=�j���[�X
IF "%GENRE%"=="���^���C�h�V���[" SET GENRE=���
IF "%GENRE%"=="�h�L�������^���[�^���{" SET GENRE=�h�L�������^���[
REM �W���������ύX End

REM �W�������ʃt�H���_
:GENREFOLDER
SET OUTPUTFOLDER=%GENRE%

REM �I�v�V����
:OPTION
IF "%OPTION%"=="1" CALL :������

REM �ԑg���擾
:TITLE
FOR /F "usebackq delims=" %%I in (`CSCRIPT //NoLogo "%SCRIPTSPATH%\ProgramTitle.vbs" "%~1"`) do set TITLE=%%~I
IF NOT "%TITLE%"=="" (
	SET OUTPUTFOLDER=%OUTPUTFOLDER%\%TITLE%
	GOTO :SCRENAME2
)

REM SCRENAME(Anime)
:SCRENAME1
FOR /F �gusebackq delims=�h %%I in (`CSCRIPT //NoLogo �g%SCRPATH%\SCRename.vbs�h �g%~1�� �g%OUTPUTFOLDER%\$SCtitle$\$SCtitle$ $SCpart$��$SCnumber$�b �u$SCsubtitle$�v�h`) do set SCRTARGET=%%~I
REM �ԑg��񂪎擾�ł��Ă���ΏI���A�ł��Ă��Ȃ����SCRename�Ń��l�[��
IF NOT "%SCRTARGET%"=="%~1" (GOTO :EOF) ELSE (GOTO :SCRENAME2)

REM SCRENAME(Other)
:SCRENAME2
FOR /F "usebackq delims=" %%I in (`CSCRIPT //NoLogo "%SCRPATH%\SCRename.vbs" -f "%~1" "%OUTPUTFOLDER%\$SCtitle$$SCservice$)"`) do set SCRTARGET=%%~I

REM �I��
GOTO :EOF


REM �I�v�V����1 ������
:������
SET OUTPUTFOLDER=%OUTPUTFOLDER%\������
GOTO :EOF