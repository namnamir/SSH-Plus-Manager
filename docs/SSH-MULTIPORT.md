**Language / زبان:** [English](SSH-MULTIPORT.md) | [فارسی](SSH-MULTIPORT.fa.md)

# SSH Multi-Port Setup (systemd + UFW)

**This setup is already implemented in SSH Plus Manager.** The script configures OpenSSH, systemd socket activation, and UFW for you. Use **menu** → **[08] CONNECTIONS** → **SSH Multi-Port Setup** to add/remove ports, run a quick multi-port setup, or verify the configuration—no need to edit files by hand unless you prefer to.

This document explains **how it works** and how to do it manually if needed: **OpenSSH** listening on **multiple ports** via **systemd socket activation**, with **UFW** controlling which ports are allowed. It matches the behavior of the built-in **SSH Multi-Port Setup** in the menu.

Tested on modern Debian/Ubuntu systems using **ssh.socket**.

Use cases:

- SSH over restrictive networks (e.g. 443, 80)
- Extra fallback ports (e.g. 3398, 8080, 8443)
- SSH-based tunneling or management on non-standard ports

---

## 1. Install SSH Plus Manager

SSH Plus Manager includes the multi-port tool. Install with:

```bash
# With curl:
bash <(curl -Ls https://raw.githubusercontent.com/namnamir/SSH-Plus-Manager/main/install.sh)

# Or with wget:
wget -qO- https://raw.githubusercontent.com/namnamir/SSH-Plus-Manager/main/install.sh | bash
```

Then run **menu** and go to **[08] CONNECTIONS** → **SSH Multi-Port Setup**.

> **Important:** Multi-port setup requires **UFW**. If UFW is not installed, the script will not continue. Install it with:  
> `apt install -y ufw`

---

## 2. UFW ports opened by the installer and by multi-port

When UFW is present, the **installer** allows:

- 443, 80, 3128 (Squid), 8799, 8080

For **SSH multi-port**, you must allow every port SSH will listen on. Typical set:

```bash
ufw allow 22/tcp
ufw allow 443/tcp
ufw allow 80/tcp
ufw allow 8080/tcp
ufw allow 8443/tcp
ufw allow 993/tcp
ufw allow 995/tcp
ufw allow 3398/tcp
ufw allow 53/tcp
```

Reload:

```bash
ufw reload
```

---

## 3. Configure SSH allowed ports (`sshd_config`)

Edit the SSH daemon config:

```bash
nano /etc/ssh/sshd_config
```

Add **all desired ports** near the top (before any `Match` blocks):

```conf
Port 22
Port 3398
Port 443
Port 80
Port 8080
Port 8443
Port 53
Port 993
Port 995
```

Check that the config is valid:

```bash
sshd -t
```

No output means it’s OK.

---

## 4. Configure systemd socket activation (`ssh.socket`)

With socket activation, **ports must be listed in `ssh.socket`** as well.

### 4.1 Override directory

```bash
mkdir -p /etc/systemd/system/ssh.socket.d
```

### 4.2 Socket override

```bash
nano /etc/systemd/system/ssh.socket.d/override.conf
```

Example for the ports above:

```ini
[Socket]
ListenStream=
ListenStream=0.0.0.0:22
ListenStream=[::]:22

ListenStream=0.0.0.0:3398
ListenStream=[::]:3398

ListenStream=0.0.0.0:443
ListenStream=[::]:443

ListenStream=0.0.0.0:80
ListenStream=[::]:80

ListenStream=0.0.0.0:8080
ListenStream=[::]:8080

ListenStream=0.0.0.0:8443
ListenStream=[::]:8443

ListenStream=0.0.0.0:53
ListenStream=[::]:53

ListenStream=0.0.0.0:993
ListenStream=[::]:993

ListenStream=0.0.0.0:995
ListenStream=[::]:995
```

Notes:

- The empty `ListenStream=` clears default listeners before adding new ones.
- Do not duplicate a port.
- Both IPv4 (`0.0.0.0`) and IPv6 (`[::]`) are set explicitly if you use both.

---

## 5. Reload systemd (required)

After editing the socket (or sshd_config):

```bash
systemctl daemon-reload
systemctl restart ssh.socket
```

Optional but recommended:

```bash
systemctl restart ssh.service
```

---

## 6. Configure UFW

Enable UFW if needed:

```bash
ufw enable
```

Allow the SSH ports you use, for example:

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
```

Check:

```bash
ufw status verbose
```

---

## 7. Verification

### Listening ports

```bash
ss -ltnp | grep ssh
```

All chosen ports should appear as `LISTEN`.

### Socket status

```bash
systemctl status ssh.socket
```

Should show something like:

```
Active: active (running)
```

### Ports accepted by sshd

```bash
sshd -T | grep '^port'
```

---

## 8. Client connection examples

```bash
ssh -p 22   user@SERVER_IP
ssh -p 3398 user@SERVER_IP
ssh -p 443  user@SERVER_IP
ssh -p 8080 user@SERVER_IP
```

---

## 9. Common pitfalls

### Forgetting `systemctl daemon-reload`

If you see:

```
Warning: unit file or drop-ins changed on disk
```

run:

```bash
systemctl daemon-reload
```

then restart `ssh.socket` (and optionally `ssh.service`).

### Duplicate ListenStream or Port

Duplicate ports can cause:

```
Address already in use
```

Each port must appear only once in the socket override and once in `sshd_config`.

### Adding a port that’s already in config

The multi-port script skips ports that are already in `sshd_config`. If you add the same port again by hand, you can get “Address already in use” or invalid config. Always keep one line per port.

### Editing `/usr/lib/systemd/system/ssh.socket` directly

Do not edit the vendor file. Use only the drop-in:

`/etc/systemd/system/ssh.socket.d/override.conf`

### UFW not allowing the new port

After adding a port in sshd and systemd, allow it in UFW:

```bash
ufw allow PORT/tcp
ufw reload
```

---

## 10. Security recommendations

Example `sshd_config` hardening:

```conf
PermitRootLogin prohibit-password
PasswordAuthentication no
PubkeyAuthentication yes
MaxAuthTries 3
LoginGraceTime 20
```

Then:

```bash
systemctl restart ssh.service
```

(Or use the menu **[15] RESTART SERVICES**.)

---

## 11. How the three layers fit together

| Component    | Role |
|-------------|------|
| `sshd_config` | Which ports SSH will accept connections on |
| `ssh.socket`  | Which ports systemd actually opens |
| UFW           | Which ports are allowed through the firewall |

**All three must match.** If a port is in `sshd_config` but not in the socket, it won’t listen. If it listens but UFW blocks it, clients can’t connect.

---

## 12. Using the menu instead of doing it by hand

You can do the same from the manager:

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
