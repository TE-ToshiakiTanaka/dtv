@ECHO OFF
DIR "F:\before" /b > M:\list.txt
FOR /F "delims=" %%a IN (M:\list.txt) DO (
	@ECHO %%a
	C:\SCRename\bat\JenkinsRecINside.bat "%%a"
)