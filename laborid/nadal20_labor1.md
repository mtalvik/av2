# Nädal 20 - Labor 1: STP optimeerimine

**Kestus:** 40 min
**Eeldus:** Nädal 19 labor töötab, GNS3 seadistatud

---

## Eesmärk

- Seadistada Root Bridge käsitsi
- Rakendada PortFast ja BPDU Guard
- Testida STP konvergentsi

---

## Topoloogia

```
         [PC1]         [PC2]
           |             |
         e0/2          e0/2
           |             |
         SW1-----------SW2
        (ROOT)   e0/0   |
           \           / e0/1
          e0/1\      /
              SW3----
             e0/0
```

Kasutame eelmise nädala topoloogiat + lisame "PC-d" (võib olla lihtsalt VPCS või loopback).

---

## Osa 1: Root Bridge käsitsi määramine (10 min)

### Ülesanne 1.1 - Kontrolli praegust Root Bridge'i

```
SW1# show spanning-tree vlan 1
```

**Kirjuta üles:** Kes on praegu Root? ___________

### Ülesanne 1.2 - Määra SW1 Root Bridge'iks

**SW1:**
```
SW1(config)# spanning-tree vlan 1 root primary
```

Või täpsemalt:
```
SW1(config)# spanning-tree vlan 1 priority 4096
```

### Ülesanne 1.3 - Määra SW2 Secondary Root

**SW2:**
```
SW2(config)# spanning-tree vlan 1 root secondary
```

### Ülesanne 1.4 - Kontrolli

```
SW1# show spanning-tree vlan 1
SW2# show spanning-tree vlan 1
SW3# show spanning-tree vlan 1
```

**Küsimused:**
1. Mis on SW1 priority nüüd? ___________
2. Mis on SW2 priority nüüd? ___________
3. Milline port on Blocked? ___________

---

## Osa 2: PortFast seadistamine (10 min)

### Ülesanne 2.1 - Lisa "PC" port (simulatsioon)

Me simuleerime PC porti loopback interface'iga:

**SW1:**
```
SW1(config)# interface e0/2
SW1(config-if)# description PC1_PORT
SW1(config-if)# switchport mode access
SW1(config-if)# switchport access vlan 10
```

### Ülesanne 2.2 - Luba PortFast

```
SW1(config-if)# spanning-tree portfast
```

Näed hoiatust:
```
%Warning: portfast should only be enabled on ports connected to a single host.
```

### Ülesanne 2.3 - Kontrolli PortFast staatust

```
SW1# show spanning-tree interface e0/2 detail
```

Otsi rida: `The port is in the portfast mode`

### Ülesanne 2.4 - Globaalne PortFast (kõik access pordid)

```
SW1(config)# spanning-tree portfast default
```

**Küsimus:** Miks see on ohtlik? ___________

---

## Osa 3: BPDU Guard (10 min)

### Ülesanne 3.1 - Luba BPDU Guard portidel

**SW1:**
```
SW1(config)# interface e0/2
SW1(config-if)# spanning-tree bpduguard enable
```

### Ülesanne 3.2 - Testi BPDU Guard

Simuleerime "vale switchi" ühendamist:

1. Ühenda **SW3** port **e0/2** → **SW1** port **e0/2**
2. Jälgi SW1 konsooli

**Mis juhtus?**
```
%SPANTREE-2-BLOCK_BPDUGUARD: Received BPDU on port e0/2...
%PM-4-ERR_DISABLE: bpduguard error detected on e0/2...
```

### Ülesanne 3.3 - Vaata err-disabled porti

```
SW1# show interfaces status err-disabled
```

### Ülesanne 3.4 - Taasta port

```
SW1(config)# interface e0/2
SW1(config-if)# shutdown
SW1(config-if)# no shutdown
```

**Eemalda enne testimise link!**

### Ülesanne 3.5 - Globaalne BPDU Guard

```
SW1(config)# spanning-tree portfast bpduguard default
```

---

## Osa 4: STP konvergentsi test (10 min)

### Ülesanne 4.1 - Mõõda konvergentsi aeg

**SW2:**
```
SW2# debug spanning-tree events
```

**GNS3:** Peata link SW1-SW2 (paremklikk → Suspend)

**Jälgi aega:** Kui kaua võtab SW3-l uue tee leidmine?

```
SW2# undebug all
```

### Ülesanne 4.2 - Proovi RSTP (kui aega)

```
SW1(config)# spanning-tree mode rapid-pvst
SW2(config)# spanning-tree mode rapid-pvst
SW3(config)# spanning-tree mode rapid-pvst
```

Korda testi - kas konvergents on kiirem?

---

## Kokkuvõte

**Täida tabel:**

| Konfiguratsioon | Käsk |
|-----------------|------|
| Root primary | `spanning-tree vlan X root primary` |
| Root secondary | `spanning-tree vlan X root secondary` |
| PortFast (port) | `spanning-tree portfast` |
| PortFast (global) | `spanning-tree portfast default` |
| BPDU Guard (port) | `spanning-tree bpduguard enable` |
| BPDU Guard (global) | `spanning-tree portfast bpduguard default` |

---

## Salvesta!

```
SW1# wr
SW2# wr
SW3# wr
```
