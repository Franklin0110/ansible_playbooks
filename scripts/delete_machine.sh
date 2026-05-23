#!/bin/bash

# Ensure a hostname was provided
if [ -z "$1" ]; then
    echo "Usage: ./script.sh <hostname>"
    exit 1
fi

HOSTNAME=$1 

# 1. Cleanup KVM
virsh destroy "$HOSTNAME" || echo "VM not running, continuing..."
virsh undefine "$HOSTNAME" --remove-all-storage

# 2. Git operations (ensure we have the latest)
git pull --rebase

# 3. Cleanup Inventory
# We use double quotes so $HOSTNAME expands correctly
sed -i "/$HOSTNAME/d" ~/ansible_playbooks/inventory/hosts

# 4. Commit and Push
git add ~/ansible_playbooks/inventory/hosts
git commit -m "Removing $HOSTNAME from inventory"
git push origin main

echo "Successfully removed $HOSTNAME and pushed to git."
