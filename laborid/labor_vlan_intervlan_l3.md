# Labor 1: VLAN + Inter-VLAN marsruutimine (L3 Switch)

**Kestus:** ~120 min  
**Keskkond:** GNS3 Web UI  
**Teemad:** VLAN, trunk, SVI, inter-VLAN routing, DHCP, troubleshooting

---

## Stsenaarium

Ettevõttel "TechBaltic OÜ" on kolm osakonda: **IT**, **Müük** ja **Juhtkond**. Praegu on kõik ühes võrgus — broadcast'id segavad tööd, turvalisus on nõrk ja haldamine keeruline.

Sinu ülesanne: segmenteeri võrk VLANidega ja seadista L3 switchil inter-VLAN marsruutimine, et osakonnad saaksid vajadusel omavahel suhelda.

---

## GNS3 Web UI — kuidas kasutada

GNS3 on võrgusimulaator. Meie serveris jookseb GNS3 ja sina kasutad seda brauseri kaudu.

### Sisselogimine

1. Ava brauser
2. Mine aadressile: `http://192.168.100.110:3080`
3. Sisesta oma kasutajanimi (nt `tudeng01`) ja parool (nt `av2lab01`)

### Projekti loomine

Pärast sisselogimist avaneb projektide vaade. Vajuta **New project**, anna nimi (nt `lab1-perenimi`) ja vajuta **Add project**. Avaneb tühi tööpind.

### Seadmete lisamine tööpinnale

Vasakul äärel on vertikaalne ikooniriba. Ülemine ikoon avab **seadmete nimekirja** (All devices). Sealt leiad:

- **IOL XE L3** — L3 switch (oskab marsruutida)
- **IOL XE L2** — L2 switch (tavaline switch)
- **VPCS** — lihtne virtuaalne arvuti (ping, traceroute, IP seadistamine)

Lohista seade nimekirjast tööpinnale (drag & drop). Seade ilmub ikoonina.

### Seadme ümbernimetamine

Topeltkliki seadme nimel (nt "IOU1"). Kirjuta uus nimi ja vajuta Enter.

### Kaablite ühendamine

1. Kliki vasakul ribal **kaabli ikoonil** (joon kahe punkti vahel)
2. Kliki esimesel seadmel → vali port rippmenüüst (nt `Ethernet0/0`)
3. Kliki teisel seadmel → vali port
4. Kaabel tekib! Vajuta **ESC** kui kaablid valmis

### Seadmete käivitamine

Üleval tööriistaribal on roheline **▶** nupp — see käivitab kõik seadmed korraga. Oota ~60 sekundit, sest IOL image'id bootivad aeglaselt.

### Konsooli avamine

Paremkliki seadmel → **Web console**. Avaneb uus aken terminaliga. Kui näed `Switch>` või `Router>` — seade on valmis. Kui ekraan on tühi, vajuta paar korda Enter.

### Kui midagi ei tööta

- Seade ei booti → oota 60 sek. Kui ikka ei tööta: paremkliki → Stop, oota, Start
- Konsool ei avane → kontrolli kas popup-blocker ei keela uut akent
- Kaotasid töö → **Ctrl+S** salvestab projekti

---

## Topoloogia

```
                    [DSW1] L3 Switch
                   /   |   \
                e0/0  e0/1  e0/2
                /      |      \
             [SW1]   [SW2]   [SW3]
             e0/0    e0/0    e0/0
              |        |        |
            e0/1     e0/1     e0/1
              |        |        |
            [PC1]    [PC2]    [PC3]
           VLAN 10  VLAN 20  VLAN 30
             IT      Müük    Juhtkond
```

**Seadmed:**

| Nimi | Tüüp GNS3-s | Roll |
|------|-------------|------|
| DSW1 | IOL XE L3 | Distribution switch — marsruudib VLANide vahel |
| SW1, SW2, SW3 | IOL XE L2 | Access switchid — ühendavad lõppseadmeid |
| PC1, PC2, PC3 | VPCS | Lõppkasutajate arvutid |

**VLAN plaan:**

| VLAN ID | Nimi | Võrk | Gateway (DSW1 SVI) |
|---------|------|------|---------------------|
| 10 | IT | 192.168.10.0/24 | 192.168.10.1 |
| 20 | MUUK | 192.168.20.0/24 | 192.168.20.1 |
| 30 | JUHTKOND | 192.168.30.0/24 | 192.168.30.1 |

---

## Osa 1: Topoloogia ehitamine (15 min)

### 1.1 Loo projekt ja lisa seadmed

1. Loo uus projekt
2. Lohista tööpinnale: 1x IOL XE L3, 3x IOL XE L2, 3x VPCS
3. Nimeta ümber vastavalt topoloogiale (DSW1, SW1, SW2, SW3, PC1, PC2, PC3)

### 1.2 Ühenda kaablid

| Ühendus | Port A | Port B |
|---------|--------|--------|
| DSW1 ↔ SW1 | DSW1 e0/0 | SW1 e0/0 |
| DSW1 ↔ SW2 | DSW1 e0/1 | SW2 e0/0 |
| DSW1 ↔ SW3 | DSW1 e0/2 | SW3 e0/0 |
| SW1 ↔ PC1 | SW1 e0/1 | PC1 e0 |
| SW2 ↔ PC2 | SW2 e0/1 | PC2 e0 |
| SW3 ↔ PC3 | SW3 e0/1 | PC3 e0 |

### 1.3 Käivita ja oota

Vajuta **▶ Start**. Oota kuni seadmed bootivad (~60 sek). Ava iga seadme konsool ja kontrolli, et näed prompti.

---

## Osa 2: VLANid ja trunk — access switchid (20 min)

Selles osas seadistad SW1, SW2 ja SW3.

### 2.1 VLANide loomine

VLANid tuleb luua **igal switchil eraldi** (VTP pole kasutusel). Loo kõigil neljal switchil (SW1, SW2, SW3 ja DSW1) kolm VLANi:

| VLAN ID | Nimi |
|---------|------|
| 10 | IT |
| 20 | MUUK |
| 30 | JUHTKOND |

Käsud mida vajad: `vlan <id>` ja `name <nimi>`.

Kontrolli igal switchil: `show vlan brief`

### 2.2 Access pordid

Iga access switch ühendab ühe PC. Sea **e0/1** port õigesse VLANi:

| Switch | Port | VLAN |
|--------|------|------|
| SW1 | e0/1 | 10 |
| SW2 | e0/1 | 20 |
| SW3 | e0/1 | 30 |

Käsud mida vajad: `switchport mode access` ja `switchport access vlan <id>`.

**Küsimus:** Mis juhtub kui PC on ühendatud porti mis on vale VLANi määratud? ___________

### 2.3 Trunk pordid

Iga access switchi **e0/0** port peab olema trunk, sest see ühendab DSW1-ga. Trunk kannab mitme VLANi liiklust ühe lingi kaudu — iga raam saab 802.1Q tagi mis ütleb millisesse VLANi ta kuulub.

Sea SW1, SW2 ja SW3 peal e0/0 trunk'iks. Luba ainult VLANid 10, 20 ja 30.

Käsud mida vajad:
- `switchport trunk encapsulation dot1q`
- `switchport mode trunk`
- `switchport trunk allowed vlan 10,20,30`

Kontrolli igal switchil: `show interfaces trunk`

**Küsimus:** Miks piirame trunk'il lubatud VLANid, mitte ei lase kõiki läbi? ___________

---

## Osa 3: L3 switch — DSW1 (20 min)

DSW1 on labori tuum. See on L3 switch — ta teeb nii switchimist (L2) kui marsruutimist (L3). Tänu sellele ei ole vaja eraldi ruuterit VLANide vaheliseks suhtluseks.

### 3.1 Trunk pordid

DSW1-l on kolm porti (e0/0, e0/1, e0/2) mis ühendavad access switchidega. Sea kõik kolm trunk'iks. Kasuta `interface range e0/0-2` et seadistada kõik korraga.

Luba ainult VLANid 10, 20, 30.

Kontrolli: `show interfaces trunk` — pead nägema 3 trunk linki.

### 3.2 IP marsruutimine

L3 switch ei marsruudi vaikimisi. Lülita sisse:

```
ip routing
```

⚠️ **See on kõige levinum viga mida unustatakse!**

### 3.3 SVI-de loomine

SVI (Switch Virtual Interface) on virtuaalne liides mis annab VLANile IP-aadressi. See IP-aadress saab selle VLANi **gateway**-ks — arvutid kasutavad seda, et pääseda teistesse võrkudesse.

Loo kolm SVI-d vastavalt VLAN plaanile. Iga SVI vajab:
- IP-aadressi (gateway aadress tabelist)
- `no shutdown`

Käsk: `interface vlan <id>`, siis `ip address <ip> <mask>` ja `no shutdown`.

### 3.4 Kontrolli

```
show ip interface brief
```

Kõik kolm VLAN interface'i peavad olema **up/up**. Kui mõni on **up/down** — siis pole selles VLANis ühtegi aktiivset trunk linki.

```
show ip route
```

Pead nägema kolme `C` (connected) marsruuti — üks iga VLANi kohta.

**Küsimus:** Mida tähendab `C` marsruut? Mille poolest erineb see `S` (staatilisest) marsruudist? ___________

---

## Osa 4: PC-de seadistamine ja testimine (15 min)

### 4.1 IP-aadresside seadistamine

VPCS-s saad IP-aadressi, maski ja gateway seada ühe käsuga:

```
ip <aadress>/<mask> <gateway>
```

Näide: `ip 192.168.10.10/24 192.168.10.1`

Sea igale PC-le aadress vastavalt VLAN plaanile. Kasuta `.10` host-osa.

Kontrolli: `show ip`

### 4.2 Testimine — süstemaatiliselt!

Testi **järjekorras** ja täida tabel. Alusta lihtsatest testidest (sama VLAN) ja liigu keerulisemate poole (eri VLANid).

**Miks selline järjekord?** Kui test 1-3 ei tööta, on probleem VLANi sees (trunk? access port? IP?). Pole mõtet testida inter-VLANi kui isegi sama VLAN ei tööta. Kui 1-3 töötavad aga 4-6 mitte, on probleem marsruutimises (`ip routing`? SVI?).

| # | Test | Allikas | Sihtkoht | Ootus | Tulemus |
|---|------|---------|----------|-------|---------|
| 1 | PC → gateway | PC1 | 192.168.10.1 | ✅ | |
| 2 | PC → gateway | PC2 | 192.168.20.1 | ✅ | |
| 3 | PC → gateway | PC3 | 192.168.30.1 | ✅ | |
| 4 | Inter-VLAN | PC1 | 192.168.20.10 (PC2) | ✅ | |
| 5 | Inter-VLAN | PC1 | 192.168.30.10 (PC3) | ✅ | |
| 6 | Inter-VLAN | PC2 | 192.168.30.10 (PC3) | ✅ | |

### 4.3 Traceroute

```
PC1> trace 192.168.30.10
```

**Küsimus:** Mitu hop'i näed? Miks ainult üks, kuigi pakett liigub VLANide vahel? ___________

---

## Osa 5: Ise lahendamine 💪 (30 min)

Nüüd tulevad ülesanded mida pead **ise** lahendama. Käske ja konfiguratsiooni ei anta ette — kasuta eelmistest osadest õpitut.

### Ülesanne 5.1 — Lisa uus VLAN

Ettevõttesse tuleb uus osakond. Lisa **VLAN 40** nimega **EXTERNAL** võrguga **192.168.40.0/24**.

Uus PC4 (VPCS) ühendatakse **SW2** porti **e0/2**.

Mida pead tegema:
1. Lisa VLAN 40 kõigile switchidele
2. Sea SW2 e0/2 õigesse VLANi
3. Lisa SVI DSW1-le (gateway = .1)
4. Luba VLAN 40 kõigil trunk'idel
5. Sea PC4 IP-aadress
6. Testi: PC4 peab pingima PC1, PC2 ja PC3

**Tüüpiline viga:** unustatakse VLAN trunk `allowed` nimekirja lisada!

Kui valmis — näita õpetajale `show vlan brief` ja töötav ping PC4 → PC1.

### Ülesanne 5.2 — Tõrkeotsing

Õpetaja sisestab DSW1-le järgmised käsud mis rikuvad konfiguratiooni:

```
configure terminal
no ip routing
interface vlan 20
 shutdown
interface range e0/0-2
 switchport trunk allowed vlan 10,30
end
```

Nüüd on asjad katki. **Sinu ülesanne:** leia 3 viga ja paranda need.

Alusta diagnoosimisest:
- Kas PC2 saab pingida oma gateway't?
- Kas PC1 saab pingida PC3?
- `show ip route` DSW1-l — mis on puudu?
- `show interfaces trunk` — kas kõik VLANid on lubatud?
- `show ip interface brief` — kas kõik SVI-d on up?

**Kirjuta vastused:**

| # | Viga | Kuidas leidsid | Paranduskäsk |
|---|------|----------------|-------------|
| 1 | | | |
| 2 | | | |
| 3 | | | |

### Ülesanne 5.3 — Boonusülesanne

Sea üles **Native VLAN 99** kõigil trunk linkidel (mõlemal poolel!).

**Küsimus:** Mis juhtub kui ühel poolel on native VLAN 99 ja teisel jääb native VLAN 1? Testi ja kirjuta tulemus: ___________

---

## Salvesta!

Igal seadmel:
```
wr
```

---

## Esitamine

Näita õpetajale:

1. `show vlan brief` kõigil switchidel — VLANid loodud, pordid õiged
2. `show interfaces trunk` DSW1-l — 3 trunk linki
3. `show ip route` DSW1-l — connected marsruudid
4. Töötav ping PC1 → PC2 → PC3 (inter-VLAN)
5. Ülesanne 5.1 — VLAN 40 töötab
6. Ülesanne 5.2 — 3 viga leitud ja parandatud

**VALMIS** ✅

---

## Tõrkeotsingu checklist

| Probleem | Mida kontrollida | Käsk |
|----------|-----------------|------|
| PC ei saa gateway'ni | Access port õiges VLANis? | `show vlan brief` |
| PC ei saa gateway'ni | Trunk töötab? | `show interfaces trunk` |
| PC ei saa gateway'ni | SVI on up/up? | `show ip interface brief` |
| Inter-VLAN ei tööta | ip routing sees? | `show ip route` |
| Inter-VLAN ei tööta | VLAN lubatud trunkil? | `show interfaces trunk` |
| Üks VLAN puudu | VLAN loodud kõigil switchidel? | `show vlan brief` igal seadmel |
