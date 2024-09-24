#!/bin/bash

# Automatically detect network interface (the first non-loopback interface)
INTERFACE=$(ip -o -4 route show to default | awk '{print $5}')
echo "Detected network interface: $INTERFACE"

# Automatically get IP address for the detected interface
ADDRESS=$(ip -4 addr show $INTERFACE | grep -oP '(?<=inet\s)\d+(\.\d+){3}/\d+')
echo "Detected IP address: $ADDRESS"

# Automatically detect gateway
GATEWAY=$(ip route | grep default | awk '{print $3}')
echo "Detected gateway: $GATEWAY"

# Automatically detect the primary storage device
STORAGE_DEVICE=$(lsblk -o NAME,TYPE | grep disk | awk 'NR==1{print "/dev/"$1}')
echo "Detected storage device: $STORAGE_DEVICE"

# Set root password (change to your desired method for setting the password)
ROOT_PASSWORD="your_secure_password_here"
echo "Using root password: $ROOT_PASSWORD"

# Download MikroTik RouterOS image
wget https://download.mikrotik.com/routeros/7.5/chr-7.5.img.zip -O chr.img.zip && \

# Extract the image
gunzip -c chr.img.zip > chr.img && \

# Mount the image
mount -o loop,offset=512 chr.img /mnt && \

# Create the MikroTik configuration script
echo "/ip address add address=$ADDRESS interface=[/interface ethernet find where name=ether1]
/ip route add gateway=$GATEWAY
/ip service disable telnet
/user set 0 name=root password=$ROOT_PASSWORD" > /mnt/rw/autorun.scr && \

# Sync and install RouterOS on the detected storage device
echo u > /proc/sysrq-trigger && \
dd if=chr.img bs=1024 of=$STORAGE_DEVICE && \
echo "sync disk" && \
echo s > /proc/sysrq-trigger && \
echo "Sleep 5 seconds" && \
sleep 5 && \
echo "Ok, reboot" && \
echo b > /proc/sysrq-trigger
