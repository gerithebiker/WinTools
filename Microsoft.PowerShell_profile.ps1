# If you have multiple PowerShell versions on your system, and you want to use the same profile, 
#	then save this file in one, and add the following line to the other environment's profile:
#	. "$env:USERPROFILE\Documents\PowerShell\Microsoft.PowerShell_profile.ps1"
#	Of course you have to update the path according to your system, but the format has to be the same,
#	the path has to have the ". $env:USERPROFILE" string in it.

function New-MyItem {
    param(
        [string]$Path
    )

    # Resolve full path
    $fullPath = if ([System.IO.Path]::IsPathRooted($Path)) {
        $Path
    } else {
        Join-Path -Path (Get-Location) -ChildPath $Path
    }

    # Extract directory part
    $directory = Split-Path -Path $fullPath -Parent

    # Ensure the directory exists
    if (-Not (Test-Path $directory)) {
        New-Item -ItemType Directory -Path $directory -Force | Out-Null
    }

    # Create or update the file timestamp
    if (-Not (Test-Path $fullPath)) {
        New-Item -ItemType File -Path $fullPath -Force | Out-Null
    } else {
        (Get-Item $fullPath).LastWriteTime = Get-Date
    }
}

function Get-Uptime {
    $os = Get-CimInstance -ClassName Win32_OperatingSystem
    $lastBoot = $os.LastBootUpTime
    $formattedDate = $lastBoot.ToString("yyyy. MM. dd HH:mm:ss")
    $uptime = (Get-Date) - $lastBoot

    $days = $uptime.Days
    $hours = $uptime.Hours
    $minutes = $uptime.Minutes

    # ANSI Escape sequences compatible with both PowerShell 5 and 7
    $esc = [char]27
    $colorCyan = "$esc[36m"
    $colorGreen = "$esc[32m"
    $colorYellow = "$esc[33m"
    $colorBlue = "$esc[34m"
    $colorRed = "$esc[31m"
    $colorReset = "$esc[0m"

    Write-Host "`n${colorGreen}Last Boot Time : " -NoNewline
    Write-Host "$colorRed$formattedDate$colorReset"
    Write-Host "${colorGreen}Uptime         : " -NoNewline
    Write-Host "$colorRed$days$colorReset days, $colorRed$hours$colorReset hours, $colorRed$minutes$colorReset minutes`n"
}

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

$HistoryFile = "$env:USERPROFILE\Documents\PowerShell_History.log"
Register-EngineEvent PowerShell.Exiting -Action {
    Get-History | ForEach-Object {
        "$($_.CommandLine)" | Out-File -Append -FilePath $HistoryFile
    }
} | Out-Null

Register-EngineEvent PowerShell.Exiting -Action {
    Set-PSReadLineOption -HistorySaveStyle SaveIncrementally
} | Out-Null

Set-PSReadLineOption -HistorySavePath "$env:USERPROFILE\Documents\PSReadLine_History.txt"

function Get-PersistentHistory {
    #Get-Content "$env:USERPROFILE\Documents\PowerShell_History.log"
    $lines = Get-Content (Get-PSReadLineOption).HistorySavePath
    $global:i = 0
    $command = ''
    foreach ($line in $lines) {
        if ($line -match '^\s' -or $line -eq '}' -or $command -eq '') {
            $command += "`n$line"
        } else {
            if ($command) {
                [PSCustomObject]@{ LineNumber = ++$i; Command = $command.Trim() }
            }
            $command = $line
        }
    }
    if ($command) {
        [PSCustomObject]@{ LineNumber = ++$i; Command = $command.Trim() }
    }
}

function Format-MyHistory {
    Get-PersistentHistory | Format-Table -Wrap -AutoSize
}

function Invoke-PersistentHistoryCommand {
    param (
        [int]$CommandNumber
    )

    # Load the persistent history
    $historyFile = (Get-PSReadLineOption).HistorySavePath
    $commands = Get-Content $historyFile

    # Retrieve and execute the command
    if ($CommandNumber -le $commands.Length -and $CommandNumber -gt 0) {
        $command = $commands[$CommandNumber - 1]
	Write-Host "Re-executing Persistent Command #${CommandNumber}: $command" -ForegroundColor Yellow
        Invoke-Expression $command
    } else {
        Write-Host "Command #$CommandNumber not found in persistent history." -ForegroundColor Red
    }
}

# Removing history alias so it can be set to my needs
Remove-Item alias:history
#Remove-Item alias:uptime

# Alias section
Set-Alias -Name getEnv -Value Get-EnvVars
Set-Alias -Name touch -Value New-MyItem
Set-Alias -Name history -Value Get-PersistentHistory
Set-Alias -Name histt -Value Format-MyHistory
Set-Alias -name uptime -value Get-Uptime
Set-Alias -Name 'npp' -Value ("$env:PROGRAMFILES\Notepad++\notepad++.exe")
Set-Alias -name 'cpl' -value ("$env:USERPROFILE\Documents\GitHub\MusicTools\Add-PlayLists.ps1")
Set-Alias -Name : -Value Invoke-PersistentHistoryCommand

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

# Now we gonna do some tricks to format a nice table with all the 'profile' defined aliases in it
# It is designed to use in different versions of PS. You should have a 'main' profile, 
# 	and the other version's profile should source in the main profile. This current file is the
# 	'main' profile. The other profiles should contain a line that sourcing in this file, something 
# 	like this:
#	if (Test-Path "$env:USERPROFILE\OneDrive\OneDokumentumok\PowerShell\Microsoft.PowerShell_profile.ps1") {
#    . "$env:USERPROFILE\OneDrive\OneDokumentumok\PowerShell\Microsoft.PowerShell_profile.ps1"
#	}
# 	We will read out the value of this line (starting with ". $env"), and use that value to read out the
#	alias settings.

# Detect if a profile file is being sourced in
$sourceFile = ""
foreach ($line in Get-Content $PROFILE) {
	if ($line -match '^[\s]+\.[ ]+"(?<Path>[^"]+rofile\.ps1)"') {
        $sourceFile = $matches['Path']
		$sourceFile = $sourceFile.replace('$env:USERPROFILE',$env:USERPROFILE)
		write-host "alma"
        break
    }
}

# If no external profile file is found in the profile file, then the 
# 	current profile should contain the aliases, fallback to the current profile
if (-not $sourceFile) {
    $sourceFile = $PROFILE
	write-host "korte"
}
write-host $sourceFile
# Extract alias names from the profile
$aliasNames = @()
foreach ($line in Get-Content $sourceFile) {
    if ($line -match "Set-Alias\s+-Name\s+'?([^' ]+)'?") {
        $aliasNames += $matches[1]
    }
}
write-host $aliasNames
# Retrieve actual alias objects using Get-Alias
$aliases = @()
foreach ($name in $aliasNames) {
    $alias = Get-Alias -Name $name -ErrorAction SilentlyContinue
    if ($alias) {
        $aliases += $alias
    } else {
	# This is a super roboust error handling
        Write-Host "Alias '$name' could not be found." -ForegroundColor Red
    }
}

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

Write-Output "To properly use the : as a replacement for the Unix ! to retrieve a command from history, you have to put a space after the colon like this: `n$ : 23`nand it will run the 23rd command again."
