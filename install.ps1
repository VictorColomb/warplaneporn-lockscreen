if (([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    $ModulePath = $env:PSModulePath.split(';')[0]
    $InstallPath = Join-Path $ModulePath "WarplanepornLockscreen"
    $ScriptPath = Join-Path $InstallPath "WarplanepornLockscreen.psm1"

    Set-ExecutionPolicy Unrestricted -Scope Process -Force

    #install ps module
    Write-Host "Installing module" -ForegroundColor DarkYellow
    if (!(test-path $InstallPath)) {mkdir($InstallPath) | Out-Null}
    elseif (test-path $ScriptPath) {Remove-Item $ScriptPath | Out-Null}
    Copy-Item ".\WarplanepornLockscreen.psm1" -Destination $InstallPath

    # test install
    if ((Get-Module -ListAvailable).name.Contains('WarplanepornLockscreen')) {
        Write-Host ("Module successfully installed in {0}" -f $InstallPath) -ForegroundColor Green

        # execute install
        WarplanepornLockscreen -install

        # user configuration
        Config-WarplanepornLockscreen -ExecuteAfter

        # check ExecutionPolicy
        $LMExecutionPolicy = (Get-ExecutionPolicy -Scope LocalMachine)
        $CUExecutionPolicy = (Get-ExecutionPolicy -Scope CurrentUser)
        $UnrestrictedExecutionPolicy = "Unrestricted"
        $UndefinedExecutionPolicy = "Undefined"
        if (-not ((($LMExecutionPolicy -eq $UnrestrictedExecutionPolicy) -and ($CUExecutionPolicy -eq $UndefinedExecutionPolicy)) -or ($CUExecutionPolicy -eq $UnrestrictedExecutionPolicy))) {
            Write-Host "`nWARNING: ExecutionPolicy is not unrestricted. The task will work but you will not be able to refresh the wallpaper manually" -ForegroundColor Red
            Write-Host "To enable execution of scripts, run " -NoNewline
            Write-Host "Set-ExecutionPolicy Unrestricted" -BackgroundColor DarkYellow -ForegroundColor Black -NoNewline
            Write-Host " as admin"
            Write-Host "See https://go.microsoft.com/fwlink/?LinkID=13517"
        }

        Write-Host "`nYou can now delete the installation files" -ForegroundColor Cyan
        cmd /c pause
    }
    else {
        Write-Host "Cannot find module, the installation must have failed" -ForegroundColor Red
        cmd /c pause
    }
}
else{
    Write-Host "You need run this script as an Admin to install" -ForegroundColor Red
    cmd /c pause
}