# Inter-VLAN marsruutimine

---

## Sissejuhatus (5 min)

Eelmisel korral rääkisime VLANidest. Te teate nüüd, et VLAN eraldab võrgu loogilisteks osadeks - HR osakond ühes VLANis, Sales teises, IT kolmandas. See on hea, sest broadcast'id ei levi enam üle terve võrgu ja meil on parem kontroll selle üle, kes kellega suhelda saab.

Aga nüüd tekib probleem. Kujutage ette, et HR osakonna töötaja peab saatma faili Sales osakonna töötajale. HR on VLAN 10-s, Sales on VLAN 20-s. Mis juhtub kui HR arvuti proovib Sales arvutit pingida?

Mitte midagi. Pakett ei lähe läbi.

Miks? Sest VLANid on erinevad broadcast domain'id. Teisisõnu - need on täiesti erinevad võrgud. Ja mis seade ühendab erinevaid võrke? Ruuter. Ilma ruuterita ei saa erinevad VLANid omavahel rääkida. See on nagu kaks eraldi hoonet ilma ühenduseta - inimesed mõlemas hoones eksisteerivad, aga nad ei saa üksteise juurde minna.

Täna vaatame, kuidas seda probleemi lahendada. Selleks on mitu võimalust.

---

## Vana lahendus: eraldi pordid (2 min)

Kõige lihtsam lahendus oleks ühendada iga VLAN eraldi kaabliga ruuteri eraldi porti. Kui sul on kolm VLANi, siis kolm kaablit ja kolm ruuteri porti.

See töötab, aga on halb lahendus. Miks? Esiteks, ruuteritel pole tavaliselt palju Ethernet porte - võib-olla neli või kaheksa. Kui sul on kümme VLANi, siis juba ei jätku. Teiseks, see on kaablite raiskamine. Kolmandaks, kui sa hiljem lisad uue VLANi, pead uue kaabli tõmbama.

Seda lahendust tänapäeval praktiliselt ei kasutata. Ma mainin seda ainult selleks, et te teaksite - see on võimalik, aga ärge seda tehke.

---

## Router-on-a-Stick (15 min)

Parem lahendus on Router-on-a-Stick. See nimi kõlab naljakalt, aga kirjeldab hästi, mida me teeme: ruuter istub "kepi otsas" ehk ühe ainsa lingi otsas.

Idee on järgmine. Ruuteri ja switchi vahel on üks trunk link. See trunk kannab kõiki VLANe. Aga ruuteri poolel me loome "subinterface'id" - virtuaalsed liidesed, üks iga VLANi jaoks.

Vaatame konkreetselt. Meil on ruuter ja switchil on kolm VLANi: VLAN 10 HR jaoks, VLAN 20 Sales jaoks, VLAN 30 IT jaoks. Ruuteri füüsiline port on GigabitEthernet 0/0. Me ei anna sellele pordile IP-aadressi! Selle asemel loome:

- G0/0.10 - see on subinterface VLAN 10 jaoks, IP-aadress 192.168.10.1
- G0/0.20 - see on subinterface VLAN 20 jaoks, IP-aadress 192.168.20.1  
- G0/0.30 - see on subinterface VLAN 30 jaoks, IP-aadress 192.168.30.1

See punkt ja number subinterface'i nimes - G0/0.10 - on lihtsalt konventsioon. Sa võid panna G0/0.999 ja seada see VLAN 10 jaoks. Aga mõistlik on kasutada sama numbrit kui VLAN ID, siis on lihtsam meeles pidada.

Kuidas see töötab? Kui HR arvuti tahab saata paketti Sales arvutile, siis:

Esiteks, HR arvuti näeb et sihtkoht 192.168.20.10 on teises võrgus, seega saadab paketi oma gateway'le. Gateway on 192.168.10.1 ehk ruuteri subinterface G0/0.10.

Teiseks, switch saadab selle paketi trunk linki kaudu ruuterisse. Pakett on märgistatud VLAN 10 tag'iga.

Kolmandaks, ruuter võtab paketi vastu subinterface G0/0.10 kaudu, sest see subinterface kuulab VLAN 10 liiklust. Ruuter vaatab marsruutimistabelit ja näeb, et 192.168.20.0/24 on otse ühendatud läbi G0/0.20.

Neljandaks, ruuter saadab paketi välja läbi G0/0.20. See tähendab, et pakett saab VLAN 20 tag'i.

Viiendaks, switch saab paketi trunk lingilt, näeb VLAN 20 tag'i ja saadab paketi edasi õigesse access porti, kus Sales arvuti istub.

See kõik toimub sekunditega. Kasutaja ei märkagi, et pakett käis ruuteris ära.

Nüüd seadistamine. Switchi poolel on tavaline trunk:

```
interface G0/1
  switchport trunk encapsulation dot1q
  switchport mode trunk
  switchport trunk allowed vlan 10,20,30
```

Ruuteri poolel esmalt aktiveerime füüsilise pordi. Tähelepanu - me ei anna sellele IP-aadressi!

```
interface G0/0
  no shutdown
```

Siis loome subinterface'id. Iga subinterface'i juures ütleme, mis VLANiga see seotud on, ja anname IP-aadressi:

```
interface G0/0.10
  encapsulation dot1Q 10
  ip address 192.168.10.1 255.255.255.0

interface G0/0.20
  encapsulation dot1Q 20
  ip address 192.168.20.1 255.255.255.0

interface G0/0.30
  encapsulation dot1Q 30
  ip address 192.168.30.1 255.255.255.0
```

See "encapsulation dot1Q 10" ütleb ruuterile: kui näed paketti VLAN 10 tag'iga, see kuulub siia subinterface'ile. Ja kui saadad paketi sellest subinterface'ist välja, pane talle VLAN 10 tag külge.

Kontrollimiseks vaata "show ip interface brief" - seal pead nägema kõiki subinterface'e "up/up" olekus. Ja "show ip route" näitab, et kõik kolm võrku on directly connected.

---

## Router-on-a-Stick puudus (3 min)

Router-on-a-Stick töötab hästi väikestes võrkudes. Aga tal on üks suur puudus: kõik VLANidevaheline liiklus käib läbi selle ühe trunk lingi.

Kujutage ette kontorit, kus on sada inimest. Viiskümmend HR-is, viiskümmend Sales-is. Ja nad kõik saadavad üksteisele faile kogu aeg. Kõik need paketid peavad minema läbi ühe GigabitEthernet lingi ruuterisse ja tagasi. See link muutub pudelikaelaks.

Pluss, ruuter peab tegema tarkvaralist marsruutimist. Ruuterid on head IP marsruutimises, aga nad pole nii kiired kui switchid Layer 2 töös.

Väikeses võrgus, näiteks labori keskkonnas või väikeses kontoris kuni paarkümmend inimest - Router-on-a-Stick on suurepärane. Aga suures ettevõttes on vaja midagi võimsamat.

---

## L3 Switch ja SVI (10 min)

Lahendus suurte võrkude jaoks on Layer 3 switch. See on switch, mis oskab ka marsruutida. Sisuliselt ruuter ja switch ühes karbis.

Layer 3 switchil me kasutame SVI-sid - Switch Virtual Interface. SVI on virtuaalne liides, mis esindab tervet VLANi. Kui sa lood "interface vlan 10" ja annad sellele IP-aadressi, siis see IP-aadress saab VLAN 10 gateway'ks.

See töötab nii. Switchi sees on kaks mootorit: switching engine ja routing engine. Kui pakett liigub sama VLANi sees, tegeleb sellega switching engine - väga kiire, wire-speed. Kui pakett peab minema teise VLANi, siis routing engine võtab üle, teeb marsruutimisotsuse, ja annab paketi tagasi switching engine'ile õigesse VLANi saatmiseks.

Erinevus Router-on-a-Stick'iga on see, et L3 switchil pole pudelikaela. Pole trunk linki, mille kaudu kõik peaks käima. Marsruutimine toimub switchi sees, riistvara tasemel, väga kiiresti.

Seadistamine on isegi lihtsam. Kõigepealt lülitame routing funktsiooni sisse:

```
ip routing
```

See käsk on oluline! Ilma selleta switch ei marsruudi, isegi kui SVI-del on IP-aadressid.

Siis loome SVI-d:

```
interface vlan 10
  ip address 192.168.10.1 255.255.255.0
  no shutdown

interface vlan 20
  ip address 192.168.20.1 255.255.255.0
  no shutdown

interface vlan 30
  ip address 192.168.30.1 255.255.255.0
  no shutdown
```

See ongi kõik. Pordid on juba VLANidesse määratud nagu tavaliselt, ja nüüd on igal VLANil gateway.

Kontrolli "show ip route" - näed kolme directly connected võrku. Ja VLANidevahelised pingid peaksid kohe tööle hakkama.

---

## Võrdlus ja millal mida kasutada (5 min)

Võtame kokku. Meil on kaks peamist lahendust: Router-on-a-Stick ja L3 Switch.

Router-on-a-Stick kasutab tavalist ruuterit ja tavalist L2 switchi. Seadistamine on lihtne, riistvara on odav. Aga kogu VLANidevaheline liiklus käib läbi ühe lingi - see on pudelikael. Kasuta seda väikeses võrgus, kodulabis, või seal kus pole palju VLANidevahelist liiklust.

L3 Switch on kallim, aga võimsam. Marsruutimine toimub riistvara tasemel, wire-speed. Pole pudelikaela. Kasuta seda ettevõtte võrgus, campus network'is, andmekeskuses - kõikjal kus on palju liiklust ja kiirus on oluline.

Päris elus näete mõlemat. Väiksemas filiaalikontoris võib olla Router-on-a-Stick. Peakontoris ja andmekeskuses on kindlasti L3 switchid.

---

## Tõrkeotsing (5 min)

Kui VLANidevaheline suhtlus ei tööta, siis kontrolli järgmisi asju.

Esiteks, kas arvuti saab oma gateway'ni? Kui PC VLAN 10-s ei saa pingida 192.168.10.1, siis probleem on juba VLANi sees, mitte VLANide vahel. Kontrolli kas port on õiges VLANis, kas link on üleval.

Teiseks, kas trunk töötab? "Show interfaces trunk" näitab kas trunk on üleval ja millised VLANid on lubatud. Kui VLAN 20 pole trunk'il lubatud, siis VLAN 20 liiklus ei jõua ruuterisse.

Kolmandaks, kas subinterface'd on üleval? "Show ip interface brief" ruuteril. Kui G0/0.10 on "down/down", siis kontrolli kas füüsiline G0/0 on "no shutdown" olekus ja kas VLAN 10 on switchi trunk'il lubatud.

Neljandaks, L3 switchil: kas "ip routing" on sees? See unub tihti ära. Ilma selleta switch lihtsalt ei marsruudi.

Viiendaks, kas PC gateway on õige? Kui PC IP on 192.168.10.10 aga gateway on seatud 192.168.20.1, siis midagi ei tööta.

---

## Kokkuvõte (2 min)

Täna õppisime, et VLANid eraldavad võrgu, aga mõnikord peavad VLANid siiski omavahel suhtlema. Selleks on vaja marsruutimist.

Router-on-a-Stick kasutab subinterface'e ja ühte trunk linki. Lihtne ja odav, aga skaleerub halvasti.

L3 Switch kasutab SVI-sid ja teeb marsruutimist riistvaras. Kiirem ja skaleerub paremini, aga maksab rohkem.

Nüüd praktika. Laboris kasutame Router-on-a-Stick lahendust, sest see on meie riistvaraga võimalik. Te seadistate kolm VLANi, trunk'i, ja subinterface'd. Lõpuks peab üks VLAN teist pingima saama.
