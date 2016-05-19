   @ECHO OFF
   REM %1=ファイル名のフルパス,%2=ジャンル,%3=オプション アニメ／特撮

   COPY "E:\before\%~1" "F:\tmp\%~1"
   PING 1.1.1.1 -n 1 -W 5000 > nul
   CSCRIPT C:\Users\setsulla\Software\dtv\BonTsDemux\taskenc.vbs "F:\tmp\%~2.ts"
   REM C:\BonTsDemux\BonTsDemux.exe -encode X264_mp4 -rf64 -vf -start -quit -noguiS -i "M:\tmp\%~1"
   CD "F:\tmp\"
   DEL F:\tmp\*.ts
   PING 1.1.1.1 -n 1 -W 5000 > nul
   MOVE "E:\before\%~1" "E:\archive\"


