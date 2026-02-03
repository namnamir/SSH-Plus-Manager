**Language / زبان:** [English](SSH-MULTIPORT.md) | [فارسی](SSH-MULTIPORT.fa.md)

# SSH Multi-Port Setup (systemd + UFW)

**This setup is already implemented in SSH Plus Manager.** The script configures OpenSSH, systemd socket activation, and UFW for you. Use **menu** → **[15] CONNECTIONS** → **SSH Multi-Port Setup** to add/remove ports, run a quick multi-port setup, or verify the configuration—no need to edit files by hand unless you prefer to.

This document explains **how it works** and how to do it manually if needed: **OpenSSH** listening on **multiple ports** via **systemd socket activation**, with **UFW** controlling which ports are allowed. It matches the behavior of the built-in **SSH Multi-Port Setup** in the menu.

Tested on modern Debian/Ubuntu systems using **ssh.socket**.

Use cases:

- SSH over restrictive networks (e.g. 443, 80)
- Extra fallback ports (e.g. 3398, 8080, 8443)
- SSH-based tunneling or management on non-standard ports

---
1. Run **menu**.
2. Choose **[08] CONNECTIONS**.
3. Open **SSH Multi-Port Setup** (or the option that runs the multiport script).
4. Use:
   - **Add port** — add one port (sshd + socket + UFW).
   - **Remove port** — remove one port from config and UFW.
   - **Setup multiple ports (quick)** — enter a comma‑separated list (e.g. `22, 3398, 443, 80, 8080`); the script trims spaces and adds only ports not already in the config.
   - **Verify setup** — check listening ports and configuration.

The script expects **UFW** to be installed; it will refuse to continue if UFW is missing, so ports are not left unguarded.

For more troubleshooting (e.g. “Configuration validation failed”, lockout), see [TROUBLESHOOTING.md](TROUBLESHOOTING.md).
