if (([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    $ModulePath = $env:PSModulePath.split(';')[0]
    $InstallPath = Join-Path $ModulePath "WarplanepornLockscreen"
    $ScriptPath = Join-Path $InstallPath "WarplanepornLockscreen.psm1"
    $ManifestPath = Join-Path $InstallPath "WarplanepornLockscreen.psd1"

    Set-ExecutionPolicy Bypass -Scope Process -Force

    #install ps module
    Write-Host "Installing module" -ForegroundColor DarkYellow
    if (!(test-path $InstallPath)) {mkdir($InstallPath) | Out-Null}
    elseif (test-path $ScriptPath) {Remove-Item $ScriptPath | Out-Null}
    Copy-Item ".\WarplanepornLockscreen.psm1" -Destination $InstallPath
    if (test-path $ManifestPath) { Remove-Item $ManifestPath | Out-Null }
    Copy-Item ".\WarplanepornLockscreen.psd1" -Destination $InstallPath

    # test install
    if ((Get-Module -ListAvailable).name.Contains('WarplanepornLockscreen')) {
        Write-Host ("Module successfully installed in {0}" -f $InstallPath) -ForegroundColor Green

        # execute install
        WarplanepornLockscreen -install

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