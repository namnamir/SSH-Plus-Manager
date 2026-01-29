**Language / زبان:** [English](USAGE.md) | [فارسی](USAGE.fa.md)

# SSH Plus Manager — Usage Guide

This guide describes every feature and menu option.

---

## Starting the menu

After installation, run:

```bash
menu
```

Or use the short alias:

```bash
h
```

You must run as **root** for full functionality.

---

## Main menu at a glance

| Option | Feature | Description |
|--------|---------|-------------|
| **01** | CREATE USER | Add a new SSH user with password, expiry, and connection limit |
| **02** | REMOVE USER | Delete an SSH user and clean up limits/expiry |
| **03** | MONITOR USERS | Live view of users, connections, traffic, last seen |
| **04** | EXPIRATION DATE | Change a user’s expiration date |
| **05** | ACCOUNT LIMIT | Change max simultaneous connections per user |
| **06** | USER PASSWORD | Change a user’s password |
| **07** | EXPIRED USERS | List and remove expired users |
| **08** | CONNECTIONS | Advanced connections menu (tunnels, proxies, **SSH multi-port**) |
| **09** | SPEEDTEST | Run download/upload speed test (requires speedtest-cli) |
| **10** | BANNER | Set the SSH login banner (e.g. IP, welcome text) |
| **11** | VPS TRAFFIC | Show live traffic with nload |
| **12** | BACKUP | Back up user list / manager data |
| **13** | VPS INFO | System info (CPU, RAM, disk, etc.) |
| **14** | REBOOT SYSTEM | Reboot the server |
| **15** | RESTART SERVICES | Restart SSH and related services |
| **16** | ROOT PASSWORD | Change the root password |
| **17** | AUTO RUN | Turn on/off “run menu at login” |
| **18** | UPDATE SCRIPT | Check version and update from the repository |
| **19** | REMOVE SCRIPT | Uninstall SSH Plus Manager |
| **00** | EXIT | Exit the menu |

In submenus, **0** usually means “back” and **00** means “exit entirely”.

---

## Feature details

### [01] CREATE USER

- Prompts for **username** (0 = back, 00 = exit).
- You set **password**, **expiration date**, and **connection limit**.
- User is created with `useradd`, expiry is applied with `chage`, and all user state is stored in the centralized `$HOME/users.db`.
- After creation, IP, user, password, expiry, and limit are shown so you can copy them.

### [02] REMOVE USER

- Choose a user from the list and confirm to remove.
- Removes the user account and their entry from the limits/expiry data.

### [03] MONITOR USERS

- Table of users with: status (online/offline/expired/expiring), connections, session time, current/total traffic, validity (days), last connection, password.
- Auto-refreshes periodically (configurable, default: 30 seconds). Press Enter to return to the menu.
- Configure refresh interval: [13] Server settings → [6] Auto-refresh interval

### [04] EXPIRATION DATE

- Pick a user, then set a new expiration date (e.g. number of days or a date).
- Uses the same user list and 0/00 behavior as other user submenus.

### [05] ACCOUNT LIMIT

- Pick a user and set maximum simultaneous connections (e.g. 1, 2, 5).
- Stored in `$HOME/users.db` (single source of truth) and used by the manager’s connection logic.

### [06] USER PASSWORD

- Pick a user and set a new password (via `chpasswd`).

### [07] EXPIRED USERS

- Lists users past their expiration date.
- Lets you remove them or clean up expired entries.

### [08] CONNECTIONS

- Opens the **Connections** submenu.
- From here you can open **SSH Multi-Port Setup** (add/remove SSH ports, quick multi-port setup, verify).  
  See [SSH Multi-Port Setup](SSH-MULTIPORT.md) for how it works and how it interacts with UFW.

### [09] SPEEDTEST

- Runs **speedtest-cli** and shows ping, download, and upload.
- If `speedtest-cli` is missing, the menu will try to install it (pip or apt) and show a short message. Press Enter to return.

### [10] BANNER

- Set the text shown before SSH login (e.g. “SSHPLUS MANAGER - IP: x.x.x.x”).
- Saved to `/etc/banner` and used by `sshd` via `Banner /etc/banner`.

### [11] VPS TRAFFIC

- Starts **nload** to show live network traffic. Exit with Ctrl+C.

### [12] BACKUP

- Backs up user/manager-related data (e.g. user list, limits) so you can restore later.

### [13] VPS INFO

- Shows hostname, CPU, RAM, disk, network, and similar system info.

### [14] REBOOT SYSTEM

- Reboots the server after confirmation.

### [15] RESTART SERVICES

- Restarts SSH (and any other managed services) so config changes take effect.

### [16] ROOT PASSWORD

- Changes the root password after you type it twice.

### [17] AUTO RUN

- Enables or disables running the menu automatically when you log in (via `/etc/profile`).

### [18] UPDATE SCRIPT

- Compares installed version with the repository.
- If newer, offers to download and replace menu and modules from the repo.  
  Repository URL is taken from `/etc/SSHPlus/repo_url` if set, otherwise the default GitHub URL.

### [19] REMOVE SCRIPT

- Uninstalls the manager: removes `/bin/menu`, modules, and related files after you confirm (including typing “DELETE”).

---

## Files and paths (reference)

| Path | Purpose |
|------|---------|
| `/bin/menu` | Main menu script |
| `/etc/SSHPlus/` | Config, colors, optional open.py/proxy.py |
| `/etc/SSHPlus/version` | Installed version (for update check) |
| `/etc/SSHPlus/repo_url` | Optional custom repo URL for updates |
| `$HOME/users.db` | **Single source of truth**: user records (8 space-separated fields per user) |
| `$HOME/sessions.log` | Append-only session audit log (one line per completed session) |
| `/etc/IP` | Cached server IP (used in banner and “Create user” output) |
| `/etc/banner` | SSH login banner text |

---

## More documentation

- [TROUBLESHOOTING.md](TROUBLESHOOTING.md) — common problems and fixes.
- [SSH-MULTIPORT.md](SSH-MULTIPORT.md) — SSH multi-port setup and UFW.
