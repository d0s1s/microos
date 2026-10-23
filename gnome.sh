#!/bin/bash

set -e

##########################################################################################################
#
# Description:
# Minimal GNOME desktop + Flatpak and Distrobox installation script for openSUSE MicroOS.
# Installs ONLY the absolute core components of GNOME, Flatpak, and container utilities.
# Includes Adwaita fonts, file indexing (tracker3), Bluetooth, and printing support (CUPS).
#
# Usage:
# After installing microos, log in and type:
# "bash <(curl -sL https://github.com/d0s1s/microos/blob/main/gnome.sh)"
#
##########################################################################################################

echo "==> 1. Installing core GNOME desktop environment, fonts, and container tools..."

# Perform the desktop core, container tools, and hardware services installation in a single clean transaction
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
'

echo "==> 2. Configuring Flatpak Flathub at USER level..."
# Executed in your current user space, outside the immutable root partition
flatpak remote-add --if-not-exists --user flathub https://flathub.org

echo "==> Basic installation completed!"
echo "==> Rebooting the system to enter the new GNOME desktop..."
sudo transactional-update reboot
