Option Explicit
Dim goShell,sLockFile
Dim sPreset,sTarget,gsTarget,sBat
Dim aTime
Dim gsSpliter,gsSpliterOpt,gsMediaCoder,gsMediaCoderOpt,gsTargetExt,gsTargetExt2,gsEncodeFile
Dim gsLogFile
Dim oArgs
Dim gbBatMode,gsBatModeInExt,gsBatModeOutExt
Dim gsScriptPath,goFs
Set goShell = WScript.CreateObject("WScript.Shell")
Set goFs = CreateObject("Scripting.FileSystemObject")
Dim goBatFile
gsScriptPath = GetParentFolder(WScript.ScriptFullName)

'====================================================================================
'====================================================================================
'====================================================================================
'==  ここから上は触らないで
' ' ←で始まる行はコメントですので、スクリプトの実行に影響ありません。
'====================================================================================

'=TsSplitterの場所をフルパスで指定する。絶対に設定する必要がある。
gsSpliter    = "C:\Users\setsulla\Software\dtv\BonTsDemux\TsSplitter\TsSplitter.exe"

'MediaCoderの実行ファイル名をフルパスで実行する。絶対に設定する必要がある。
gsMediaCoder = "C:\Users\setsulla\Software\dtv\BonTsDemux\BonTsDemux.exe"

'====================================================================================
'==  ここから下のオプションは好みで変更してください。
'====================================================================================
'=TsSplitterのオプションを指定する。変更する必要は無いが、好みがあれば。
gsSpliterOpt    = "-SD -1SEG -WAIT2 -SEP3 -OVL5,7,0"
'====================================================================================
'TsSplitterの出力するファイルでMediaCoderでのエンコード対象とするファイルの末尾を表現する
'正規表現を設定する
'TsSplitterに-SEPオプションを付けて起動すると。
'aa.ts → "aa_HD-1.ts","aa_HD-2.ts","aa_HD-3.ts"
'みたいに複数のファイルを出力する。
'このスクリプトはエンコード元のファイル名(ex."番組名.ts")から拡張子を取り(ex."番組名")
'ここで指定した正規表現を後ろにを付け足し(ex."番組名_HD.*\.ts")、この正規表現に
'マッチするファイルの中から最も*サイズが大きいもの*をエンコードします。
'通常変更する必要はない
gsTargetExt = "_HD.*\.ts"
gsTargetExt2 = ".*\.ts"
'gsTargetExt = "_SD.*\.ts"
'====================================================================================
'MediaCoderのpreset以外で使用するオプションを指定する。変更する必要なし
gsMediaCoderOpt = "-encode X264_HIGH_WXGA -rf64 -vf -start -quit -i "
'====================================================================================
'ロックファイルの場所を指定する。変更する必要は無いが、好みがあれば変更する。
'デフォルトではこのスクリプトがあるのと同じフォルダにロックファイルを作成する。
sLockFile = gsScriptPath & "taskenc.lock"
'sLockFile = "d:\tv\taskenc.lock"
'====================================================================================
'ログファイルの場所を指定する。変更する必要は無いが、好みがあれば変更する。
'デフォルトではこのスクリプトがあるのと同じフォルダにログファイルを作成する。
gsLogFile = gsScriptPath & "taskenc.log"
'gsLogFile = "d:\tv\taskenc.log"
'====================================================================================
'エンコーダの起動を許可する時間帯を指定する。変更する必要は無いが、好みがあれば変更する。
'デフォルトではいつでも起動する。昼間のみにエンコードを実行したい場合は
'コメントアウトしてある行みたいにする。
aTime = Array(0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23)
'aTime = Array(6,7,8,9,10,11,12,13,14,15,16,17,18)
'↑の例では6時から18時の間しかエンコーダを起動しない。
'====================================================================================
'batモードの時のデフォルトのエンコード対象の拡張子と、エンコード形式を指定する。
'通常モードのときは自動検索するので指定する必要はない。
'/inext,/outextオプションを使用して変更したほうがいいです。
gsBatModeInExt  = "_HD.ts"
gsBatModeOutExt = ".mp4"
'====================================================================================

'====================================================================================


'==  ここから下は触らないで
'====================================================================================
'====================================================================================
'====================================================================================

Dim gsUsage
gsUsage           = _
"使い方" & _
"　cscript taskenc.vbs  [エンコードするtsファイル名]"  & vbNewLine & _
"　　　　　　　　　　 　  (/p:[使用するプリセットファイル名]"  & vbNewLine & _
"　　　　　　　　　　　   (/b:[出力するバッチファイル名])"  & vbNewLine & _
vbNewLine & _
"オプション "  & vbNewLine & _
"　必須オプション：[エンコードするtsファイル名]"  & vbNewLine & _
"　　エンコードするTSファイル名を指定する"  & vbNewLine & _
"　追加オプション：/p:[使用するプリセットファイル名]"  & vbNewLine & _
"　　MediaCoderで使用するpresetファイル名を指定します"  & vbNewLine & _
"　追加オプション：/b:[出力するファイル名]"  & vbNewLine & _
"　　エンコード処理を実行せずに、エンコード用のバッチファイルを出力します"  & vbNewLine & _
"　　実際のエンコードは行いません。動作確認等に使用してください。"  & vbNewLine & _
vbNewLine & _
"例) cscript taskenc.vbs ""d:\tv\番組タイトル.ts"" "  & vbNewLine & _
"　メディアコーダーのデフォルトの設定を使用してtsファイルをエンコードします"  & vbNewLine & _
"例) cscript taskenc.vbs ""d:\tv\番組タイトル.ts"" /p:""d:\tv\psp.xml"""  & vbNewLine & _
"　psp.xmlのプリセットファイルを使用してtsファイルをエンコードします"  & vbNewLine & vbNewLine &_
"以下batモードの例" & vbNewLine & _
" /b:[出力ファイル名]のオプションを指定するとbatモードでスクリプトを実行します。" & vbNewLine & _
"batモードではエンコードを実施せず、エンコード用のバッチファイルを出力するだけです。" & vbNewLine & _
"例) cscript taskenc.vbs ""d:\tv\番組タイトル.ts"" /p:""d:\tv\psp.xml"" /b:""d:\tv\enc.bat"""  & vbNewLine & _
"　指定されたtsファイルをエンコードするbatファイルを、指定したファイルに書き出す"  & vbNewLine & _
"例) cscript taskenc.vbs ""d:\tv\番組タイトル.ts"" /p:""d:\tv\psp.xml"" /b:""d:\tv\enc.bat""  /outext:"".avi"" /inext:""_HD-1.ts"" " & vbNewLine & _
"　指定されたtsファイルをエンコードするbatファイルを、指定したファイルに書き出す"  & vbNewLine & _
"　batモードではTsSplitterが出力したどのファイルをエンコードすればいいか分からないため、" & vbNewLine & _
"　/inext:オプションを指定してTsSplitterが出力するファイルの末尾を指定します。省略した場合は末尾が""_HD.ts""のファイルを" & vbNewLine & _
"　エンコードします。末尾が""_HD.ts""以外のファイルをエンコード対象としたい場合は例の様に/inextオプションを指定します。" & vbNewLine & _
"　/outext:MediaCoderが出力するファイルの拡張子を指定します。省略した場合は末尾が"".mp4""のファイルを" & vbNewLine & _
"　エンコードします。末尾が"".mp4""以外のファイルが出力される場合は例の様に/outextオプションを指定します。"

gsEncodeFile=""
'====================================================================================
'==  メイン処理　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　==
'====================================================================================
Call WriteLog("スクリプトが起動されました。")

'コマンドラインオプションの解析
if False = ReadArgs(sTarget,sPreset,sBat) Then
   WScript.StdErr.Write "コマンドラインオプションの解析に失敗しました。" & vbNewLine
   WScript.StdErr.Write gsUsage
   WScript.Quit
end if

Call WriteLog("処理を開始します。")

WriteLog("処理対象TS:" & sTarget)
if ("" = sPreset) then
   WriteLog("プリセット:MediaCoderのデフォルト" )
else
   WriteLog("プリセット:" & sPreset)
end if

if ("" <> sBat) then
   WriteLog("出力バッチ:" & sBat)
end if

' 処理が可能になるまで待ちます。
if ("" = sBat) then
   Call WaitStart(aTime)
end if

' 処理を開始します。
Call DoScript(sTarget,sPreset,sBat)

' ロックファイルを削除して、処理を終了します。
Call DeleteLock(sLockFile)

Call WriteLog("処理を終了しました。")


'====================================================================================
'==  メイン処理終了　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　==
'====================================================================================
'以下関数郡
'==========================================
'エンコードの処理を実行します。
'sTarget-指定したtsファイルのフルパス (ex."d:\tv\番組名.ts")
'sPreset-指定したtsファイルのフルパス(ex."d:\tv\psp.xml")
'sBat-指定したtsファイルのフルパス(ex."d:\tv\enc.bat")
Function DoScript(sTarget,sPreset,sBat)
   Dim sTmp,oFs,oFile,oShell,sEncodeFile
   Dim i,iLen
   Set oFs = CreateObject("Scripting.FileSystemObject")
   Set oShell = WScript.CreateObject("WSCript.shell")

   if (True = gbBatMode) then
      Set goBatFile = oFs.OpenTextFile(sBat,2,True)
   end if

   '===========================================================================
   'TsSplitterの実行
   sTmp = """" & gsSpliter & """ " & gsSpliterOpt    & " """ & sTarget & """"
   DoIt(sTmp)

   '===========================================================================
   'TsSplitterの出力ファイルから最もサイズが大きいものを探す。
   Dim aFiles,sTmpFileName,sOutFileName
   aFiles = Array(0)
   sEncodeFile = ""
   if (not gbBatMode) then
      sEncodeFile = GetLargestFile(sTarget,gsTargetExt,aFiles)
      if "" = sEncodeFile then
         WriteLog("エンコード可能なファイルが見つかりませんでした")
         sEncodeFile = GetLargestFile(sTarget,gsTargetExt2,aFiles)
         if "" = sEncodeFile then
             WriteLog("エンコード可能なファイルが全くもって見つかりませんでした")
             exit function
         end if
      end if
   else
      'batモード場合は決め打ち。
      sEncodeFile = GetParentFolder(sTarget) & oFs.GetBaseName(sTarget) & gsBatModeInExt
   end if

   WScript.echo "parent=" & GetParentFolder(sTarget)


   WriteLog("""" & sEncodeFile & """をエンコードします")
   '===========================================================================
   'MediaCoderは日本語のファイル名の扱いに不安があるので、
   '英数字のTMPファイルにリネームする
   sTmpFileName = GetParentFolder(sTarget) & Left(oFs.GetTempName(),8) & ".ts"
   sTmp = "cmd /c move """ & sEncodeFile & """ """ & sTmpFileName &""""
   DoIt(sTmp)

   '===========================================================================
   'MediaCoderの実行
   sTmp = """" & gsMediaCoder & """ " & gsMediaCoderOpt
   if ("" <> sPreset) then
      sTmp = sTmp & " -preset  """ & sPreset & """ "
   end if
   sTmp = sTmp & " """ & sTmpFileName & """"
   DoIt(sTmp)

   '===========================================================================
   'エンコード元のTMPファイルから元のファイル名にリネームする。
   sTmp = "cmd /c move """ & sTmpFileName & """ """ & sEncodeFile &""""
   DoIt(sTmp)

   '===========================================================================
   'エンコードされたファイルのファイル名は"TMPファイル名.mp4"みたいになっているので
   '拡張子以外を元のファイル名に戻す。
   Dim sSrc,sDest
   if (not gbBatMode) then
      if (not GetOutputFile(sEncodeFile,sTmpFileName,sSrc,sDest)) then
         WriteLog("出力ファイルが見つかりません。")
         exit function
      end if
   else
      'batモードの場合は拡張子を決め打ちします。
      sSrc  = GetParentFolder(sTmpFileName)  & oFs.GetBaseName(sTmpFileName) & gsBatModeOutExt
      sDest = GetParentFolder(sEncodeFile)  & oFs.GetBaseName(sEncodeFile) & gsBatModeOutExt
   end if

   sTmp = "cmd /c move """ & sSrc & """ """ & sDest & """"
   DoIt(sTmp)

   '===========================================================================
   '不要ファイルの削除
'   if (not gbBatMode) then
'      iLen = UBound(aFiles)
'      For i = 0 to iLen
'         if (aFiles(i) <> sEncodeFile) and (aFiles(i) <> sTarget)then
'            sTmp = "cmd /k del " & aFiles(i)
'            WriteLog("ファイル削除：" & sTmp)
'            DoIt(sTmp)
'         end if
'      next
'   end if
   '===========================================================================
   '終了
   if (gbBatMode) then
      goBatFile.Close
   end if
End Function
'==========================================
'エンコードが可能になるまで待つ
Function WaitStart(aTime)

   '同時に終わった番組を同時にエンコードの開始をしないように
   '最大3分の乱数秒待ちます。
   WriteLog("処理開始まで一応3分ぐらい待ちます。")
'  WaitRandTime( 3 * 60 * 1000)

   ' 起動時間制御機能を使用した場合は、時間になるまで待ちます。
   Dim sEncodeingFile
   Do
      if AllowTime(aTime) then
         if DoLock(sLockFile,sEncodeingFile) then
            exit do
         else
            WriteLog(sEncodeingFile & "がエンコード中ですので10分待ちます。")
         end if
      else
         WriteLog("現在は処理実行禁止時間帯です。")
      end if
      WScript.Sleep 1 * 60 * 1000
   Loop While (True)

End Function

'==========================================
'ロックファイルを作成する
Function DoLock(sLockFile,ByRef sEncodeingFile)
   Dim oFs,oFile
   Set oFs = CreateObject("Scripting.FileSystemObject")
   If ( oFs.FileExists(sLockFile) ) Then
      Dim oLockFile
      Set oLockFile = oFs.OpenTextFile(sLockFile,1)
      On Error Resume Next
      sEncodeingFile = oLockFile.ReadLine
      On Error GoTo 0
      DoLock = False
      Exit Function
   end if
   Set oFile = oFs.CreateTextFile(sLockFile, True)
   oFile.Write (gsTarget)
   oFile.Close
   sEncodeingFile = ""
   DoLock = True
End Function
'==========================================
'ロックファイルを削除する
Function DeleteLock(sLockFile)
   Dim oFs,oFile
   Set oFs = CreateObject("Scripting.FileSystemObject")
   If ( oFs.FileExists(sLockFile) ) Then
      oFs.DeleteFile(sLockFile)
   End if

End Function


'==========================================
'引数のコマンドをシェルで実行する。
Function  DoIt(sCmd)
   if (gbBatMode) then
      WriteBat(sCmd)
   else
      WriteLog("コマンド実行：" & sCmd)
      call goShell.Run(sCmd,7,True)
   end if
End Function
'==========================================
'aTime-配列-エンコードを起動していい時間を持つ
'その配列内の数字が現在の時刻と一致しているものがあれば
'Trueを返す。
Function AllowTime(aTime)
   Dim iHour,i,iLen
   iHour = Hour(Now)
   iLen = UBound(aTime)
   for i = 0 to iLen
      if iHour = aTime(i) then
         AllowTime = True
         Exit Function
      end if
   next
   AllowTime = False
End Function
'==========================================
'引数の文字列をログに書き込む
Function WriteLog(sString)
   Dim oFs,oFile,sTmp
   Set oFs = CreateObject("Scripting.FileSystemObject")
   Set oFile = oFs.OpenTextFile(gsLogFile, 8, True)
   sTmp = FormatDateTime(Now,vbShortDate) & " " & FormatDateTime(Now,vbLongTime) & " " & gsTarget & "|" & sString
   oFile.WriteLine ( sTmp )
   WScript.StdOut.Write sTmp & vbNewLine
   oFile.Close
End Function
'==========================================
'コマンドライン引数を解析する。
'コマンドライン引数からsTarget(入力TSファイル),sPreset(プリセットファイル名)
'sBat(出力するbatファイル名)を設定する。
Function ReadArgs(ByRef sTarget,ByRef sPreset,ByRef sBat)
   Dim oNamed, oUnnamed
   Set oNamed = WScript.Arguments.Named
   Set oUnnamed = WScript.Arguments.Unnamed

   sTarget = ""
   sPreset = ""
   sBat    = ""
   gbBatMode = False
   ReadArgs = False

   if 1 > oUnnamed.Count  then
      WriteLog("エンコードするTSファイル名を指定してください。")
      Exit Function
   End if
   sTarget = oUnnamed.Item(0)
   gsTarget = sTarget
   if (oNamed.Exists("p")) then
      sPreset = oNamed.Item("p")
   end if

   if (oNamed.Exists("b")) then
      sBat = oNamed.Item("b")
      gbBatMode = True
   end if

   '"_HD.ts"みたいな
   if (oNamed.Exists("inext")) then
      gsBatModeInExt = oNamed.Item("inext")
   end if

   '".mp4"みたいな
   if (oNamed.Exists("outext")) then
      gsBatModeOutExt = oNamed.Item("outext")
   end if

   ReadArgs = True
End Function
'==========================================
'乱数で最大引数に指定されたミリ秒間、処理を停止する。
Function WaitRandTime(imSec)
   Dim i
   i=Int(imSec * Rnd)
   WScript.Sleep i
End Function
'==========================================
'sTarget-指定したTSファイル(ex."d:\tv\aaa.ts")
'sTargetExt-TsSplitterが出力するファイル名の末尾の正規表現(ex."_HD.*\.ts"
'aFiles-sTargetの".ts"の部分をsTargetExtに変更して作成した正規表現に
'       マッチするファイル郡を返す。
'       (ex."d:\tv\aaa_HD.*\.ts"にマッチするので
'       "d:\tv\aaa_HD-1.ts","d:\tv\aaa_HD-2.ts"等のファイル名が入る
'戻り値-aFilesのなかで最もファイルサイズが大きいファイルのファイル名を返す。
Function GetLargestFile(sTarget,sTargetExt,ByRef aFiles)
   Dim oSh,oFs,oRe,oDir,oFiles,file
   Dim sPath,sPattern,iMaxSize,sMaxFile,i

   GetLargestFile = ""
   i = -1
   iMaxSize = 0
   sMaxFile = ""
   Set oFs = CreateObject("Scripting.FileSystemObject")
   Set oRe = New RegExp
   oRe.IgnoreCase = True

'   WScript.StdOut.WriteLine ("sTarget=" & sTarget)
'   WScript.StdOut.WriteLine ("sTargetExt=" & sTargetExt)

   'ファイル名のみを取り出す
   sPattern = oFs.GetFileName(sTarget)
'   WScript.StdOut.WriteLine("Before_sPattern=" & sPattern)
   'ファイル名からメタキャラクタをエスケープする
   sPattern = EscapeMetaChar(sPattern)
'   WScript.StdOut.WriteLine("after_sPattern=" & sPattern)
   'ファイルの末尾を、ユーザが指定した正規表現に変える
   oRe.Pattern = "\\.ts$"
   oRe.Pattern = oRe.Replace(sPattern,sTargetExt)
   WriteLog("エンコード対象リスト正規表現:" & oRe.Pattern)

   sPath = GetParentFolder(sTarget)
   if "" = sPath then
      WriteLog("エンコードする対象のファイルはフルパスで指定してください。")
      WriteLog(" 例)×→""aa.ts"" OK!→""c:\tv\aa.ts"" ")
      exit function
   end if
   Set oDir = oFs.GetFolder(sPath)
   Set oFiles = oDir.Files

   For Each file in oFiles
      If oRe.Test(file.name) then
      WriteLog("エンコード候補発見:" & file.name & ",size=" & file.size & "[byte]")
         i= i+1
         ReDim Preserve aFiles(i)
         aFiles(i) = sPath & file.name
         if (iMaxSize < file.size) then
            iMaxSize = file.size
            sMaxFile = aFiles(i)
         end if
      end if
   Next

   GetLargestFile = sMaxFile
End Function
'==========================================
'文字列から正規表現のメタキャラクタをエスケープする
Function EscapeMetaChar(sString)
   Dim oRe,sTmp
   Set oRe = New RegExp

  oRe.Global = True
   sTmp = sString

   oRe.Pattern = "\\"
   sTmp = oRe.Replace(sTmp,"\\")

   oRe.Pattern = "\."
   sTmp = oRe.Replace(sTmp,"\.")

   oRe.Pattern = "\^"
   sTmp = oRe.Replace(sTmp,"\^")

   oRe.Pattern = "\+"
   sTmp = oRe.Replace(sTmp,"\+")

   oRe.Pattern = "\$"
   sTmp = oRe.Replace(sTmp,"\$")

   oRe.Pattern = "\{"
   sTmp = oRe.Replace(sTmp,"\{")
   oRe.Pattern = "\}"
   sTmp = oRe.Replace(sTmp,"\}")

   oRe.Pattern = "\("
   sTmp = oRe.Replace(sTmp,"\(")
   oRe.Pattern = "\)"
   sTmp = oRe.Replace(sTmp,"\)")

   oRe.Pattern = "\["
   sTmp = oRe.Replace(sTmp,"\[")
   oRe.Pattern = "\]"
   sTmp = oRe.Replace(sTmp,"\]")

   EscapeMetaChar = sTmp
End Function

'==========================================
'エンコード後のファイル名を推定し
'TMPファイルと同じ名前になっているエンコード後のファイル名と
'元のファイル名を返す。
function GetOutputFile(sOrgName,sTmpName,sMoveSrc,sMoveDest)
   Dim oFs,oRe
   Dim sFilename,sExt,sBasename,sPattern,sPath,sOrgBaseName,sTmpBaseName

   Set oFs = CreateObject("Scripting.FileSystemObject")
   Set oRe = New RegExp

   sPath = GetParentFolder(sTmpName)
   sOrgBaseName = oFs.GetBaseName(sOrgName)
   sTmpBaseName = oFs.GetBaseName(sTmpName)

   oRe.Pattern = EscapeMetaChar(sTmpBaseName) & "\." & ".+$"

   WScript.Echo "patteern=" & oRe.Pattern

   'ファイル名が同じで拡張子が違うファイルを探す

   Dim oDir,oFiles,file
   Set oDir = oFs.GetFolder(sPath)
   Set oFiles = oDir.Files

   For Each file in oFiles
'   WScript.Echo "findname=" & file.name
      If oRe.Test(file.name) then
'      WScript.Echo "match=" & file.name
         Dim sTmp
         sMoveSrc  = sPath & file.name
         sMoveDest = sPath & sOrgBaseName & "." & oFs.GetExtensionName(file.name)
         GetOutputFile = True
         exit function
      end if
   Next
   GetOutputFile = False
end function

Function  GetParentFolder(sString)
   Dim sTmp
   sTmp = goFs.GetParentFolderName(sString)
   if (0 = Len(sTmp)) then
      sTmp = ".\"
   elseif ("\" <> Right(sTmp,1) ) then
      sTmp = sTmp & "\"
   end if
   GetParentFolder = sTmp
end function
