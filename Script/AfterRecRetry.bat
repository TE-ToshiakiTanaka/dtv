@ECHO OFF
REM %1=ファイル名のフルパス,%2=ジャンル,%3=オプション アニメ／特撮

COPY "F:\retry\%~1" "M:\tmp\%~1"
CSCRIPT C:\BonTsDemux\taskenc.vbs "M:\tmp\%~2.ts"
REM C:\BonTsDemux\BonTsDemux.exe -encode X264_mp4 -rf64 -vf -start -quit -i "M:\tmp\%~1"
CD "M:\tmp\"
DEL M:\tmp\*.ts
MOVE "F:\retry\%~1" "F:\archive\"


