@echo off

FOR /F "delims=." %%a IN (video.txt) DO (
   @ECHO %%a
   C:\SCRename\bat\AfterRec.bat "\\NEWMAN\Video\video\%%a.ts" "\\NEWMAN\Video\video\" "%%a" "�A�j���^���B"
)