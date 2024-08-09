#Requires -Version 5.0

<#
.SYNOPSIS
    Install Language Packs.

.DESCRIPTION
    This script installs the selected Language Packs.

.PARAMETER $LanguageList
    The list of Language Packs to install.
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory)]
    [ValidateSet("Arabic (Saudi Arabia)", "Bulgarian (Bulgaria)", "Chinese (Simplified, China)", "Chinese (Traditional, Taiwan)", "Croatian (Croatia)", "Czech (Czech Republic)", "Danish (Denmark)", "Dutch (Netherlands)", "English (United Kingdom)", "Estonian (Estonia)", "Finnish (Finland)", "French (Canada)", "French (France)", "German (Germany)", "Greek (Greece)", "Hebrew (Israel)", "Hungarian (Hungary)", "Italian (Italy)", "Japanese (Japan)", "Korean (Korea)", "Latvian (Latvia)", "Lithuanian (Lithuania)", "Norwegian, Bokmål (Norway)", "Polish (Poland)", "Portuguese (Brazil)", "Portuguese (Portugal)", "Romanian (Romania)", "Russian (Russia)", "Serbian (Latin, Serbia)", "Slovak (Slovakia)", "Slovenian (Slovenia)", "Spanish (Mexico)", "Spanish (Spain)", "Swedish (Sweden)", "Thai (Thailand)", "Turkish (Turkey)", "Ukrainian (Ukraine)", "English (Australia)", "English (United States)", "Scottish Gaelic", "Welsh (Great Britain)")]
    [System.String[]]$languageList
)

function Add-LanguagePack {
    BEGIN {
        # Start Stop Watch.
        $stopWatch = [System.Diagnostics.Stopwatch]::StartNew()

        Write-Host = "Starting AVD Custom Image Template Customisation: Installing Language Packs: $((Get-Date).ToUniversalTime())."

        # Populate Dictionary
        $languageDictionary = @{}
        $languageDictionary.Add("Arabic (Saudi Arabia)", "ar-SA")
        $languageDictionary.Add("Bulgarian (Bulgaria)", "bg-BG")
        $languageDictionary.Add("Chinese (Simplified, China)", "zh-CN")
        $languageDictionary.Add("Chinese (Traditional, Taiwan)", "zh-TW")
        $languageDictionary.Add("Croatian (Croatia)", "hr-HR")
        $languageDictionary.Add("Czech (Czech Republic)", "cs-CZ")
        $languageDictionary.Add("Danish (Denmark)", "da-DK")
        $languageDictionary.Add("Dutch (Netherlands)", "nl-NL")
        $languageDictionary.Add("English (United Kingdom)", "en-GB")
        $languageDictionary.Add("Estonian (Estonia)", "et-EE")
        $languageDictionary.Add("Finnish (Finland)", "fi-FI")
        $languageDictionary.Add("French (Canada)", "fr-CA")
        $languageDictionary.Add("French (France)", "fr-FR")
        $languageDictionary.Add("German (Germany)", "de-DE")
        $languageDictionary.Add("Greek (Greece)", "el-GR")
        $languageDictionary.Add("Hebrew (Israel)", "he-IL")
        $languageDictionary.Add("Hungarian (Hungary)", "hu-HU")
        $languageDictionary.Add("Italian (Italy)", "it-IT")
        $languageDictionary.Add("Japanese (Japan)", "ja-JP")
        $languageDictionary.Add("Korean (Korea)", "ko-KR")
        $languageDictionary.Add("Latvian (Latvia)", "lv-LV")
        $languageDictionary.Add("Lithuanian (Lithuania)", "lt-LT")
        $languageDictionary.Add("Norwegian, Bokmål (Norway)", "nb-NO")
        $languageDictionary.Add("Polish (Poland)", "pl-PL")
        $languageDictionary.Add("Portuguese (Brazil)", "pt-BR")
        $languageDictionary.Add("Portuguese (Portugal)", "pt-PT")
        $languageDictionary.Add("Romanian (Romania)", "ro-RO")
        $languageDictionary.Add("Serbian (Latin, Serbia)", "sr-Latn-RS")
        $languageDictionary.Add("Slovak (Slovakia)", "sk-SK")
        $languageDictionary.Add("Spanish (Spain)", "es-ES")
        $languageDictionary.Add("Swedish (Sweden)", "sv-SE")
        $languageDictionary.Add("Thai (Thailand)", "th-TH")
        $languageDictionary.Add("Turkish (Turkey)", "tr-TR")
        $languageDictionary.Add("Ukrainian (Ukraine)", "uk-UA")
        $languageDictionary.Add("English (Australia)", "en-AU")
        $languageDictionary.Add("English (United States)", "en-US")
        $LanguageDictionary.Add("Scottish Gaelic", "gd-GB")
        $LanguageDictionary.Add("Welsh (Great Britain)", "cy-GB")

        # Disable LanguageComponentsInstaller whilst installing Language Packs to prevent errors.
        Disable-ScheduledTask -TaskName "\Microsoft\Windows\LanguageComponentsInstaller\Installation"
        Disable-ScheduledTask -TaskName "\Microsoft\Windows\LanguageComponentsInstaller\ReconcileLanguageResources"
    }
    PROCESS {
        ForEach ($selectedLanguage in $languageList) {
            # Attempt to retry Language Pack(s) installation up to 5 times.
            for ($i = 1; $i -le 5; $i++) {
                try {
                    Write-Host "AVD Custom Image Template Customisation: Installing Language Packs: Attempt:$i."
                    $languageCode = $languageDictionary.$selectedLanguage
                    Install-Language -Language $languageCode -ErrorAction Stop
                    Write-Host "AVD Custom Image Template Customisation: Installing Language Packs: Installed Language Pack $languageCode."
                    break
                }
                catch {
                    Write-Host "AVD Custom Image Template Customisation: Installing Language Packs: An exception occurred installing Language Pack $languageCode."
                    Write-Host $PSItem.Exception
                    continue
                }
            }
        }
    }
    END {
        # Enable LanguageComponentsInstaller after Language Pack(s) installed.
        Enable-ScheduledTask -TaskName "\Microsoft\Windows\LanguageComponentsInstaller\Installation"
        Enable-ScheduledTask -TaskName "\Microsoft\Windows\LanguageComponentsInstaller\ReconcileLanguageResources"

        # Stop Stop Watch and output elapsed time.
        $stopWatch.Stop()
        $elapsedTime = $stopWatch.Elapsed
        Write-Host "AVD Custom Image Template Customisation: Installing Language Packs: Exit Code: $LASTEXITCODE."
        Write-Host "Ending AVD Custom Image Template Customisation: Installing Language Packs: Time taken: $elapsedTime."
        
    }
}

Install-LanguagePack -LanguageList $languageList
