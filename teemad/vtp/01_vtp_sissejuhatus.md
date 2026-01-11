# VTP (VLAN Trunking Protocol) - Sissejuhatus

## Miks VTP?

Kujuta ette võrku 20 switchiga ja 50 VLANiga. Ilma VTP-ta peaksid **igal switchil eraldi** kõik VLANid looma. VTP automatiseerib selle protsessi.

```
Ilma VTP-ta:                    VTP-ga:
┌──────┐ ┌──────┐ ┌──────┐      ┌──────┐ ┌──────┐ ┌──────┐
│ SW1  │ │ SW2  │ │ SW3  │      │ SW1  │ │ SW2  │ │ SW3  │
│VLAN10│ │VLAN10│ │VLAN10│      │VLAN10│→│VLAN10│→│VLAN10│
│VLAN20│ │VLAN20│ │VLAN20│      │SERVER│ │CLIENT│ │CLIENT│
└──────┘ └──────┘ └──────┘      └──────┘ └──────┘ └──────┘
   ↑        ↑        ↑              ↑
 käsitsi  käsitsi  käsitsi      automaatne sünkroniseerimine
```

---

## Mis on VTP?

**VTP (VLAN Trunking Protocol)** on Cisco protokoll, mis sünkroniseerib VLAN infot switchide vahel.

**Põhiomadused:**
- Cisco proprietary (ainult Cisco seadmed)
- Töötab Layer 2 tasemel
- Kasutab trunk ühendusi info edastamiseks
- Sünkroniseerib VLAN ID-d ja nimed

---

## VTP režiimid (modes)

| Režiim | Loo/Muuda VLANe | Sünkroniseerib | Edastab reklaame |
|--------|-----------------|----------------|------------------|
| **Server** | ✅ Jah | ✅ Jah | ✅ Jah |
| **Client** | ❌ Ei | ✅ Jah | ✅ Jah |
| **Transparent** | ✅ Ainult lokaalselt | ❌ Ei | ✅ Jah |

```
       VTP Server              VTP Transparent           VTP Client
      ┌──────────┐             ┌──────────┐            ┌──────────┐
      │ Loob     │   BPDU      │ Ei sünkro│   BPDU    │ Ei saa   │
      │ VLANe    │────────────→│ Edastab  │──────────→│ luua     │
      │          │             │ reklaame │            │ VLANe    │
      └──────────┘             └──────────┘            └──────────┘
```

### Server režiim (vaikimisi)
- Saab luua, muuta, kustutada VLANe
- Sünkroniseerib teistega
- Edastab VTP reklaame

### Client režiim
- **EI SAA** luua VLANe
- Sünkroniseerib serveriga
- Edastab VTP reklaame edasi

### Transparent režiim
- Saab luua **lokaalseid** VLANe (ei jagata teistega)
- **EI** sünkroniseeri
- Edastab reklaame läbi (pass-through)

---

## VTP domeen

Kõik switchid, mis jagavad VTP infot, peavad olema **samas domeenis**.

```
VTP Domain: "SCHOOL"
┌─────────────────────────────────────┐
│  ┌──────┐    ┌──────┐    ┌──────┐  │
│  │ SW1  │────│ SW2  │────│ SW3  │  │
│  │Server│    │Client│    │Client│  │
│  └──────┘    └──────┘    └──────┘  │
└─────────────────────────────────────┘
```

**Oluline:** Domeeni nimi peab olema **identne** kõigil switchidel!

---

## Revision number

Iga kord kui VTP serveril VLANi muudetakse, suureneb **revision number**.

```
Algne olek:     Pärast VLAN 10 lisamist:
Rev: 0          Rev: 1
VLANs: 1        VLANs: 1, 10
```

**Switchid sünkroniseerivad kõrgema revision numberiga!**

---

## VTP põhikäsud

### Domeeni seadistamine
```
Switch(config)# vtp domain SCHOOL
```

### Režiimi muutmine
```
Switch(config)# vtp mode server
Switch(config)# vtp mode client
Switch(config)# vtp mode transparent
```

### VTP staatuse vaatamine
```
Switch# show vtp status
```

### VTP parooli seadistamine
```
Switch(config)# vtp password salajane
```

---

## show vtp status väljund

```
SW1# show vtp status
VTP Version                     : 2
Configuration Revision          : 5
Maximum VLANs supported locally : 1005
Number of existing VLANs        : 7
VTP Operating Mode              : Server
VTP Domain Name                 : SCHOOL
VTP Pruning Mode                : Disabled
```

**Mida vaadata:**
- `Configuration Revision` - mitu korda VLANe muudetud
- `VTP Operating Mode` - server/client/transparent
- `VTP Domain Name` - domeeni nimi

---

## ⚠️ VTP oht - "VTP Bomb"

**Stsenaarium:**
1. Võtad vana switchi laborist
2. Sellel on kõrge revision number (nt 100)
3. Ühendad tootmisvõrku (revision 5)
4. **KÕIK VLANID KUSTUTATAKSE!**

```
Labor switch (rev 100, 0 VLANs)
         │
         ▼ Ühendad võrku
┌─────────────────────────────┐
│ Tootmisvõrk (rev 5)         │
│ VLAN 10, 20, 30, 40, 50     │
│           ↓                 │
│ Rev 100 > Rev 5             │
│ Sünkroniseerib → 0 VLANi!   │
└─────────────────────────────┘
```

### Kuidas vältida?

**1. Kasuta VTP versiooni 3** (turvalisem)

**2. Kasuta Transparent režiimi**

**3. Nulli revision number enne ühendamist:**
```
Switch(config)# vtp domain FAKE
Switch(config)# vtp domain SCHOOL
```

---

## VTP versioonid

| Versioon | Omadused |
|----------|----------|
| **V1** | Põhiline, VLAN 1-1001 |
| **V2** | + Token Ring tugi |
| **V3** | + Extended VLANs (1006-4094), turvalisem |

**Soovitus:** Kasuta VTP v3 kui võimalik!

---

## VTP pruning

Vähendab tarbetut broadcast liiklust trunk linkidel.

```
Ilma pruningita:                 Pruningiga:
  VLAN 10 broadcast              VLAN 10 broadcast
       │                              │
  ┌────┴────┐                    ┌────┴────┐
  ▼         ▼                    ▼         ✗
┌────┐   ┌────┐                ┌────┐   ┌────┐
│SW2 │   │SW3 │                │SW2 │   │SW3 │
│V10 │   │V20 │                │V10 │   │V20 │
└────┘   └────┘                └────┘   └────┘
  ↑         ↑                    ↑
 Vaja    Pole vaja!            Vaja    Blokeeritud
```

```
Switch(config)# vtp pruning
```

---

## Kokkuvõte

| Küsimus | Vastus |
|---------|--------|
| Mis on VTP? | VLAN info sünkroniseerimise protokoll |
| Mitu režiimi? | 3: Server, Client, Transparent |
| Mis on revision number? | Konfiguratsioonide loendur |
| Suurim oht? | Kõrge rev nr switch kustutab VLANid |
| Parim praktika? | VTP v3 või Transparent režiim |

---

## Viited

- [NetworkLessons: Introduction to VTP](https://networklessons.com/switching/introduction-to-vtp-vlan-trunking-protocol)
- [Cisco: VTP Configuration Guide](https://www.cisco.com/c/en/us/support/docs/lan-switching/vtp/98154-conf-vlan.html)
