#!/bin/bash
# ============================================================
# GNS3 Server install - Debian 12 peal
# Jooksuta root'ina värske Debian 12 VM-is
# ============================================================

set -e

echo "=== 1. Süsteemi uuendus ==="
apt-get update && apt-get upgrade -y

echo "=== 2. Vajalikud paketid ==="
apt-get install -y \
    curl wget gnupg2 ca-certificates \
    python3 python3-pip python3-venv \
    git qemu-system-x86 qemu-utils \
    docker.io docker-compose \
    net-tools bridge-utils

echo "=== 3. GNS3 server installimine ==="
pip3 install gns3-server --break-system-packages

echo "=== 4. GNS3 kasutaja ==="
if ! id "gns3" &>/dev/null; then
    useradd -m -s /bin/bash -G docker gns3
    echo "gns3:gns3" | chpasswd
fi

echo "=== 5. GNS3 kataloogid ==="
mkdir -p /opt/gns3/images/IOU
mkdir -p /opt/gns3/projects
mkdir -p /var/log/gns3
chown -R gns3:gns3 /opt/gns3
chown -R gns3:gns3 /var/log/gns3

echo "=== 6. GNS3 server konfiguratsioon ==="
mkdir -p /home/gns3/.config/GNS3/2.2
cat > /home/gns3/.config/GNS3/2.2/gns3_server.conf << 'EOF'
[Server]
host = 0.0.0.0
port = 3080
images_path = /opt/gns3/images
projects_path = /opt/gns3/projects
EOF
chown -R gns3:gns3 /home/gns3/.config

echo "=== 7. Systemd teenus ==="
cat > /etc/systemd/system/gns3-server.service << 'EOF'
[Unit]
Description=GNS3 Server
After=network.target docker.service
Requires=docker.service

[Service]
Type=simple
User=gns3
Group=gns3
ExecStart=/usr/local/bin/gns3server
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable gns3-server
systemctl start gns3-server

echo "=== 8. Docker teenus ==="
systemctl enable docker
systemctl start docker

echo "=== 9. Tulemüür (luba port 3080) ==="
if command -v ufw &>/dev/null; then
    ufw allow 3080/tcp
fi

echo "=== 10. IOU tugi (vajalik IOL-XE jaoks) ==="
dpkg --add-architecture i386 2>/dev/null || true
apt-get update
apt-get install -y libelf1t64 2>/dev/null || apt-get install -y libelf1 2>/dev/null || true

echo ""
echo "============================================================"
echo "  GNS3 Server on valmis!"
echo "============================================================"
echo ""
echo "  VM IP: $(hostname -I | awk '{print $1}')"
echo "  GNS3 Web UI: http://$(hostname -I | awk '{print $1}'):3080"
echo ""
echo "  Järgmine samm:"
echo "  1. Kopeeri IOL image'id: scp *.iol gns3@<IP>:/opt/gns3/images/IOU/"
echo "  2. Jooksuta Ansible: ansible-playbook -i <IP>, bootstrap.yaml"
echo "  3. Jooksuta Ansible: ansible-playbook -i <IP>, gns3.yaml"
echo ""
echo "  OS login:  gns3 / gns3"
echo "  Web login: admin / admin (bootstrap muudab ära)"
echo "============================================================"
