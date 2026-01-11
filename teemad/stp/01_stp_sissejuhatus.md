# STP (Spanning Tree Protocol) - Sissejuhatus

## Miks STP?

Võrgus on **redundantsus** oluline - kui üks link katki, töötab teine. Aga redundantsus tekitab **loope**.

### Probleem: Layer 2 loop

```
Ühe kaabliga (pole redundantne):     Kahe kaabliga (redundantne, AGA loop!):
    ┌────────┐                           ┌────────┐
    │  SW1   │                           │  SW1   │
    └───┬────┘                           └─┬────┬─┘
        │                                  │    │
    ┌───┴────┐                           ┌─┴────┴─┐
    │  SW2   │                           │  SW2   │
    └────────┘                           └────────┘
```

**Mis juhtub loopiga?**

1. PC saadab broadcast (nt ARP request)
2. SW1 saadab mõlemast pordist välja
3. SW2 saab kaks koopiat
4. SW2 saadab mõlemast pordist välja
5. SW1 saab kaks koopiat tagasi
6. **LÕPMATU TSÜKKEL!**

```
     ┌─────────────────────────────┐
     │                             │
     ▼                             │
  ┌──────┐  broadcast   ┌──────┐   │
  │ SW1  │─────────────→│ SW2  │───┘
  │      │←─────────────│      │
  └──────┘  broadcast   └──────┘
     │                             
     └─────────────────────────────→ Ja uuesti... ja uuesti...
```

**Ethernet framelil pole TTL-i** (nagu IP paketil), seega loopib igavesti!

Tulemus: **Broadcast storm** → võrk kokku!

---

## Kuidas STP lahendab?

STP **blokeerib** ühe pordi, et loop kaoks, aga jätab selle **varuks**.

```
Ilma STP-ta (loop):              STP-ga (loop blokeeritud):
    ┌────────┐                       ┌────────┐
    │  SW1   │                       │  SW1   │
    └─┬────┬─┘                       └─┬────┬─┘
      │    │                           │    │
      │    │                           │    ╳ ← Blokeeritud
      │    │                           │    
    ┌─┴────┴─┐                       ┌─┴────┴─┐
    │  SW2   │                       │  SW2   │
    └────────┘                       └────────┘
```

Kui aktiivne link katkeb, **aktiveeritakse blokeeritud port automaatselt!**

---

## STP põhikontseptsioonid

### 1. Root Bridge (juur-sild)

- **Üks switch** valitakse "bossiks" - root bridge
- Kõik teised switchid arvutavad oma tee root bridge'ni
- Root bridge'i **kõik pordid on forwarding**

### 2. Bridge ID

Switchi identifikaator, koosneb:

```
Bridge ID = Priority + MAC address
            (32768)   (0011.2233.4455)
```

**Madalaim Bridge ID võidab = saab root bridge'ks!**

### 3. Port rollid

| Roll | Kirjeldus |
|------|-----------|
| **Root Port** | Lühim tee root bridge'ni (non-root switchidel) |
| **Designated Port** | Forwarding port (root bridge'il kõik pordid) |
| **Alternate/Blocked** | Blokeeritud (loop prevention) |

---

## Root Bridge valimine

```
         SW1                    SW2                    SW3
    MAC: AAA                MAC: BBB                MAC: CCC
    Priority: 32768         Priority: 32768         Priority: 32768
         │                       │                       │
         └───────────────────────┴───────────────────────┘
                                 │
                         Kes võidab?
                                 │
                                 ▼
                    SW1 (madalaim MAC = AAA)
                        = ROOT BRIDGE
```

**Vaikimisi priority:** 32768  
**Tiebreaker:** Madalaim MAC aadress

---

## Port staatused

Kui port aktiveerub, läbib ta mitu staatust:

```
Blocking → Listening → Learning → Forwarding
              15 sek      15 sek
              
Kokku: ~30 sekundit enne kui port hakkab liiklust edastama!
```

| Staatus | BPDU saatmine | MAC õppimine | Andmete edastus |
|---------|---------------|--------------|-----------------|
| **Blocking** | Ei | Ei | Ei |
| **Listening** | Jah | Ei | Ei |
| **Learning** | Jah | Jah | Ei |
| **Forwarding** | Jah | Jah | Jah |

---

## BPDU (Bridge Protocol Data Unit)

Switchid saadavad üksteisele **BPDU** pakette, et:
- Teatada oma Bridge ID
- Leida root bridge
- Arvutada parim tee

```
BPDU sisu:
┌─────────────────────────────┐
│ Root Bridge ID              │
│ Sender Bridge ID            │
│ Cost to Root                │
│ Port ID                     │
│ Timers                      │
└─────────────────────────────┘
```

BPDU saadetakse **iga 2 sekundi** tagant (Hello Time).

---

## Path Cost (tee maksumus)

Kiiremad lingid = väiksem cost = eelistatud

| Kiirus | Cost (vana) | Cost (uus) |
|--------|-------------|------------|
| 10 Mbps | 100 | 2,000,000 |
| 100 Mbps | 19 | 200,000 |
| 1 Gbps | 4 | 20,000 |
| 10 Gbps | 2 | 2,000 |

```
Näide: Kumb tee valitakse?

        ┌────────────────────────────┐
        │         ROOT               │
        └──────┬───────────┬─────────┘
               │           │
         Gi (cost 4)   Fa (cost 19)
               │           │
        ┌──────┴───────────┴─────────┐
        │         SW2                │
        └────────────────────────────┘
        
Vastus: Gi link (cost 4 < 19)
```

---

## show spanning-tree

```
SW1# show spanning-tree

VLAN0001
  Spanning tree enabled protocol ieee
  Root ID    Priority    32769
             Address     000f.34ca.1000
             This bridge is the root     ← See switch ON root bridge!

  Bridge ID  Priority    32769
             Address     000f.34ca.1000

Interface        Role Sts Cost      Prio.Nbr Type
---------------- ---- --- --------- -------- ----
Fa0/14           Desg FWD 19        128.14   P2p
Fa0/16           Desg FWD 19        128.16   P2p
```

**Mida vaadata:**
- `This bridge is the root` - kas see on root bridge
- `Role`: Root/Desg/Altn - pordi roll
- `Sts`: FWD/BLK - forwarding või blocking

---

## STP näide kolme switchiga

```
                 SW1 (Root)
              MAC: AAA ← Madalaim
              Priority: 32768
                  │
         ┌───────┴───────┐
         │               │
        D│              D│       D = Designated (FWD)
         │               │       R = Root Port (FWD)
      ┌──┴───┐       ┌───┴──┐    A = Alternate (BLK)
      │ SW2  │───────│ SW3  │
      │ BBB  │  R  A │ CCC  │
      └──────┘       └──────┘
         R               R
         │               │
      Root Port      Root Port
      
SW2-SW3 vahel: SW2 võidab (BBB < CCC)
→ SW3 port blokeeritakse
```

---

## STP taimerid

| Taimer | Vaikeväärtus | Kirjeldus |
|--------|--------------|-----------|
| **Hello Time** | 2 sek | BPDU saatmise intervall |
| **Forward Delay** | 15 sek | Listening/Learning kestvus |
| **Max Age** | 20 sek | Kui kaua oodata enne topoloogia muutust |

**Convergence aeg:** ~30-50 sekundit (aeglane!)

---

## STP versioonid

| Versioon | Standard | Convergence | Märkused |
|----------|----------|-------------|----------|
| **STP** | 802.1D | 30-50 sek | Originaal, aeglane |
| **PVST** | Cisco | 30-50 sek | Per-VLAN STP |
| **RSTP** | 802.1w | 1-2 sek | Rapid STP, kiirem |
| **PVST+** | Cisco | 30-50 sek | PVST + 802.1Q tugi |
| **Rapid PVST+** | Cisco | 1-2 sek | RSTP + per-VLAN |
| **MST** | 802.1s | 1-2 sek | Multiple VLANs per instance |

---

## Kokkuvõte

| Küsimus | Vastus |
|---------|--------|
| Miks STP? | Vältida Layer 2 loope |
| Kes on root bridge? | Madalaim Bridge ID (priority + MAC) |
| Mis on root port? | Lühim tee root bridge'ni |
| Miks 30 sek convergence? | Listening (15s) + Learning (15s) |
| Parem alternatiiv? | RSTP (Rapid STP) - 1-2 sek |

---

## Viited

- [NetworkLessons: Introduction to Spanning-Tree](https://networklessons.com/switching/introduction-to-spanning-tree)
- [NetworkLessons: Spanning-Tree Cost Calculation](https://networklessons.com/switching/spanning-tree-cost-calculation)
