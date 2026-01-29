**Language / زبان:** [English](TROUBLESHOOTING.md) | [فارسی](TROUBLESHOOTING.fa.md)

# SSH Plus Manager — Troubleshooting

Common issues and what to do.

---

## Installation and first run

### `menu: command not found` after install

The installer puts the menu at `/bin/menu`. If your `PATH` doesn’t include `/bin`, run:

```bash
/bin/menu
```

Or add `/bin` to your PATH, or create an alias:

```bash
alias menu='/bin/menu'
```

### `curl: command not found` or `wget: command not found` when installing

The one-line installer needs either `curl` or `wget`. Install one first:

- **Debian/Ubuntu:**  
  `apt update && apt install -y curl`  
  or  
  `apt install -y wget`
- **CentOS/RHEL:**  
  `yum install -y curl`  
  or  
  `yum install -y wget`

Then run the install command again (curl or wget, depending on what you installed).

### Script says “Could not fetch version file” or version shows as `v0`

- The installer needs internet to download the **version** file from the repo. If the fetch fails, version stays 0 and update checks won’t work properly.
- Ensure the server can reach `https://raw.githubusercontent.com` (and that you have `curl` or `wget`).  
  If you’re behind a proxy or firewall, fix that first.
- After a successful install or update, version is stored in `/etc/SSHPlus/version` and `/bin/version`. You can set it manually if needed, e.g.:  
  `echo "1.0.8" | sudo tee /etc/SSHPlus/version /bin/version`

---

## IP and banner

### IPv4 or IP is blank in the menu or in “SSH ACCOUNT CREATED”

- The manager uses `/etc/IP` first. That file is filled by the installer (or by **Install/list**) using a public “what is my IP” service.
- If it’s empty or wrong:
  - Ensure the server has outbound internet and can reach e.g. `ipv4.icanhazip.com` or `whatismyip.akamai.com`.
  - Ensure **wget** or **curl** is installed (the installer should install them). If not:  
    `apt install -y wget curl`
- You can set `/etc/IP` manually:  
  `echo "YOUR.SERVER.IP" | sudo tee /etc/IP`

### Banner or “Create user” screen shows “IP:” with nothing after it

Same as above: the script reads `/etc/IP`. Populate it as in the previous section.

---

## Speedtest [09]

### [09] SPEEDTEST exits immediately or shows an error

- **[09]** uses **speedtest-cli**. If it’s missing, the menu will try to install it (pip or apt) and then ask you to press Enter. If install failed, it will suggest:  
  `pip3 install speedtest-cli`  
  or  
  `apt install speedtest-cli`
- Install as root if needed:  
  `pip3 install speedtest-cli`  
  or  
  `apt install -y speedtest-cli`
- If speedtest-cli runs but shows no result, the server may not be able to reach speedtest.net. Check outbound connectivity and try again.

### Speedtest shows “Error output” or “Check connectivity to speedtest.net”

- The script is showing speedtest-cli’s own error. Typical causes:
  - Firewall or network blocking access to speedtest.net.
  - No outbound internet from the VPS.
  - Rate limiting or temporary failure of the service.  
  Try again later or from another network.

---

## Users and limits

### “Create user” or “Remove user” doesn’t show the user I expect

- User lists are built from current system accounts and the centralized `$HOME/users.db`. If you deleted a user at the system level (e.g. `userdel`), they may still have a record in `$HOME/users.db` until the manager updates it (e.g. via “Remove user” / “Remove expired users”).

### Password or limit change doesn’t seem to apply

- For **password**: the service uses `chpasswd` (non-interactive) and then updates `$HOME/users.db`. Make sure you’re not looking at an old session; try logging in again in a new terminal.
- For **connection limit**: the limit is stored in `$HOME/users.db` (single source of truth) and applied by the manager logic.

---

## SSH, ports, and firewall (multi-port / UFW)

### I added SSH ports in the menu but still can’t connect

- **UFW:** If UFW is enabled, each SSH port must be allowed. The multi-port setup expects UFW; if UFW isn’t installed, the script will not continue.
- **Ports in three places:** For multiple SSH ports to work you need:
  1. **sshd_config** — `Port` lines for every port.
  2. **systemd** — `ssh.socket` (or equivalent) listening on those ports (e.g. via `ListenStream` in an override).
  3. **UFW** — `ufw allow <port>/tcp` for each port.

If any of these is missing or wrong, that port won’t work. See **[SSH-MULTIPORT.md](SSH-MULTIPORT.md)** for the full procedure.

### “Configuration validation failed” or “Invalid SSH configuration” when adding ports

- The multi-port script runs `sshd -t` (or similar) to check config. If that fails, it may revert changes.
- Typical causes:
  - **Port already in use** — don’t add a port that’s already in `sshd_config` or in the socket unit.
  - **Duplicate Port lines** — each port only once.
  - **Missing dirs** — e.g. “Missing privilege separation directory: /run/sshd”. Create it if needed:  
    `mkdir -p /run/sshd && chmod 0755 /run/sshd`
- Always fix according to the exact error message, then run `sshd -t` yourself. When it prints nothing, config is valid.

### After changing SSH ports, I’m locked out

- If you changed the main SSH port and didn’t allow it in the firewall, or closed the old port before confirming the new one works, you can lose access.
- **Prevention:** Use the multi-port *add* flow so SSH keeps listening on 22 (or your current port) and *add* new ports. Allow the new port in UFW before testing. Only remove or change the old port when you’re sure the new one works.
- **Recovery:** Use the provider’s “Console” or “Recovery” (VNC/out-of-band) to log in and fix `sshd_config`, systemd, and UFW, or restore from backup.

---

## Updates and dependencies

### “Current version: v0” and “Latest version: v0” in [18] UPDATE SCRIPT

- Version is read from `/etc/SSHPlus/version` or `/bin/version`, and “latest” is fetched from the repo’s **version** file.
- If both are 0, either:
  - The installed version files are empty or missing, or
  - The server can’t reach the repo (e.g. `raw.githubusercontent.com`).
- Fix: ensure outbound HTTPS works and **wget**/ **curl** are installed. Then run **[18]** again, or set version manually as under “Script says Could not fetch version file” above.

### “Could not install: …” during install

- The installer uses `apt install` for dependencies. If a package fails (not found or error), it’s listed at the end.
- Install them yourself, e.g.:  
  `apt update && apt install -y wget curl bc screen nano unzip zip lsof net-tools dos2unix nload jq figlet python3 python3-pip`
- **speedtest-cli** is tried via apt and then via pip. If both fail, install manually:  
  `pip3 install speedtest-cli`

### Color or “command not found” errors for `get_color_code`, `banner_info`, etc.

- Those come from the **colors** helper. The menu loads it from `/etc/SSHPlus/colors` or `/bin/colors`.
- If you run the menu from a copy that wasn’t installed by the installer (e.g. only partial files under `/bin`), colors may be missing.  
  Re-run the installer or **[18] UPDATE SCRIPT** so all modules (including `colors`) are placed in `/bin` or `/etc/SSHPlus` as intended.

---

## SSH Multi-Port and UFW (reference)

For detailed steps on:

- Allowing SSH ports in UFW (e.g. 22, 3398, 443, 80, 8080, 8443, 53, 993, 995)
- Editing `sshd_config` and systemd `ssh.socket`
- Reloading systemd and checking that SSH listens on the right ports

see **[SSH-MULTIPORT.md](SSH-MULTIPORT.md)**.

The installer, when UFW is present, allows certain ports (e.g. 443, 80, 3128, 8799, 8080). For **multi-port SSH** you must ensure every SSH port you use is explicitly allowed, e.g.:

```bash
ufw allow 22/tcp
ufw allow 3398/tcp
ufw allow 443/tcp
ufw allow 80/tcp
ufw allow 8080/tcp
ufw allow 8443/tcp
ufw allow 53/tcp
ufw allow 993/tcp
ufw allow 995/tcp
ufw reload
```

---

## Getting more help

- **Repository:** [namnamir/SSH-Plus-Manager](https://github.com/namnamir/SSH-Plus-Manager)
- **Usage and options:** [USAGE.md](USAGE.md)
- **SSH multi-port and UFW:** [SSH-MULTIPORT.md](SSH-MULTIPORT.md)
