#!/bin/bash
set -e

DEB_FILE="AVEVA-Adapter-Configuration-Utility-1.0.0-x64_.deb"

echo "=== AVEVA Adapter Configuration Utility Installer ==="

# 1. Ensure root/sudo privileges
if [ "$EUID" -ne 0 ]; then
  echo "Error: Please run this script with sudo or as root."
  exit 1
fi

# 2. Find the .deb package
if [ ! -f "$DEB_FILE" ]; then
    # Look for any matching pattern in current directory
    FOUND_DEB=$(ls AVEVA-Adapter-Configuration-Utility*.deb 2>/dev/null | head -n 1)
    if [ -n "$FOUND_DEB" ]; then
        DEB_FILE="$FOUND_DEB"
    else
        echo "Error: Could not find '$DEB_FILE' in $(pwd)."
        echo "Please place this script in the same directory as your .deb package."
        exit 1
    fi
fi
echo "Using package: $DEB_FILE"

# 3. Clean up broken Microsoft APT repository if present (fixes Debian 13/Trixie SHA1 error)
if [ -f /etc/apt/sources.list.d/microsoft-prod.list ]; then
    echo "Removing legacy Microsoft APT repo to avoid GPG/SHA1 conflicts..."
    rm -f /etc/apt/sources.list.d/microsoft-prod.list
fi

# 4. Install system prerequisites
echo "Installing prerequisites (curl, wget, python3)..."
apt-get update -qq
apt-get install -y -qq curl wget python3 ca-certificates

# 5. Install ASP.NET Core 10.0 system-wide
echo "Installing ASP.NET Core 10.0 Runtime to /usr/share/dotnet..."
curl -sSL https://dot.net/v1/dotnet-install.sh | bash /dev/stdin \
    --channel 10.0 \
    --runtime aspnetcore \
    --install-dir /usr/share/dotnet

# 6. Symlink dotnet binary to system PATH (required for systemd services)
ln -sf /usr/share/dotnet/dotnet /usr/bin/dotnet

# 7. Add DOTNET_ROOT to /etc/environment for all system sessions if missing
if ! grep -q "DOTNET_ROOT" /etc/environment; then
    echo 'DOTNET_ROOT="/usr/share/dotnet"' >> /etc/environment
fi

export DOTNET_ROOT="/usr/share/dotnet"
export PATH="$PATH:/usr/share/dotnet"

echo "System-wide .NET configuration verified:"
/usr/bin/dotnet --list-runtimes

# 8. Install the AVEVA ACU .deb package
echo "Installing AVEVA ACU package ($DEB_FILE)..."
apt-get install -y ./"$DEB_FILE"

# 9. Service health check & recovery
echo "Verifying systemd service status..."
sleep 2

if ! systemctl is-active --quiet aveva.adapter.config.utility.service; then
    echo "Service not active yet. Resetting failed state and restarting..."
    systemctl reset-failed aveva.adapter.config.utility.service || true
    systemctl restart aveva.adapter.config.utility.service
fi

echo "=========================================================="
echo " Installation Complete!"
echo " Service Status: $(systemctl is-active aveva.adapter.config.utility.service)"
echo " ACU Endpoint:   http://localhost:5800"
echo "=========================================================="
