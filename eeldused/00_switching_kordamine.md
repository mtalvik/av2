# Switching põhitõed (Unit 1 kordamine)

See materjal on **kordamiseks** - need teemad käsitlesite Arvutivõrgud I kursusel.

---

## 1. Mis on LAN?

**LAN = Local Area Network = Kohtvõrk**

LAN on lokaalne võrk, mis võib olla:
- Nii väike kui 2 arvutit omavahel ühendatuna
- Nii suur kui tuhandeid seadmeid ühes hoones
- Mitu hoonet samas piirkonnas (campus network)

**Võtmesõna on "lokaalne"** - see on sinu enda võrk.

Kui kasutad ühendust väljaspool (nt Internet), siis see on **WAN (Wide Area Network)**.

---

## 2. Ethernet

**Ethernet** on domineeriv tehnoloogia juhtmega LANides. See on IEEE standard (802.3).

### Ethernet standardid

| Kiirus | Tavanimi | Tehniline nimi | IEEE |
|--------|----------|----------------|------|
| 10 Mbps | Ethernet | 10BASE-T | 802.3 |
| 100 Mbps | Fast Ethernet | 100BASE-T | 802.3u |
| 1000 Mbps | Gigabit Ethernet | 1000BASE-T | 802.3ab |
| 10 Gbps | 10 Gigabit Ethernet | 10GBASE-T | 802.3an |

### Kaablitüübid

**UTP (Unshielded Twisted Pair):**
- Vask, elektrisignaal
- Odav ja lihtne
- Max kaugus: **100 meetrit**
- RJ45 pistik

**Fiber (kiudoptika):**
- Klaas/plastik, valgussignaal
- Kaugus: kilomeetrid
- Pole EMI häireid
- Kallim

### Kaabli valik: Straight-through vs Crossover

| Ühendus | Kaabel |
|---------|--------|
| Arvuti → Switch | Straight-through |
| Switch → Switch | Crossover |
| Ruuter → Switch | Straight-through |
| Arvuti → Arvuti | Crossover |

**NB!** Kaasaegsed switchid kasutavad **auto-MDIX** - tunnevad kaabli automaatselt ära!

---

## 3. Ethernet kaader (frame)

![Ethernet kaadri struktuur](https://cdn.networklessons.com/wp-content/uploads/2017/02/ip-header-checksum-field.png)

| Väli | Suurus | Selgitus |
|------|--------|----------|
| Preamble | 7 baiti | Sünkroniseerimine (10101010...) |
| SFD | 1 bait | Start Frame Delimiter - kaadri algus |
| Destination MAC | 6 baiti | Sihtkoha MAC-aadress |
| Source MAC | 6 baiti | Allika MAC-aadress |
| Type | 2 baiti | Mis on sees (0x0800 = IPv4, 0x0806 = ARP) |
| Data | 46-1500 baiti | Kasulik koormus (payload) |
| FCS | 4 baiti | Frame Check Sequence - vigade kontroll |

**MTU (Maximum Transmission Unit) = 1500 baiti** (data välja suurus)

---

## 4. MAC-aadress

**MAC = Media Access Control**

MAC-aadress on võrgukaardi **unikaalne** aadress.

### Formaat
- **48 bitti = 6 baiti**
- Kirjutatakse hexadecimalis
- Näited:
  - `0000.0c12.3456` (Cisco stiil)
  - `00:00:0c:12:34:56` (Linux/Mac stiil)
  - `00-00-0c-12-34-56` (Windows stiil)

### Struktuur

```
┌─────────────────────┬─────────────────────┐
│   OUI (24 bitti)    │  Vendor (24 bitti)  │
│   Tootja kood       │  Unikaalne number   │
└─────────────────────┴─────────────────────┘
```

- **OUI (Organizationally Unique Identifier)** - IEEE annab tootjale
- Näiteks: `0000.0c` = Cisco
- Ülejäänud 24 bitti määrab tootja iga seadme jaoks

### MAC-aadressi tüübid

| Tüüp | Selgitus | Näide |
|------|----------|-------|
| Unicast | Üks konkreetne seade | `0000.0c12.3456` |
| Broadcast | KÕIK seadmed | `FFFF.FFFF.FFFF` |
| Multicast | Grupp seadmeid | `0100.5e...` |

---

## 5. Kuidas switch õpib MAC-aadresse?

Switch on **tark seade** - ta õpib, kus MAC-aadressid asuvad!

### Protsess samm-sammult

**1. H1 saadab kaadri H2-le:**
```
Allikas: AAA (H1)
Sihtkoht: BBB (H2)
```

**2. Switch saab kaadri pordist 1:**
- Switch vaatab **SOURCE MAC** (AAA)
- Lisab MAC-aadresside tabelisse: `AAA → Port 1`

**3. Switch ei tea, kus on BBB:**
- Switch ujutab (**flood**) kaadri KÕIGILE portidele (v.a port 1)

**4. H2 vastab:**
- Switch õpib: `BBB → Port 2`

**5. Edaspidi:**
- Switch teab mõlemat aadressi
- Kaadrid lähevad otse õigesse porti (switching, mitte flooding)

### MAC-aadresside tabel (CAM table)

```
SW1#show mac address-table dynamic

Vlan    Mac Address       Type        Ports
----    -----------       --------    -----
1       fa16.3e15.d86d    DYNAMIC     Gi0/1
1       fa16.3e5c.bc0f    DYNAMIC     Gi0/2
1       fa16.3ed2.c7c2    DYNAMIC     Gi0/3
```

### Aegumisaeg (Aging Time)

```
SW1#show mac address-table aging-time
Global Aging Time:  300
```

Kui switch ei näe MAC-aadressi **300 sekundi** jooksul, kustutatakse see tabelist.

### Kasulikud käsud

| Käsk | Mida teeb |
|------|-----------|
| `show mac address-table dynamic` | Näita õpitud MAC-aadresse |
| `show mac address-table dynamic interface Gi0/1` | Näita konkreetse pordi MAC-e |
| `clear mac address-table dynamic` | Kustuta kõik õpitud MAC-id |
| `show mac address-table aging-time` | Näita aegumisaega |

---

## 6. Broadcast domeen

**Broadcast domeen** = kõik seadmed, mis saavad broadcast liiklust üksteiselt.

### Mis on broadcast?

Broadcast tähendab: **saadame kõigile, kas nad tahavad või mitte**.

- Sihtkoha MAC: `FF:FF:FF:FF:FF:FF`
- Switch edastab broadcast'i **KÕIGILE** portidele (v.a sissetulev port)

### Näide: ARP Request

```
Destination: Broadcast (ff:ff:ff:ff:ff:ff)
Source: fa:16:3e:38:94:9d
Type: ARP (0x0806)
```

H1 küsib: "Kellel on IP 192.168.1.2? Öelge mulle oma MAC!"
- See küsimus läheb **KÕIGILE**

### Miks broadcast on probleem?

- Raiskab ribalaiust
- Raiskab CPU-d (iga seade peab kaadrit töötlema)
- Liiga palju broadcast'i = võrk aeglustub

**Hea praktika:** Hoia broadcast domeen 1-1000 seadme piires.

### Kuidas piirata broadcast domeeni?

1. **Ruuter** - ei edasta broadcast'i (Layer 3 seade)
2. **VLANid** - jagavad switchi mitmeks loogiliseks võrguks

```
┌─────────────────────────────────────────────┐
│           Üks switch ilma VLANideta         │
│         = ÜKS broadcast domeen              │
└─────────────────────────────────────────────┘

┌──────────────────┬──────────────────────────┐
│    VLAN 10       │        VLAN 20           │
│  Broadcast 1     │     Broadcast 2          │
└──────────────────┴──────────────────────────┘
         Üks switch VLANidega
         = MITU broadcast domeeni
```

---

## 7. Collision domeen

**Collision domeen** = ala, kus võivad tekkida kokkupõrked (collisions).

### Ajalugu: Hub

**Hub** oli loll seade - lihtsalt kordaja (repeater):
- Saab signaali ühest pordist
- Kordab KÕIGILE teistele portidele
- Ei tea midagi MAC-aadressidest

**Probleem:** Kui kaks seadet saadavad korraga → **COLLISION!**

### Half Duplex vs Full Duplex

| Režiim | Selgitus | Kus kasutatakse |
|--------|----------|-----------------|
| Half Duplex | Ei saa saata ja vastu võtta korraga | Hub, WiFi |
| Full Duplex | Saab saata JA vastu võtta korraga | Switch |

### CSMA/CD

**CSMA/CD = Carrier Sense Multiple Access / Collision Detection**

- **CS** - kuula, kas keegi saadab
- **MA** - kõik võivad saata
- **CD** - tuvasta kokkupõrge

Kui collision juhtub:
1. Mõlemad seadmed jammivad liini
2. Käivitavad juhusliku taimeri
3. Proovivad uuesti saata

### Switch vs Hub

| Hub | Switch |
|-----|--------|
| Kordab kõigile | Saadab ainult õigesse porti |
| Üks collision domeen | Iga port = eraldi collision domeen |
| Half duplex | Full duplex |
| CSMA/CD sisse lülitatud | CSMA/CD välja lülitatud |

**Tänapäeval:** Hub'e enam ei kasutata. Switchid on standard.

### Mitu collision domeeni?

```
         HUB
    ┌────┴────┐
    │         │
   PC1       PC2
   
= 1 collision domeen (kogu hub)
```

```
        SWITCH
    ┌────┬────┐
    │    │    │
   PC1  PC2  PC3
   
= 3 collision domeeni (iga port eraldi)
```

---

## 8. Kokkuvõte: Switch vs Hub vs Ruuter

| Seade | Layer | Mida teeb | Broadcast | Collision |
|-------|-------|-----------|-----------|-----------|
| Hub | 1 (Physical) | Kordab signaali | Edastab | Üks domeen |
| Switch | 2 (Data Link) | Õpib MAC-e, switchib | Edastab | Iga port eraldi |
| Ruuter | 3 (Network) | Ruutib IP pakette | EI edasta | Iga port eraldi |

---

## Kontrollküsimused

1. Mis vahe on LAN ja WAN vahel?
2. Mis on MAC-aadressi suurus bittides?
3. Mis juhtub kui switch saab kaadri tundmatu sihtkoha MAC-aadressiga?
4. Mis on broadcast MAC-aadress?
5. Miks hub tekitab collision'e, aga switch mitte?
6. Mis on CSMA/CD ja millal seda kasutatakse?
7. Mitu broadcast domeeni tekitab üks switch ilma VLANideta?
8. Mis seade piirab broadcast domeeni?

---

## Lisalugemine (inglise keeles)

- [NetworkLessons: Introduction to LANs](https://networklessons.com/switching/introduction-to-lans)
- [NetworkLessons: Introduction to Ethernet](https://networklessons.com/switching/introduction-to-ethernet)
- [NetworkLessons: How does a switch learn MAC Addresses](https://networklessons.com/switching/how-does-a-switch-learn-mac-addresses)
- [NetworkLessons: Broadcast Domain](https://networklessons.com/switching/broadcast-domain)
- [NetworkLessons: Collision Domains](https://networklessons.com/switching/collision-domains)
