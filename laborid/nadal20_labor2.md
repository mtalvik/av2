# Nädal 20 - Labor 2: VTP troubleshooting

**Kestus:** 50 min
**Eeldus:** Labor 1 töötab, VLANid seadistatud

---

## Eesmärk

- Mõista VTP revision numbri ohtu
- Troubleshootida VTP probleeme
- Rakendada VTP kaitset

---

## Osa 1: VTP "Bomb" simulatsioon (15 min)

### Stsenaarium

> Oled võrguadmin. Keegi IT-osakonnast toob laost vana switchi (SW4) ja ühendab selle võrku. Switchil on sama VTP domain aga kõrgem revision number...

### Ülesanne 1.1 - Kontrolli praegust seisu

**SW1 (server):**
```
SW1# show vtp status
SW1# show vlan brief
```

**Kirjuta üles:**
- VTP domain: ___________
- Revision number: ___________
- VLANid: ___________

### Ülesanne 1.2 - Lisa "vana switch" (SW4)

GNS3-s:
1. Lisa uus switch **SW4**
2. Ühenda SW4 e0/0 → SW2 e0/2

**SW4 (simuleerib vana switchit):**
```
SW4# configure terminal
SW4(config)# vtp domain AV2LAB
SW4(config)# vtp mode client
SW4(config)# end
```

### Ülesanne 1.3 - Tõsta SW4 revision number

Trikk: revision number tõuseb iga VLAN muudatusega

**SW4:**
```
SW4(config)# vtp mode transparent
SW4(config)# vlan 100
SW4(config-vlan)# exit
SW4(config)# no vlan 100
SW4(config)# vlan 101
SW4(config-vlan)# exit
SW4(config)# no vlan 101
! Korda mitu korda...
SW4(config)# end
SW4# show vtp status
```

Revision peab olema **kõrgem** kui SW1-l!

### Ülesanne 1.4 - Lülita SW4 tagasi client mode

```
SW4(config)# vtp mode client
SW4(config)# end
```

**NB!** Enne järgmist sammu - **salvesta SW1 config** igaks juhuks!

### Ülesanne 1.5 - Ühenda trunk

**SW2:**
```
SW2(config)# interface e0/2
SW2(config-if)# switchport trunk encapsulation dot1q
SW2(config-if)# switchport mode trunk
```

**SW4:**
```
SW4(config)# interface e0/0
SW4(config-if)# switchport trunk encapsulation dot1q
SW4(config-if)# switchport mode trunk
```

### Ülesanne 1.6 - Vaata mis juhtus!

**SW1:**
```
SW1# show vlan brief
SW1# show vtp status
```

**Küsimused:**
1. Kas VLANid on alles? ___________
2. Mis on uus revision number? ___________

😱 **VTP BOMB!**

---

## Osa 2: Taastamine (10 min)

### Ülesanne 2.1 - Kiire lahendus

Katkesta kohe SW4 ühendus! (GNS3: peata link)

### Ülesanne 2.2 - Taasta VLANid käsitsi

**SW1:**
```
SW1(config)# vlan 10
SW1(config-vlan)# name TUDENGID
SW1(config-vlan)# vlan 20
SW1(config-vlan)# name OPETAJAD
SW1(config-vlan)# vlan 99
SW1(config-vlan)# name MANAGEMENT
SW1(config-vlan)# end
```

### Ülesanne 2.3 - Kontrolli teisi switche

```
SW2# show vlan brief
SW3# show vlan brief
```

---

## Osa 3: VTP kaitse (15 min)

### Meetod 1: VTP Password

**Kõik switchid:**
```
SW1(config)# vtp password TugEvPar00l!
SW2(config)# vtp password TugEvPar00l!
SW3(config)# vtp password TugEvPar00l!
```

Testi: Proovi SW4 ilma paroolita ühendada.

### Meetod 2: VTP Transparent mode kriitilistes kohtades

**SW3 (näiteks access switch):**
```
SW3(config)# vtp mode transparent
```

Transparent switch:
- ✅ Edastab VTP infot
- ❌ EI võta vastu muudatusi
- ❌ EI saada oma muudatusi

### Meetod 3: VTP off (IOS 15+)

```
SW4(config)# vtp mode off
```

### Meetod 4: VTPv3 (parim!)

```
SW1(config)# vtp version 3
SW1# vtp primary vlan
```

VTPv3 nõuab **eksplitsiitset** primary server määramist.

---

## Osa 4: Troubleshooting stsenaarium (10 min)

### Stsenaarium A: VLANid ei sünkroniseeru

**Sümptomid:**
- SW1-l on VLAN 10
- SW2-l pole VLAN 10

**Debug:**
```
SW2# show vtp status
SW2# show interfaces trunk
```

**Võimalikud põhjused:**
1. Vale VTP domain
2. Vale password
3. Trunk pole up
4. Transparent mode

### Stsenaarium B: Port ei liigu õigesse VLANi

**Sümptomid:**
- `show vlan brief` näitab VLAN 10
- Port on VLAN 10-s
- Aga liiklus ei toimi

**Debug:**
```
SW1# show interfaces e0/2 switchport
SW1# show spanning-tree vlan 10
```

**Võimalikud põhjused:**
1. Port on err-disabled
2. VLAN pole trunk'il lubatud
3. STP blokeerib

---

## Kontrollküsimused

1. Kuidas **nullida** VTP revision number?
   - Muuda domain → muuda tagasi
   - Või: vtp mode transparent → server

2. Miks on **password** üksi nõrk kaitse?
   - Kui keegi teab parooli, saab ikka "pommitada"

3. Millal kasutada **transparent** mode?
   - Access layer switchidel
   - Testikeskkondades
   - Kui VTP pole üldse vajalik

---

## Boonusülesanne: VTPv3

Kui aega jääb:

```
! Kõigepealt kõik switchid v3 peale
SW1(config)# vtp version 3
SW2(config)# vtp version 3
SW3(config)# vtp version 3

! Määra primary server (nõuab exec mode!)
SW1# vtp primary vlan
```

Proovi nüüd SW4 "pommi" - kas töötab?

---

## Salvesta!

```
SW1# wr
SW2# wr
SW3# wr
```

---

## Lahendused (õpetajale)

<details>
<summary>Klikka vastuste nägemiseks</summary>

**VTP Bomb:** Kui SW4 revision > SW1 revision, siis SW4 VLAN database kirjutab üle KÕIK switchid (ka serveri!)

**Taastamine:** VLANid tuleb käsitsi uuesti luua. Või: taasta startup-config backupist.

**Parim kaitse:** VTPv3 + password + primary server

</details>
