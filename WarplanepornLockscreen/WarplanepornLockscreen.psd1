@{

RootModule = 'WarplanepornLockscreen.psm1'
ModuleVersion = '1.1.0'

# CompatiblePSEditions = @()

GUID = 'f3f9b340-1e99-4646-9ffe-0fc7b02f9c72'
Author = 'Victor Colomb'
Copyright = '(c) 2023 Victor Colomb'
Description = 'Daily lock screen wallpaper from one or several subreddits.'
PowerShellVersion = '5.0'
DotNetFrameworkVersion = '1.1'
FunctionsToExport = @("WarplanepornLockscreen")
CmdletsToExport = @()
VariablesToExport = '*'
AliasesToExport = @("*")

PrivateData = @{
    PSData = @{
        Tags = @("reddit","wallpaper","lockscreen","warplaneporn")
        LicenseUri = 'https://github.com/viccol961/warplaneporn-lockscreen/blob/master/LICENSE'
        ProjectUri = 'https://github.com/viccol961/warplaneporn-lockscreen'
        IconUri = 'https://github.com/viccol961/warplaneporn-lockscreen/raw/master/WarplanepornLockscreen.png'
    }
}

}

