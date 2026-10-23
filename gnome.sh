#!/bin/bash

set -e

##########################################################################################################
#
# Description:
# Minimal GNOME desktop + Flatpak and Distrobox installation script for openSUSE MicroOS.
# Installs ONLY the absolute core components of GNOME, Flatpak, and container utilities.
# Includes Adwaita fonts, file indexing (tracker3), Bluetooth, printing (CUPS), and Plymouth boot splash.
#
# Usage:
# After installing microos, log in and type:
# "bash <(curl -sL <URL_OF_THIS_SCRIPT>)"
#
##########################################################################################################

echo "==> 1. Installing core GNOME desktop environment, fonts, and container tools..."

# Perform the entire system setup, hardware services, and Plymouth configuration in a single clean transaction
sudo transactional-update -c run bash -c '
	zypper in -y --recommends \
		gnome-shell \
		gnome-session \
		gdm \
		gnome-control-center \
		gnome-console \
		nautilus \
		tracker3 \
		adwaita-fonts \
		bluez \
		gnome-bluetooth \
		cups \
		plymouth \
		plymouth-dracut \
		plymouth-scripts \
		gvfs \
		gvfs-backends \
		xdg-user-dirs \
		xdg-desktop-portal-gnome \
		xdg-desktop-portal-gtk \
		gnome-software \
		flatpak \
		distrobox \
		podman \
		NetworkManager \
		pipewire \
		wireplumber

	echo "==> Enabling system services (GDM, Bluetooth, CUPS)..."
	systemctl enable gdm.service
	systemctl enable bluetooth.service
	systemctl enable cups.service
	systemctl set-default graphical.target

	echo "==> Configuring Plymouth kernel cmdline (systemd-boot / BLS)..."
	mkdir -p /etc/kernel
	touch /etc/kernel/cmdline

	# Read the current cmdline flattened into a single line
	CMDLINE=$(tr -d "\n" < /etc/kernel/cmdline)

	# Append splash parameters only if not already present
	case "$CMDLINE" in
		*splash*) echo "==> splash already present in /etc/kernel/cmdline, leaving as-is." ;;
		*) echo "${CMDLINE} splash=silent quiet" > /etc/kernel/cmdline ;;
	esac

	echo "==> /etc/kernel/cmdline now contains:"
	cat /etc/kernel/cmdline

	echo "==> Regenerating initrd so the plymouth dracut module is included..."
	mkinitrd

	echo "==> Refreshing the BLS boot entries from /etc/kernel/cmdline..."
	sdbootutil update-all-entries || {
		echo "==> update-all-entries unavailable, falling back to remove/add cycle..."
		sdbootutil remove-all-kernels
		sdbootutil add-all-kernels
	}
'

echo "==> 2. Configuring Flatpak Flathub at USER level..."
# Executed in your current user space, outside the immutable root partition
flatpak remote-add --if-not-exists --user flathub https://flathub.org

echo "==> Basic installation completed!"
echo "==> Rebooting the system to enter the new GNOME desktop..."
sudo transactional-update reboot
