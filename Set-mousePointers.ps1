[CmdletBinding()]
PARAM
(
	$PathToCursors = "%USERPROFILE%\Downloads\Lefty\Green"
)


$RegConnect = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey([Microsoft.Win32.RegistryHive]"CurrentUser", "$env:COMPUTERNAME")
$RegCursors = $RegConnect.OpenSubKey("Control Panel\Cursors", $true)
$RegCursors.SetValue("", "GreenLefty")
$RegCursors.SetValue("AppStarting", "$PathToCursors\Green-Working-Left.ani")
$RegCursors.SetValue("Arrow", "$PathToCursors\Green-Left.cur")
$RegCursors.SetValue("Crosshair", "$PathToCursors\GreenStone - Precision.ani")
$RegCursors.SetValue("Hand", "$PathToCursors\GreenStoneLeft - Link.cur")
$RegCursors.SetValue("Help", "$PathToCursors\Green-Question-Left.cur")
$RegCursors.SetValue("IBeam", "$PathToCursors\GreenStone - Text.ani")
$RegCursors.SetValue("No", "")
$RegCursors.SetValue("NWPen", "$PathToCursors\Green-Handwriting.cur")
$RegCursors.SetValue("Scheme Source", 0, 'DWord')
$RegCursors.SetValue("SizeAll", "$PathToCursors\GreenStone - Move.ani")
$RegCursors.SetValue("SizeNESW", "$PathToCursors\Green-Resize 2.cur")
$RegCursors.SetValue("SizeNS", "$PathToCursors\Green-Vertical Resize.cur")
$RegCursors.SetValue("SizeNWSE", "$PathToCursors\Green-Resize 1.cur")
$RegCursors.SetValue("SizeWE", "$PathToCursors\Green-Horizontal Resize.cur")
$RegCursors.SetValue("UpArrow", "$PathToCursors\Green-Alternate.cur")
$RegCursors.SetValue("Wait", "$PathToCursors\Green-Busy.ani")
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
$CursorRefresh
$CursorRefresh::SystemParametersInfo(0x0057, 0, $null, 0)