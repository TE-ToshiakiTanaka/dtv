
DIR "E:\before" /b > F:\list.txt
FOR /F "delims=" %%a IN (F:\list.txt) DO (
	@ECHO %%a
	@ECHO %%~a
	@ECHO %%~na

	COPY "E:\before\%%~a" "F:\tmp\%%~a"

   	PING 1.1.1.1 -n 1 -W 5000 > nul

   	CSCRIPT C:\Users\setsulla\Software\dtv\BonTsDemux\taskenc.vbs "F:\tmp\%%~na.ts"
   	CD "F:\tmp\"
   	DEL F:\tmp\*.ts
   	PING 1.1.1.1 -n 1 -W 5000 > nul
   	
	MOVE "E:\before\%%~a" "E:\archive\"
)