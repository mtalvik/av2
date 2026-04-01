# Labor: NAT + ACL — Packet Tracer

**Kestus:** ~90 min | **Töövorm:** Paaristöö | **Keskkond:** Cisco Packet Tracer

---

## Osa 1: Wildcard mask soojendus (15 min)

**Ava fail:** `2020-03-28_Wildcard_Bits_vs_Mask.pkt`

Tee harjutus läbi. Kui jääd hätta — vaata `teemad/acl.md` osa 4.

**Kiire meeldetuletus:** wildcard = 255 miinus subnet mask oktett.

---

## Osa 2: NAT/PAT seadistamine (25 min)

**Ava fail:** `OGIT-2020-04-12_PT_Lab.pkt`

### Ülesanne

> Seadista NAT/PAT edge ruuteril nii, et PC1 saab avada veebilehe TheKeithBarker.com.

Serveril **ei ole default gateway-d** — mõtle, miks NAT on ainus lahendus.

### Mida pead tegema (mitte käsud, vaid sammud!)

1. Uuri topoloogiat — tuvasta inside ja outside liidesed
2. Märgi liidesed vastavalt
3. Loo Standard ACL — mis sisevõrgu aadressid saavad NAT-i
4. Seadista PAT (`overload`) outside liidese aadressiga
5. Testi brauseriga

Kui jääd hätta — vaata `teemad/nat/02_nat_seadistamine.md` osa 3 (PAT).

### Kontrolli

```
Router# show ip nat translations
Router# show ip nat statistics
```

**Vastake paariga:**
- Mis on Inside Local ja Inside Global selles tabelis?
- Miks server ei vaja default gateway-d kui NAT töötab?

---

## Osa 3: ACL + NAT kombinatsioon — ehita ise (50 min)

### Topoloogia

Ehita Packet Traceris:

```
                         Server (209.165.200.130/25)
                              |
LAN 1                   [ISP — eelseadistatud]
192.168.50.0/24               |
     |                  209.165.200.0/30
   [Sw1]                      |
     |        172.16.3.0/30   |        172.16.1.0/24
   PC-A ---[Rtr1]----------[Rtr2]-------[Sw2]--- PC-B
    .10    g0/0/0  g0/0/1  g0/0/1 g0/0/0          .10
```

### Aadressitabel

| Seade | Liides | IP | Mask |
|-------|--------|----|------|
| Rtr1 | G0/0/0 | 192.168.50.1 | /24 |
| Rtr1 | G0/0/1 | 172.16.3.1 | /30 |
| Rtr2 | G0/0/0 | 172.16.1.1 | /24 |
| Rtr2 | G0/0/1 | 172.16.3.2 | /30 |
| Rtr2 | S0/1/0 | 209.165.200.1 | /30 |
| PC-A | | 192.168.50.10 | /24, gw .1 |
| PC-B | | 172.16.1.10 | /24, gw .1 |
| Server | | 209.165.200.130 | /25, gw .1 |

*Topoloogia põhineb Cisco CCNAv7 ENSA Skills Assessment eksamil.*

### Ülesanne 1: Baasseadistus + marsruutimine

1. Seadista kõik IP aadressid mõlemal ruuteril
2. Lisa staatilised marsruudid, et kõik võrgud üksteist näeksid
3. **Testi ENNE NAT-i:** PC-A → ping PC-B ja Server

Kui ping ei tööta — ära mine edasi! Kontrolli aadresse ja marsruute.

### Ülesanne 2: PAT seadistamine Rtr1-l

**Stsenaarium:** LAN 1 (192.168.50.0/24) vajab NAT-i internetti pääsemiseks.

1. Määra inside ja outside liidesed
2. Loo ACL mis lubab LAN 1 aadressid
3. Seadista PAT outside liidese aadressiga
4. Testi: PC-A → ping Server

**Kontrolli:** `show ip nat translations` — mis on Inside Local? Inside Global?

### Ülesanne 3: Extended ACL turvapoliitika Rtr2-l

**Stsenaarium — firma turvapoliitika:**

> - LAN 1 (192.168.50.0/24) **EI TOHI** pääseda Web Serverile (HTTP/HTTPS)
> - LAN 1 **EI TOHI** kasutada SSH-d aadressile 209.165.200.129
> - Kõik muu liiklus **ON LUBATUD**

**Sinu ülesanne:**

1. Mis tüüpi ACL on vaja — Standard või Extended? Miks?
2. Loo **nimetatud** Extended ACL nimega `TURVAPOLIITIKA`
3. Kirjuta reeglid õiges järjekorras (mõtle: implicit deny!)
4. Paigalda ACL õigele liidesele õiges suunas
5. Testi alltoodud tabeliga

Kui jääd hätta — vaata `teemad/acl.md` osa 3 ja 5.

### Testimine

| Allikas | Sihtkoht | Protokoll | Oodatav |
|---------|----------|-----------|---------|
| PC-A | PC-B | Ping | ✅ |
| PC-A | Server 209.165.200.130 | HTTP | ❌ |
| PC-A | 209.165.200.129 | SSH | ❌ |
| PC-B | Server 209.165.200.130 | HTTP | ✅ |
| PC-B | 209.165.200.129 | SSH | ✅ |

Kui tulemused ei klapi:
```
Rtr2# show access-lists
Rtr2# show ip interface g0/0/1 | include access
```

Vaata match count — kas õiged reeglid saavad tabamusi?

### Boonusülesanne (tugevamatele)

> LAN 2 (172.16.1.0/24) tohib serverile ainult HTTP (80) ja HTTPS (443), mitte midagi muud.

Lisa reeglid oma ACL-i. Mõtle järjekorra peale!

---

## VALMIS

- [ ] Osa 1: Wildcard harjutus tehtud
- [ ] Osa 2: OGIT lab — PAT töötab, `show ip nat translations` näitab tõlkeid
- [ ] Osa 3: Topoloogia ehitatud, kõik pingid töötavad enne NAT-i
- [ ] PAT töötab Rtr1-l
- [ ] ACL TURVAPOLIITIKA blokeerib PC-A HTTP/SSH
- [ ] ACL lubab PC-B HTTP/SSH
- [ ] `show access-lists` näitab match-e
