# warplaneporn-lockscreen

Set a lockscreen background from one or several subreddits on a daily basis

## Requirements

* Powershell 5+
* Admin rights

Works for Windows 10 (build 1703 or later)

## Install

1. Clone the repo
2. Allow execution of powershell scripts (can be disabled after installation) : `Set-ExecutionPolicy Unrestricted`
3. Register desired subreddits in `subreddits.txt` (no spaces, one line per subreddit, no "/r/" prefix). If this file is not found by the installer, it will default to [/r/warplaneporn](https://reddit.com/r/warplaneporn)
4. Run script `install.bat` with admin rights (right click > Run as administrator)

A task will be set to run everyday to refresh the wallpaper as soon as possible starting from 1am.

## Usage

You can run the command at any given time

From `powershell` :

```
set-WarplanepornLockscreen [-subreddits list_of_subreddits (default from installation)] [-logfile logfile (default in appdata)] [-nolog] [-nsfw]
```

From `cmd` add "`powershell`" before the command.

Naturally, both need admin rights.

## Uninstall

Run `set-WarplanepornLockscreen -uninstall`

You will be asked to manually delete the module folder.
