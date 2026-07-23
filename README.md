# Hysteria 2 Auto Installer

A one-command installer for deploying a **Hysteria 2 VPN server** on a fresh **Ubuntu 24.04 VPS**.

The installer automatically:

- Installs the latest Hysteria 2
- Installs Certbot
- Obtains a free Let's Encrypt SSL certificate
- Creates the Hysteria server configuration
- Enables and starts the Hysteria service
- Disables `systemd-resolved` to free UDP port **53**
- Verifies the server is running
- Generates a Hysteria 2 Import URI
- Displays a QR Code for easy client import

---

# Requirements

Before running the installer you need:

- Ubuntu 24.04 VPS
- Root or sudo access
- A domain name
- Ports **80/TCP** and **53/UDP** open in your VPS firewall or cloud provider (AWS Security Groups, Azure NSGs, etc.)

---

# Domain Setup (IMPORTANT)

Before running the installer, your domain **MUST** already point to your VPS.

Example domain:

```text
vpn.example.com
```

or

```text
server.example.com
```

or

```text
saserver.smarty.kdns.fr
```

Create an **A Record** in your DNS provider.

Example:

| Type | Host | Points To |
|------|------|-----------|
| A | vpn | YOUR_PUBLIC_IP |

Example:

```text
vpn.example.com
        │
        ▼
203.0.113.10
```

Wait a few minutes for DNS propagation.

Verify that your domain resolves correctly:

```bash
ping vpn.example.com
```

or

```bash
dig +short vpn.example.com
```

Both commands should return your VPS public IP address.

If they do not, **do not run the installer yet**.

Let's Encrypt cannot issue a certificate until your domain points to the VPS.

---

# Installation

Run using **wget**:

```bash
wget -qO- https://raw.githubusercontent.com/clintonpaul19/hysteria-installer/main/install.sh | sudo bash
```

or using **curl**:

```bash
curl -fsSL https://raw.githubusercontent.com/clintonpaul19/hysteria-installer/main/install.sh | sudo bash
```

---

# Installer Prompts

## Domain

Enter the domain that points to your VPS.

Example:

```text
saserver.smarty.kdns.fr
```

## Email

Enter your email address.

This is only used by Let's Encrypt to send certificate expiry notifications.

Example:

```text
admin@example.com
```

## Password

Choose any password you want.

This password will be required when importing or connecting to your VPN.

Example:

```text
MyStrongPassword123
```

---

# After Installation

The installer displays:

- Server
- Port
- Password
- SNI
- Import URI
- QR Code

Example output:

```text
Server   : saserver.smarty.kdns.fr
Port     : 53
Password : MyStrongPassword123

Import URI:

hysteria2://MyStrongPassword123@saserver.smarty.kdns.fr:53/?sni=saserver.smarty.kdns.fr&insecure=0#saserver.smarty.kdns.fr
```

Simply copy the Import URI into any Hysteria 2 compatible client.

---

# Supported Clients

- Hiddify
- NekoBox
- Nekoray
- v2rayN
- v2rayNG
- sing-box
- Any client that supports Hysteria 2

---

# Notes

- Designed for **Ubuntu 24.04**.
- Your VPS must allow **UDP Port 53**.
- Your domain **must** point to your VPS before running the installer.
- SSL certificates are automatically issued by Let's Encrypt.
- The installer will display a ready-to-use Hysteria 2 Import URI after installation.

---

# License

This project is provided **as-is**, without warranty.
