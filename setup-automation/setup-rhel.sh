#!/bin/bash
USER=rhel

echo "Adding wheel" > /root/post-run.log
usermod -aG wheel rhel

echo "Setup vm control01" > /tmp/progress.log

chmod 666 /tmp/progress.log 

#dnf install -y nc

# Epel
#dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-10.noarch.rpm
# certbot if needed
#dnf install -y certbot

# Enable cockpit functionality in showroom.
#dnf -y remove tlog cockpit-session-recording
#echo "[WebService]" > /etc/cockpit/cockpit.conf
#echo "Origins = https://cockpit-${GUID}.${DOMAIN}" >> /etc/cockpit/cockpit.conf
#echo "AllowUnencrypted = true" >> /etc/cockpit/cockpit.conf
#systemctl enable --now cockpit.socket
