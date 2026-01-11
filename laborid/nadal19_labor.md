# Nädal 19 - Labor: STP + VTP kordamine

**Kestus:** 50 min
**Eeldused:** GNS3 installitud, IOL-XE töötab

---

## Topoloogia

```
        SW1
       /   \
    e0/0   e0/1
     /       \
   SW2-------SW3
       e0/0
```

**3 switchit kolmnurgaks ühendatud = STP peab ühe lingi blokeerima!**

---

## Osa 1: Topoloogia loomine (10 min)

### Samm 1.1 - Uus projekt

1. GNS3: `File` → `New blank project`
2. Nimi: `N19_STP_VTP_Labor`

### Samm 1.2 - Lisa 3 switchit

1. Lohista **Switch-L2** töölauale
2. Nimeta: `SW1`, `SW2`, `SW3` (paremklikk → Change hostname)

### Samm 1.3 - Ühenda kolmnurgaks

| Ühendus | SW1 port | SW2 port | SW3 port |
|---------|----------|----------|----------|
| SW1-SW2 | e0/0 | e0/0 | - |
| SW1-SW3 | e0/1 | - | e0/0 |
| SW2-SW3 | - | e0/1 | e0/1 |

### Samm 1.4 - Käivita

Vajuta **Start all nodes** (roheline ▶️)

Oota ~30-60 sek kuni switchid bootivad.

---

## Osa 2: STP uurimine (15 min)

### Ülesanne 2.1 - Leia Root Bridge

Ava konsool **igal switchil** ja sisesta:

```
SW1# show spanning-tree
```

**Küsimused:**
1. Milline switch on Root Bridge? ___________
2. Miks just see? (vihje: Bridge ID) ___________

### Ülesanne 2.2 - Port rollid

```
SW1# show spanning-tree | include role
```

**Täida tabel:**

| Switch | Port | Role | State |
|--------|------|------|-------|
| SW1 | e0/0 | | |
| SW1 | e0/1 | | |
| SW2 | e0/0 | | |
| SW2 | e0/1 | | |
| SW3 | e0/0 | | |
| SW3 | e0/1 | | |

**Küsimus:** Milline port on **Blocked/Alternate**? ___________

### Ülesanne 2.3 - Testi konvergentsi

1. Ühenda SW2 konsoolile
2. Sisesta: `debug spanning-tree events`
3. GNS3-s: **Peata** üks link (paremklikk → Stop)
4. Jälgi debug väljundit

**Küsimus:** Kui kaua võttis STP uue tee leidmine? ___________

```
SW2# undebug all
```

---

## Osa 3: VTP seadistamine (15 min)

### Ülesanne 3.1 - VTP domeeni loomine

**SW1** (saab serveriks):
```
SW1# configure terminal
SW1(config)# vtp domain AV2LAB
SW1(config)# vtp mode server
SW1(config)# vtp password cisco123
SW1(config)# end
SW1# show vtp status
```

**Küsimus:** Mis on SW1 VTP revision number? ___________

### Ülesanne 3.2 - VTP client seadistus

**SW2 ja SW3:**
```
SW2# configure terminal
SW2(config)# vtp domain AV2LAB
SW2(config)# vtp mode client
SW2(config)# vtp password cisco123
SW2(config)# end
```

### Ülesanne 3.3 - Loo VLANid serveris

**SW1:**
```
SW1# configure terminal
SW1(config)# vlan 10
SW1(config-vlan)# name TUDENGID
SW1(config-vlan)# vlan 20
SW1(config-vlan)# name OPETAJAD
SW1(config-vlan)# vlan 99
SW1(config-vlan)# name MANAGEMENT
SW1(config-vlan)# end
```

### Ülesanne 3.4 - Kontrolli sünkroniseerimist

**SW2 ja SW3:**
```
SW2# show vlan brief
```

**Küsimus:** Kas näed VLANe 10, 20, 99? ___________

```
SW3# show vtp status
```

**Küsimus:** Mis on SW3 revision number nüüd? ___________

---

## Osa 4: Kontrolli trunke (5 min)

```
SW1# show interfaces trunk
```

**Küsimused:**
1. Kas pordid on trunk mode? ___________
2. Milliseid VLANe lubatakse trunkil? ___________

Kui trunk ei tööta automaatselt:
```
SW1(config)# interface range e0/0-1
SW1(config-if-range)# switchport trunk encapsulation dot1q
SW1(config-if-range)# switchport mode trunk
```

---

## Osa 5: Salvesta konfiguratsioon (5 min)

**OLULINE!** Igal switchil:

```
SW1# copy running-config startup-config
```

või lühemalt:
```
SW1# wr
```

---

## Kontrollküsimused (arutelu)

1. **Miks** blokeeris STP just selle pordi?
2. Mis juhtuks kui VTP password oleks **vale**?
3. Kui lisad SW3-le uue VLANi, kas SW1 seda näeb? **Miks?**

---

## Lisaülesanne (kui aega jääb)

**Muuda Root Bridge:**

```
SW3(config)# spanning-tree vlan 1 priority 0
```

Kontrolli:
```
SW1# show spanning-tree
```

**Küsimus:** Kes on nüüd Root Bridge? ___________

---

## Lahendused (õpetajale)

<details>
<summary>Klikka vastuste nägemiseks</summary>

**2.1:** Root Bridge on switch kõige madalama MAC aadressiga (priority on vaikimisi 32768 kõigil)

**2.2:** Üks port peab olema Alternate/Blocked - tüüpiliselt SW3 e0/1 või SW2 e0/1

**3.1:** Revision number algab 0-st

**3.4:** Jah, VLANid sünkroniseeruvad. Revision number suureneb iga muudatusega.

**Lisaülesanne:** SW3 saab Root Bridge'iks sest priority 0 < 32768

</details>
