@ECHO OFF
REM %1=ファイル名のフルパス,%2=ジャンル,%3=オプション

REM 環境変数(行末に\は不要)
SET SCRPATH=C:\SCRename
SET SCRIPTSPATH=C:\SCRename\bat\Scripts

REM 引数
SET GENRE=%~2
SET OPTION=%~3

REM ジャンル
REM ジャンルがない場合
IF "%GENRE%"=="" SET GENRE=不明
REM 最後の半角スペースを除去
IF "%GENRE:~-1%"==" " SET GENRE=%GENRE:~0,-1%
REM ジャンル名変更 Start
IF "%GENRE%"=="アニメ／特撮" SET GENRE=アニメ
IF "%GENRE%"=="ニュース／報道" SET GENRE=ニュース
IF "%GENRE%"=="情報／ワイドショー" SET GENRE=情報
IF "%GENRE%"=="ドキュメンタリー／教養" SET GENRE=ドキュメンタリー
REM ジャンル名変更 End

REM ジャンル別フォルダ
:GENREFOLDER
SET OUTPUTFOLDER=%GENRE%

REM オプション
:OPTION
IF "%OPTION%"=="1" CALL :未視聴

REM 番組名取得
:TITLE
FOR /F "usebackq delims=" %%I in (`CSCRIPT //NoLogo "%SCRIPTSPATH%\ProgramTitle.vbs" "%~1"`) do set TITLE=%%~I
IF NOT "%TITLE%"=="" (
	SET OUTPUTFOLDER=%OUTPUTFOLDER%\%TITLE%
	GOTO :SCRENAME2
)

REM SCRENAME(Anime)
:SCRENAME1
FOR /F “usebackq delims=” %%I in (`CSCRIPT //NoLogo “%SCRPATH%\SCRename.vbs” “%~1″ “%OUTPUTFOLDER%\$SCtitle$\$SCtitle$ $SCpart$第$SCnumber$話 「$SCsubtitle$」”`) do set SCRTARGET=%%~I
REM 番組情報が取得できていれば終了、できていなければSCRenameでリネーム
IF NOT "%SCRTARGET%"=="%~1" (GOTO :EOF) ELSE (GOTO :SCRENAME2)

REM SCRENAME(Other)
:SCRENAME2
FOR /F "usebackq delims=" %%I in (`CSCRIPT //NoLogo "%SCRPATH%\SCRename.vbs" -f "%~1" "%OUTPUTFOLDER%\$SCtitle$$SCservice$)"`) do set SCRTARGET=%%~I

REM 終了
GOTO :EOF


REM オプション1 未視聴
:未視聴
SET OUTPUTFOLDER=%OUTPUTFOLDER%\未視聴
GOTO :EOF