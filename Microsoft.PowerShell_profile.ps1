# First we define a few functions
function Get-EnvVars {
    Get-ChildItem env: | Sort-Object Name
}
#function prompt() {
 #   "`e[48;2;255;64;64m`e[38;2;0;0;0mPS `e[4m$($executionContext.SessionState.Path.CurrentLocation)`e[24m$('>' * ($nestedPromptLevel + 1))`e[0m "
#}
function prompt {
	"$([char]27)[36m$([Environment]::UserName)$([char]27)[36m" + "@" + "$([char]27) $((Get-ChildItem  Env:Computername).Value)$([char]27)[0m" + "$([char]27)[33m " + "$((Get-Location).Path)" + "$([char]27)[0m`r`n$ "
}

# Alias section
#Set-Alias cpl '${USERPROFILE}\Documents\Scripts\CreatePlayLists.ps1'
Set-Alias -name 'cpl' -value 'C:\Users\gerit\Documents\GitHub\MusicTools\Add-PlayLists.ps1'
Set-Alias -Name getEnv -Value Get-EnvVars


# Ensure proper encoding
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# Define Unicode characters for box drawing
$topLeft = [char]0x250C    # ┌
$topRight = [char]0x2510   # ┐
$bottomLeft = [char]0x2514 # └
$bottomRight = [char]0x2518 # ┘
$horizontal = [char]0x2500 # ─
$vertical = [char]0x2502   # │
$middleTop = [char]0x252C  # ┬
$middleBottom = [char]0x2534 # ┴
$middleLeft = [char]0x251C # ├
$middleRight = [char]0x2524 # ┤
$intersection = [char]0x253C # ┼

# Get all aliases
$aliases = Get-Alias cpl, getEnv

# Find the longest alias name and definition length for justification
$maxNameLength = ($aliases | ForEach-Object { $_.Name.Length }) | Measure-Object -Maximum | Select-Object -ExpandProperty Maximum
$maxDefLength = ($aliases | ForEach-Object { $_.Definition.Length }) | Measure-Object -Maximum | Select-Object -ExpandProperty Maximum
if($maxNameLength -lt 4){$maxNameLength = 4}
if($maxDefLength -lt 10){$maxDefLength = 10}

# Helper function to repeat a character
function Repeat-Char {
    param (
        [Parameter(Mandatory = $true)]
        [char]$Char,
        [Parameter(Mandatory = $true)]
        [int]$Count
    )
    return ($Char.ToString() * $Count)
}

# Print the top border
Write-Output ("  $topLeft" + (Repeat-Char -Char $horizontal -Count ($maxNameLength + 2)) + "$middleTop" + (Repeat-Char -Char $horizontal -Count ($maxDefLength + 2)) + "$topRight")

# Print the header
$header = "  $vertical {0,-$($maxNameLength)} $vertical {1,-$($maxDefLength)} $vertical" -f "Name", "Definition"
Write-Output $header

# Print the separator line
Write-Output ("  $middleLeft" + (Repeat-Char -Char $horizontal -Count ($maxNameLength + 2)) + "$intersection" + (Repeat-Char -Char $horizontal -Count ($maxDefLength + 2)) + "$middleRight")

# Print each alias entry
$aliases | ForEach-Object {
    Write-Output ("  $vertical {0,-$($maxNameLength)} $vertical {1,-$($maxDefLength)} $vertical" -f $_.Name, $_.Definition)
}

# Print the bottom border
Write-Output ("  $bottomLeft" + (Repeat-Char -Char $horizontal -Count ($maxNameLength + 2)) + "$middleBottom" + (Repeat-Char -Char $horizontal -Count ($maxDefLength + 2)) + "$bottomRight")
