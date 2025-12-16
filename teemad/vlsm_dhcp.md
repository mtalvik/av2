# VLSM meeldetuletus

## Mis on VLSM?
**Variable Length Subnet Masking** = Erineva suurusega alamvõrgud

Selle asemel et jagada võrk võrdselt:
```
192.168.1.0/24 → 4 võrdset /26 alamvõrku (igaüks 64 aadressi)
```

Saame teha targalt:
```
192.168.1.0/24 → Erinevad suurused vastavalt vajadusele
```

## 📚 Eelmine nädal: Võrdne jagamine

### Kuidas jagada /24 neljaks võrdseks osaks?

### 🎯 Magic Number meetod

**Magic Number = alamvõrgu suurus**

**Kuidas leida Magic Number?**
```
256 - subnet mask viimane oktet = Magic Number
```

**Näited:**
- /26 mask = 255.255.255.192
- Magic Number = 256 - 192 = **64**
- Alamvõrgud: 0, 64, 128, 192

- /27 mask = 255.255.255.224  
- Magic Number = 256 - 224 = **32**
- Alamvõrgud: 0, 32, 64, 96, 128, 160, 192, 224

- /25 mask = 255.255.255.128
- Magic Number = 256 - 128 = **128**
- Alamvõrgud: 0, 128

**Reegel:** Iga järgmine alamvõrk = eelmine + Magic Number

**Näide: 192.168.1.0/26 jagamine:**
```
Magic Number = 256 - 192 = 64

Subnet 1: 192.168.1.0   (+64)
Subnet 2: 192.168.1.64  (+64)
Subnet 3: 192.168.1.128 (+64)
Subnet 4: 192.168.1.192 (lõpp: 255)
```

**2. Uus mask:**
- Vana: /24 (255.255.255.0)
- Uus: /24 + 2 = /26 (255.255.255.192)

**3. Iga alamvõrk saab:**
- 256 ÷ 4 = 64 aadressi
- 62 kasutatavat hosti

**4. Näide 192.168.1.0/24 → 4 x /26:**
```
Subnet 1: 192.168.1.0/26   (0-63)
          Network: .0, Broadcast: .63
          Gateway: .1, DHCP: .2-.62

Subnet 2: 192.168.1.64/26  (64-127)
          Network: .64, Broadcast: .127
          Gateway: .65, DHCP: .66-.126

Subnet 3: 192.168.1.128/26 (128-191)
          Network: .128, Broadcast: .191
          Gateway: .129, DHCP: .130-.190

Subnet 4: 192.168.1.192/26 (192-255)
          Network: .192, Broadcast: .255
          Gateway: .193, DHCP: .194-.254
```

## 🎯 See nädal: VLSM (erinev suurus!)

## 🐵 Lihtne VLSM reegel

### 1️⃣ SORTEERI (suuremast väiksemani)
```
Vajadused:
- Kontor: 100 hosti
- Müük: 50 hosti  
- IT: 20 hosti
- Link: 2 hosti

↓ SORTEERI ↓

1. Kontor: 100 hosti
2. Müük: 50 hosti
3. IT: 20 hosti
4. Link: 2 hosti
```

### 2️⃣ ARVUTA (kui palju tegelikult vaja?)
```
Vajab hosti → Vaja aadresse → Subnet
100 hosti → 128 (2^7) → /25
50 hosti → 64 (2^6) → /26
20 hosti → 32 (2^5) → /27
2 hosti → 4 (2^2) → /30
```

**Meeldetuletus:** 2^n - 2 = kasutatavad hostid
- -2 tuleneb: võrgu aadress + broadcast

### 3️⃣ MÄÄRA (järjest, ei hüppa!)
```
Baas: 192.168.1.0/24

1. Kontor (/25): 192.168.1.0 - 192.168.1.127
2. Müük (/26): 192.168.1.128 - 192.168.1.191
3. IT (/27): 192.168.1.192 - 192.168.1.223
4. Link (/30): 192.168.1.224 - 192.168.1.227
```

## Subnet Mask Spikker

| CIDR | Mask | Aadresse | Hostid |
|------|------|----------|--------|
| /30 | 255.255.255.252 | 4 | 2 |
| /29 | 255.255.255.248 | 8 | 6 |
| /28 | 255.255.255.240 | 16 | 14 |
| /27 | 255.255.255.224 | 32 | 30 |
| /26 | 255.255.255.192 | 64 | 62 |
| /25 | 255.255.255.128 | 128 | 126 |
| /24 | 255.255.255.0 | 256 | 254 |
| /23 | 255.255.254.0 | 512 | 510 |
| /22 | 255.255.252.0 | 1024 | 1022 |

## /23 Näide (teie labor!)

```
172.16.18.0/23 = 512 aadressi

See on tegelikult:
- 172.16.18.0 - 172.16.18.255 (esimene /24)
- 172.16.19.0 - 172.16.19.255 (teine /24)

Vajadused:
1. 200 hosti → 256 (kogu esimene /24)
2. 100 hosti → 128 (pool teisest /24)
3. 50 hosti → 64 (veerand teisest /24)
4. 25 hosti → 32 (kaheksandik teisest /24)
```

## Kiire kontroll
✅ Kas alamvõrgud kattuvad? → EI TOHI!
✅ Kas kõik mahub ära? → PEAB!
✅ Kas alustasin suurimast? → ALATI!

## Arvutamise näpunäide

Kui vaja 73 hosti:
1. 2^? ≥ 73+2 (hostid + network + broadcast)
2. 2^7 = 128 ✅ (2^6 = 64 ❌ liiga väike)
3. Seega vaja /25 (32-7=25)

## 🚫 Vead mida vältida

❌ **Võrkude kattumine**
```
VALE:
Võrk1: 192.168.1.0/26 (0-63)
Võrk2: 192.168.1.32/27 (32-63) ← KATTUB!
```

❌ **Vale järjekord**
```
VALE:
Alustasin väikseimast → jääb auke!
```

❌ **Aadresside raiskamine**
```
VALE:
2 hosti vajadus → /24 võrk (raiskad 252 aadressi!)
```

## 💡 Kiire meeldetuletus
- **Võrdne jagamine** = kõik alamvõrgud sama suured (eelmine nädal)
- **VLSM** = iga alamvõrk täpselt nii suur kui vaja (see nädal)
- **Alati alusta suurimast** = muidu ei mahu ära!
