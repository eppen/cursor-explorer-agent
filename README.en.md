# Windows Explorer context menu → Cursor Agent

Right-click a folder (or empty space inside a folder), enter a task description, and run the local `agent` CLI against that directory.

[中文说明](README.md)

## Prerequisites

1. [Cursor CLI](https://cursor.com/docs/cli/headless) installed (common path: `%LOCALAPPDATA%\cursor-agent\agent.cmd`)
2. Signed in, or `CURSOR_API_KEY` set:

```powershell
agent login
# or
$env:CURSOR_API_KEY = 'your_api_key'
```

## Install

In PowerShell:

```powershell
cd <path-to-this-tool>
.\Install-ContextMenu.ps1
```

No admin rights required (writes to the current user’s HKCU).

## Usage

1. In File Explorer, right-click a **folder**, or right-click **empty space** inside a folder
2. Choose **用 Cursor Agent 执行...**
3. Enter the task description and confirm
4. A new console runs `agent -p --force --trust --workspace <path>`; press Enter when finished to close

On Windows 11, open **Show more options** if the item is hidden in the compact menu.

## Uninstall

```powershell
cd <path-to-this-tool>
.\Uninstall-ContextMenu.ps1
```

## Files

| File | Purpose |
|------|---------|
| `Invoke-CursorAgent.ps1` | Dialog + launch agent |
| `Install-ContextMenu.ps1` | Register context menu |
| `Uninstall-ContextMenu.ps1` | Remove context menu |

## Quick test

After install, right-click any test folder and enter something like:

> List the main files in this directory and briefly summarize what they are for (do not modify any files)

A console should open with agent output. If agent is missing or auth fails, check **Prerequisites** above.

## License

This project is released under the [GNU General Public License v2.0](LICENSE) (GPLv2).
