# Labor 1: VLANide loomine ja Trunk seadistamine

## Topoloogia

```
        VLAN 10 (Students)              VLAN 10 (Students)
            PC1                              PC3
             |                                |
           Fa0/1                            Fa0/1
        +-------+        Fa0/24        +-------+
        |  SW1  |======================|  SW2  |
        +-------+         Trunk        +-------+
           Fa0/2                            Fa0/2
             |                                |
            PC2                              PC4
        VLAN 20 (Teachers)              VLAN 20 (Teachers)
```

---

## IP-aadressid

| Seade | VLAN | IP-aadress | Gateway |
|-------|------|------------|---------|
| PC1 | 10 | 192.168.10.1/24 | - |
| PC3 | 10 | 192.168.10.3/24 | - |
| PC2 | 20 | 192.168.20.2/24 | - |
| PC4 | 20 | 192.168.20.4/24 | - |

---

## Ülesanne

### Osa 1: VLANide loomine (SW1)

1. Ühenda SW1-ga
2. Loo VLAN 10 nimega "Students"
3. Loo VLAN 20 nimega "Teachers"

```
SW1>enable
SW1#configure terminal
SW1(config)#vlan ?
SW1(config)#vlan 10
SW1(config-vlan)#name ?
SW1(config-vlan)#name Students
SW1(config-vlan)#exit
SW1(config)#vlan 20
SW1(config-vlan)#name Teachers
SW1(config-vlan)#exit
```

**Kontrolli:**
```
SW1#show vlan brief
```

**Küsimus:** Millises VLANis on hetkel kõik pordid?

---

### Osa 2: Portide määramine VLANidesse (SW1)

1. Sea Fa0/1 access režiimi ja VLANi 10
2. Sea Fa0/2 access režiimi ja VLANi 20

```
SW1(config)#interface fa0/1
SW1(config-if)#switchport mode access
SW1(config-if)#switchport access vlan 10
SW1(config-if)#exit

SW1(config)#interface fa0/2
SW1(config-if)#switchport mode access
SW1(config-if)#switchport access vlan 20
SW1(config-if)#exit
```

**Kontrolli:**
```
SW1#show vlan brief
SW1#show interfaces fa0/1 switchport
```

**Küsimus:** Mida näitab "Administrative Mode" ja "Operational Mode"?

---

### Osa 3: Korda sama SW2 peal

1. Loo samad VLANid (10 ja 20) SW2 peal
2. Määra Fa0/1 → VLAN 10, Fa0/2 → VLAN 20

```
SW2>enable
SW2#configure terminal
SW2(config)#vlan 10
SW2(config-vlan)#name Students
SW2(config-vlan)#exit
SW2(config)#vlan 20
SW2(config-vlan)#name Teachers
SW2(config-vlan)#exit

SW2(config)#interface fa0/1
SW2(config-if)#switchport mode access
SW2(config-if)#switchport access vlan 10
SW2(config-if)#exit

SW2(config)#interface fa0/2
SW2(config-if)#switchport mode access
SW2(config-if)#switchport access vlan 20
SW2(config-if)#exit
```

---

### Osa 4: Ühenduvuse test ENNE trunk'i

**Proovi ping'ida:**

PC1 → PC3: `ping 192.168.10.3`

**Küsimus:** Kas ping töötab? Miks / miks mitte?

---

### Osa 5: Trunk seadistamine

**SW1:**
```
SW1(config)#interface fa0/24
SW1(config-if)#switchport trunk encapsulation dot1q
SW1(config-if)#switchport mode trunk
SW1(config-if)#exit
```

**SW2:**
```
SW2(config)#interface fa0/24
SW2(config-if)#switchport trunk encapsulation dot1q
SW2(config-if)#switchport mode trunk
SW2(config-if)#exit
```

**NB!** Kui saad veateate `encapsulation` käsuga, jäta see rida vahele (uuemad switchid ei vaja seda).

**Kontrolli:**
```
SW1#show interfaces trunk
SW1#show interfaces fa0/24 switchport
```

**Küsimus:** Mis on Native VLAN väärtus?

---

### Osa 6: Lõplik ühenduvuse test

**Testi järgmisi ühendusi:**

| Allikas | Sihtkoht | Peaks töötama? | Tulemus |
|---------|----------|----------------|---------|
| PC1 (VLAN 10) | PC3 (VLAN 10) | JAH | |
| PC2 (VLAN 20) | PC4 (VLAN 20) | JAH | |
| PC1 (VLAN 10) | PC2 (VLAN 20) | EI | |
| PC1 (VLAN 10) | PC4 (VLAN 20) | EI | |

**Küsimus:** Miks VLAN 10 ja VLAN 20 ei saa omavahel suhelda?

---

## Boonusülesanne

1. Muuda Native VLAN väärtuseks 99 mõlemal switchil
2. Loo VLAN 99 mõlemal switchil (nimi: "Native")
3. Kontrolli, et trunk ikka töötab

```
SW1(config)#vlan 99
SW1(config-vlan)#name Native
SW1(config-vlan)#exit
SW1(config)#interface fa0/24
SW1(config-if)#switchport trunk native vlan 99
```

---

## Esitamine

Labori lõpus näita õpetajale:
1. `show vlan brief` mõlemal switchil
2. `show interfaces trunk` mõlemal switchil
3. Töötav ping VLAN 10 sees (PC1 → PC3)
4. Töötav ping VLAN 20 sees (PC2 → PC4)

---

## Tõrkeotsing

**Ping ei tööta sama VLANi sees:**
- Kontrolli IP-aadresse (sama võrk?)
- Kontrolli VLAN määramist: `show vlan brief`
- Kontrolli pordi staatust: `show interfaces status`

**Trunk ei tööta:**
- Kontrolli mõlemat poolt: `show interfaces trunk`
- Kas encapsulation on sama? (dot1q)
- Kas native VLAN on sama mõlemal pool?

**VLAN pole näha:**
- Kas lõid VLANi mõlemal switchil?
- VLANid EI levi automaatselt (VTP on välja lülitatud)

---

## Käskude kokkuvõte

| Käsk | Mida teeb |
|------|-----------|
| `vlan 10` | Loo VLAN 10 |
| `name Students` | Anna VLANile nimi |
| `switchport mode access` | Sea port access režiimi |
| `switchport access vlan 10` | Määra port VLANi 10 |
| `switchport mode trunk` | Sea port trunk režiimi |
| `switchport trunk encapsulation dot1q` | Kasuta 802.1Q |
| `switchport trunk native vlan 99` | Muuda native VLAN |
| `show vlan brief` | Näita VLANide lühiülevaadet |
| `show interfaces trunk` | Näita trunk infot |
| `show interfaces fa0/1 switchport` | Näita pordi detaile |
