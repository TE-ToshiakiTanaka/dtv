@ECHO OFF
DIR "F:\retry" /b > M:\list.txt
FOR /F "delims=" %%a IN (M:\list.txt) DO (
	@ECHO %%a
	C:\SCRename\bat\JenkinsRecINsideRetry.bat "%%a"
)