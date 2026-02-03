**Language / زبان:** [English](README.md) | [فارسی](README.fa.md)

<p align="center"><img src="logo.png" alt="SSH Plus Manager" width="280"></p>

# SSH Plus Manager

A terminal-based manager for SSH users and network services on Linux servers. Create and remove users, set passwords and expiration dates, limit simultaneous connections, monitor traffic, and manage OpenSSH, Dropbear, OpenVPN, Squid, SOCKS, SSL tunnel, and SSLH — all from one menu.

---

## Features

### User management

| Feature | Description |
|--------|-------------|
| **Create user** | Add SSH users with password, expiration date, and connection limit. Supports OpenVPN (.ovpn) generation. |
| **Remove user** | Remove one user or all users; removes the user's record from the centralized `users.db` and cleans OpenVPN certs. |
| **Change password** | Change a user's password via the service (`chpasswd`) and keep `users.db` in sync. |
| **Expiration manager** | View all users with expiration status, change expiration dates, list/remove expired users — all in one screen. |
| **Account limit** | Set max simultaneous connections per user (stored in `users.db`). |

### Monitoring and traffic

| Feature | Description |
|--------|-------------|
| **Monitor users** | Live table: online/offline/expired/expiring, connections, session time, down/up traffic, validity, last seen. Expand to see individual connections. Auto-refresh interval configurable. |
| **Speedtest** | Run download/upload speed test (uses `speedtest-cli`). |
| **VPS traffic** | Live network traffic view with `nload` (Ctrl+C to exit). |
| **VPS info** | Hostname, IPv4/IPv6, OS, kernel, uptime, RAM/CPU/disk usage, listening ports, SSH/Dropbear/OpenVPN connection counts. |

### Connection modes and services

| Feature | Description |
|--------|-------------|
| **Connections** | Submenu: OpenSSH (multi-port), Squid proxy, Dropbear, OpenVPN, SOCKS proxy (SSH + OpenVPN), SSL tunnel (stunnel), SSLH multiplexer. Install, configure ports, and manage each service. |
| **SSH multi-port** | Add/remove SSH ports via `sshd_config` and systemd socket; UFW rules applied. |

### System and maintenance

| Feature | Description |
|--------|-------------|
| **Restart services** | Restart SSH (and related) services. |
| **Reboot system** | Reboot the server (with confirmation). |
| **Server settings** | Change root password, timezone, keyboard layout, server name, privacy/logging settings, and auto-refresh interval. |
| **Banner** | Set SSH login banner (e.g. IP, welcome text; uses `figlet`). |
| **Backup** | Back up user list and manager-related data. |

### Manager lifecycle

| Feature | Description |
|--------|-------------|
| **Auto run** | Toggle "run `menu` on login" (add/remove from `/etc/profile`). |
| **Update script** | Check repo version and update all manager files from the repository. |
| **Remove script** | Uninstall manager scripts (with double confirmation). |

---

## Installation

Run **one** of these on your server as **root** (use the first if you have `curl`, the second if you have `wget`):

```bash
# With curl:
bash <(curl -Ls https://raw.githubusercontent.com/namnamir/SSH-Plus-Manager/main/install.sh)
```

```bash
# With wget:
wget -qO- https://raw.githubusercontent.com/namnamir/SSH-Plus-Manager/main/install.sh | bash
```

**Requirements:** Root, `curl` or `wget`, and a Debian/Ubuntu-style system. The installer installs dependencies (e.g. `wget`, `curl`, `screen`, `nano`, `python3`, `nload`, `figlet`, `speedtest-cli`).

---

## Usage

After installation, run:

```bash
menu
```

Or the short alias:

```bash
h
```

In submenus, **0** = back, **00** = exit.

---

## Project structure

```
SSH-Plus-Manager/
├── install.sh          # One-line installer: deps, download Install/list, run bootstrap
├── version             # Version string (e.g. 1.0.0) for update checks
├── Install/
│   └── list            # Bootstrap: download Modules, dirs, hosts, crontab, version
├── Modules/
│   ├── menu            # Main loop; sources colors, shows dashboard, dispatches to scripts
│   ├── colors          # UI: msg_ok/msg_err/msg_warn/msg_info, banner_info/banner_danger, color_echo, menu_option, c(), hr, kv
│   ├── db              # Centralized user database helpers
│   ├── createuser      # [01] Create SSH user + optional OpenVPN
│   ├── removeuser      # [02] Remove one or all users
│   ├── changepassword  # [03] Change user password
│   ├── expirationmanager # [04] Manage user expirations (view, change, remove expired)
│   ├── changelimit     # [05] Change connection limit per user
│   ├── sshmonitor      # [07] Live user/connection/traffic monitor
│   ├── speedtest       # [08] speedtest-cli
│   ├── vpstraffic      # [09] nload
│   ├── vpsinfo         # [10] System info
│   ├── restartservices # [11] Restart SSH
│   ├── rebootsystem    # [12] Reboot
│   ├── serversettings  # [13] Root password, timezone, keyboard, server name, privacy, refresh
│   ├── removescript    # [14] Uninstall
│   ├── connections     # [15] OpenSSH/Squid/Dropbear/OpenVPN/SOCKS/SSL/SSLH
│   ├── multiport       # Called from connections: SSH multi-port (sshd + systemd + UFW)
│   ├── bannersetup     # [16] SSH banner
│   ├── userbackup      # [17] Backup
│   ├── autorun         # [18] Menu on login
│   ├── updatescript    # [19] Update from repo
│   ├── open.py         # SOCKS over OpenVPN (used by connections)
│   └── proxy.py        # SOCKS over SSH (used by connections)
├── docs/               # USAGE, TROUBLESHOOTING, SSH-MULTIPORT (+ Persian)
└── README.md
```

Installed layout (after `install.sh` + `Install/list`):

- Scripts in `/bin/` (e.g. `/bin/menu`, `/bin/createuser`).
- `colors`, `db`, `open.py`, `proxy.py` in `/etc/SSHPlus/`.
- User DB (single source of truth): `$HOME/users.db` (9 fields per user).
- Session audit log (append-only): `$HOME/sessions.log`.

---

## Documentation

- **[docs/USAGE.md](docs/USAGE.md)** — All menu options and behavior.
- **[docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md)** — Common issues and fixes.
- **[docs/SSH-MULTIPORT.md](docs/SSH-MULTIPORT.md)** — SSH multi-port setup (systemd + UFW).

**فارسی:** [README.fa.md](README.fa.md) · [راهنما](docs/USAGE.fa.md) · [رفع مشکلات](docs/TROUBLESHOOTING.fa.md) · [چند پورت SSH](docs/SSH-MULTIPORT.fa.md)

---

## Contributing

Contributions are welcome. Follow the conventions below so the project stays consistent and easy to maintain.

### Conventions

1. **Scripts**
   - Bash: `#!/bin/bash`, use `[[ ]]` and quoted variables (`"$var"`). Prefer `print_header " Title "` and `color_echo` / `menu_option` from `colors` instead of raw `tput` or `\033`.
   - Python: Use Python 3; `print()` and `bytes` for socket I/O where appropriate.

2. **Module layout**
   - First line: shebang.
   - Second block: short comment `# scriptname – one-line description (menu option [NN] LABEL).`
   - Then: load `colors` from `/etc/SSHPlus/colors`, `/bin/colors`, or `$(dirname "$0")/colors`.
   - Use `msg_err`, `msg_ok`, `msg_warn`, `msg_info` for feedback.

3. **User lists**
   - Build list with `awk -F: '$3>=1000 {print $1}' /etc/passwd` (and filter e.g. `grep -v nobody`). Use `idx` and display index `i` with `[[ $idx -le 9 ]] && i=0$idx || i=$idx`. Build `_userPass` as `_userPass+="\n${i}:${username}"`. Resolve option to user with:  
     `awk -v o="$option" -F: 'NF>=2 && $1+0==o+0 {print $2; exit}'` so that typing `1` or `01` both select the first user.

4. **Paths**
   - User DB: `$HOME/users.db`. Sessions: `$HOME/sessions.log`. Version: `/etc/SSHPlus/version` or `/bin/version`.

5. **Exit codes**
   - `0` = back to menu, `99` = exit entirely (menu handles this and exits).

### Adding a new menu option

1. Add the script under `Modules/` with the header and color loading as above.
2. In `Modules/menu`, add a line in the menu block (e.g. `[20] MY FEATURE`) and a `case)` that runs your script (and handles exit 99 if needed).
3. In `Install/list`, add the script name to the `_mdls` array (or equivalent) so it is downloaded and installed.
4. In `Modules/updatescript`, add the script to the `for spec in ...` list so updates overwrite it.
5. Update `docs/USAGE.md` (and optionally Persian docs) with the new option.

### Before submitting

- Run your script on a test VM (e.g. Debian/Ubuntu as root).
- Prefer no extra dependencies; if you add one, document it and add it to `install.sh` dependency list if it must be installed for the feature to work.
- Keep changes minimal and consistent with existing style (no trailing whitespace, no `expr` where `(( ))` or `[[ ]]` is enough).

### Pull requests

- Describe what the change does and which menu option or file it affects.
- If you add a feature, mention it in README (features table) and/or docs/USAGE.md.

---

## License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.
