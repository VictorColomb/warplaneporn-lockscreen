$configPath = Join-Path $PSScriptRoot "config.json"

function WarplanepornLockscreen {
    param (
        [string[]]$subreddits,
        [switch]$nsfw,
        [switch]$install,
        [switch]$uninstall,
        [switch]$showpic,
        [switch]$showlog,
        [switch]$list,
        [string]$add,
        [string]$remove,
        [string]$sort,
        [switch]$config,
        [switch]$save,
        [switch]$showSaved,
        [switch]$noUpdateCheck
    )

    $warplanepornPic = Join-Path $PSScriptRoot "lockscreen.jpg"

    # get config and check for update
    $configuration = Get-Config
    if (-not $noUpdateCheck) {
        if (
            (-not $configuration.nextUpdateCheck) -or
            ($configuration.nextUpdateCheck -lt [int64](Get-Date(Get-Date).ToUniversalTime() -UFormat %s))
        ) {
            Test-ForUpdate
        }
    }

    # catch weird argument combinaisons
    if ($install -and $uninstall) {
        Write-Host "Why would you want to install and uninstall??"
        Write-Host "See help : WarplanepornLockscreen -help"
        Break
    }
    if ($install -and ($list -or $add -or $remove -or $config)) {
        Write-Host "Don't ask for both installation and configuration. The former does the latter!"
        Write-Host "See help : WarplanepornLockscreen -help"
        Break
    }

    # install and uninstall options
    if ($install) {
        Install-WarplanepornLockscreen
        Break
    }

    elseif ($uninstall) {
        Uninstall-WarplanepornLockscreen
        Break
    }

    # check installed
    if ((-not (Test-Path $configPath)) -or (!$configuration.installed)) {
        Write-Host "The module was never installed, would you like to install it ? (y/n) : " -ForegroundColor Cyan -NoNewline
        if ((Read-Host).ToLower() -eq "y") {
            Install-WarplanepornLockscreen
            Break
        }
    }

    # parse options
    if (!$nsfw) { $nsfw = $configuration.nsfw }
    $sort = $sort.ToLower()
    if (-not (($sort -eq "hot") -or ($sort -eq "top") -or ($sort -eq "new") -or ($sort -eq $null) -or ($sort -eq ""))) {
        Write-Host ("Sort input {0} unknown. It should be one of top, hot and new" -f $sort) -ForegroundColor Red
        Write-Host "See help : WarplanepornLockscreen -help"
        cmd /c pause
        Break
    }
    if (!$sort) {
        if ($configuration.sort) {
            $sort = $configuration.sort
        }
        else {
            $sort = "hot"
        }
    }

    if ($showpic) {
        if (Test-Path $warplanepornPic) {
            Invoke-Item $warplanepornPic
        }
        else {
            Write-Host "No picture was found, maybe the utility was never run" -ForegroundColor Yellow
        }
    }

    if ($showlog) {
        $logfile = Join-Path $PSScriptRoot "log.txt"
        if (Test-Path $logfile) {
            Invoke-Item $logfile
        }
        else {
            Write-Host "No log was found, maybe the utility was never run" -ForegroundColor Yellow
        }
    }

    if ($list) {
        Write-Host $configuration.subreddits
    }

    if ($save) {
        $savedDir = Join-Path $PSScriptRoot "Saved"
        if (!(Test-Path $savedDir)) {
            New-Item -Path $PSScriptRoot -Name "Saved" -ItemType "directory" | Out-Null
        }
        if (Test-Path $warplanepornPic) {
            Copy-Item -Path $warplanepornPic -Destination $savedDir -Force | Out-Null
            Rename-Item -Path (Join-Path $savedDir "lockscreen.jpg") -NewName ((Get-date -Format "dd_MM_yyyy HH_mm_ss") + ".jpg") | Out-Null
            Write-Host "Successfully saved current wallpaper" -ForegroundColor Green
        }
        else {
            Write-Host "No wallpaper was found to be saved" -ForegroundColor Yellow
        }
    }

    if ($showSaved) {
        $savedDir = Join-Path $PSScriptRoot "Saved"
        if (Test-Path $savedDir) {
            Invoke-Item $savedDir
        }
        else {
            Write-Host "No wallpaper was ever saved" -ForegroundColor Yellow
        }
    }

    if ($add -and (!$config)) {
        $subreddit_add = $add.Trim()
        $ProgressPreference = 'SilentlyContinue'
        $subredditStatus = Invoke-WebRequest ("https://reddit.com/r/{0}/about.json" -f $subreddit_add) | ConvertFrom-Json
        if ($subredditStatus.data.subreddit_type -eq "public") {
            $configuration.subreddits += $subreddit_add
            $configuration | ConvertTo-Json | Out-File $configPath
            Write-Host ("Subreddit {0} was added to configuration" -f $subreddit_add) -ForegroundColor Green
        }
        else {
            Write-Host "Subreddit {0} could not be found. It could not exist or be restricted." -ForegroundColor Red
        }
    }

    if ($remove -and (!$config)) {
        if ($configuration.subreddits.count -le 1) {
            Write-Host "There is only one subreddit left in the configuration, please add a new one before removing it." -ForegroundColor Red
        }
        else {
            $subreddit_remove = $remove.Trim()
            if ($configuration.subreddits.Contains($subreddit_remove)) {
                $subreddits_remove = @()
                $configuration.subreddits | ForEach-Object {
                    if ($_ -ne $subreddit_remove) {
                        $subreddits_remove += $_
                    }
                }
                $configuration.subreddits = $subreddits_remove
                Set-Content $configPath ($configuration | ConvertTo-Json)
                Write-Host ("Subreddit {0} was removed from configuration" -f $subreddit_remove) -ForegroundColor Green
            }
            else {
                Write-Host ("Could not find subreddit {0} in the current configuration" -f $subreddit_remove) -ForegroundColor Red
            }
        }
    }

    if ($config) {
        Set-Config
    }

    if ($help) {
        Show-Help
    }

    if (!$install -and !$uninstall -and !$list -and !$config -and !$add -and !$remove -and !$showlog -and !$showpic -and !$help -and !$save -and !$showSaved) {
        if (!$subreddits) {
            if ($configuration.subreddits) {
                $subreddits = $configuration.subreddits
            }
            else {
                $subreddits = @('warplaneporn')
            }
        }

        Get-Picture -subreddits $subreddits -nsfw $nsfw -sort $sort
    }
}

function Show-Help {
    Write-Host "Usage: WarplanepornLockscreen [-subreddits sub1,sub2...] [-nsfw] [-sort top|hot|new]"
    Write-Host "Refresh lock screen wallpaper from the subreddits specified or from those in the config"
    Write-Host ""
    Write-Host "Other usages"
    Write-Host "=============="
    Write-Host "WarplanepornLockscreen [-uninstall]"
    Write-Host "WarplanepornLockscreen [-config]"
    Write-Host "WarplanepornLockscreen [-list]"
    Write-Host "WarplanepornLockscreen [-add subreddit]"
    Write-Host "WarplanepornLockscreen [-remove subreddit]"
    Write-Host "WarplanepornLockscreen [-saveCurrent]"
    Write-Host "WarplanepornLockscreen [-showSaved]"
    Write-Host "WarplanepornLockscreen [-showPic]"
    Write-Host "WarplanepornLockscreen [-showlog]"
}

function Get-Config {
    $configuration = @{}

    if (Test-Path $configPath) {
        (Get-Content -Raw -Path $configPath | ConvertFrom-Json).psobject.Properties | ForEach-Object {
            $configuration[$_.Name] = $_.Value
        }
    }

    return $configuration
}

function Set-Config {
    param(
        [switch]$ExecuteAfter,
        [switch]$install
    )

    $ProgressPreference = 'SilentlyContinue'

    $configuration = Get-Config

    if ($install) {
        $configuration.installed = $true
    }


    # ask nsfw
    $nsfw = (Read-Host "Do you want to include nsfw posts in the potential wallpapers ? (y/n) (default no)").ToLower()
    $configuration.nsfw = ($nsfw -eq "y")

    # ask sort
    while ($true) {
        $sort = (Read-Host "How to sort posts ? (top|hot|new) (leave empty for hot)")
        if ($sort -eq "") {
            $configuration.sort = "hot"
            Break
        }
        elseif (($sort -eq "top") -or ($sort -eq "hot") -or ($sort -eq "new")) {
            $configuration.sort = $sort
            Break
        }
        Write-Host "I didn't get that..."
    }

    # ask subreddits
    Write-Host "What subreddits would you like to see wallpapers from ?" -ForegroundColor Yellow
    Write-Host "Enter one without the r/ prefix, press enter then the next one. Leave a line empty to confirm." -ForegroundColor Yellow
    Write-Host "Just press ENTER for default (warplaneporn)" -ForegroundColor Yellow

    $inSubIdx = 1
    $subreddits = @()
    while ($true) {
        $subreddit = (Read-Host ("Subreddit {0}" -f $inSubIdx)).Trim()
        if ($subreddit -eq "") { Break }

        Write-Host ("Checking subreddit {0}..." -f $subreddit) -ForegroundColor DarkYellow
        $subredditStatus = Invoke-WebRequest ("https://reddit.com/r/{0}/about.json" -f $subreddit) | ConvertFrom-Json
        if ($subredditStatus.data.subreddit_type -eq "public") {
            $subreddits += $subreddit
            $inSubIdx += 1
        }
        else {
            Write-Host ("Subreddit {0} could not be found. It could not exist or be restricted." -f $subreddit) -ForegroundColor Red
        }
    }
    if (!$subreddits) {
        $subreddits = @("warplaneporn")
    }
    $configuration.subreddits = $subreddits

    # write to file
    if (Test-Path $configPath) { Remove-Item $configPath | Out-Null }
    $configuration | ConvertTo-Json | Out-File $configPath

    # execute utility if asked to
    if ($ExecuteAfter) {
        Write-Host ""
        WarplanepornLockscreen
    }
    else {
        Write-Host "Configuration saved" -ForegroundColor Green
    }
}

function Test-ForUpdate {
    $configuration = Get-Config
    $configuration.nextUpdateCheck = [int64](Get-Date(Get-Date).ToUniversalTime() -UFormat %s) + 86400

    if (Test-Path $configPath) {
        Remove-Item $configPath | Out-Null
    }
    $configuration | ConvertTo-Json | Out-File $configPath

    $localVersion = (Get-Module -Name WarplanepornLockscreen).Version
    $remoteVersion = (Find-Module -Name WarplanepornLockscreen -Repository PSGallery).Version

    if ($remoteVersion -gt $localVersion) {
        Write-Host "New version available. Would you like to update (y/n)? " -ForegroundColor Yellow -NoNewline
        if ((Read-Host).ToLower() -eq 'y') {
            Update-Module -Name WarplanepornLockscreen

            $newVersionDirectory = Join-Path (Split-Path -Parent $PSScriptRoot) $remoteVersion
            if (Test-Path $newVersionDirectory) {
                Copy-Item -Force -Path (Join-Path $PSScriptRoot "config.json") -Destination $newVersionDirectory | Out-Null
                Write-Host "Successfully updated WarplanepornLockscreen to version $remoteVersion." -ForegroundColor Green
            }
            else {
                Write-Host "Successfully updated WarplanepornLockscreen to version $remoteVersion " -NoNewline
                Write-Host "but could not copy current configuration to the new version..." -ForegroundColor Yellow
            }

            Write-Host "Please relaunch WarplanepornLockscreen to continue."
            Exit
        }
    }
}

function Get-Picture {
    # get image from given subreddit and check dimensions
    param (
        [string[]]$subreddits,
        [string]$sort,
        [bool]$nsfw
    )
    Write-Host ("List of configured subreddits : {0}" -f [string]$subreddits)

    $ProgressPreference = 'SilentlyContinue'
    $templockscreenImagePath = Join-Path $PSScriptRoot "lockscreen_temp.jpg"
    $lockscreenImagePath = Join-Path $PSScriptRoot "lockscreen.jpg"

    $ShuffledSubreddits = $subreddits | Sort-Object { Get-Random }
    $notfound = 1
    $subIdx = 0
    while (($subIdx -lt $ShuffledSubreddits.count) -and $notfound) {
        $Subreddit = @($ShuffledSubreddits)[$subIdx]
        Write-Log ("Will choose image from subreddit {0}, sorting by {1}" -f $Subreddit, $sort);

        $request = 'https://reddit.com/r/{0}/{1}.json?limit=10' -f $Subreddit, $sort
        $jsonRequest = Invoke-WebRequest $request | ConvertFrom-Json
        $posts = $jsonRequest.data.children

        $posts | ForEach-Object {
            if (($_.data.post_hint -eq "image") -and ((-not $_.data.over_18) -or $nsfw) -and $notfound) {
                Write-Log ("Downloading image at {0}" -f $_.data.url);
                (New-Object System.Net.WebClient).DownloadFile($_.data.url, $templockscreenImagePath)

                [void][System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
                $Image = [System.Drawing.Image]::FromFile($templockscreenImagePath)
                $imagewidth = $Image.width
                $imageheight = $Image.height
                $Image.Dispose();
                if (($imagewidth -ge 1000) -and (($imagewidth / $imageheight) -ge 1)) {
                    $notfound = 0
                    if (Test-Path $lockscreenImagePath) { Remove-Item $lockscreenImagePath -Force }
                    Rename-Item $templockscreenImagePath "lockscreen.jpg"
                }
                elseif ($imagewidth -le 1000) {
                    Write-Log ("Image is too small (width : {0})" -f $imagewidth);
                }
                else {
                    Write-Log ("Image is too disproportionate (width/height ratio : {0})" -f ($imagewidth / $imageheight));
                }
            }
        }

        if ($notfound) {
            Write-Log "No images could be found...";
        }
        else {
            Write-Log "Setting lockscreen background";
            Set-LockscreenWallpaper -LockScreenImageValue $lockscreenImagePath;
        }

        $subIdx += 1
    }
}

function Set-LockscreenWallpaper {
    param(
        [string]$LockScreenImageValue
    )

    $RegKeyPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\PersonalizationCSP"
    $LockScreenPath = "LockScreenImagePath"
    $LockScreenStatus = "LockScreenImageStatus"
    $LockScreenUrl = "LockScreenImageUrl"
    $StatusValue = "1"

    if (([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
        if (!(Test-Path $RegKeyPath)) {
            New-Item -Path $RegKeyPath -Force | Out-Null

            New-ItemProperty -Path $RegKeyPath -Name $LockScreenStatus -Value $StatusValue -PropertyType DWORD -Force | Out-Null
            New-ItemProperty -Path $RegKeyPath -Name $LockScreenPath -Value $LockScreenImageValue -PropertyType STRING -Force | Out-Null
            New-ItemProperty -Path $RegKeyPath -Name $LockScreenUrl -Value $LockScreenImageValue -PropertyType STRING -Force | Out-Null
        }
        else {
            New-ItemProperty -Path $RegKeyPath -Name $LockScreenStatus -Value $value -PropertyType DWORD -Force | Out-Null
            New-ItemProperty -Path $RegKeyPath -Name $LockScreenPath -Value $LockScreenImageValue -PropertyType STRING -Force | Out-Null
            New-ItemProperty -Path $RegKeyPath -Name $LockScreenUrl -Value $LockScreenImageValue -PropertyType STRING -Force | Out-Null
        }

    }
    else {
        Write-Log ("Error: not running as admin, cannot set the registry");
    }
}

function Install-WarplanepornLockscreen {
    # check to see if user is admin
    if (([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {

        # get PS version (Core/Desktop)
        if ($PSVersionTable.PSEdition -eq "Core") { $PSExecutable = "pwsh.exe" }
        else { $PSExecutable = "powershell.exe" }

        # Create a task scheduler event
        $argument = "-WindowStyle Hidden -ExecutionPolicy Bypass -command `"WarplanepornLockscreen -noUpdateCheck`""
        $action = New-ScheduledTaskAction -id "WarplanepornLockscreen" -execute $PSExecutable -Argument $argument
        $settings = New-ScheduledTaskSettingsSet -StartWhenAvailable -RunOnlyIfNetworkAvailable -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -DontStopOnIdleEnd
        $trigger = New-ScheduledTaskTrigger -Daily -At 1am
        Write-Host "`nThe task that is about to be created needs an administrator password to work" -ForegroundColor Cyan
        $Credentials = Test-Credential
        if ($Credentials) {
            Write-Host "Username and password are correct" -ForegroundColor Green
            Write-Host "Unregistering any existing scheduled task" -ForegroundColor DarkYellow
            Unregister-ScheduledTask -TaskName "WarplanepornLockscreen" -ErrorAction SilentlyContinue -Confirm:$false
            Write-Host "Registering new task" -ForegroundColor DarkYellow
            Register-ScheduledTask `
                -TaskName "WarplanepornLockscreen" `
                -User $Credentials[0] `
                -Action $action `
                -Settings $settings `
                -Trigger $trigger -RunLevel Highest `
                -Password $Credentials[1] `
                -taskPath "\WarplanepornLockscreen\" | Out-Null
        }

        if ($? -and (Get-ScheduledTask -TaskName "WarplanepornLockscreen" -ErrorAction SilentlyContinue)) {
            Write-Log "WarplanepornLockscreen is installed" -colour "Green"
            Write-Host ""
        }

        # run user config
        Set-Config -ExecuteAfter -install

        # check execution policy
        $LMExecutionPolicy = (Get-ExecutionPolicy -Scope LocalMachine)
        $CUExecutionPolicy = (Get-ExecutionPolicy -Scope CurrentUser)
        $UnrestrictedExecutionPolicy = "Unrestricted"
        $UndefinedExecutionPolicy = "Undefined"
        if (-not ((($LMExecutionPolicy -eq $UnrestrictedExecutionPolicy) -and ($CUExecutionPolicy -eq $UndefinedExecutionPolicy)) -or ($CUExecutionPolicy -eq $UnrestrictedExecutionPolicy))) {
            Write-Host "`nWARNING: ExecutionPolicy is not unrestricted. The task will work but you will not be able to refresh the wallpaper manually" -ForegroundColor Red
            Write-Host "To enable execution of scripts, run " -NoNewline
            Write-Host "Set-ExecutionPolicy Unrestricted" -BackgroundColor DarkYellow -ForegroundColor Black -NoNewline
            Write-Host " as admin"
            Write-Host "See https://github.com/viccol961/warplaneporn-lockscreen#executionpolicy"
            Write-Host "See https://go.microsoft.com/fwlink/?LinkID=135170"
        }
    }
    else {
        Write-Host "You need run this script as an Admin to install it" -ForegroundColor Red
        exit
    }
}

function Uninstall-WarplanepornLockscreen {
    if (([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
        # remove registry key
        $RegKeyPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\PersonalizationCSP"
        Remove-Item -Path $RegKeyPath -Force -Recurse | Out-Null;
        if (Test-Path $RegKeyPath) {
            Write-Host "Failed to remove registry key" -ForegroundColor Red
        }
        else {
            Write-Host "Removed registry key" -ForegroundColor Green
        }

        # unregister task
        Unregister-ScheduledTask -TaskName "WarplanepornLockscreen" -ErrorAction SilentlyContinue -Confirm:$false | Out-Null;
        Get-ScheduledTask -TaskName "WarplanepornLockscreen" -ErrorAction SilentlyContinue -OutVariable task
        if ($task) {
            Write-Host "Failed to unregister task" -ForegroundColor Red
        }
        else {
            Write-Host "Unregistered task" -ForegroundColor Green
        }

        # remove ps module
        Remove-Item  $PSScriptRoot -Recurse -ErrorAction SilentlyContinue -Force | Out-Null;
        if (Test-Path $PSScriptRoot) {
            Write-Host "Could not automatically remove PowerShell module" -ForegroundColor Red
            Write-host "You may want to manually remove the module. Just delete the WarplanepornLockscreen folder." -ForegroundColor Cyan
            Start-Sleep 1
            Invoke-Item (Split-Path -Parent $PSScriptRoot);
        }
        else {
            Write-Host "Uninstalled module" -ForegroundColor Green
        }
    }
    else {
        Write-host "You need to run this script as admin to uninstall" -ForegroundColor Red
    }

}
function Test-Credential {
    # check password, allowing multiple attemps
    $retryPassword = $true;
    $usernameCorrect = $false;
    Add-Type -AssemblyName System.DirectoryServices.AccountManagement
    $DS = New-Object System.DirectoryServices.AccountManagement.PrincipalContext('machine', $env:COMPUTERNAME)

    while ((!$usernameCorrect) -and $retryPassword) {
        $username = Read-Host "Enter administrator username "
        $securePassword = Read-Host "Enter password for that user " -AsSecureString
        $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($securePassword)
        $password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
        if ($DS.ValidateCredentials($username, $password)) {
            return ($username, $password)
        }
        else {
            Write-Warning "Username and/or password incorrect";
            $retryPassword = ((Read-Host "Try again (y/n) ?").ToLower() -eq "y")
        }
        if (!$retryPassword) {
            Write-Host "WARNING: The task creation will fail without administator password." -ForegroundColor Red
            Write-Host "You will still be able to run the utility to manually refresh the lock screen wallpaper`n" -ForegroundColor Red
            return $false
        }
        Start-Sleep -s 1
    }
}

function Write-Log {
    param (
        [string]$Msg,
        [string]$colour = "White"
    )

    $logfile = Join-Path $PSScriptRoot "log.txt"

    if (($null -ne $logfile)) {
        $date = Get-date -Format "dd/MM/yyyy HH:mm:ss"
        if (!(Test-Path $logfile)) { Set-Content $logfile "WarplanepornLockscreen log" }
        if ((get-item $logfile).length -gt 64kb) {
            $oldlog = (Get-Content $logfile)[-40..-1]
            Set-Content $logfile ("WarplanepornLockscreen log -- Trimmed {0}" -f $date)
            Add-Content $logfile $oldlog
        }
        Add-Content $logfile ("" + $date + "-> " + $msg)
    }

    Write-Host $Msg -ForegroundColor $colour
}

Set-Alias -Name WPP-LS -Value WarplanepornLockscreen
Export-ModuleMember -Alias "WPP-LS"
