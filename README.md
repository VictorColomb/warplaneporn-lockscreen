# WarplanepornLockscreen

[![Powershell Gallery](https://img.shields.io/powershellgallery/v/WarplanepornLockscreen?style=flat-square)](https://www.powershellgallery.com/packages/WarplanepornLockscreen)
[![Issues](https://img.shields.io/github/issues/viccol961/warplaneporn-lockscreen?style=flat-square)](https://github.com/viccol961/warplaneporn-lockscreen/issues)
[![License](https://img.shields.io/github/license/viccol961/warplaneporn-lockscreen?style=flat-square)](https://github.com/viccol961/warplaneporn-lockscreen/blob/master/LICENSE)
[![r/warplaneporn](https://img.shields.io/static/v1?label=r/&message=warplaneporn&color=informational&style=flat-square)](https://reddit.com/r/warplaneporn)

Daily lock screen wallpaper from one or several subreddits.

## ⚙️ Requirements

* Windows 10 or 11, build 1703 (Creators Update) or later
* Powershell 5+
* Admin rights

## ⬇️ Installation

In a Powershell console with elevated rights:

```[powershell]
Set-ExecutionPolicy Unrestricted -Scope Process
Install-Module -Name WarplanepornLockscreen
WarplanepornLockscreen -install
```

This will download the module from PowerShell Gallery and install it on your machine.

When installed, the script will launch once a day and set a new wallpaper (given your machine is running and connected to the internet).

## 🔨 Usage

For your convenience, `WarplanepornLockscreen` has an alias : `WPP-LS`!

### 1. Manual wallpaper refresh

```[batch]
WPP-LS [-subreddits sub1[,sub2[...]]] [-nsfw] [-sort top|hot|new]
```

### 2. Change configuration

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

### 3. Display current picture or open log

```[batch]
WarplanepornLockscreen -showpic
WarplanepornLockscreen -showlog
```

### 4. Save current wallpaper and see saved wallpapers

```[batch]
WarplanepornLockscreen -save
WarplanepornLockscreen -showSaved
```

## ❌ Uninstall

In a Powershell console with elevated rights:

```[batch]
Set-ExecutionPolicy Unrestricted -Scope Process
WarplanepornLockscreen -uninstall
```

## 📃 To do

* Check for updates
* Adapt for desktop background (same thing, different registry key)

Feel free to help !

## ⚖️ License

This code is licensed under the MIT license. Fell free to use it as you wish!
