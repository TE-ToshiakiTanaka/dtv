'ProgramTitle 1.0

Option Explicit

'•Ï”’è‹`
Dim str1
Dim argv()
Dim i,j,argc
Dim path
Dim objFSO,objFile

'ˆø”ˆ—
For Each str1 In WScript.Arguments
	ReDim Preserve argv(argc)
	argv(argc)=str1
	argc=argc+1
Next

'PTitle.prg “Ç‚Ýž‚Ý
path=Left(WScript.ScriptFullName,InStrRev(WScript.ScriptFullName,"\"))
str1=path&"PTitle.prg"
Set objFSO=CreateObject("Scripting.FileSystemObject")
If objFSO.FileExists(str1) Then
	'OpenTextFile(filename,iomode,create,format)
	Set objFile=objFSO.OpenTextFile(str1,1,False,-2)
	Do While Not objFile.AtEndOfStream
		str1=objFile.ReadLine
		If InStr(argv(0),str1)>0 Then
			objFile.Close
			Set objFile=Nothing
			WScript.Echo str1
		End If
	Loop
End If