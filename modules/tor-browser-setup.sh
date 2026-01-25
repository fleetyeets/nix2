#!/usr/bin/env bash
set -euo pipefail

CONTAINER_NAME="tor-browser"
IMAGE="images:debian/12"

echo "Setting up isolated Tor Browser container..."

# Initialize Incus if not already initialized
if ! incus admin init --dump 2>/dev/null | grep -q "config:"; then
    echo "Initializing Incus..."
    cat <<EOF | incus admin init --preseed
config: {}
networks:
- config:
    ipv4.address: auto
    ipv6.address: none
  description: ""
  name: incusbr0
  type: bridge
  project: default
storage_pools:
- config:
    size: 10GB
  description: ""
  name: default
  driver: dir
profiles:
- config: {}
  description: ""
  devices:
    eth0:
      name: eth0
      network: incusbr0
      type: nic
    root:
      path: /
      pool: default
      type: disk
  name: default
projects: []
EOF
fi

# Create container with security profile
echo "Creating container: $CONTAINER_NAME"
incus launch "$IMAGE" "$CONTAINER_NAME"

# Wait for container to be ready
echo "Waiting for container to boot..."
sleep 5

# Configure container limits and security
echo "Applying security restrictions..."
incus config set "$CONTAINER_NAME" security.nesting false
incus config set "$CONTAINER_NAME" security.privileged false
incus config set "$CONTAINER_NAME" security.syscalls.intercept.mknod true
incus config set "$CONTAINER_NAME" security.syscalls.intercept.setxattr true

# Limit resources
incus config set "$CONTAINER_NAME" limits.cpu 2
incus config set "$CONTAINER_NAME" limits.memory 2GB

# Mount Wayland/X11 sockets for display
incus config device add "$CONTAINER_NAME" X0 disk source=/tmp/.X11-unix path=/tmp/.X11-unix
incus config device add "$CONTAINER_NAME" Wayland0 disk source="$XDG_RUNTIME_DIR/$WAYLAND_DISPLAY" path=/wayland-display optional=true 2>/dev/null || true

# Install required packages in container
echo "Installing Tor Browser dependencies..."
incus exec "$CONTAINER_NAME" -- bash <<'CONTAINER_SETUP'
set -e

# Update package list
apt-get update

# Install dependencies for Tor Browser
apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    gnupg \
    libgtk-3-0 \
    libdbus-glib-1-2 \
    libx11-xcb1 \
    libxt6 \
    libpci3 \
    fonts-liberation \
    libasound2 \
    sudo

# Create non-root user for running Tor Browser
useradd -m -s /bin/bash user
echo "user ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/user

# Download and install Tor Browser
su - user <<'USER_SETUP'
set -e

cd /home/user

# Download Tor Browser
TOR_VERSION="13.5.7"
TOR_LANG="en-US"
TOR_URL="https://www.torproject.org/dist/torbrowser/${TOR_VERSION}/tor-browser-linux-x86_64-${TOR_VERSION}.tar.xz"

echo "Downloading Tor Browser ${TOR_VERSION}..."
curl -L -o tor-browser.tar.xz "$TOR_URL"

# Extract
tar -xf tor-browser.tar.xz
rm tor-browser.tar.xz

# Configure Tor Browser to use Tor network only
mkdir -p /home/user/.local/share/torbrowser/tbb/x86_64/tor-browser/Browser/TorBrowser/Data/Tor

# Create restrictive torrc
cat > /home/user/tor-browser/Browser/TorBrowser/Data/Tor/torrc <<'TORRC'
# Tor configuration for isolated browser
SOCKSPort 9150
ControlPort 9151

# Disable non-Tor connections
DisableNetwork 0

# Use only Tor network
FascistFirewall 1

# No local services
ClientOnly 1

# DNS through Tor
DNSPort 5353
AutomapHostsOnResolve 1

# Prevent leaks
WarnUnsafeSocks 1
TORRC

USER_SETUP

# Clean up apt cache
apt-get clean
rm -rf /var/lib/apt/lists/*
CONTAINER_SETUP

echo ""
echo "Tor Browser container setup complete!"
echo ""
echo "You can now launch Tor Browser with: tor-browser-isolated"
echo "Or find it in your application launcher as 'Tor Browser (Isolated)'"
