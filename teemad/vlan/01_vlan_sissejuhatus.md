# VLAN Sissejuhatus

## Miks me VLANe vajame?

Vaatame kõigepealt ühte võrku:

![Suur switchitud võrk](https://networklessons.com/wp-content/uploads/2013/02/large-switched-network.png)

Siin on mitu osakonda ja igaühel on oma switch. Kasutajad on füüsiliselt grupeeritud ja ühendatud oma switchidega.

**Mõtle hetkeks:**
- Mis juhtub kui Research osakonna arvuti saadab broadcast'i (näiteks ARP request)?
- Mis juhtub kui Helpdesk switch läheb katki?
- Kas Human Resource kasutajatel on kiire võrguühendus?
- Kuidas me saame turvalisust tagada?

---

## Probleem: Broadcast'id levivad KÕIKJALE

Kui ükskõik milline arvuti saadab broadcast'i, mida switchid teevad? **Nad ujutavad (flood) selle üle kogu võrgu!**

See tähendab, et üks broadcast kaader levib KOGU võrgus. Sama juhtub kui switch ei tea veel mingit MAC-aadressi - kaader ujutatakse kõikjale.

**Veel probleeme:**
- Kui Helpdesk switch läheb katki, on Human Resource kasutajad "isoleeritud" - nad ei saa teiste osakondadega ühendust
- Kõik peavad Helpdesk switchi kaudu internetti minema = jagame ribalaiust
- Turvalisus? MAC-aadresside filtreerimine pole turvaline, sest MAC-aadresse on lihtne võltsida (spoof)

---

## Mitu broadcast domeeni siin on?

Vaata uuesti pilti. Kui Sales osakonna arvuti saadab broadcast'i, edastavad kõik switchid seda edasi.

Aga näed ruuterit pildi ülaosas? **Kas ruuter edastab broadcast'i?**

**Vastus: EI!** Ruuterid ei edasta broadcast kaadrit. Seega on selles võrgus **2 broadcast domeeni**:
1. Kogu sisevõrk (kõik switchid)
2. Interneti pool (ruuterist paremal)

---

## Lahendus: VLAN

![Switchid VLANidega](https://networklessons.com/wp-content/uploads/2013/02/switches-with-vlans.png)

Switchidega töötades pead meeles pidama: **füüsiline ja loogiline topoloogia on erinevad asjad!**

- **Füüsiline** = kuidas kaablid on ühendatud
- **Loogiline** = kuidas me oleme asjad "virtuaalselt" seadistanud

Ülaloleval pildil on 4 switchi ja ma olen loonud 3 VLANi:
- Research (punane)
- Engineering (sinine)  
- Sales (kollane)

**VLAN = Virtual LAN = "switch switchi sees"**

---

## VLANide eelised

1. **Üks VLAN = üks broadcast domeen**
   - Kui Research VLANis olev kasutaja saadab broadcast'i, saavad seda AINULT sama VLANi kasutajad

2. **Kasutajad saavad suhelda ainult sama VLANi sees**
   - Erinevate VLANide vahel suhtlemiseks on vaja ruuterit

3. **Kasutajad ei pea olema füüsiliselt koos**
   - Vaata pilti: Engineering VLANi kasutajad istuvad 1., 2. ja 3. korrusel!

---

## VLAN ID numbrid

VLANidel on numbrid 1-4094:

| VLAN vahemik | Kasutus |
|--------------|---------|
| 1 | Vaikimisi VLAN (default) - kõik pordid on alguses siin |
| 2-1001 | Tavalised VLANid (normal range) |
| 1002-1005 | Reserveeritud vanadele tehnoloogiatele (FDDI, Token Ring) |
| 1006-4094 | Laiendatud vahemik (extended range) |

**NB!** VLAN 1 on eriline:
- Kõik pordid on vaikimisi VLAN 1-s
- Haldusliiklus (CDP, VTP, DTP) liigub VLAN 1-s
- Ei saa kustutada

---

## Pordi tüübid

Switchil on kaks porditüüpi:

### Access port (ligipääsuport)
- Kuulub **ühte** VLANi
- Ühendab lõppseadmeid (arvutid, printerid, telefonid)
- Liiklus on **märgistamata** (untagged)

### Trunk port (magistraalport)
- Kannab **mitut** VLANi
- Ühendab switche omavahel (või switchit ruuteriga)
- Liiklus on **märgistatud** (tagged) - 802.1Q

---

## Kokkuvõte

| Ilma VLANideta | VLANidega |
|----------------|-----------|
| Üks suur broadcast domeen | Mitu väikest broadcast domeeni |
| Broadcast levib kõikjale | Broadcast jääb VLANi sisse |
| Halb turvalisus | Parem turvalisus - VLANid on isoleeritud |
| Kasutajad peavad füüsiliselt koos olema | Kasutajad võivad olla eri kohtades |

---

## Kontrollküsimused

1. Mis on VLAN ja miks seda kasutatakse?
2. Mitu broadcast domeeni tekib kui sul on 5 VLANi?
3. Mis vahe on access ja trunk pordil?
4. Miks ei tohiks VLAN 1 kasutada tootmisvõrgus?
5. Kas erinevates VLANides olevad arvutid saavad omavahel suhelda ilma ruuterita?

---

## Lisalugemine

- [NetworkLessons: Introduction to VLANs](https://networklessons.com/switching/introduction-to-vlans)
- [NetworkLessons: Broadcast Domain](https://networklessons.com/switching/broadcast-domain)
- [NetworkLessons: Collision Domains](https://networklessons.com/switching/collision-domains)
