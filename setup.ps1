[CmdletBinding(SupportsShouldProcess=$true)]

param (
	[string] $Command,
	[switch] $Help
)

Begin
{

    $ProgressPreference = "SilentlyContinue"
    $ErrorActionPreference = "Continue"
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]'Ssl3,Tls,Tls11,Tls12';

    $dotfilesRepo = "https://github.com/crownreach/jdjdk"
    $dotfilesDir = Join-Path $env:USERPROFILE "dotfiles"

	if(Test-Path $dotfilesDir) {
        . $dotfilesDir\powershell\common.ps1
    }


	function SetTimeZone {
		[System.ComponentModel.Description(
			"Sets the system time zone.")]
		[CmdletBinding(HelpURI="cmd")] param()

        if (-not (IsElevated)) {
            return $false
        }

        Set-TimeZone -Name "Taipei Standard Time"
        net stop w32time
        w32tm /resync /force
        net start w32time
        w32tm /query /status

        return $true
	}

    function OptimizedPowerPlan {
		[System.ComponentModel.Description(
			"Optimized power plan, good for low-end laptops.")]
		[CmdletBinding(HelpURI="cmd")] param()

        if (-not (IsElevated)) {
            return $false
        }

        powercfg -restoredefaultschemes
        $schemeGuid = (powercfg -q | find "Power Scheme GUID").Split(" ").Where{$_ -like "*-*"}

        powercfg -SetDcValueIndex $schemeGuid SUB_NONE CONSOLELOCK 0
        powercfg -SetAcValueIndex $schemeGuid SUB_NONE CONSOLELOCK 0
        powercfg -SetDcValueIndex $schemeGuid SUB_NONE DEVICEIDLE 0
        powercfg -SetAcValueIndex $schemeGuid SUB_NONE DEVICEIDLE 0
        powercfg -SetDcValueIndex $schemeGuid SUB_NONE CONNECTIVITYINSTANDBY 1
        powercfg -SetAcValueIndex $schemeGuid SUB_NONE CONNECTIVITYINSTANDBY 1

        $0 = (powercfg -q | find " (Hard disk)").Split(" ").Where{$_ -like "*-*"}
        $1 = (powercfg -q | find " (Turn off hard disk after)").Split(" ").Where{$_ -like "*-*"}
        powercfg -SetDcValueIndex $schemeGuid $0 $1 0
        powercfg -SetAcValueIndex $schemeGuid $0 $1 0

        $0 = (powercfg -q | find " (Internet Explorer)").Split(" ").Where{$_ -like "*-*"}
        $1 = (powercfg -q | find " (JavaScript Timer Frequency)").Split(" ").Where{$_ -like "*-*"}
        powercfg -SetDcValueIndex $schemeGuid $0 $1 1
        powercfg -SetAcValueIndex $schemeGuid $0 $1 1

        $0 = (powercfg -q | find " (Desktop background settings)").Split(" ").Where{$_ -like "*-*"}
        $1 = (powercfg -q | find " (Slide show)").Split(" ").Where{$_ -like "*-*"}
        powercfg -SetDcValueIndex $schemeGuid $0 $1 1
        powercfg -SetAcValueIndex $schemeGuid $0 $1 1

        $0 = (powercfg -q | find " (Wireless Adapter Settings)").Split(" ").Where{$_ -like "*-*"}
        $1 = (powercfg -q | find " (Power Saving Mode)").Split(" ").Where{$_ -like "*-*"}
        powercfg -SetDcValueIndex $schemeGuid $0 $1 0
        powercfg -SetAcValueIndex $schemeGuid $0 $1 0

        $0 = (powercfg -q | find " (Sleep)").Split(" ").Where{$_ -like "*-*"}
        $1 = (powercfg -q | find " (Allow Away Mode Policy)").Split(" ").Where{$_ -like "*-*"}
        powercfg -SetDcValueIndex $schemeGuid $0 $1 0
        powercfg -SetAcValueIndex $schemeGuid $0 $1 0
        $1 = (powercfg -q | find " (Sleep after)").Split(" ").Where{$_ -like "*-*"}
        powercfg -SetDcValueIndex $schemeGuid $0 $1 0
        powercfg -SetAcValueIndex $schemeGuid $0 $1 0
        $1 = (powercfg -q | find " (Hibernate after)").Split(" ").Where{$_ -like "*-*"}
        powercfg -SetDcValueIndex $schemeGuid $0 $1 0
        powercfg -SetAcValueIndex $schemeGuid $0 $1 0
        $1 = (powercfg -q | find " (Allow wake timers)").Split(" ").Where{$_ -like "*-*"}
        powercfg -SetDcValueIndex $schemeGuid $0 $1 0
        powercfg -SetAcValueIndex $schemeGuid $0 $1 0

        $0 = (powercfg -q | find " (Intel(R) Graphics Settings)").Split(" ").Where{$_ -like "*-*"}
        $1 = (powercfg -q | find " (Intel(R) Graphics Power Plan)").Split(" ").Where{$_ -like "*-*"}
        powercfg -SetDcValueIndex $schemeGuid $0 $1 2
        powercfg -SetAcValueIndex $schemeGuid $0 $1 2

        $0 = (powercfg -q | find " (Power buttons and lid)").Split(" ").Where{$_ -like "*-*"}
        $1 = (powercfg -q | find " (Lid close action)").Split(" ").Where{$_ -like "*-*"}
        powercfg -SetDcValueIndex $schemeGuid $0 $1 0
        powercfg -SetAcValueIndex $schemeGuid $0 $1 0
        $1 = (powercfg -q | find " (Lid open action)").Split(" ").Where{$_ -like "*-*"}
        powercfg -SetDcValueIndex $schemeGuid $0 $1 1
        powercfg -SetAcValueIndex $schemeGuid $0 $1 1

        $0 = (powercfg -q | find " (PCI Express)").Split(" ").Where{$_ -like "*-*"}
        $1 = (powercfg -q | find " (Link State Power Management)").Split(" ").Where{$_ -like "*-*"}
        powercfg -SetDcValueIndex $schemeGuid $0 $1 0
        powercfg -SetAcValueIndex $schemeGuid $0 $1 0

        $0 = (powercfg -q | find " (Display)").Split(" ").Where{$_ -like "*-*"}
        $1 = (powercfg -q | find " (Turn off display after)").Split(" ").Where{$_ -like "*-*"}
        powercfg -SetDcValueIndex $schemeGuid $0 $1 0
        powercfg -SetAcValueIndex $schemeGuid $0 $1 0
        $1 = (powercfg -q | find " (Display brightness)").Split(" ").Where{$_ -like "*-*"}
        powercfg -SetDcValueIndex $schemeGuid $0 $1 100
        powercfg -SetAcValueIndex $schemeGuid $0 $1 100
        $1 = (powercfg -q | find " (Enable adaptive brightness)").Split(" ").Where{$_ -like "*-*"}
        powercfg -SetDcValueIndex $schemeGuid $0 $1 0
        powercfg -SetAcValueIndex $schemeGuid $0 $1 0

        $0 = (powercfg -q | find " (Multimedia settings)").Split(" ").Where{$_ -like "*-*"}
        $1 = (powercfg -q | find " (When sharing media)").Split(" ").Where{$_ -like "*-*"}
        powercfg -SetDcValueIndex $schemeGuid $0 $1 1
        powercfg -SetAcValueIndex $schemeGuid $0 $1 1
        $1 = (powercfg -q | find " (Video playback quality bias)").Split(" ").Where{$_ -like "*-*"}
        powercfg -SetDcValueIndex $schemeGuid $0 $1 1
        powercfg -SetAcValueIndex $schemeGuid $0 $1 1
        $1 = (powercfg -q | find " (When playing video)").Split(" ").Where{$_ -like "*-*"}
        powercfg -SetDcValueIndex $schemeGuid $0 $1 0
        powercfg -SetAcValueIndex $schemeGuid $0 $1 0

        $0 = (powercfg -q | find " (Battery)").Split(" ").Where{$_ -like "*-*"}
        $1 = (powercfg -q | find " (Critical battery action)").Split(" ").Where{$_ -like "*-*"}
        powercfg -SetDcValueIndex $schemeGuid $0 $1 0
        powercfg -SetAcValueIndex $schemeGuid $0 $1 0
        $1 = (powercfg -q | find " (Low battery action)").Split(" ").Where{$_ -like "*-*"}
        powercfg -SetDcValueIndex $schemeGuid $0 $1 0
        powercfg -SetAcValueIndex $schemeGuid $0 $1 0

        powercfg -S $schemeGuid
        return $true
	}

    function OptimizeRamUsage {
        Enable-MMAgent -ApplicationPreLaunch -MemoryCompression
    }

    function Update-Script {
        $tempDir = Join-Path ([System.IO.Path]::GetTempPath()) ([System.IO.Path]::GetRandomFileName())

        if(-not (Test-Path $tempDir)) {
            New-Item -ItemType Directory -Path $tempDir | Out-Null
        }

        Copy-Item $( Join-Path $dotfilesDir "setup.ps1" ) $( Join-Path $tempDir "setup.ps1" )
        & $( Join-Path $tempDir "setup.ps1" )
    }

    function Clone {
        Pop-Location
        Remove-Item $dotfilesDir -Recurse -Force -ErrorAction SilentlyContinue
        git clone --recurse-submodules $dotfilesRepo $dotfilesDir
        Push-Location $dotfilesDir
        Update-Script
    }

    function Update {
        git -C $dotfilesDir submodule sync --quiet --recursive
        git submodule update --init --recursive $dotfilesDir
        Update-Script
    }

    function Check {
        If (Test-Path $dotfilesDir) {
            Push-Location $dotfilesDir

            $remoteUrl = git config --get remote.origin.url
            if ((Get-Location).Path -eq $dotfilesDir) {
                if ($remoteUrl -match "^(https?|git)://[^\s/$.?#].[^\s]*$") {
                    if ($remoteUrl -eq $dotfilesRepo) {
                        $status = git -c status.submodulesummary=1 status
                        if ($status -match "Your branch is behind") {
                            Write-Host "Updating Dotfiles..."
                            Update
                        }
                    } else {
                        Write-Host "Current dotfiles is not from the repo..."
                        Clone
                    }
                } else {
                    Write-Host "Dotfiles folder is not initialized..."
                    Clone
                }
            }
        } Else {
            Write-Host "Dotfiles is not exist, creating one..."
            Clone
        }
    }
} Process {
    if ($Help) {
        if ($Command) {
            GetCommand $Command
            return
        }
        GetCommandList
        return
    }

    if ($Command) {
        InvokeCommand $Command | Out-Null
        return
    }


    if (-not (Get-Command "git" -ErrorAction SilentlyContinue)) {
        Write-Host "Git is not installed..."
        exit 1
    }

    Check

    if (-not (IsElevated -Warn)) {
        write-host $myInvocation.MyCommand.Definition
        $process = New-Object System.Diagnostics.ProcessStartInfo "PowerShell"
        $process.Arguments = $myInvocation.MyCommand.Definition
        $process.Verb = "runas"
        [System.Diagnostics.Process]::Start($process) | Out-Null
        exit
    }

    Read-Host "Done..."
}
