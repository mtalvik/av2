# GNS3 paigaldusjuhend

## Mis on GNS3?

GNS3 on võrgusimulaator, mis võimaldab käivitada **päris Cisco IOS-i** virtuaalselt. Erinevalt Packet Tracerist, kus käsud on simuleeritud, jooksutab GNS3 tegelikku switchi/ruuteri tarkvara.

```
Packet Tracer:              GNS3:
┌─────────────┐            ┌─────────────┐
│ Simulatsioon│            │ Päris IOS   │
│ (piiratud)  │            │ VM-is       │
└─────────────┘            └─────────────┘
```

---

## Vajalikud failid

Õpetaja jagab Google Drive'is:

| Fail | Suurus | Kirjeldus |
|------|--------|-----------|
| `GNS3-2.2.54-all-in-one-regular.exe` | 107 MB | GNS3 installer |
| `iol-xe-l2-17-15-01.iol` | 232 MB | L2 Switch (STP, VTP, VLAN) |
| `iol-xe-l3-17-15-01.iol` | 278 MB | L3 Router (hilisemaks) |

**Lae kõik failid alla ENNE tunni algust!**

---

## 1. GNS3 installimine

1. Käivita `GNS3-2.2.54-all-in-one-regular.exe`
2. Vajuta **Next** kõigil sammudel
3. **Oluline:** Jäta kõik vaikimisi valikud!
4. Lõpus **Finish**

Installimine võtab ~5-10 minutit.

---

## 2. GNS3 esmane käivitus

### Samm 2.1 - Käivita GNS3

Esimesel käivitusel avaneb **Setup Wizard**:

1. Vali: **Run appliances on my local computer**
2. Kliki **Next**
3. Local server seaded - jäta vaikimisi
4. Kliki **Next** → **Finish**

---

### Samm 2.2 - Sulge tervitusaken

Kui avaneb "New project" aken, kliki **Cancel** (esmalt lisame image'id).

---

## 3. IOL-XE Switch lisamine

IOL-XE on Cisco IOS XE image, mis jookseb otse GNS3-s ilma eraldi VM-ita.

### Samm 3.1 - Ava Preferences

`Edit` → `Preferences` (või `Ctrl+Shift+P`)

---

### Samm 3.2 - Mine IOS on UNIX sektsiooni

Vasakul menüüs:
1. Kliki `IOS on UNIX`
2. Kliki `IOU Devices`
3. Kliki **New**

---

### Samm 3.3 - Server type

Vali: **Run this IOU device on my local computer**

Kliki **Next**

---

### Samm 3.4 - Vali IOU image

1. Kliki **Browse**
2. Otsi üles allalaaditud `iol-xe-l2-17-15-01.iol` fail
3. Vali see

---

### Samm 3.5 - Anna nimi ja tüüp

- **Name:** `Switch-L2` (või muu nimi)
- **Type:** vali **L2 image** (oluline!)

Kliki **Next** → **Finish**

---

### Samm 3.6 - Lisa ka L3 image (valikuline)

Korda samme 3.2-3.5 failiga `iol-xe-l3-17-15-01.iol`:
- **Name:** `Router-L3`
- **Type:** vali **L3 image**

---

### Samm 3.7 - IOU License

IOL/IOU vajab litsentsi. **Ilma selleta ei käivitu!**

1. Mine: `Edit` → `Preferences`
2. Vali vasakult: `IOS on UNIX`
3. Leia `IOU License` väli
4. Kopeeri sinna see tekst:

```
[license]
gns3 = 73635fd3b0a13ad0;
```

5. Vajuta **Apply** → **OK**

---

## 4. Esimese topoloogia loomine

### Samm 4.1 - Uus projekt

`File` → `New blank project`

- **Name:** `STP_Labor`
- **Location:** jäta vaikimisi

Kliki **OK**

---

### Samm 4.2 - Lisa switchid

1. Vasakul paneelil kliki **Browse all devices** ikoonil
   (või vajuta `Ctrl+Shift+A`)
2. Leia **Switch-L2** (sinu lisatud image)
3. **Drag & drop** töölauale

Lisa **3 switchit** STP labori jaoks.

---

### Samm 4.3 - Ühenda switchid kolmnurgaks

1. Kliki **Add a link** nuppu (kaabli ikoon) või vajuta `L`
2. Kliki SW1 → vali port `e0/0`
3. Kliki SW2 → vali port `e0/0`

Korda kuni kolmnurk on valmis:

```
       SW1
      /   \
   e0/0   e0/1
    /       \
  SW2-------SW3
      e0/0
```

**IOL pordid:** `e0/0`, `e0/1`, `e0/2`, `e0/3`, `e1/0`, `e1/1`...

---

### Samm 4.4 - Käivita seadmed

Kliki **Start all nodes** (roheline ▶️) või `Ctrl+Shift+R`

⏳ Oota ~30-60 sekundit kuni switchid bootivad.
(IOL on kiirem kui vIOS!)

---

### Samm 4.5 - Ühenda konsoolile

1. **Topeltklõps** switchil
   (või paremklikk → **Console**)

Avaneb terminal kus saad sisestada Cisco käske!

---

## 5. Esimesed käsud - kontrolli et töötab

```
Switch> enable
Switch# show version
```

Peaksid nägema:
```
Cisco IOS XE Software, Version 17.15.01
...
```

Proovi ka:
```
Switch# show spanning-tree
Switch# show vlan brief
Switch# show interfaces status
```

🎉 **GNS3 on valmis!**

---

## 6. Konfiguratsiooni salvestamine

**OLULINE:** IOL ei salvesta config automaatselt!

Enne GNS3 sulgemist:
```
Switch# copy running-config startup-config
```

Või lühemalt:
```
Switch# wr
```

---

## Vigade lahendamine

### "IOU device won't start"

- Kontrolli, et **license** on lisatud
- Proovi: `Preferences` → `IOS on UNIX` → lisa license uuesti

### "Cannot find iourc" või "License check failed"

Loo fail `C:\Users\<sinu_nimi>\.iourc` sisuga:
```
[license]
gns3 = 73635fd3b0a13ad0;
```

Või lisa GNS3-s: `Edit` → `Preferences` → `IOS on UNIX` → `IOU License`

### "Pordid ei tööta / link down"

- Kontrolli et mõlemad switchid on **started** (roheline)
- IOL pordid algavad `e0/0` - mitte `Gi0/0`!

### "Switch on aeglane"

- IOL-XE vajab ~768MB RAM seadme kohta
- Kontrolli et arvutil on vaba mälu

---

## Kasulikud kiirklahvid

| Klahv | Tegevus |
|-------|---------|
| `Ctrl+Shift+A` | Browse all devices |
| `L` | Add link mode |
| `Ctrl+Shift+R` | Start all nodes |
| `Ctrl+Shift+E` | Stop all nodes |
| `Ctrl+S` | Save project |
| `Del` | Kustuta valitud objekt |

---

## IOL vs vIOS võrdlus

| Omadus | IOL-XE | vIOS |
|--------|--------|------|
| Boot aeg | ~30 sek | ~2 min |
| RAM vajadus | 768 MB | 1 GB |
| IOS versioon | 17.x | 15.x |
| Pordid | e0/0, e0/1... | Gi0/0, Gi0/1... |
| License | Vajalik | Ei vaja |

---

## Järgmine samm

Kui GNS3 töötab, mine edasi **STP labori** juurde!

---

## Lisa: IOU License

Kasuta seda license'it:

```
[license]
gns3 = 73635fd3b0a13ad0;
```

See töötab kõigil arvutitel.
