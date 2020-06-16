if (([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    # install ps module
    $ModulePath = $env:PSModulePath.split(';')[0]
    $InstallPath = Join-Path $ModulePath "warplaneporn-lockscreen"
    $ScriptPath = Join-Path $InstallPath "warplaneporn-lockscreen.psm1"
    if (!(test-path $InstallPath)) {mkdir($InstallPath)}
    elseif (test-path $ScriptPath) {Remove-Item $ScriptPath}
    Copy-Item ".\warplaneporn-lockscreen.psm1" -Destination $InstallPath

    # test install
    if ((Get-Module -ListAvailable).name.Contains('warplaneporn-lockscreen')) {
        Write-Host ("Module successfully installed in {0}" -f $InstallPath) -ForegroundColor Green

        # get subreddits
        if (Test-Path ".\subreddits.txt") {
            $subreddits_temp = Get-Content -Path ".\subreddits.txt"
            $subreddits = @()
            $subreddits_temp | ForEach-Object {
                if (!(($_.Trim()) -match ' ')) {
                    $subreddits += $_.Trim()
                }
            }
        }
        else {
            $subreddits = @('warplaneporn')
        }
        Write-Host ("Installing for subreddits : {0}" -f $subreddits) -ForegroundColor DarkYellow

        # execute install
        set-WarplanepornLockscreen -install -subreddits $subreddits
    }
    else {
        Write-Host "Cannot find module, the installation must have failed" -ForegroundColor Red
    }
}
else{
    Write-Host "You need run this script as an Admin to install" -ForegroundColor Red
}