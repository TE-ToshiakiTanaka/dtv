@ECHO OFF
REM %1=ファイル名のフルパス,%2=ジャンル,%3=オプション アニメ／特撮

MOVE "M:\tmp\%~1" "K:\Recorded TV\"
C:\SCRename\bat\TvRock.bat "K:\Recorded TV\%~1" "%~2"
