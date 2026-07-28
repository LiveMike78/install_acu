# AVEVA Adapter Configuration Utility (ACU) Installer

An automated, cross-distro installer script for the **AVEVA Adapter Configuration Utility (ACU)** on Linux systems. 

This script streamlines the deployment process by automatically resolving prerequisites, installing the **ASP.NET Core 10.0** runtime system-wide, and configuring systemd services across various Linux distributions without hitting package manager GPG key issues.

---

## 🚀 Features

* **Cross-Distro Compatibility:** Works on Debian (including Debian 13 / Trixie), Ubuntu, and Raspberry Pi OS (x86_64 and ARM64).
* **Bypasses APT GPG / SHA-1 Failures:** Avoids `sqv` verification errors on newer Debian/Ubuntu releases by fetching `.NET` runtimes directly via official Microsoft scripts.
* **System-Wide `.NET` Integration:** Installs ASP.NET Core 10.0 to `/usr/share/dotnet` and creates system-wide symlinks so systemd services can discover the runtime without user environment dependencies.
* **Automated Recovery:** Resets failed systemd unit states and verifies ACU service health post-install.

---

## 📋 Prerequisites

* A Linux distribution (Debian 12/13, Ubuntu 22.04+, Raspberry Pi OS, etc.).
* `sudo` / root privileges.
* The official AVEVA ACU `.deb` installer package placed in the repository folder.

---

## 📦 Quick Start

### 1. Clone the Repository
```bash
git clone https://github.com/LiveMike78/install_acu.git
cd install_acu
