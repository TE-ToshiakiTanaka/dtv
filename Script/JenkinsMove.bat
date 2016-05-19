@ECHO OFF
DIR "M:\tmp" /b > M:\move.txt
FOR /F "delims=" %%a IN (M:\move.txt) DO (
	@ECHO %%a
	C:\SCRename\bat\JenkinsMoveINside.bat "%%a"
)