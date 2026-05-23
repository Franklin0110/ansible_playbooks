#!/bin/bash

# Ensure a hostname is passed as an argument
if [ -z "$1" ]; then
    echo "Usage: $0 <hostname>"
    echo "Example: $0 kmaster02"
    exit 1
fi

HOSTNAME=$1

# Determine the target directory based on the hostname prefix
if [[ "$HOSTNAME" == kmaster* ]]; then
    DEST_DIR="/kvm/machines/userdata/kmasters"
elif [[ "$HOSTNAME" == knode* ]]; then
    DEST_DIR="/kvm/machines/userdata/knodes"
else
    echo "Error: Hostname must start with 'kmaster' or 'knode'"
    exit 1
fi

# Ensure the target directory exists
mkdir -p "$DEST_DIR"

YAML_FILE="$DEST_DIR/${HOSTNAME}.yaml"
IMG_FILE="$DEST_DIR/${HOSTNAME}.img"

echo "Generating cloud-init data for $HOSTNAME in $DEST_DIR..."

# Create the YAML file and inject the hostname
cat << EOF > "$YAML_FILE"
#cloud-config
hostname: ${HOSTNAME}

# 1. Install the agent and common tools
packages:
  - curl
  - tmux
  - qemu-guest-agent
  - ansible
  - ansible-core

# 2. Configure the user
users:
  - name: ansible
    lock_passwd: true
    sudo: ALL=(ALL) NOPASSWD:ALL
    gecos: System Administrator
    ssh_authorized_keys:
      - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDIblH7Ow0VK/wucRokAsOD6waBOMBdbKgFhTydQwfw86HJG41a6WkbFAMv9sMGynoo+iPc4lUBO22e0PzhrvuS+iyb1E8VH27vjZO0aKi+ECYs+fgiPYhsvl2L6Qu4A2qFVGRNFWU1Tg3c8g80WpB6dJh+qXdNrJIW6LM/TNEjKE1OSY4/t0Wr4wiP4G1Q4YO308LqINKMiHE1JGJspgfAMLF+rEDpzeigBudwMRF0bVNVBiYbH0tl/Jh1+TSTwRraCz8dxbB8uho11K0NoqT1mwnBtCDziFEcb++8aZWSd5MzBYJ3BNVZhkI7p+StXVlmmFayTci6qws56QOTKlQRfIPq/9WLw+sJZsApiRg2+XpMInXFabrqSZBVQ0talrg8+4FhvkFaCmOObDq5+1CRZg91NdI823K5Rg4lwanYOwoVh/hC1ztfzFJu7NhgExsdIRC2TO1wsVJHIAqGivrOx0HR+nAw3ffNzVPCPK/4eKDPEW9e1WQkDxeGjJrlc+U= Franklin@DESKTOP-S8L0ILK
      - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQD3aD3d4tPQdUjHya981o9gpufvCYv4D8xovHZ2bF3g7nIRSXNRwcE0Pw7yp4T2twbl0OHNoVxY3FY/GHRViH9ejW+o/Fejq6O0t+w1cHkA9U08BgM9nOUtTAA9Yr2oKdY9xPvkBlNiiVBsFHlRC9Kbv4K8LN09Hc5JnFOzlfwrl118XjTyhf/pK2tSe/s+AOl+HeZmjCf9VsEKAillSi8vK+9PDHvxwvDTxAGwtBMoiChRaL6Ss/Se5qrGGMvE0kReYb39cIP+w5SJNAynue0rBwoMWzEnLCF1cEvng7BBPTc60fKvhhx1SQGRmPjNboMr26U5yjp5H4Hc05THkowYWd65T+Ku4Nah2HrvVPycit9PiCeBh1yrqbU42BnBZ9lMDUoLaHrYlLmcETW1dtQFZnH8LBbG4RqEvjKUnl/0aY6svvqeRaHLUvo2j5K5+ti9rPzHupOv2ijo/m9kN3Khy+F6Afho1C6MKmmBbdHFKes8q0rhlE6lCjv21nkEuP0= ansible@jenkins01

ssh_pwauth: false

growpart:
  mode: auto
  devices: ['/']
  ignore_growroot_disabled: false

resize_rootfs: true

package_update: true
package_upgrade: true

runcmd:
  - systemctl enable --now qemu-guest-agent
  - ufw allow OpenSSH
  - ufw --force enable
EOF

# Verify cloud-localds is installed
if ! command -v cloud-localds &> /dev/null; then
    echo "Error: cloud-localds is not installed. Install 'cloud-image-utils' first."
    exit 1
fi

# Generate the seed image
cloud-localds "$IMG_FILE" "$YAML_FILE"

if [ $? -eq 0 ]; then
    echo "Success! Image generated at: $IMG_FILE"
else
    echo "Error: Failed to generate the image."
    exit 1
fi
