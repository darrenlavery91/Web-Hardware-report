#!/bin/bash

# Function to display section headers
echo_section() {
  echo -e "\n=============================="
  echo -e "$1"
  echo -e "=============================="
}

# Hostname and DNS details
echo_section "System Details"
echo "Hostname: $(hostname)"
echo "DNS Servers:"
cat /etc/resolv.conf | grep "^nameserver" | awk '{print $2}'
echo "Operating System: $(lsb_release -d | awk -F":" '{print $2}' | xargs)"
echo "Kernel Version: $(uname -r)"
echo "Uptime: $(uptime -p)"

echo_section "Memory Usage"
free -h

echo_section "CPU Usage"
mpstat | grep "all"
echo "Load Average: $(cat /proc/loadavg)"

echo_section "Network Details"
ip -br addr show
ip -br link show
ip route show

echo_section "Running Services"
systemctl list-units --type=service --state=running

echo_section "Open Ports"
ss -tuln | awk 'NR==1 || $1 ~ /LISTEN/'

echo_section "Tuning Profiles"
if command -v tuned-adm &> /dev/null; then
  tuned-adm active
else
  echo "Tuned is not installed."
fi

# Disk usage and details
echo_section "Disk Usage"
df -h
echo "\nInode Usage:"
df -i
echo "\nSMART Status for Disks (if supported):"
if command -v smartctl &> /dev/null; then
  for disk in $(lsblk -nd --output NAME); do
    echo "SMART Status for /dev/$disk:"
    smartctl -H /dev/$disk | grep "SMART overall-health"
  done
else
  echo "smartctl is not installed."
fi

# Hardware Information
echo_section "Hardware Information"
echo "CPU Details:"
lscpu | grep -E "Model name|Architecture|CPU MHz"
echo "\nMemory Details:"
dmidecode --type memory | grep -E "Size|Speed|Type" | grep -v "No Module Installed"
echo "\nPCI Devices:"
lspci

echo_section "RAID and LVM Details"
if command -v mdadm &> /dev/null; then
  echo "RAID Configuration:"
  sudo mdadm --detail --scan || echo "No RAID configuration found."
else
  echo "mdadm is not installed."
fi

echo "\nLVM Configuration:"
lvdisplay || echo "No LVM configuration found."

# Security details
echo_section "Security Information"
echo "Firewall Rules:"
if command -v ufw &> /dev/null; then
  ufw status
elif command -v iptables &> /dev/null; then
  iptables -L
else
  echo "No firewall detected."
fi

echo "SELinux/AppArmor Status:"
if command -v getenforce &> /dev/null; then
  getenforce
elif command -v apparmor_status &> /dev/null; then
  apparmor_status
else
  echo "No SELinux/AppArmor detected."
fi

# System Logs
echo_section "System Logs"
echo "Recent Kernel Messages:"
dmesg | tail -n 10
echo "\nRecent Warnings/Errors in System Logs:"
journalctl -p 3 -n 10

# Software details
echo_section "Software Information"
echo "Installed Packages:"
dpkg-query -l | wc -l | awk '{print $1 " packages installed."}'
echo "Updates Available:"
if command -v apt &> /dev/null; then
  apt list --upgradable 2>/dev/null | tail -n +2
else
  echo "apt is not installed."
fi

# User details
echo_section "User Information"
echo "Currently Logged-in Users:"
w

echo "\nLast Logins:"
last -a | head -n 5
echo "\nFailed Login Attempts:"
cat /var/log/auth.log | grep "Failed password" | tail -n 5

# Network statistics
echo_section "Network Statistics"
echo "Bandwidth Usage:"
sar -n DEV 1 1 | grep Average
echo "\nActive Connections:"
ss -s
echo "\nARP Table:"
ip neigh

# Time synchronization
echo_section "Time Synchronization"
if command -v timedatectl &> /dev/null; then
  timedatectl status
else
  echo "timedatectl is not installed."
fi

# Virtualization details
echo_section "Virtualization Information"
if command -v virt-what &> /dev/null; then
  virt-what
else
  echo "virt-what is not installed or system not virtualized."
fi

# Power and Temperature
echo_section "Power and Temperature"
if command -v sensors &> /dev/null; then
  sensors
else
  echo "sensors is not installed."
fi

echo_section "Summary"
echo "Hostname: $(hostname)"
echo "Uptime: $(uptime -p)"
echo "Total Memory: $(free -h | awk '/^Mem:/ {print $2}')"
echo "Total CPU Cores: $(nproc)"
echo "Primary DNS Server: $(cat /etc/resolv.conf | grep "^nameserver" | head -n 1 | awk '{print $2}')"
echo "Default Gateway: $(ip route | grep default | awk '{print $3}')"

