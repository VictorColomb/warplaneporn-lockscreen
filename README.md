# warplaneporn-lockscreen

[![Releases](https://img.shields.io/github/v/release/viccol961/warplaneporn-lockscreen?sort=semver&style=flat-square)](https://github.com/viccol961/warplaneporn-lockscreen/releases)
[![Issues](https://img.shields.io/github/issues/viccol961/warplaneporn-lockscreen?style=flat-square)](https://github.com/viccol961/warplaneporn-lockscreen/issues)
[![License](https://img.shields.io/github/license/viccol961/warplaneporn-lockscreen?style=flat-square)](https://github.com/viccol961/warplaneporn-lockscreen/blob/master/LICENSE)
[![r/warplaneporn](https://img.shields.io/static/v1?label=r/&message=warplaneporn&color=informational&style=flat-square)](https://reddit.com/r/warplaneporn)

Daily lock screen wallpaper from one or several subreddits.

[This PowerShell module is hosted in the PowerShell Gallery.](https://www.powershellgallery.com/packages/WarplanepornLockscreen)

## Requirements

* Powershell 5+
* Admin rights

Works for Windows 10, build 1703 (Creators Update) or later.

## Install

### Option 1 : from the PowerShell Gallery (personal favorite)

In an administrator powershell session, run

```[powershell]
Set-ExecutionPolicy Unrestricted -Scope Process
Install-Module -Name WarplanepornLockscreen
WarplanepornLockscreen -install
```

This will download the module from PowerShell Gallery and install it on your machine.

### Option 2 : auto-extractible archive

Download auto-extractible archive from the [latest release](https://github.com/viccol961/warplaneporn-lockscreen/releases), extract in any directory. The `install.bat` should auto run and prompt for admin privileges. If not, simply double click it.

Follow installation instructions directly from the terminal. You will be prompted for configuration.  
Defaults : no nsfw posts, sort by hot, fetch images from [r/warplaneporn](https://reddit.com/r/warplaneporn).

### Option 3 : clone repository

Clone repo, run either `install.bat` or `install.ps1` with admin privileges.

If you wish to run the PowerShell installer script directly, `ExecutionPolicy` should be set to `Unrestricted` for this to work. You could also run the script by passing the argument `-ExecutionPolicy Bypass` to PowerShell.  
See [below](#executionpolicy "Go to ExecutionPolicy").

## Functionalities

Upon installation, a daily task is set (for 1am and as soon as possible after that). This task runs the utility with the configurated parameters.

That means that each morning, when you start your computer and if it's connected to the internet, a new lock screen wallpaper will be set for you using the configuration you provided during installation.  
Change this configuration at any time using the `-config` switch (see [below](#change-configuration "Go to change configuration"))

### Changes in the registry

The following registry key is set by the utility to set the lock screen wallpaper :

```[registry]
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\PersonalizationCSP]
"LockScreenImageStatus"=dword:00000001
"LockScreenImagePath"="%PathToPSModule%\\lockscreen.jpg"
"LockScreenImageUrl"="%PathToPSModule%\\lockscreen.jpg"
```

## Usage

The utility can be run at any time to manually refresh the lock screen wallpaper :

```[batch]
WarplanepornLockscreen [-subreddits sub1[,sub2[...]]] [-nsfw] [-sort top|hot|new]
WPP-LS [-subreddits sub1[,sub2[...]]] [-nsfw] [-sort top|hot|new]
```

For your convenience, `WarplanepornLockscreen` has an alias : `WPP-LS` (way shorter !)

### Change configuration

```[batch]
WarplanepornLockscreen -config
```

You can also add or remove one subreddit at a time from the configuration :

```[batch]
WarplanepornLockscreen -add subreddit
WarplanepornLockscreen -remove subreddit
```

To see which subreddits are currently configured, use

```[batch]
WarplanepornLockscreen -list
```

### Display current picture or open log

```[batch]
WarplanepornLockscreen -showpic
WarplanepornLockscreen -showlog
```

### Save current wallpaper and see saved wallpapers

```[batch]
WarplanepornLockscreen -save
WarplanepornLockscreen -showSaved
```

## Uninstall

| As long as the registry key (see [above](#changes-in-the-registry "Go to Changes in the registry")) is set, that's about what you'll see in the settings : | [![https://i.imgur.com/imRGQo4.jpg](https://i.imgur.com/imRGQo4.jpg)](https://i.imgur.com/imRGQo4.jpg) |
|-|-|

If you wish to choose a lock screen wallpaper yourself, you have to uninstall this utility. The uninstaller will remove the task and the PowerShell module and delete the registry key, enabling you to once again choose your lock screen wallpaper.

```[batch]
WarplanepornLockscreen -uninstall
```

If your execution policy if restricted, open an admin command prompt and enter

```[batch]
powershell -ExecutionPolicy Bypass -Command "WarplanepornLockscreen -uninstall"
```

## ExecutionPolicy

PowerShell has an execution policy for scripts, which by default does not allow PowerShell to run a script that has not been signed.

The installer and the daily task have the `-ExecutionPolicy Bypass` switch and therefore are still able to run.  
However, the module function `WarplanepornLockscreen` will not run and you will get a big red error message.

If you want to manually refresh the lockscreen or change configuration without having to reinstall, change the execution policy to `Unrestricted` or `Bypass`, using the `Set-ExecutionPolicy` PowerShell command.  
Be aware that with these settings, you will be able to run any PowerShell scripts on your computer, potentially dangerous and/or malicious ones. Be very careful !  
It's best to only change the execution policy for the session only : open an administrator powershell session and enter the command `Set-ExecutionPolicy Unrestricted -Scope Process`. At this point you can use the `WarplanepornLockscreen` command.

The installer will check your current execution policy and warn you should it be too restricted for the utility to be ran manually.

See <https://go.microsoft.com/fwlink/?LinkID=135170> for more information.

## To do

* Check for updates
* Option to save current wallpaper and option to see saved images
* Adapt for desktop background (same thing, different registry key)
* Support for Windows 7 ([this](https://www.reddit.com/r/PowerShell/comments/56r68w/script_to_change_windows_7_lock_screen/d8m51bk?utm_source=share&utm_medium=web2x) or [this](https://www.robdiesel.com/wordpress/2018/10/a-powershell-script-to-update-the-windows-7-and-windows-10-lock-screen-image/) should do it)
* (Eventually) port for linux (some distributions at least)

Feel free to help !
