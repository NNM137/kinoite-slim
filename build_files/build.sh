#!/bin/bash

set -ouex pipefail

### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/39/x86_64/repoview/index.html&protocol=https&redirect=1

# this installs a package from fedora repos
dnf5 -y install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
dnf5 config-manager setopt fedora-cisco-openh264.enabled=1
sed -i.bak '/^name=RPM Fusion for Fedora \$releasever - Nonfree$/,/^$/ {
    /^gpgkey=file:\/\/\/etc\/pki\/rpm-gpg\/RPM-GPG-KEY-rpmfusion-nonfree-fedora-\$releasever$/a\
exclude=akmod-nvidia* kmod-nvidia* xorg-x11-drv-nvidia* nvidia-*
}' /etc/yum.repos.d/rpmfusion-nonfree.repo
dnf5 -y remove firefox firefox-langpacks
dnf5 -y config-manager addrepo --from-repofile=https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo
dnf5 -y config-manager addrepo --from-repofile=https://negativo17.org/repos/fedora-nvidia.repo
dnf5 -y swap ffmpeg-free ffmpeg --allowerasing
dnf5 -y group install multimedia --setopt="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin
dnf5 -y group install sound-and-video
dnf5 -y install intel-media-driver rpmdevtools akmods
grubby --update-kernel=ALL --args="i915.enable_guc=2 i915.enable_fbc=1"
# Use a COPR Example:
#
# dnf5 -y copr enable ublue-os/staging
# dnf5 -y install package
# Disable COPRs so they don't end up enabled on the final image:
# dnf5 -y copr disable ublue-os/staging

#### Example for enabling a System Unit File

#systemctl enable podman.socket
