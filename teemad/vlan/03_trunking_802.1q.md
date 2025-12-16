# 802.1Q ja Trunk pordid

## Probleem: kuidas saata mitut VLANi ühe kaabli kaudu?

Kui sul on kaks switchi ja mõlemal on mitu VLANi, kuidas nad omavahel suhtlevad?

![VLANid kahe switchi vahel](https://cdn.networklessons.com/wp-content/uploads/2014/07/8021q-trunk-example.png)

Ilma trunk'ita vajaksid **iga VLANi jaoks eraldi kaablit** - see pole praktiline!

---

## Lahendus: Trunk link

**Trunk** on ühendus, mis kannab mitut VLANi ühe kaabli kaudu.

Aga kuidas switch teab, millisesse VLANi kaader kuulub? Tavaline Ethernet kaader ei ütle midagi VLANi kohta!

Vaata - pole ühtegi välja VLANi jaoks!

---

## 802.1Q märgistamine (tagging)

**802.1Q** on tööstusstandard, mis lisab Ethernet kaadrisse **4-baidise märgendi (tag)**.

![802.1Q kaader](https://cdn.networklessons.com/wp-content/uploads/2014/07/8021q-frame-headers.png)

**Märgendi struktuur (4 baiti = 32 bitti):**

| Väli | Suurus | Selgitus |
|------|--------|----------|
| EtherType | 16 bitti | Alati 0x8100 (ütleb et see on 802.1Q kaader) |
| Priority | 3 bitti | QoS prioriteet (0-7), kõrgem = tähtsam |
| CFI | 1 bitt | Canonical Format Indicator (tavaliselt 0) |
| VLAN ID | 12 bitti | VLANi number (0-4095) |

**12 bitti VLAN ID = 2^12 = 4096 võimalikku VLANi** (tegelikult 1-4094 kasutatavad)

---

## Kaks trunk protokolli

| Protokoll | Tüüp | Märkus |
|-----------|------|--------|
| **802.1Q** | IEEE standard | Kõik tootjad toetavad, **KASUTA SEDA!** |
| **ISL** | Cisco proprietary | Vana, ainult Cisco, enam ei kasutata |

**Alati kasuta 802.1Q!**

---

## Kuidas märgistamine töötab?

1. **Arvuti** saadab tavalise Ethernet kaadri (märgistamata)
2. **Switch** võtab kaadri vastu access pordist
3. Switch teab, et see port on VLAN 50-s
4. Kui kaader läheb **trunk porti**, lisab switch **802.1Q märgendi** (VLAN 50)
5. Teine switch saab kaadri, loeb märgendi, teab et see on VLAN 50
6. Switch **eemaldab märgendi** ja saadab kaadri õigesse access porti

**NB!** Lõppseadmed (arvutid) ei näe kunagi märgendeid - need on ainult switchide vahel!

---

## Native VLAN (vaikimisi VLAN trunk'il)

**Native VLAN** on eriline - selle liiklust **EI märgistata**!

Vaikimisi on Native VLAN = VLAN 1

```
SW1#show interface fa0/14 trunk

Port        Mode         Encapsulation  Status        Native vlan
Fa0/14      on           802.1q         trunking      1
```

**Miks Native VLAN eksisteerib?**
- Vanade seadmete jaoks, mis ei mõista 802.1Q
- Haldusprotokollid (CDP, VTP, DTP) liiguvad native VLANis

**TURVAVIHJE:** Muuda Native VLAN ära VLAN 1 pealt! VLAN 1 on rünnakute sihtmärk (VLAN hopping).

---

## Trunk seadistamine

### Topoloogia

![Trunk topoloogia](https://cdn.networklessons.com/wp-content/uploads/2013/02/two-cisco-switches.png)

Kaks switchi, igaühel arvuti, teeme trunk'i nende vahel.

### Samm 1: Loo VLAN mõlemal switchil

```
SW1(config)#vlan 50
SW1(config-vlan)#name Computers
SW1(config-vlan)#exit

SW2(config)#vlan 50
SW2(config-vlan)#name Computers
SW2(config-vlan)#exit
```

### Samm 2: Määra access pordid

```
SW1(config)#interface fa0/1
SW1(config-if)#switchport mode access
SW1(config-if)#switchport access vlan 50

SW2(config)#interface fa0/2
SW2(config-if)#switchport mode access
SW2(config-if)#switchport access vlan 50
```

### Samm 3: Seadista trunk

```
SW1(config)#interface fa0/14
SW1(config-if)#switchport trunk encapsulation dot1q
SW1(config-if)#switchport mode trunk

SW2(config)#interface fa0/14
SW2(config-if)#switchport trunk encapsulation dot1q
SW2(config-if)#switchport mode trunk
```

**NB!** Mõned uuemad switchid toetavad ainult 802.1Q ja ei vaja `encapsulation dot1q` käsku.

---

## Trunk kontrollimine

### show interfaces trunk

```
SW1#show interfaces fa0/14 trunk

Port        Mode         Encapsulation  Status        Native vlan
Fa0/14      on           802.1q         trunking      1

Port        Vlans allowed on trunk
Fa0/14      1-4094

Port        Vlans allowed and active in management domain
Fa0/14      1,50

Port        Vlans in spanning tree forwarding state and not pruned
Fa0/14      1,50
```

**Mida näeme:**
- `Mode: on` - trunk on sisse lülitatud
- `Encapsulation: 802.1q` - kasutame 802.1Q
- `Status: trunking` - trunk töötab
- `Native vlan: 1` - märgistamata liiklus läheb VLAN 1
- `Vlans allowed: 1-4094` - kõik VLANid lubatud
- `Vlans active: 1,50` - hetkel aktiivsed ainult VLAN 1 ja 50

### show vlan - trunk porte EI NÄITA!

```
SW1#show vlan

VLAN Name                             Status    Ports
---- -------------------------------- --------- -------------------------------
1    default                          active    Fa0/3, Fa0/4...
50   Computers                        active    Fa0/1
```

**TÄHTIS:** `show vlan` näitab AINULT access porte! Trunk porte seal pole!

---

## Switchport režiimid

Cisco switchidel on mitu pordi režiimi:

| Režiim | Selgitus |
|--------|----------|
| `access` | Alati access port (üks VLAN) |
| `trunk` | Alati trunk port (mitu VLANi) |
| `dynamic auto` | Eelistab access, aga läheb trunk'iks kui teine pool tahab |
| `dynamic desirable` | Aktiivselt proovib trunk'i teha |

### DTP (Dynamic Trunking Protocol)

DTP on Cisco protokoll, mis automaatselt lepib trunk'i kokku.

**Režiimide kombinatsioonid:**

|  | trunk | access | dynamic auto | dynamic desirable |
|--|-------|--------|--------------|-------------------|
| **trunk** | Trunk | ❌ Limited | Trunk | Trunk |
| **access** | ❌ Limited | Access | Access | Access |
| **dynamic auto** | Trunk | Access | Access | Trunk |
| **dynamic desirable** | Trunk | Access | Trunk | Trunk |

**TURVAVIHJE:** Ära kasuta dynamic režiime tootmisvõrgus! Määra alati selgelt `trunk` või `access`.

```
SW1(config-if)#switchport nonegotiate
```
See käsk lülitab DTP välja.

---

## Native VLANi muutmine

Vaikimisi on Native VLAN = 1. Turvalisuse jaoks muuda see:

```
SW1(config)#interface fa0/14
SW1(config-if)#switchport trunk native vlan 99

SW2(config)#interface fa0/14
SW2(config-if)#switchport trunk native vlan 99
```

**TÄHTIS:** Native VLAN peab olema mõlemal pool SAMA! Muidu tekivad probleemid.

Kontrollimine:
```
SW1#show interfaces fa0/14 trunk

Port        Mode         Encapsulation  Status        Native vlan
Fa0/14      on           802.1q         trunking      99
```

---

## Trunk käskude kokkuvõte

| Käsk | Selgitus |
|------|----------|
| `switchport mode trunk` | Sea port trunk režiimi |
| `switchport trunk encapsulation dot1q` | Kasuta 802.1Q (vanematel switchidel) |
| `switchport trunk native vlan 99` | Muuda native VLAN |
| `switchport trunk allowed vlan 10,20,30` | Luba ainult teatud VLANid |
| `switchport trunk allowed vlan add 40` | Lisa VLAN lubatute hulka |
| `switchport trunk allowed vlan remove 10` | Eemalda VLAN |
| `switchport nonegotiate` | Lülita DTP välja |
| `show interfaces trunk` | Näita trunk infot |
| `show interfaces fa0/14 switchport` | Pordi detailne info |

---

## Näidiskonfiguratsioon

### SW1
```
hostname SW1
!
vlan 50
 name Computers
!
interface FastEthernet0/1
 switchport mode access
 switchport access vlan 50
!
interface FastEthernet0/14
 switchport trunk encapsulation dot1q
 switchport mode trunk
!
end
```

### SW2
```
hostname SW2
!
vlan 50
 name Computers
!
interface FastEthernet0/2
 switchport mode access
 switchport access vlan 50
!
interface FastEthernet0/14
 switchport trunk encapsulation dot1q
 switchport mode trunk
!
end
```

---

## Kontrollküsimused

1. Miks on trunk vajalik kahe switchi vahel?
2. Mis on 802.1Q märgendi suurus baitides?
3. Mis on Native VLAN ja miks on see oluline?
4. Miks `show vlan` ei näita trunk porte?
5. Miks ei tohiks kasutada dynamic režiime?
6. Mis juhtub kui Native VLAN on switchidel erinev?

---

## Lisalugemine

- [NetworkLessons: 802.1Q Encapsulation](https://networklessons.com/switching/802-1q-encapsulation-explained)
- [NetworkLessons: Trunking on Cisco IOS Switch](https://networklessons.com/switching/how-to-configure-trunk-on-cisco-catalyst-switch)
- [NetworkLessons: Native VLAN](https://networklessons.com/switching/802-1q-native-vlan-cisco-ios-switch)
- [NetworkLessons: DTP Negotiation](https://networklessons.com/switching/cisco-dtp-dynamic-trunking-protocol-negotiation)
