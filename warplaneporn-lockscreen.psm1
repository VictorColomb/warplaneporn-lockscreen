function set-WarplanepornLockscreen{
    param (
    [string]$warplanepornFolder = (join-path $env:APPDATA "\warplaneporn-lockscreen\"),
    [array]$subreddits,
    [string]$logfile = (join-path $warplanepornFolder "log.txt"),
    [switch]$nsfw,
    [switch]$install,
    [switch]$uninstall
    )

    write-host "Logfile at $logfile"

    if (! (test-path $warplanepornFolder)){mkdir $warplanepornFolder}
    $warplanepornPic = Join-Path $warplanepornFolder "lockscreen.jpg"


    if ($install){
        install-warplaneporn-lockscreen -warplanepornFolder $warplanepornFolder -subreddits $subreddits -logfile $logfile -nolog $nolog -nsfw $nsfw
    }

    if ($showpic) {
        Invoke-Item $warplanepornPic
    }
    elseif ($uninstall){
        uninstall-warplaneporn-lockscreen -logfile $logfile -warplanepornFolder $warplanepornFolder;
    }
    else {
        if(!$subreddits) {
            if (test-path (Join-Path $warplanepornFolder "subreddits.txt")) {
                $subreddits_temp = Get-Content -Path ".\subreddits.txt"
                $subreddits = @()
                $subreddits_temp | ForEach-Object {
                    if (!(($_.Trim()) -match ' ') -and $_) {
                        $subreddits += $_.Trim()
                    }
                }
            }
            else{
                $subreddits = @(warplaneporn)
            }
        }
        get-warplanepornPicFortheDay -subreddits $subreddits -logFile $logfile -nsfw $nsfw;
    }
}

function get-warplanepornPicFortheDay {
    # get image from given subreddit and check dimensions
    param (
    [array]$subreddits,
    [string]$logfile,
    [bool]$nsfw
    )

    $Subreddit = $subreddits[(Get-Random -Maximum $subreddits.count)]
    write-Log ("Will choose image from subreddit {0}" -f $Subreddit) -logfile $logfile;

    $templockscreenImagePath = join-path $env:APPDATA "\warplaneporn-lockscreen\lockscreen_temp.jpg"
    $lockscreenImagePath = join-path $env:APPDATA "\warplaneporn-lockscreen\lockscreen.jpg"

    $request = 'https://reddit.com/r/{0}/hot.json?limit=25' -f $Subreddit
    $jsonRequest = Invoke-WebRequest $request | ConvertFrom-Json
    $posts = $jsonRequest.data.children

    $i = 0
    $notfound = 1
    $posts | ForEach-Object {
        if (($_.data.post_hint -eq "image") -AND ((-NOT $_.data.over_18) -OR $nsfw) -AND $notfound) {
            write-Log ("Downloading image at {0}" -f $_.data.url) -logfile $logfile;
            (New-Object System.Net.WebClient).DownloadFile($_.data.url, $templockscreenImagePath)

            [void][System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
            $Image = [System.Drawing.Image]::FromFile($templockscreenImagePath)
            $imagewidth = $Image.width
            $imageheight = $Image.height
            $Image.Dispose();
            if (($imagewidth -ge 1000) -and (($imagewidth/$imageheight) -ge 1)) {
                $notfound = 0
                $imageurl = $_.data.url
                if (test-path $lockscreenImagePath) {Remove-Item $lockscreenImagePath}
                Rename-Item $templockscreenImagePath "lockscreen.jpg"
            }
            elseif ($imagewidth -le 1000) {
                write-Log ("Image is too small (width : {0})" -f $imagewidth) -logfile $logfile;
            }
            else {
                write-Log ("Image is too disproportionate (width/height ratio : {0})" -f ($imagewidth/$imageheight)) -logfile $logfile;
            }
            $i += 1
        }
    }

    if ($notfound) {
        write-Log "No images could be found..." -logfile $logfile;
    }
    else {
        write-Log "Setting lockscreen background" -logfile $logfile;
        Set-LockscreenWallpaper -LockScreenImageValue $lockscreenImagePath -logfile $logfile;
    }
}

function Set-LockscreenWallpaper {
    # this was adapted from
    # https://abcdeployment.wordpress.com/2017/04/20/how-to-set-custom-backgrounds-for-desktop-and-lockscreen-in-windows-10-creators-update-v1703-with-powershell/
    # The Script sets custom background Images for the Lock Screen by leveraging the new feature of PersonalizationCSP that is only available in
    # the Windows 10 v1703 aka Creators Update and later build versions #
    # Applicable only for Windows 10 v1703 and later build versions #

    param(
    [string]$LockScreenImageValue,
    [string]$logfile
    )

    $RegKeyPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\PersonalizationCSP"

    $LockScreenPath = "LockScreenImagePath"
    $LockScreenStatus = "LockScreenImageStatus"
    $LockScreenUrl = "LockScreenImageUrl"
    $StatusValue = "1"

    If (([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")){

        IF(!(Test-Path $RegKeyPath))

        {

            New-Item -Path $RegKeyPath -Force | Out-Null

            New-ItemProperty -Path $RegKeyPath -Name $LockScreenStatus -Value $StatusValue -PropertyType DWORD -Force | Out-Null
            New-ItemProperty -Path $RegKeyPath -Name $LockScreenPath -Value $LockScreenImageValue -PropertyType STRING -Force | Out-Null
            New-ItemProperty -Path $RegKeyPath -Name $LockScreenUrl -Value $LockScreenImageValue -PropertyType STRING -Force | Out-Null

        }

        ELSE {

            New-ItemProperty -Path $RegKeyPath -Name $LockScreenStatus -Value $value -PropertyType DWORD -Force | Out-Null
            New-ItemProperty -Path $RegKeyPath -Name $LockScreenPath -Value $LockScreenImageValue -PropertyType STRING -Force | Out-Null
            New-ItemProperty -Path $RegKeyPath -Name $LockScreenUrl -Value $LockScreenImageValue -PropertyType STRING -Force | Out-Null
        }
    } else {
        write-Log ("Error: not running as Admin, can't set the registry.") -logFile $logfile;
    }
}

function install-warplaneporn-lockscreen {
    param(
    [string]$warplanepornFolder = (join-path $env:APPDATA "\warplaneporn-lockscreen\"),
    [array]$subreddits = @('warplaneporn'),
    [String]$logfile = (join-path $env:APPDATA "\warplaneporn-lockscreen\log.txt")
    )
    # save subreddits
    if ($subreddits) {$subreddits | Out-File (join-path $warplanepornFolder "subreddits.txt")}

    # check to see if user is admin
    if (([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")){
        # is admin, we're good to install
        Write-Host "This will install warplaneporn-lockscreen on your machine and it will download a top image from the given subreddit(s) (default warplaneporn) login screen every day" -ForegroundColor DarkYellow

        # Create a task scheduler event
        $argument = "-WindowStyle Hidden -command `"import-module 'warplaneporn-lockscreen'; set-WarplanepornLockscreen -logfile {0} -warplanepornFolder {1} -subreddits {2}`"" -f `
            $logfile, `
            $warplanepornFolder, `
            $subreddits
        $action = New-ScheduledTaskAction -id "warplaneplorn-lockscreen" -execute 'Powershell.exe' -Argument $argument
        $settings = New-ScheduledTaskSettingsSet -StartWhenAvailable -RunOnlyIfNetworkAvailable
        $trigger = New-ScheduledTaskTrigger -Daily -At 1am
        Write-Host "This script needs admin privileges to work" -ForegroundColor DarkBlue
        $Credential = Test-Credential
        if ($Credential){
            Write-Host "Username correct" -ForegroundColor Green
            write-Log "Unregistering any existing scheduled task" -logfile $logfile -ForegroundColor DarkYellow
            Unregister-ScheduledTask -TaskName "warplaneporn-lockscreen" -ErrorAction SilentlyContinue
            Register-ScheduledTask `
            -TaskName "warplaneporn-lockscreen" `
            -User $Credential.username `
            -Action $action `
            -Settings $settings `
            -Trigger $trigger -RunLevel Highest `
            -Password $Credential.GetNetworkCredential().Password `
            -taskPath "\warplaneporn-lockscreen\"
        }
        if ($? -and (Get-ScheduledTask -TaskName "warplaneporn-lockscreen" -ErrorAction SilentlyContinue)){
            write-Log "warplaneporn-lockscreen is installed" -colour "Green" -logFile $logfile
        } else {
            throw "Task creation failed"
        }
    }  else {
        # not admin
        Write-Host "You need run this script as an Admin to install it" -ForegroundColor Red
        throw "Missing admin privileges"
    }
}

function uninstall-warplaneporn-lockscreen {
    param(
    [string]$logfile,
    [string]$warplanepornFolder
    )
    if (([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")){
        $RegKeyPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\PersonalizationCSP"
        remove-item -Path $RegKeyPath -Force -Recurse| Out-Null;
        Unregister-ScheduledTask -TaskName "warplaneporn-lockscreen" -ErrorAction SilentlyContinue;
        Remove-Item  $warplanepornFolder -Recurse -ErrorAction SilentlyContinue;
        $scriptPath = (get-item $myInvocation.ScriptName).Directory
        if ($scriptPath.name -eq "warplaneporn-lockscreen"){
            Write-host "You have to manually remove the module now. Just delete the warplaneporn-lockscreen folder." -ForegroundColor Red
            Invoke-Item $scriptPath;
        }
    } else {
        Write-host "You need to run this script as admin to uninstall it" -ForegroundColor Red
        throw "Missing admin rights"
    }

}
function Test-Credential {
    # check password, allowing multiple attemps
    $againWithThePassword = $true;
    $usernameChecksOut = $false;
    Add-Type -AssemblyName System.DirectoryServices.AccountManagement
    $DS = New-Object System.DirectoryServices.AccountManagement.PrincipalContext('machine',$env:COMPUTERNAME)

    while ((! $usernameChecksOut) -and $againWithThePassword){
        $Credential = Get-Credential -ErrorAction SilentlyContinue
        if ($null -eq $Credential){
            Write-Warning "You did not input any credentials"
            $againWithThePassword = ((read-host "Try again with the password this time (y/n) ?").ToLower() -ne "n")
        } else {
            $usernameChecksOut = $DS.ValidateCredentials($Credential.UserName, $Credential.GetNetworkCredential().Password)
            if ($usernameChecksOut){
                return $Credential
            } else {
                Write-Warning "Username and / or password is incorrect. Soz.";
                $againWithThePassword = ((read-host "Try again with the password this time (y/n) ?").ToLower() -eq "n")
            }
        }
        if (! $againWithThePassword){
            return $false
        }
        Start-Sleep 1
    }
}

function write-Log  {
    param (
    [string]$Msg,
    [string]$colour = "White",
    [string]$logfile
    )

    if (($null -ne $logfile)){
        $date = Get-date -f "dd/MM/yyyy HH:mm:ss"
        if (! (test-path $logfile )){set-content $logfile "WarplanePorn-lockscreen log"}
        if ((get-item $logfile).length -gt 64kb){
            $oldlog = (Get-Content $logfile)[-40..-1]
            Set-Content $logfile ("WarplanePorn-lockscreen log -- Trimmed {0}" -f $date)
            Add-Content $logfile $oldlog
        }
        add-content $logfile ("" + $date + "-> " + $msg)
    }
    Write-Host $Msg -foregroundColor $colour
}

Export-ModuleMember -Function set-WarplanepornLockscreen
