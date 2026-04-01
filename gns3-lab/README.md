# AV2 GNS3 Labor

GNS3 serveri automatiseeritud seadistus Arvutivõrgud II laboriteks.
Põhineb [NM2025 Skill39 ModuleC](https://github.com/WS-EE/NM2025-Skill39-Public) materjalidel.

## Eeldused

- Proxmox VE server
- GNS3 VM (Debian/Ubuntu) Proxmoxis
- Ansible kontrollarvutis
- IOL-XE image'id (jaga eraldi, mitte Gitis!)

## GNS3 VM ettevalmistus Proxmoxis

1. Lae alla GNS3 VM: https://gns3.com/software/download-vm
2. Impordi Proxmoxi (OVA → qcow2 konversioon)
3. VM seaded:
   - **CPU:** 4+ tuuma (nested virtualization lubatud)
   - **RAM:** 32GB+ (17 tudengit × ~1.7GB per topoloogia)
   - **Ketas:** 50GB+
   - **Võrk:** Bridge kooli võrku (tudengid peavad ligi saama)

4. Käivita VM, kontrolli IP: `ip addr show`

## Kasutamine

### 1. Kopeeri IOL image'id

```bash
cp iol-xe-l2-17-15-01.iol iou_images/
cp iol-xe-l3-17-15-01.iol iou_images/
```

### 2. Esmane seadistus (ainult esimesel korral)

```bash
ansible-playbook -i <GNS3_IP>, bootstrap.yaml
```

### 3. Põhiseadistus (kontod, template'id, image'id)

```bash
ansible-playbook -i <GNS3_IP>, gns3.yaml
```

### 4. Ainult tudengite kontod uuesti

```bash
ansible-playbook -i <GNS3_IP>, gns3.yaml --tags users
```

### 5. Ainult Cisco template'id

```bash
ansible-playbook -i <GNS3_IP>, gns3.yaml --tags cisco
```

## Tudengite ligipääs

Tudengid avavad brauseris: `http://<GNS3_IP>`

| Kasutaja | Parool |
|----------|--------|
| tudeng01 | av2-lab-01 |
| tudeng02 | av2-lab-02 |
| ... | ... |
| tudeng17 | av2-lab-17 |

## Saadaolevad template'id GNS3-s

| Template | Kirjeldus | RAM |
|----------|-----------|-----|
| IOL XE L2 | Cisco L2 Switch (17.15.01) | 256 MB |
| IOL XE L3 | Cisco L3 Router/Switch (17.15.01) | 512 MB |
| Lab Client | Debian klient (ping, trace, nmap, tcpdump) | ~128 MB |

## Ressursside arvutus

Üks tudengi topoloogia (3× L2 + 1× L3 + 3× Client):
- L2: 3 × 256 MB = 768 MB
- L3: 1 × 512 MB = 512 MB
- Client: 3 × 128 MB = 384 MB
- **Kokku: ~1.7 GB per tudeng**
- **17 tudengit: ~29 GB RAM**

Soovitus: GNS3 VM-ile **32-48 GB RAM**.
