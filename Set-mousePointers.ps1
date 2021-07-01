$RegConnect = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey([Microsoft.Win32.RegistryHive]"CurrentUser", "$env:COMPUTERNAME")
$RegCursors = $RegConnect.OpenSubKey("Control Panel\Cursors", $true)
$RegCursors.SetValue("", "GreenLefty")
$RegCursors.SetValue("AppStarting", "%USERPROFILE%\Downloads\Lefty\Green\Green-Working-Left.ani")
$RegCursors.SetValue("Arrow", "%USERPROFILE%\Downloads\Lefty\Green\Green-Left.cur")
$RegCursors.SetValue("Crosshair", "%USERPROFILE%\Downloads\Lefty\Green\GreenStone - Precision.ani")
$RegCursors.SetValue("Hand", "%USERPROFILE%\Downloads\Lefty\Green\GreenStoneLeft - Link.cur")
$RegCursors.SetValue("Help", "%USERPROFILE%\Downloads\Lefty\Green\Green-Question-Left.cur")
$RegCursors.SetValue("IBeam", "%USERPROFILE%\Downloads\Lefty\Green\GreenStone - Text.ani")
$RegCursors.SetValue("No", "")
$RegCursors.SetValue("NWPen", "%USERPROFILE%\Downloads\Lefty\Green\Green-Handwriting.cur")
$RegCursors.SetValue("Scheme Source", 0, 'DWord')
$RegCursors.SetValue("SizeAll", "%USERPROFILE%\Downloads\Lefty\Green\GreenStone - Move.ani")
$RegCursors.SetValue("SizeNESW", "%USERPROFILE%\Downloads\Lefty\Green\Green-Resize 2.cur")
$RegCursors.SetValue("SizeNS", "%USERPROFILE%\Downloads\Lefty\Green\Green-Vertical Resize.cur")
$RegCursors.SetValue("SizeNWSE", "%USERPROFILE%\Downloads\Lefty\Green\Green-Resize 1.cur")
$RegCursors.SetValue("SizeWE", "%USERPROFILE%\Downloads\Lefty\Green\Green-Horizontal Resize.cur")
$RegCursors.SetValue("UpArrow", "%USERPROFILE%\Downloads\Lefty\Green\Green-Alternate.cur")
$RegCursors.SetValue("Wait", "%USERPROFILE%\Downloads\Lefty\Green\Green-Busy.ani")
$RegCursors.Close()
$RegConnect.Close()

$CSharpSig = @'
[DllImport("user32.dll", SetLastError = true, EntryPoint = "SystemParametersInfo")]
[return: MarshalAs(UnmanagedType.Bool)]
public static extern bool SystemParametersInfo(
                 uint uiAction,
                 uint uiParam,
                 bool pvParam,
                 uint fWinIni);
'@

$CursorRefresh = Add-Type -MemberDefinition $CSharpSig -Name WinAPICall -Namespace SystemParamInfo -PassThru
$CursorRefresh::SystemParametersInfo(0x0057, 0, $null, 0)