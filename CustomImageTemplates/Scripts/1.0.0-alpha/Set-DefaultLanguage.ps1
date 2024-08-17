#Requires -Version 5.1

<#
.SYNOPSIS
    Set default language.

.DESCRIPTION
    This script sets the default language and installs the selected language if it is not installed.

.PARAMETER $DefaultLanguage
    The language to set as the default.
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory)]
    [ValidateSet("Arabic (Saudi Arabia)", "Bulgarian (Bulgaria)", "Chinese (Simplified, China)", "Chinese (Traditional, Taiwan)", "Croatian (Croatia)", "Czech (Czech Republic)", "Danish (Denmark)", "Dutch (Netherlands)", "English (United Kingdom)", "Estonian (Estonia)", "Finnish (Finland)", "French (Canada)", "French (France)", "German (Germany)", "Greek (Greece)", "Hebrew (Israel)", "Hungarian (Hungary)", "Italian (Italy)", "Japanese (Japan)", "Korean (Korea)", "Latvian (Latvia)", "Lithuanian (Lithuania)", "Norwegian, Bokmål (Norway)", "Polish (Poland)", "Portuguese (Brazil)", "Portuguese (Portugal)", "Romanian (Romania)", "Russian (Russia)", "Serbian (Latin, Serbia)", "Slovak (Slovakia)", "Slovenian (Slovenia)", "Spanish (Mexico)", "Spanish (Spain)", "Swedish (Sweden)", "Thai (Thailand)", "Turkish (Turkey)", "Ukrainian (Ukraine)", "English (Australia)", "English (United States)", "Scottish Gaelic", "Welsh (Great Britain)")]
    [System.String[]]$DefaultLanguage
)

function Set-DefaultLanguage {
    param (
        [string]$DefaultLanguage
    )

    BEGIN {
        $stopWatch = [System.Diagnostics.Stopwatch]::StartNew()
        Write-Host "INFO: Starting AVD Custom Image Template Customisation: Set Default Language: $((Get-Date).ToUniversalTime())"
        $allCultures = [System.Globalization.CultureInfo]::GetCultures('InstalledWin32Cultures')
        $defaultLanguageId = ($allCultures | Where-Object -Property DisplayName -eq $defaultLanguage).Name
        $defaultLanguageRegionInfo = [System.Globalization.RegionInfo]$defaultLanguageId
        $installedLanguages = Get-InstalledLanguage
    }
    PROCESS {
        foreach ($installedLanguage in $installedLanguages) {
            $installedLanguageId = $installedLanguage.LanguageId
            if ($installedLanguageId -eq $defaultLanguageId) {
                try {
                    Set-Culture -CultureInfo $defaultLanguageId -ErrorAction Stop
                    Set-SystemPreferredUILanguage -Language $defaultLanguageId -ErrorAction Stop
                    Set-WinHomeLocation -GeoId $defaultLanguageRegionInfo.GeoId -ErrorAction Stop
                    Set-WinSystemLocale -SystemLocale $defaultLanguageId -ErrorAction Stop
                    Set-WinUILanguageOverride -Language $defaultLanguageId -ErrorAction Stop
                    Set-WinUserLanguageList -LanguageList $defaultLanguageId -Force -ErrorAction Stop
                    Copy-UserInternationalSettingsToSystem -WelcomeScreen $true -NewUser $true -ErrorAction Stop
                    break
                }
                catch {
                    Write-Host "ERROR: AVD Custom Image Template Customisation: Setting Default Language to $defaultLanguage."
                    Write-Host $PSItem.Exception
                }
            }
            else {
                Write-Host "INFO: AVD Custom Image Template Customisation: Set Default Language: $defaultLanguage is not installed."
                try {
                    Write-Host "INFO: AVD Custom Image Template Customisation: Installing Language Pack: Installing $defaultLanguage."
                    Disable-ScheduledTask -TaskName "\Microsoft\Windows\LanguageComponentsInstaller\Installation" -ErrorAction SilentlyContinue
                    Disable-ScheduledTask -TaskName "\Microsoft\Windows\LanguageComponentsInstaller\ReconcileLanguageResources" -ErrorAction SilentlyContinue
                    Install-Language -Language $defaultLanguageId -ErrorAction Stop
                    Write-Host "INFO: AVD Custom Image Template Customisation: Installing Language Pack: Installed $defaultLanguage."
                    Set-DefaultLanguage -DefaultLanguage $defaultLanguage -ErrorAction Stop
                }
                catch {
                    Write-Host "ERROR: AVD Custom Image Template Customisation: Installing Language Pack: Installing $defaultLanguage."
                    Write-Host $PSItem.Exception
                }
            }
        }
    }
    END {
        Enable-ScheduledTask -TaskName "\Microsoft\Windows\LanguageComponentsInstaller\Installation" -ErrorAction SilentlyContinue
        Enable-ScheduledTask -TaskName "\Microsoft\Windows\LanguageComponentsInstaller\ReconcileLanguageResources" -ErrorAction SilentlyContinue
        $stopWatch.Stop()
        $elapsedTime = $stopWatch.Elapsed
        Write-Host "INFO: Ending AVD Custom Image Template Customisation: Set Default Language: Exit code: $LASTEXITCODE."
        Write-Host "INFO: Ending AVD Custom Image Template Customisation: Set Default Language: Time taken: $elapsedTime."
    }
}

Set-DefaultLanguage -DefaultLanguage $defaultLanguage
