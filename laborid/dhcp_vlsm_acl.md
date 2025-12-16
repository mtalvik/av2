# **DHCP + VLSM + ACL Labor**

## **Labori Ülevaade**
Seadista võrk VLAN-ide, DHCP ja Access Control List-idega kasutades VLSM-i efektiivseks IP-aadressimiseks.

**Seadmed:** 1 Ruuter, 1 Kommutaator, 1 Arvuti  
**Kestus:** 3 tundi  
**Sinu Võrk:** 10.**X**.0.0/16 (kus **X** = sinu number × 4)

---

## **Osa 1: VLSM Arvutused (30 punkti)**

### **Nõuded - 6 VLAN-i:**
| VLAN | Osakond | Vajab hosti |
|------|---------|-------------|
| 30 | Arendajad (Developers) | 500 hosti |
| 50 | Külaliste WiFi (Guest) | 250 hosti |
| 40 | Müük (Sales) | 120 hosti |
| 60 | Printerid | 30 hosti |
| 10 | Serverid | 10 hosti |
| 20 | Haldus (Management) | 5 hosti |

### **Täida See Tabel (SORTEERI SUURUSE JÄRGI - SUURIM ESIMESENA!):**

| VLAN | Vajab hosti | 2^n Suurus | Slash | Võrgu aadress | Alamvõrgu mask | Gateway | Magic Number |
|------|-------------|------------|-------|---------------|----------------|---------|--------------|
| 30 | 500 | 512 | /23 | 10.___.___.__ | 255.255.254.0 | Esimene IP | 2 (3. oktet) |
| 50 | 250 | ___ | /___ | 10.___.___.__ | 255.255.___.__ | Esimene IP | ___ |
| 40 | 120 | ___ | /___ | 10.___.___.__ | 255.255.___.__ | Esimene IP | ___ |
| 60 | 30 | ___ | /___ | 10.___.___.__ | 255.255.___.__ | Esimene IP | ___ |
| 10 | 10 | ___ | /___ | 10.___.___.__ | 255.255.___.__ | Esimene IP | ___ |
| 20 | 5 | ___ | /___ | 10.___.___.__ | 255.255.___.__ | Esimene IP | ___ |

**Magic Number Meeldetuletus:** 🐵
```
Magic Number = 256 - maski oktet
/23 = 255.255.254.0 → Magic = 256 - 254 = 2 (3. oktetis)
/24 = 255.255.255.0 → Magic = 256 - 0 = 256
/25 = 255.255.255.128 → Magic = 256 - 128 = 128
/26 = 255.255.255.192 → Magic = 256 - 192 = 64
/27 = 255.255.255.224 → Magic = 256 - 224 = 32
/28 = 255.255.255.240 → Magic = 256 - 240 = 16
/29 = 255.255.255.248 → Magic = 256 - 248 = 8

Järgmine alamvõrk = Praegune + Magic Number!
```

---

## **Osa 2: Kommutaatori Seadistus (15 punkti)**

### **Portide Jaotus:**
- Pordid 1-3: VLAN 10 (Serverid)
- Pordid 4-5: VLAN 20 (Haldus)
- Pordid 6-11: VLAN 30 (Arendajad)
- Pordid 12-16: VLAN 40 (Müük)
- Pordid 17-20: VLAN 50 (Külalised)
- Pordid 21-22: VLAN 60 (Printerid)
- Port 24: TRUNK ruuterisse

### **Konfiguratsioon:**
```cisco
! Loo VLAN-id
vlan 10
 name SERVERID
vlan 20
 name HALDUS
vlan 30
 name ARENDAJAD
vlan 40
 name MUUK
vlan 50
 name KULALISED
vlan 60
 name PRINTERID

! Määra pordid (näide VLAN 10 jaoks)
interface range fa0/1-3
 switchport mode access
 switchport access vlan 10

! Seadista trunk
interface fa0/24
 switchport mode trunk

! Halduse IP (kasuta OMA arvutatud IP-d!)
interface vlan 20
 ip address [sinu_haldus_IP] [sinu_mask]
 no shutdown
```

---

## **Osa 3: Ruuteri Seadistus (20 punkti)**

### **Router-on-a-Stick:**
```cisco
! Füüsiline liides
interface g0/0
 no ip address
 no shutdown

! Alamliidesed (kasuta OMA arvutatud IP-sid!)
interface g0/0.10
 encapsulation dot1Q 10
 ip address [gateway_IP] [subnet_mask]
 description SERVERID

interface g0/0.20
 encapsulation dot1Q 20
 ip address [gateway_IP] [subnet_mask]
 description HALDUS

! Jätka kõigi 6 VLAN-iga...
```

---

## **Osa 4: DHCP Seadistus (15 punkti)**

### **DHCP Nõuded:**
| Pool | VLAN | IP Vahemik | Välistatud | Rendiaja |
|------|------|------------|------------|----------|
| DEV_POOL | 30 | .10-.450 | .1-.9 | 8 tundi |
| GUEST_POOL | 50 | .10-.240 | .1-.9 | 2 tundi |
| SALES_POOL | 40 | .5-.100 | .1-.4 | 12 tundi |
| SRV_POOL | 10 | .4-.12 | .1-.3 | 7 päeva |
| Ainult staatilised | 20 | Pole | Kõik | - |
| Ainult staatilised | 60 | Pole | Kõik | - |

### **DHCP Käsud:**
```cisco
! Näide arendajatele
ip dhcp pool DEV_POOL
 network [sinu_võrk] [sinu_mask]
 default-router [sinu_gateway]
 dns-server 8.8.8.8 1.1.1.1
 lease 0 8

ip dhcp excluded-address [algus] [lõpp]

! Staatiline printeri jaoks
ip dhcp pool PRINTER1
 host [IP_aadress] [mask]
 hardware-address aaaa.bbbb.0001
```

**Rendiaja süntaks:**
- `lease 7` = 7 päeva
- `lease 0 8` = 8 tundi  
- `lease 0 2` = 2 tundi
- `lease 0 0 30` = 30 minutit

---

## **Osa 5: Pääsuloendid / Access Control Lists (20 punkti)**

### **ACL Nõuded:**

#### **ACL 100: Külaliste Isoleerimine**
- Külalised → DNS (8.8.8.8, 1.1.1.1): LUBA
- Külalised → Sisevõrk (10.0.0.0/8): KEELA
- Külalised → Internet: LUBA
- Rakenda: interface g0/0.50 IN

```cisco
access-list 100 permit ip [kulaliste_vork] [wildcard] host 8.8.8.8
access-list 100 permit ip [kulaliste_vork] [wildcard] host 1.1.1.1
access-list 100 deny ip [kulaliste_vork] [wildcard] 10.0.0.0 0.255.255.255
access-list 100 permit ip [kulaliste_vork] [wildcard] any

interface g0/0.50
 ip access-group 100 in
```

#### **ACL 101: Serverite Kaitse**
- Haldus → Serverid: LUBA KÕIK
- Arendajad → Serverid: LUBA pordid 80,443
- Müük → Serverid: KEELA
- Rakenda: interface g0/0.10 IN

```cisco
access-list 101 permit ip [haldus_vork] [wildcard] [serveri_vork] [wildcard]
access-list 101 permit tcp [arendaja_vork] [wildcard] [serveri_vork] [wildcard] eq 80
access-list 101 permit tcp [arendaja_vork] [wildcard] [serveri_vork] [wildcard] eq 443
access-list 101 deny ip [muugi_vork] [wildcard] [serveri_vork] [wildcard]
access-list 101 permit ip any any
```

#### **ACL 102: VTY Ligipääs**
- Ainult Halduse VLAN saab SSH/Telnet
- Rakenda: line vty 0 4

```cisco
access-list 102 permit ip [haldus_vork] [wildcard] any
access-list 102 deny ip any any

line vty 0 4
 access-class 102 in
 password cisco
 login
```

### **Wildcard Maski Spikker:**
```
Alamvõrgu mask → Wildcard mask
255.255.255.0 → 0.0.0.255
255.255.255.128 → 0.0.0.127  
255.255.255.192 → 0.0.0.63
255.255.255.224 → 0.0.0.31
255.255.255.240 → 0.0.0.15
255.255.255.248 → 0.0.0.7
255.255.254.0 → 0.0.1.255

MEELDETULETUS: Wildcard on maski "tagurpidi"!
```

### **Mis on ACL?** 🦍
Access Control List = Liikluse filter (nagu tulemüür)
- **Standard ACL (1-99)**: Kontrollib ainult LÄHTE IP-d
- **Extended ACL (100-199)**: Kontrollib LÄHTE, SIHTKOHTA, PORTE

**ACL reeglid:**
1. **Järjekord on oluline!** Esimene vaste võidab
2. **Nähtamatu "deny all" lõpus** 
3. **"in" vs "out"** - Mõtle ruuteri vaatenurgast

---

## **Osa 6: Testimine**

### **Kohustuslikud Testid:**
```cisco
! Ruuterist:
show vlan brief
show ip interface brief  
show ip dhcp binding
show access-lists
show ip route

! Arvutist (testi iga VLAN):
ipconfig /release
ipconfig /renew
ping [gateway]
ping 8.8.8.8
```

### **Testide Maatriks - Peavad Töötama:**
| Test | Oodatud Tulemus |
|------|-----------------|
| Külaline → ping 8.8.8.8 | ✓ Töötab |
| Külaline → ping Müügi PC | ✗ Blokeeritud |
| Müük → ping Server | ✗ Blokeeritud |
| Arendaja → telnet Server 80 | ✓ Töötab |
| Iga VLAN saab DHCP | ✓ Töötab |

---

## **Hindamine:**
- VLSM arvutused: 30%
- Töötavad VLAN-id ja trunk: 15%
- DHCP konfiguratsioon: 15%
- Ruuteri alamliidesed: 20%
- ACL-id seadistatud ja rakendatud: 20%

**Boonusülesanded (+5% iga):**
- Seadista NAT interneti ligipääsuks
- Lisa ajapõhine ACL (ainult tööajal)
- Seadista port security

---

## **Sagedased Vead:** 🐒
- ❌ VLSM kattuvus (arvuta hoolikalt!)
- ❌ Unustasid gateway DHCP-st välistada
- ❌ ACL vales suunas (in vs out)
- ❌ Vale wildcard mask (see on maski vastand!)
- ❌ Unustasid "permit any any" ACL lõppu
- ❌ Pole trunk-i pordil 24

---

## **Esitamise Nõuded:**
1. Ekraanipilt `show vlan brief`
2. Ekraanipilt `show ip dhcp binding`
3. Ekraanipilt `show access-lists` (koos loendritega)
4. Täidetud VLSM tabel
5. Töötav konfiguratsioonifail

**Tähtaeg:** Labori lõpp  
**NB:** Igal tudengil on UNIKAALSED IP-aadressid - MITTE KOPEERIDA!

**Edu! Küsi julgelt abi kui jääd hätta!** 🦍
