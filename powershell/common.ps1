
    $proEdition = $null

    $script:shell = "PowerShell"
    if ($PSVersionTable.PSVersion.Major -lt 6) { $script:shell = "WindowsPowerShell" }

    function RefreshEnv {
        $previous = ''
        $expanded = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
        while($previous -ne $expanded) {
            $previous = $expanded
            $expanded = [System.Environment]::ExpandEnvironmentVariables($previous)
        }
        $env:Path = $expanded
    }

    function GetCommandList {
        Get-ChildItem function:\ | where HelpUri -match "cmd" | sort-object -property @{expression={ $_.Name } } |
        ForEach-Object {
            $function = $_
            $description = $function.ScriptBlock.Attributes[0].Description

            Write-Host "- $($function.Name) : $($description)"
        }
    }

    function GetCommand {
        Param(
            [Parameter(Mandatory=$true)]
            [string]$Command
        )

        $function = Get-ChildItem function:\ | where Name -eq $Command
        if ($function -and ($function.HelpUri -match "cmd")) {
            Write-Host "Name: $($function.Name)"
            $description = $function.ScriptBlock.Attributes[0].Description
            if ($description) {
                Write-Host "Description: $($description)"
            }

            $params = $function.Parameters.Keys | Where-Object { $_ -notin
                "Verbose", "Debug", "ErrorAction", "WarningAction", "InformationAction", "ErrorVariable",
                "WarningVariable", "InformationVariable", "OutVariable", "OutBuffer", "PipelineVariable"
            }

            if ($params) {
                Write-Host "Parameters:"
                $params | ForEach-Object {
                    $type = $function.Parameters.Item($_).ParameterType.Name
                    Write-Host " - $_ ($($type))"
                }
            }

        }
    }

    function InvokeCommand {
		[System.ComponentModel.Description(
			"Invokes a script command if it exists.")]
		[CmdletBinding(HelpURI="cmd")] param(
            [Parameter(Mandatory=$true)]
            [string]$Command,

            [object[]]$Arguments
        )

        $function = Get-ChildItem function:\ | where Name -eq $Command
        if ($function -and ($function.HelpUri -match "cmd")) {
            " ... Invoking command $($function.Name) " | Write-Host -ForegroundColor Black -BackgroundColor Yellow

            $params = @{
                "Command" = $Command
            }

            if ($Arguments) {
                $params["ArgumentList"] = $Arguments
            }

            try {
                $Error.Clear()
                $output = Invoke-Expression @params *>&1 | Out-Null
                if ($Command -eq "InvokeCommand") {
                    return $output
                }
                return $true
            } catch {
                $Error | ForEach-Object {
                    Write-Host "Error in line $($_.InvocationInfo.ScriptLineNumber): $($_.Exception.Message)" | Write-Host -ForegroundColor Black -BackgroundColor Red
                }
                return $false
            }


    $Error.Clear()
    if (!$NoError) {
        try {
            $output = Invoke-Expression @params *>&1 -ErrorAction Stop | Out-Null
            if ($Command -eq "InvokeCommand") {
                return $output
            }
        } catch {
            $Error | ForEach-Object {
                Write-Host "Error in line $($_.InvocationInfo.ScriptLineNumber): $($_.Exception.Message)" | Write-Host -ForegroundColor Black -BackgroundColor Red
            }
            return $false
        }
    } else {
        & $ScriptBlock *>&1 | Out-Null
    }
        } else {
            " '$Command' is not a recognized command " | Write-Host -ForegroundColor Black -BackgroundColor Yellow
            " Use -Help argument to see all commands " | Write-Host -ForegroundColor Black -BackgroundColor Yellow
            return $false
        }
    }

    function IsElevated {
		[System.ComponentModel.Description(
			"Checks if the current PowerShell session is elevated.")]
		[CmdletBinding(HelpURI="cmd")] param(
	        [switch] $Warn
        )

        if (([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
            return $true
        }

        if ($Warn) {
            " ... Requires administrative permission, open an administrative PowerShell window and run again " | Write-Host -ForegroundColor Black -BackgroundColor Yellow
        }

        return $false
    }

    function IsWindows11 {
		[System.ComponentModel.Description(
			"Checks if the current Windows version is Windows 11.")]
		[CmdletBinding(HelpURI="cmd")] param()

        $0 = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion"
        ([int](Get-ItemPropertyValue -path $0 -name CurrentBuild) -ge 22000)
    }

    function IsWindowsHomeEdition {
		[System.ComponentModel.Description(
			"Checks if the current Windows edition is Home.")]
		[CmdletBinding(HelpURI="cmd")] param()

        return (-not (IsWindowsProEdition))
    }

    function IsWindowsProEdition {
		[System.ComponentModel.Description(
			"Checks if the current Windows edition is Professional.")]
		[CmdletBinding(HelpURI="cmd")] param()

        if ($null -eq $proEdition) {
            $script:proEdition = (Get-WindowsEdition -online).Edition -eq "Professional"
        }

        $proEdition
    }