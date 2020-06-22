function WarplanepornLockscreen{
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
    [switch]$config
    )

    $warplanepornPic = Join-Path $PSScriptRoot "lockscreen.jpg"
    $configPath = Join-Path $PSScriptRoot "config.json"

    # catch weird argument combinaisons
    if ($install -and $uninstall) {
        Write-Host "Why would you want to install and uninstall ??"
        Write-Host "See help : WarplanepornLockscreen -help"
        Break
    }
    if ($install -and ($list -or $add -or $remove -or $config)) {
        Write-Host "Don't ask for both installation and configuration. The former does the latter !"
        Write-Host "See help : WarplanepornLockscreen -help"
        Break
    }

    # install and uninstall options
    if ($install){
        Install-WarplanepornLockscreen
        Break
    }

    elseif ($uninstall) {
        Uninstall-WarplanepornLockscreen
        Break
    }

    # get config and check installed
    if (-not (Test-Path $configPath)) {
        Write-Host "The module was never installed, would you like to install it ? (y/n) : " -ForegroundColor Cyan -NoNewline
        if ((Read-Host).ToLower() -eq "y") {
            Install-WarplanepornLockscreen
            Break
        }
    }
    $configuration = Get-Content -Raw -Path $configPath | ConvertFrom-Json
    if (!$configuration.installed) {
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
        Write-Host ("Sort input {0} makes no sense. It should be one of top, hot and new" -f $sort) -ForegroundColor Red
        Write-Host "See help : WarplanepornLockscreen -help"
        cmd /c pause
        Break
    }
    if (!$sort) {
        if ($configuration.sort) {
            $sort = $configuration.sort
        }
        else {
            $configuration.sort = "hot"
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
        Config-WarplanepornLockscreen
    }

    if ($help) {
        showHelp
    }

    if (!$install -and !$uninstall -and !$list -and !$add -and !$remove -and !$showlog -and !$showpic -and !$help) {
        if(!$subreddits) {
            if ($config.subreddits) {
                $subreddits = $config.subreddits
            }
            else {
                $subreddits = @('warplaneporn')
            }
        }

        Get-WarplanepornPicfortheday -subreddits $subreddits -nsfw $nsfw -sort $sort;
    }
}

function showHelp {
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
    Write-Host "WarplanepornLockscreen [-showPic]"
    Write-Host "WarplanepornLockscreen [-showlog]"
}

function Config-WarplanepornLockscreen {
    param(
        [switch]$ExecuteAfter,
        [switch]$install
    )

    $ProgressPreference = 'SilentlyContinue'
    $configPath = Join-Path $PSScriptRoot "config.json"

    $configuration = @{}

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
}

function Get-WarplanepornPicfortheday {
    # get image from given subreddit and check dimensions
    param (
    [string[]]$subreddits,
    [string]$sort,
    [bool]$nsfw
    )
    Write-Host ("List of configured subreddits : {0}" -f $subreddits)

    $ProgressPreference = 'SilentlyContinue'
    $templockscreenImagePath = Join-Path $PSScriptRoot "lockscreen_temp.jpg"
    $lockscreenImagePath = Join-Path $PSScriptRoot "lockscreen.jpg"

    $ShuffledSubreddits = $subreddits | Sort-Object {Get-Random}
    $notfound = 1
    $subIdx = 0
    while (($subIdx -lt $ShuffledSubreddits.count) -and $notfound) {
        $Subreddit = @($ShuffledSubreddits)[$subIdx]
        Write-Log ("Will choose image from subreddit {0}, sorting by {1}" -f $Subreddit,$sort);

        $request = 'https://reddit.com/r/{0}/{1}.json?limit=10' -f $Subreddit,$sort
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
                if (($imagewidth -ge 1000) -and (($imagewidth/$imageheight) -ge 1)) {
                    $notfound = 0
                    $imageurl = $_.data.url
                    if (Test-Path $lockscreenImagePath) {Remove-Item $lockscreenImagePath -Force}
                    Rename-Item $templockscreenImagePath "lockscreen.jpg"
                }
                elseif ($imagewidth -le 1000) {
                    Write-Log ("Image is too small (width : {0})" -f $imagewidth);
                }
                else {
                    Write-Log ("Image is too disproportionate (width/height ratio : {0})" -f ($imagewidth/$imageheight));
                }
                $i += 1
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
        if (!(Test-Path $RegKeyPath))
        {
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
    if (([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")){

        # Create a task scheduler event
        $argument = "-WindowStyle Hidden -ExecutionPolicy Bypass -command `"WarplanepornLockscreen`""
        $action = New-ScheduledTaskAction -id "WarplanepornLockscreen" -execute 'Powershell.exe' -Argument $argument
        $settings = New-ScheduledTaskSettingsSet -StartWhenAvailable -RunOnlyIfNetworkAvailable -AllowStartIfOnBatteries
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

        if ($? -and (Get-ScheduledTask -TaskName "WarplanepornLockscreen" -ErrorAction SilentlyContinue)){
            Write-Log "WarplanepornLockscreen is installed" -colour "Green"
            Write-Host ""
        }

        # run user config
        Config-WarplanepornLockscreen -ExecuteAfter -install

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
    if (([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")){
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
        if (Get-ScheduledTask -TaskName "WarplanepornLockscreen") {
            Write-Host "Failed to unregister task" -ForegroundColor Red
        }
        else {
            Write-Host "Unregistered task" -ForegroundColor Green
        }

        # remove ps module
        Remove-Item  $PSScriptRoot -Recurse -ErrorAction SilentlyContinue -Force | Out-Null;
        if (Test-Path $PSScriptRoot){
            Write-Host "Could not automatically remove PowerShell module" -ForegroundColor Red
            Write-host "You may want to manually remove the module. Just delete the WarplanepornLockscreen folder." -ForegroundColor Cyan
            Start-Sleep 1
            Invoke-Item (Split-Path -Parent $PSScriptRoot);
        }
        else {
            Write-Host "Uninstalled module" -ForegroundColor Green
        }
    } else {
        Write-host "You need to run this script as admin to uninstall" -ForegroundColor Red
    }

}
function Test-Credential {
    # check password, allowing multiple attemps
    $retryPassword = $true;
    $usernameCorrect = $false;
    Add-Type -AssemblyName System.DirectoryServices.AccountManagement
    $DS = New-Object System.DirectoryServices.AccountManagement.PrincipalContext('machine',$env:COMPUTERNAME)

    while ((!$usernameCorrect) -and $retryPassword){
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
        if (!$retryPassword){
            Write-Host "WARNING: The task creation will fail without administator password." -ForegroundColor Red
            Write-Host "You will still be able to run the utility to manually refresh the lock screen wallpaper`n" -ForegroundColor Red
            return $false
        }
        Start-Sleep -s 1
    }
}

function Write-Log  {
    param (
    [string]$Msg,
    [string]$colour = "White"
    )

    $logfile = Join-Path $PSScriptRoot "log.txt"

    if (($null -ne $logfile)){
        $date = Get-date -Format "dd/MM/yyyy HH:mm:ss"
        if (!(Test-Path $logfile)) {Set-Content $logfile "WarplanepornLockscreen log"}
        if ((get-item $logfile).length -gt 64kb){
            $oldlog = (Get-Content $logfile)[-40..-1]
            Set-Content $logfile ("WarplanepornLockscreen log -- Trimmed {0}" -f $date)
            Add-Content $logfile $oldlog
        }
        Add-Content $logfile ("" + $date + "-> " + $msg)
    }

    Write-Host $Msg -ForegroundColor $colour
}
