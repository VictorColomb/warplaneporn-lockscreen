# warplaneporn-lockscreen

[![GitHub release (latest SemVer)](https://img.shields.io/github/v/release/viccol961/warplaneporn-lockscreen?sort=semver)](https://github.com/viccol961/warplaneporn-lockscreen/releases)
[![GitHub issues](https://img.shields.io/github/issues/viccol961/warplaneporn-lockscreen)](https://github.com/viccol961/warplaneporn-lockscreen/issues)
[![GitHub license](https://img.shields.io/github/license/viccol961/warplaneporn-lockscreen)](https://github.com/viccol961/warplaneporn-lockscreen/blob/master/LICENSE)
[![r/warplaneporn](https://img.shields.io/static/v1?label=r/&message=warplaneporn&color=informational)](https://reddit.com/r/warplaneporn)

Daily background from one or several subreddits

## Requirements

* Powershell 5+
* Admin rights

Works for Windows 10 (build 1703 or later)

## Install

1. Clone the repo or download archive from [releases](https://github.com/viccol961/warplaneporn-lockscreen/releases)
2. Allow execution of powershell scripts (can be disabled after installation) : `Set-ExecutionPolicy Unrestricted`
3. Register desired subreddits in `subreddits.txt` (no spaces, one line per subreddit, no "/r/" prefix). If this file is not found by the installer, it will default to [/r/warplaneporn](https://reddit.com/r/warplaneporn)
4. Run script `install.ps1` with admin rights

A task will be set to run everyday to refresh the wallpaper as soon as possible starting from 1am.

Reinstall to modify the list of subreddits to choose a wallpaper from.

## Usage

You can run the utility at any given time to try and find a new background.

From `powershell` :

```
set-WarplanepornLockscreen [-subreddits list_of_subreddits (default from installation)] [-logfile logfile (default in appdata)] [-nolog] [-nsfw]
```

From `cmd` add "`powershell`" before the command.

Naturally, both need admin rights.

## Uninstall

Run `set-WarplanepornLockscreen -uninstall`

You will be asked to manually delete the module folder.
