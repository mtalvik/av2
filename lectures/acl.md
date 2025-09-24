# **ACL Seadistamise Õpetus** 🐵

## **1. MIS on ACL?**
Access Control List = **Liikluse filter** (nagu tulemüür)
- Kontrollib, mis liiklus **TOHIB** või **EI TOHI** läbi minna
- Töötab nagu nimekiri reegleid ülalt alla

## **2. ACL Tüübid:**
```
Standard ACL (1-99): Vaatab AINULT source IP
Extended ACL (100-199): Vaatab source + destination + ports
```

## **3. KUIDAS ACL-i KIRJUTADA:**

### **Samm 1: Kirjuta ACL reegel**
```cisco
access-list [number] [permit/deny] [protocol] [source] [wildcard] [dest] [wildcard] [port]

! NÄIDE - Luba kontori võrgust Google DNS-ile:
access-list 100 permit ip 192.168.1.0 0.0.0.255 host 8.8.8.8
         ↑       ↑      ↑     ↑        ↑         ↑
      number  action protocol source wildcard destination
```

### **Samm 2: Rakenda ACL interface'ile**
```cisco
interface g0/0.10              ! Mine õigele interface'ile
 ip access-group 100 in        ! Rakenda ACL 100 sissetulevale liiklusele
                    ↑  ↑
                ACL number  suund

! SUUND:
! in = liiklus mis TULEB SISSE ruuterisse
! out = liiklus mis LÄHEB VÄLJA ruuterist
```

## **4. WILDCARD MASK - Kuidas arvutada?**

**LIHTNE REEGEL: Tee subnet mask "tagurpidi"!**

```
Subnet Mask → Wildcard Mask
255.255.255.0 → 0.0.0.255     (0 ↔ 255)
255.255.255.128 → 0.0.0.127   (128 → 127)
255.255.255.192 → 0.0.0.63    (192 → 63)
255.255.255.224 → 0.0.0.31    (224 → 31)
255.255.255.240 → 0.0.0.15    (240 → 15)
255.255.255.248 → 0.0.0.7     (248 → 7)

VALEM: Wildcard = 255 - subnet_octet
Näide: 255 - 224 = 31
```

## **5. TÄIELIK NÄIDE - Kontori Külaliste WiFi:**

### **Ülesanne:** Külalised tohivad ainult internetti, mitte firma võrku

```cisco
! STEP 1: Kirjuta ACL reeglid
Router(config)# access-list 100 remark === VISITOR WIFI ===
Router(config)# access-list 100 permit ip 192.168.50.0 0.0.0.255 host 8.8.8.8
Router(config)# access-list 100 permit ip 192.168.50.0 0.0.0.255 host 1.1.1.1
Router(config)# access-list 100 deny ip 192.168.50.0 0.0.0.255 192.168.0.0 0.0.255.255
Router(config)# access-list 100 permit ip 192.168.50.0 0.0.0.255 any

! Mida see teeb:
! Rida 1: Luba Külalised → Google DNS
! Rida 2: Luba Külalised → Cloudflare DNS  
! Rida 3: Keela Külalised → Kõik 192.168.x.x võrgud
! Rida 4: Luba Külalised → Kõik muu (internet)

! STEP 2: Rakenda Külaliste VLAN interface'ile
Router(config)# interface g0/1.50
Router(config-subif)# ip access-group 100 in
```

## **6. VTY ACL (SSH/Telnet jaoks):**

```cisco
! Luba ainult IT osakond SSH-ida
Router(config)# access-list 102 permit ip 172.16.10.0 0.0.0.255 any
Router(config)# access-list 102 deny ip any any    ! Tegelikult pole vaja, implicit deny

! Rakenda VTY ridadele (MITTE interface'ile!)
Router(config)# line vty 0 4
Router(config-line)# access-class 102 in    ! NB! access-CLASS, mitte access-group!
Router(config-line)# password cisco
Router(config-line)# login
```

## **7. SERVER KAITSE NÄIDE:**

```cisco
! Ainult IT ja Arendajad saavad serveritesse
access-list 101 remark === SERVER PROTECTION ===
access-list 101 permit ip 172.16.10.0 0.0.0.31 172.16.100.0 0.0.0.15  ! IT → Servers
access-list 101 permit tcp 172.16.20.0 0.0.0.63 172.16.100.0 0.0.0.15 eq 80  ! Dev → Web
access-list 101 permit tcp 172.16.20.0 0.0.0.63 172.16.100.0 0.0.0.15 eq 443 ! Dev → HTTPS
access-list 101 deny ip any 172.16.100.0 0.0.0.15  ! Keela kõik muu serveritesse
access-list 101 permit ip any any  ! Luba muu liiklus

! Rakenda serveri interface'ile
interface g0/0.100
 ip access-group 101 in
```

## **8. KUIDAS KONTROLLIDA:**

```cisco
! Vaata ACL-i ja kas keegi on seda kasutanud
Router# show access-lists
Extended IP access list 100
    10 permit ip 192.168.50.0 0.0.0.255 host 8.8.8.8 (15 matches)  ← 15 paketti läks läbi!
    20 deny ip 192.168.50.0 0.0.0.255 192.168.0.0 0.0.255.255 (3 matches) ← 3 blokeeritud!

! Vaata mis on kus rakendatud
Router# show ip interface g0/1.50 | include access
  Inbound access list is 100
```

## **9. SAGEDASED VEAD:** ❌

```cisco
! VIGA 1: Vale suund
interface g0/0.50
 ip access-group 100 out    ! ← VALE! Liiklus tuleb SISSE, mitte välja

! VIGA 2: Vale wildcard
access-list 100 deny ip 192.168.1.0 255.255.255.0 any   ! ← VALE! See on subnet mask!
access-list 100 deny ip 192.168.1.0 0.0.0.255 any       ! ← ÕIGE! Wildcard mask

! VIGA 3: ACL pole rakendatud
! Kirjutasid ACL ära, aga unustasid interface'ile panna!

! VIGA 4: Vale ACL number VTY jaoks
line vty 0 4
 ip access-group 102 in    ! ← VALE! VTY kasutab access-CLASS
 access-class 102 in       ! ← ÕIGE!
```

## **KOKKUVÕTE - 3 SAMMU:**
1. **KIRJUTA** ACL (access-list 100 ...)
2. **RAKENDA** interface'ile (ip access-group 100 in) või VTY-le (access-class)
3. **KONTROLLI** (show access-lists)

**MEELDETULETUS:** 
- ACL töötab ülalt alla - esimene vaste võidab!
- Lõpus on alati nähtamatu "deny all"
- **SINU laboris kasuta OMA arvutatud 10.x.x.x IP-sid!** 🦍
