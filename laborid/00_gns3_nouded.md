# GNS3 süsteeminõuded

## Minimaalsed nõuded

| Komponent | Miinimum | Soovituslik |
|-----------|----------|-------------|
| **RAM** | 8 GB | 16 GB |
| **CPU** | 4 tuuma | 8 tuuma |
| **Ketas** | 10 GB vaba | 20 GB vaba |
| **OS** | Windows 10/11, macOS, Linux | - |

---

## Virtualiseerimise tugi

GNS3 vajab **VT-x** (Intel) või **AMD-V** (AMD) tuge.

### Kuidas kontrollida (Windows)?

1. Ava **Task Manager** (`Ctrl+Shift+Esc`)
2. Mine **Performance** → **CPU**
3. Vaata kas **Virtualization: Enabled**

Kui näitab **Disabled** - pead BIOS-is sisse lülitama!

---

## BIOS seaded

Kui virtualiseerimine on välja lülitatud:

### Intel CPU:
1. Restart → vajuta `F2`, `F10`, `Del` (sõltub emaplaadist)
2. Otsi: **Intel Virtualization Technology** või **VT-x**
3. Lülita **Enabled**
4. Save & Exit

### AMD CPU:
1. Restart → vajuta `F2`, `F10`, `Del`
2. Otsi: **SVM Mode** või **AMD-V**
3. Lülita **Enabled**
4. Save & Exit

---

## Allalaadimised enne tundi

**Kõik failid on Google Drive'is (õpetaja jagab lingi):**

| Fail | Suurus | Kirjeldus |
|------|--------|-----------|
| `GNS3-2.2.54-all-in-one-regular.exe` | 107 MB | GNS3 installer |
| `iol-xe-l2-17-15-01.iol` | 232 MB | L2 Switch image |
| `iol-xe-l3-17-15-01.iol` | 278 MB | L3 Router image (valikuline) |

**Kokku:** ~350-620 MB

⚠️ **Lae alla KODUS enne tundi!** Kooli wifi ei pruugi jõuda.

---

## Checklist enne laborit

- [ ] GNS3 installitud
- [ ] IOL-XE image'id allalaaditud
- [ ] Virtualiseerimine BIOS-is lubatud
- [ ] Vähemalt 8GB RAM vaba

---

## Kui sul pole sobivat arvutit

Räägi õpetajaga - on võimalik kasutada:
- Kooli laborit
- Proxmox serverit (kaughaldus)
