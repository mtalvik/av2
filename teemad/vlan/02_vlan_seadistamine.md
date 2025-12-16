# VLANide seadistamine Cisco switchil

## Topoloogia

![VLAN topoloogia](https://cdn.networklessons.com/wp-content/uploads/2013/02/two-computers-cisco-2950-switch-1.png)

Meil on kaks arvutit (H1 ja H2) ühendatud switchiga SW1. Paneme nad samasse VLANi.

---

## Vaikimisi VLAN seadistus

Kõigepealt vaatame, mis VLANid on switchil vaikimisi:

```
SW1#show vlan

VLAN Name                             Status    Ports
---- -------------------------------- --------- -------------------------------
1    default                          active    Fa0/1, Fa0/2, Fa0/3, Fa0/4
                                                Fa0/5, Fa0/6, Fa0/7, Fa0/8
                                                Fa0/9, Fa0/10, Fa0/12
                                                Fa0/13, Fa0/14, Fa0/22
                                                Fa0/23, Fa0/24, Gi0/1, Gi0/2
1002 fddi-default                     act/unsup
1003 token-ring-default               act/unsup
1004 fddinet-default                  act/unsup
1005 trnet-default                    act/unsup
```

**Mida me näeme:**
- VLAN 1 on vaikimisi VLAN
- KÕIK aktiivsed pordid on VLAN 1-s
- VLANid 1002-1005 on reserveeritud (act/unsup = active/unsupported)

---

## VLAN info salvestamine

**TÄHTIS!** VLAN info EI salvestu running-config ega startup-config faili!

VLAN info salvestatakse eraldi faili: `vlan.dat` flash mälus.

Kui tahad VLANe kustutada:
```
SW1#delete flash:vlan.dat
```

---

## Uue VLANi loomine

```
SW1(config)#vlan 50
SW1(config-vlan)#name Computers
SW1(config-vlan)#exit
```

**Selgitus:**
1. `vlan 50` - loob VLANi numbriga 50 (või siseneb olemasolevasse)
2. `name Computers` - annab VLANile nime (valikuline, aga soovituslik!)
3. `exit` - väljub VLAN konfiguratsioonist

Kontrollime:
```
SW1#show vlan

VLAN Name                             Status    Ports
---- -------------------------------- --------- -------------------------------
1    default                          active    Fa0/1, Fa0/2, Fa0/3, Fa0/4...
50   Computers                        active
```

VLAN 50 on loodud ja aktiivne, aga ükski port pole veel seal!

---

## Portide määramine VLANi

```
SW1(config)#interface fa0/1
SW1(config-if)#switchport mode access
SW1(config-if)#switchport access vlan 50

SW1(config)#interface fa0/2
SW1(config-if)#switchport mode access
SW1(config-if)#switchport access vlan 50
```

**Selgitus:**
1. `interface fa0/1` - vali port FastEthernet 0/1
2. `switchport mode access` - sea port access režiimi (ühe VLANi jaoks)
3. `switchport access vlan 50` - määra port VLANi 50

**NB!** Kui VLANi 50 poleks olemas, looksid need käsud selle automaatselt!

---

## Kontrollimine

### show vlan
```
SW1#show vlan

VLAN Name                             Status    Ports
---- -------------------------------- --------- -------------------------------
1    default                          active    Fa0/3, Fa0/4, Fa0/5...
50   Computers                        active    Fa0/1, Fa0/2
```

Nüüd on Fa0/1 ja Fa0/2 VLAN 50-s!

### show interfaces switchport
```
SW1#show interfaces fa0/1 switchport
Name: Fa0/1
Switchport: Enabled
Administrative Mode: static access
Operational Mode: static access
Administrative Trunking Encapsulation: negotiate
Operational Trunking Encapsulation: native
Negotiation of Trunking: Off
Access Mode VLAN: 50 (Computers)
Trunking Native Mode VLAN: 1 (default)
```

**Mida me näeme:**
- `Administrative Mode: static access` - port on seadistatud access režiimi
- `Operational Mode: static access` - port töötab access režiimis
- `Access Mode VLAN: 50 (Computers)` - port on VLAN 50-s

---

## Mitme pordi korraga seadistamine

Kui tahad mitut porti korraga seadistada:

```
SW1(config)#interface range fa0/1 - 10
SW1(config-if-range)#switchport mode access
SW1(config-if-range)#switchport access vlan 50
```

See seadistab pordid Fa0/1 kuni Fa0/10 kõik VLANi 50.

**Võid ka mitte-järjestikuseid porte valida:**
```
SW1(config)#interface range fa0/1 - 5, fa0/10, fa0/15 - 20
```

---

## VLANi kustutamine

```
SW1(config)#no vlan 50
```

**HOIATUS!** Kui kustutad VLANi, jäävad pordid sellesse VLANi määratuks, aga nad ei tööta! Pead pordid ümber määrama enne või pärast kustutamist.

---

## Praktilised käsud kokkuvõte

| Käsk | Selgitus |
|------|----------|
| `show vlan` | Näita kõiki VLANe ja nende porte |
| `show vlan brief` | Lühike ülevaade VLANidest |
| `show interfaces switchport` | Pordi detailne info |
| `show interfaces fa0/1 switchport` | Konkreetse pordi info |
| `vlan 50` | Loo VLAN 50 (või sisene olemasolevasse) |
| `name Nimi` | Anna VLANile nimi |
| `switchport mode access` | Sea port access režiimi |
| `switchport access vlan 50` | Määra port VLANi 50 |
| `no vlan 50` | Kustuta VLAN 50 |

---

## Näidiskonfiguratsioon

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
interface FastEthernet0/2
 switchport mode access
 switchport access vlan 50
!
end
```

---

## Kontrollküsimused

1. Kus salvestatakse VLAN informatsioon?
2. Mis käsuga näed, millises VLANis port on?
3. Mis juhtub kui määrad pordi VLANi, mida pole olemas?
4. Mis juhtub portidega kui kustutad VLANi?
5. Mis vahe on `show vlan` ja `show interfaces switchport` käskudel?

---

## Lisalugemine

- [NetworkLessons: How to configure VLANs](https://networklessons.com/switching/how-to-configure-vlans-on-cisco-catalyst-switch)
