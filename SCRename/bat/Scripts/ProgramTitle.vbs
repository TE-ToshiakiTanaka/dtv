'ProgramTitle 1.1

Option Explicit
On Error Resume Next

'�ϐ���`
Dim str1
Dim argv()
Dim i,j,argc
Dim path,title
Dim objFSO,objFile

'��������
For Each str1 In WScript.Arguments
	ReDim Preserve argv(argc)
	argv(argc)=str1
	argc=argc+1
Next

'�N��������
If argv(0)="" Then
	WScript.StdErr.WriteLine "�G���["
	WScript.Sleep(1000)
	WScript.Quit(1)
End If

'PTitle.prg �ǂݍ���
path=Left(WScript.ScriptFullName,InStrRev(WScript.ScriptFullName,"\"))
str1=path&"PTitle.prg"
Set objFSO=CreateObject("Scripting.FileSystemObject")
If objFSO.FileExists(str1) Then
	'OpenTextFile(filename,iomode,create,format)
	Set objFile=objFSO.OpenTextFile(str1,1,False,-2)
	Do While Not objFile.AtEndOfStream
		str1=objFile.ReadLine
		If Left(str1,1)<>":" Then
			i=InStr(str1,",")
			title=Left(str1,i-1)
			If InStr(argv(0),title)>0 Then
				objFile.Close
				Set objFile=Nothing
				title=Mid(str1,i+1)
				WScript.Echo title
				WScript.Quit(1)
			End If
		End If
	Loop
End If