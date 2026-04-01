# ACL — Access Control List

## Mis on ACL?

ACL on nimekiri reeglitest, mis ütleb ruuterile: **"Lase see pakett läbi"** või **"Blokeeri see pakett"**.

Mõtle sellest nagu turvatöötajast uksehoidjast klubis. Tal on nimekiri — kes pääseb sisse, kes mitte. Ruuter teeb sama asja pakettidega.

Ilma ACL-ita laseb ruuter **kõik paketid** läbi. See on nagu lahtine uks — igaüks pääseb. ACL paneb uksele turvatöötaja.

---

## Kus sa oled ACL-i juba kasutanud?

NAT seadistamises! Mäleta seda rida:

```
R1(config)# access-list 1 permit 192.168.1.0 0.0.0.255
R1(config)# ip nat inside source list 1 interface G0/1 overload
```

See `access-list 1 permit ...` ongi ACL! Ta ütleb: "need aadressid saavad NAT-i". ACL ei pea alati liiklust blokeerima — ta võib ka lihtsalt **liiklust tuvastada** teiste funktsioonide jaoks (NAT, VPN, QoS).

Aga ACL kõige tavalisem kasutus on ikkagi liikluse filtreerimine — kes pääseb kuhu.

---

## Permit ja Deny — kuidas loogika töötab?

ACL on **järjestatud nimekiri**. Ruuter loeb ridu ülalt alla ja peatub **esimese sobiva** juures.

```
10 permit 192.168.1.0 0.0.0.255
20 deny   192.168.2.0 0.0.0.255
30 permit any
```

Kui pakett tuleb aadressilt 192.168.1.50:
1. Rida 10: Kas 192.168.1.50 sobib 192.168.1.0/24-ga? **JAH** → PERMIT → **lõpeta**
2. Ridu 20 ja 30 ei vaadatagi

Kui pakett tuleb aadressilt 192.168.2.100:
1. Rida 10: Kas 192.168.2.100 sobib 192.168.1.0/24-ga? EI → liigu edasi
2. Rida 20: Kas sobib 192.168.2.0/24-ga? **JAH** → DENY → **lõpeta, pakett visatakse ära**

### Implicit deny — nähtamatu reegel lõpus

**See on kõige tähtsam asi ACL-ides!**

Iga ACL lõpus on peidetud reegel, mida sa ei näe:

```
deny any
```

See tähendab: **kõik, mis ei sobinud ühegi reegli alla, visatakse ära.**

Seepärast peab ACL-is alati olema vähemalt üks `permit`, muidu blokeeritakse KÕIK.

---

## Wildcard mask — mis see on?

Sa juba tead subnet maski: `255.255.255.0`. Wildcard mask on **vastupidine** — pöörab bitid ümber.

| Subnet mask | Wildcard mask | Tähendus |
|-------------|---------------|----------|
| 255.255.255.0 | 0.0.0.255 | Esimesed 3 oktetti peavad klappima, viimane võib olla ükskõik mis |
| 255.255.0.0 | 0.0.255.255 | Esimesed 2 oktetti peavad klappima |
| 255.255.255.252 | 0.0.0.3 | Esimesed 30 bitti peavad klappima |
| 255.255.255.255 | 0.0.0.0 | **Täpne aadress** — kõik bitid peavad klappima |

### Kuidas arvutada?

Lihtne: **255 miinus subnet mask oktett = wildcard mask oktett**

```
Subnet mask:  255.255.255.0
              255 - 255 = 0
              255 - 255 = 0
              255 - 255 = 0
              255 - 0   = 255
Wildcard:     0.0.0.255
```

Teine näide:
```
Subnet mask:  255.255.255.192
              255 - 192 = 63
Wildcard:     0.0.0.63
```

### Kaks erilist wildcard maski

| ACL rida | Lühiversioon | Tähendus |
|----------|-------------|----------|
| `permit 0.0.0.0 255.255.255.255` | `permit any` | Luba kõik |
| `permit 10.0.0.1 0.0.0.0` | `permit host 10.0.0.1` | Ainult see üks aadress |

---

## Standard ACL vs Extended ACL

Cisco-l on kaks ACL tüüpi ja vahe on lihtne:

### Standard ACL

Standard ACL filtreerib ainult **lähteaadressi** järgi. Numbrid on **1–99** (ja 1300–1999). See on lihtne, aga piiratud — sa ei saa öelda kuhu pakett läheb ega mis teenust ta kasutab.

```
R1(config)# access-list 1 permit 192.168.1.0 0.0.0.255
R1(config)# access-list 1 deny   192.168.2.0 0.0.0.255
```

Standard ACL vaatab ainult: "Kust pakett tuli?"

### Extended ACL

Extended ACL filtreerib **lähte- JA sihtaadressi**, **protokolli** ja **pordi** järgi. Numbrid on **100–199** (ja 2000–2699). Palju täpsem kontroll.

```
R1(config)# access-list 100 permit tcp 192.168.1.0 0.0.0.255 any eq 80
R1(config)# access-list 100 permit tcp 192.168.1.0 0.0.0.255 any eq 443
R1(config)# access-list 100 deny   ip  192.168.1.0 0.0.0.255 any
```

See ütleb: sisevõrgust (192.168.1.0/24) lubatakse ainult HTTP (port 80) ja HTTPS (port 443). Kõik muu blokeeritakse.

### Extended ACL süntaks

```
access-list <number> <permit|deny> <protokoll> <lähte-IP> <wildcard> <siht-IP> <wildcard> [eq <port>]
```

| Osa | Näide | Selgitus |
|-----|-------|----------|
| Protokoll | `tcp`, `udp`, `ip`, `icmp` | Mis tüüpi liiklus |
| Lähte-IP + wildcard | `192.168.1.0 0.0.0.255` | Kust tuleb |
| Siht-IP + wildcard | `any` | Kuhu läheb |
| Port | `eq 80`, `eq 443`, `eq 22` | Mis teenus (TCP/UDP puhul) |

### Levinumad pordinumbrid

| Port | Teenus | Protokoll |
|------|--------|-----------|
| 22 | SSH | TCP |
| 23 | Telnet | TCP |
| 53 | DNS | TCP/UDP |
| 80 | HTTP | TCP |
| 443 | HTTPS | TCP |
| 67/68 | DHCP | UDP |

---

## ACL paigaldamine liidesele

ACL-i loomine üksi **ei tee midagi**! See on nagu reeglite kirjutamine paberile — keegi peab need uksele panema.

```
R1(config)# interface GigabitEthernet0/0
R1(config-if)# ip access-group 1 in
```

### Suund: `in` vs `out`

- **`in`** — kontrolli pakette, mis **tulevad sisse** sellelt liideselt
- **`out`** — kontrolli pakette, mis **lähevad välja** sellelt liideselt

### Kuhu paigaldada?

**Rusikareegel:**
- **Standard ACL** → pane **sihtkoha lähedale** (sest ta teab ainult lähteaadressi — kui paned lähtekoha juurde, blokeerid kogu liikluse sellest allikast kõigile)
- **Extended ACL** → pane **lähtekoha lähedale** (sest ta saab täpselt filtreerida — blokeeri ebavajalik liiklus nii vara kui võimalik)

---

## Named ACL — nimetatud ACL

Numbreid on raske meeles pidada. Named ACL kasutab nime ja lubab ridu muuta ilma kogu ACL-i ümber tegemata:

```
R1(config)# ip access-list standard KONTOR-NAT
R1(config-std-nacl)# permit 192.168.1.0 0.0.0.255
R1(config-std-nacl)# exit
```

```
R1(config)# ip access-list extended TURVAPOLIITIKA
R1(config-ext-nacl)# permit tcp 192.168.1.0 0.0.0.255 any eq 80
R1(config-ext-nacl)# permit tcp 192.168.1.0 0.0.0.255 any eq 443
R1(config-ext-nacl)# deny ip any any
R1(config-ext-nacl)# exit
```

---

## VTY ACL — SSH/Telnet ligipääsu piiramine

ACL saab panna ka VTY ridadele, et piirata kes tohib ruuterisse SSH-da:

```
R1(config)# access-list 10 permit 172.16.10.0 0.0.0.255
R1(config)# line vty 0 4
R1(config-line)# access-class 10 in
```

**NB!** VTY kasutab `access-class`, mitte `access-group`!

---

## ACL kontrollikäsud

```
R1# show access-lists
R1# show access-lists 1
R1# show ip interface G0/0 | include access
```

`matches` näitab mitu paketti selle reegli alla sobis — kasulik veaotsingul!

```
R1# show access-lists
Standard IP access list 1
    10 permit 192.168.1.0, wildcard bits 0.0.0.255 (156 matches)
    20 deny   any (3 matches)
```

---

## Standard vs Extended — võrdlus

| Omadus | Standard | Extended |
|--------|----------|----------|
| Number | 1–99 | 100–199 |
| Filtreerib | Ainult lähteaadress | Lähte + siht + protokoll + port |
| Täpsus | Madal | Kõrge |
| Kus paigaldada | Sihtkoha lähedal | Lähtekoha lähedal |
| Kasutus | NAT, VPN, lihtne filtreerimine | Tulemüüri reeglid, täpne kontroll |

---

## Levinumad vead

### 1. Reeglitest järjekord on vale

```
! VALE — deny any on enne permit-i!
access-list 100 deny ip any any
access-list 100 permit tcp 192.168.1.0 0.0.0.255 any eq 80
! Teine rida ei rakendu kunagi
```

### 2. Unustasid ACL liidesele panna

ACL loodi, aga `ip access-group` käsku ei antud. ACL ei tee midagi!

### 3. Vale suund (in/out)

```
! VALE — liiklus tuleb SISSE, mitte välja
interface g0/0
 ip access-group 100 out
```

### 4. Implicit deny unustamine

```
! Ainult deny reegel — kõik on blokeeritud!
access-list 1 deny 192.168.2.0 0.0.0.255
! Puudu: permit any
```

### 5. Wildcard vs subnet mask

```
! VALE — see on subnet mask!
access-list 100 deny ip 192.168.1.0 255.255.255.0 any

! ÕIGE — wildcard mask
access-list 100 deny ip 192.168.1.0 0.0.0.255 any
```

### 6. VTY-l access-group asemel access-class

```
! VALE
line vty 0 4
 ip access-group 10 in

! ÕIGE
line vty 0 4
 access-class 10 in
```

---

## Kontrolli ennast

1. Mis on ACL ja miks seda kasutatakse?
2. Mis vahe on Standard ja Extended ACL-il?
3. Mis on implicit deny?
4. Arvuta wildcard mask subnet maskist 255.255.255.128.
5. Kuhu paigaldada Standard ACL? Kuhu Extended ACL? Miks?
6. Kirjuta Extended ACL reegel: luba VLAN 10-st (10.10.10.0/24) HTTP ja HTTPS liiklust.
7. Kus sa oled juba ACL-i kasutanud? (Vihje: NAT!)

---

## Lisalugemine

- [NetworkLessons: Introduction to ACL](https://networklessons.com/cisco/ccna-routing-switching-icnd1-100-105/introduction-to-access-lists)
- [NetworkLessons: Standard ACL](https://networklessons.com/cisco/ccna-routing-switching-icnd1-100-105/cisco-ios-standard-access-list)
- [NetworkLessons: Extended ACL](https://networklessons.com/cisco/ccna-routing-switching-icnd1-100-105/cisco-ios-extended-access-list)
- [Cisco: ACL Configuration Guide](https://www.cisco.com/c/en/us/support/docs/security/ios-firewall/23602-confaccesslists.html)
