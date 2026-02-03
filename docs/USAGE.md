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

The menu is organized into four sections:

### USERS

| Option | Feature | Description |
|--------|---------|-------------|
| **01** | CREATE USER | Add a new SSH user with password, expiry, and connection limit |
| **02** | REMOVE USER | Delete an SSH user and clean up limits/expiry |
| **03** | CHANGE PASSWORD | Change a user's password |
| **04** | EXPIRATION MANAGER | View users, change expiration dates, remove expired users |
| **05** | ACCOUNT LIMIT | Change max simultaneous connections per user |

### MONITORING

| Option | Feature | Description |
|--------|---------|-------------|
| **07** | MONITOR USERS | Live view of users, connections, traffic, last seen |
| **08** | SPEEDTEST | Run download/upload speed test (requires speedtest-cli) |
| **09** | VPS TRAFFIC | Show live traffic with nload |
| **10** | VPS INFO | System info (CPU, RAM, disk, etc.) |

### SYSTEM

| Option | Feature | Description |
|--------|---------|-------------|
| **11** | RESTART SERVICES | Restart SSH and related services |
| **12** | REBOOT SYSTEM | Reboot the server |
| **13** | SERVER SETTINGS | Root password, timezone, keyboard, server name, privacy, refresh interval |
| **14** | REMOVE SCRIPT ⚠️ | Uninstall SSH Plus Manager |

### SETTINGS

| Option | Feature | Description |
|--------|---------|-------------|
| **15** | CONNECTIONS | Advanced connections menu (tunnels, proxies, **SSH multi-port**) |
| **16** | BANNER | Set the SSH login banner (e.g. IP, welcome text) |
| **17** | BACKUP | Back up user list / manager data |
| **18** | AUTORUN | Turn on/off "run menu at login" |
| **19** | UPDATE SCRIPT | Check version and update from the repository |

| **00/q/Q** | EXIT | Exit the menu |

In submenus, **0** usually means "back" and **00** means "exit entirely".

---

## Feature details

### [01] CREATE USER

- Prompts for **username** (0 = back, 00 = exit).
- You set **password**, **expiration date**, and **connection limit**.
- User is created with `useradd`, expiry is applied with `chage`, and all user state is stored in the centralized `users.db`.
- After creation, IP, user, password, expiry, and limit are shown so you can copy them.

### [02] REMOVE USER

- Choose a user from the list and confirm to remove.
- Removes the user account and their entry from the limits/expiry data.

### [03] CHANGE PASSWORD

- Pick a user and set a new password (via `chpasswd`).
- The password is also updated in `users.db`.

### [04] EXPIRATION MANAGER

A unified screen that combines expiration date management and expired user cleanup:

- **View all users** with their expiration status (days remaining, expired, never).
- **Change expiration** for any user by entering days or a specific date.
- **List expired users** and remove them individually or all at once.
- Color-coded: green for OK, yellow for expiring soon (≤7 days), red for expired.

### [05] ACCOUNT LIMIT

- Pick a user and set maximum simultaneous connections (e.g. 1, 2, 5).
- Stored in `users.db` (single source of truth) and used by the manager's connection logic.

### [07] MONITOR USERS

- Live table of users with: status (🟢 active, 🟡 idle, 🔴 inactive, ⚪ never), connections (NOW/MAX), session time, current traffic, last seen.
- **Expand mode** (`[e]` key): Shows individual connections for each active user with per-connection traffic and time.
- **Details view** (`[d]` key): Shows total traffic, remaining days, and passwords.
- **Filter** (`[f]` key): Cycle through all / active / expiring≤7d / expired / never.
- **Sort** (`[s]` key): Cycle through username / last_seen / bandwidth / total_time.
- Auto-refreshes periodically (configurable, default: 10 seconds in monitor, 30 seconds in main menu).
- Press Enter to return to the menu.

### [08] SPEEDTEST

- Runs **speedtest-cli** and shows ping, download, and upload.
- If `speedtest-cli` is missing, the menu will try to install it (pip or apt) and show a short message. Press Enter to return.

### [09] VPS TRAFFIC

- Starts **nload** to show live network traffic. Exit with Ctrl+C.

### [10] VPS INFO

- Shows hostname, CPU, RAM, disk, network, and similar system info.

### [11] RESTART SERVICES

- Restarts SSH (and any other managed services) so config changes take effect.

### [12] REBOOT SYSTEM

- Reboots the server after confirmation.

### [13] SERVER SETTINGS

A submenu for server configuration:

| Option | Feature |
|--------|---------|
| **1** | Change root password |
| **2** | Datetime & timezone |
| **3** | Keyboard layout |
| **4** | Server name (hostname) |
| **5** | Privacy (IP & banner logging for sessions) |
| **6** | Auto-refresh interval (5-300 seconds) |
| **0** | Back |
| **00** | Exit |

### [14] REMOVE SCRIPT ⚠️

- Uninstalls the manager: removes `/bin/menu`, modules, and related files after you confirm (including typing "DELETE").

### [15] CONNECTIONS

- Opens the **Connections** submenu.
- From here you can access **SSH Multi-Port Setup** (add/remove SSH ports, quick multi-port setup, verify).  
  See [SSH Multi-Port Setup](SSH-MULTIPORT.md) for how it works and how it interacts with UFW.
- Other options: Squid proxy, Dropbear, OpenVPN, SOCKS proxy, SSL tunnel, SSLH multiplexer.

### [16] BANNER

- Set the text shown before SSH login (e.g. "SSHPLUS MANAGER - IP: x.x.x.x").
- Saved to `/etc/banner` and used by `sshd` via `Banner /etc/banner`.

### [17] BACKUP

- Backs up user/manager-related data (e.g. user list, limits) so you can restore later.

### [18] AUTORUN

- Enables or disables running the menu automatically when you log in (via `/etc/profile`).

### [19] UPDATE SCRIPT

- Compares installed version with the repository.
- If newer, offers to download and replace menu and modules from the repo.  
  Repository URL is taken from `/etc/SSHPlus/repo_url` if set, otherwise the default GitHub URL.

---

## Files and paths (reference)

| Path | Purpose |
|------|---------|
| `/bin/menu` | Main menu script |
| `/etc/SSHPlus/` | Config, colors, db, optional open.py/proxy.py |
| `/etc/SSHPlus/version` | Installed version (for update check) |
| `/etc/SSHPlus/repo_url` | Optional custom repo URL for updates |
| `/etc/SSHPlus/refresh_interval` | Auto-refresh interval in seconds |
| `/etc/SSHPlus/privacy.conf` | Privacy settings for session logging |
| `$HOME/users.db` | **Single source of truth**: user records (9 space-separated fields per user) |
| `$HOME/sessions.log` | Append-only session audit log (one line per completed session) |
| `/etc/IP` | Cached server IP (used in banner and "Create user" output) |
| `/etc/banner` | SSH login banner text |

### users.db format (column meanings)

The file has **no header** by default on older installs. New installs get a comment header line. Each data line has exactly **9 space-separated columns**:

| Column | Meaning |
|--------|---------|
| 1 | **username** — login name |
| 2 | **connection_limit** — max simultaneous connections (number) |
| 3 | **expiration_date** — account expiry (YYYY-MM-DD or `never`) |
| 4 | **registration_date** — when user was created (YYYY-MM-DD) |
| 5 | **total_upload** — total upload bytes (number) |
| 6 | **total_download** — total download bytes (number) |
| 7 | **last_connection_traffic** — bytes from last session (number) |
| 8 | **latest_connection_date** — last seen (ISO datetime or `never`) |
| 9 | **password** — plain text password (may contain spaces) |

To add a header line to an existing file, prepend:

```
# username connection_limit expiration_date registration_date total_upload total_download last_connection_traffic latest_connection_date password
```

---

## More documentation

- [TROUBLESHOOTING.md](TROUBLESHOOTING.md) — common problems and fixes.
- [SSH-MULTIPORT.md](SSH-MULTIPORT.md) — SSH multi-port setup and UFW.
