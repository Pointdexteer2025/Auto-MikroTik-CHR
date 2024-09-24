#!/bin/bash

# Update and install required packages
sudo apt-get update
sudo apt-get install -y qemu-utils qemu-kvm libvirt-bin virtinst bridge-utils

# Set the MikroTik CHR version and download URL
CHR_VERSION="stable"
CHR_IMAGE_URL="https://download.mikrotik.com/routeros/$CHR_VERSION/chr-$CHR_VERSION.img.zip"

# Download the MikroTik CHR image
echo "Downloading MikroTik CHR image..."
wget $CHR_IMAGE_URL -O chr.img.zip

# Unzip the image
echo "Unzipping the CHR image..."
unzip chr.img.zip

# Create a virtual machine image
echo "Creating a disk image for MikroTik CHR..."
qemu-img create -f qcow2 chr.qcow2 10G

# Convert MikroTik CHR raw image to qcow2 format
echo "Converting CHR image to qcow2..."
qemu-img convert chr-$CHR_VERSION.img -O qcow2 chr.qcow2

# Set up a virtual machine using KVM
echo "Setting up the MikroTik CHR virtual machine..."
virt-install --name mikrotik-chr --ram 512 --vcpus 1 --disk path=chr.qcow2,format=qcow2,bus=virtio \
--import --network network=default,model=virtio --os-type linux --os-variant generic --graphics none \
--noautoconsole --cpu host

# Clean up unnecessary files
echo "Cleaning up downloaded files..."
rm chr.img.zip chr-$CHR_VERSION.img

echo "MikroTik CHR installation completed!"

# Force reboot the server
sudo reboot -f
