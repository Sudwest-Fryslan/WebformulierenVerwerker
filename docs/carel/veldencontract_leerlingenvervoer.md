# Veldencontract leerlingenvervoer: Atabix-webformulier → CAReL

**Bron:** afgeleid van het werkdocument `velden_carel_met_types.md` (fb-carel), bijgewerkt na de
reactie van de Atabix-formulierbeheerder op de 5 formulierpunten (3 september 2026). Persoonsgegevens
in dit document zijn overal verzonnen/geanonimiseerd of vervangen door rollen.

**Scope: dit contract beschrijft wat de integratie naar CAReL verstuurt, verder niets.** In de hele keten
zijn vier verschillende weergaven te onderscheiden: (1) het webformulier zoals de aanvrager het ziet, (2)
de binnenkomende aanvraag zoals de integratie die ontvangt, (3) wat de integratie vervolgens naar CAReL
verstuurt, en (4) hoe CAReL dit intern toont/verwerkt. Dit document gaat over **(3)**. Weergave (1) staat
erbij als bron (waar komt de waarde vandaan), weergave (4) staat er soms bij als korte toelichting (waarom
vraagt CAReL dit), maar geen van beide is zelf onderdeel van wat hier is vastgelegd.

**Bron van de veldnamen:** de echte mapping (`creeerZaak_Lk01_mapping.xsl`) is nagelopen voor de exacte
veldnamen.

**Echte naam vs. vriendelijke naam:** de "Echte naam"-kolom is de letterlijke technische key uit het
uitwisselcontract (StUF-XML-tag of `extraElement naam=`) — die ligt vast bij CAReL/Eljakim of in de
StUF-ZKN-standaard, niet aanpasbaar vanuit de integratie. De "Vriendelijke naam" is voor de leesbaarheid
van dit document.

**Voorbeeldwaarden:** persoonsgegevens (BSN, naam, adres, telefoon, e-mail) zijn **altijd verzonnen/
geanonimiseerd**. Schoolnamen/-adressen zijn wél echt, want dat is publieke informatie.

---

## Achtergrond: twee leidende principes

**1. Identiteit en authenticatie bepalen wat verstuurd wordt.** De **aanvrager** is zelf ingelogd met
DigiD — die authenticatie legt al onomstotelijk vast wie iemand is. De overige aanvragervelden (naam,
adres, etc.) hebben dus geen zin om door te sturen: die zouden hoe dan ook dezelfde waarde opleveren als
wat CAReL zelf via GBAV ophaalt op basis van het BSN. Het BSN wordt wél verstuurd, niet om de identiteit
vast te stellen (dat staat al vast), maar om **traceerbaar te houden wie de aanvraag heeft gedaan**
(rechtmatigheid). De **leerling** logt zelf niet in en wordt alleen door de aanvrager beschreven — die
gegevens worden dus met de hand ingevuld en zijn foutgevoelig. Daarom is bewust gekozen om ze wél als
losse vrije velden mee te sturen, niet om ze te laten verrijken vanuit GBAV zoals bij de aanvrager, maar
zodat **CAReL ze zelf kan controleren** op juistheid. Voor het verblijfsadres is dat expliciet vastgelegd
(zie sectie 1). Voor de overige leerlinggegevens (roepnaam, achternaam, geboortedatum, geslacht) is niet
vastgelegd of en hoe CAReL deze controleert.

**2. Scope: eerst de burger-route, dan pas organisatie.** Alle keuzes hier gaan vooralsnog uitsluitend
over een **persoon** als aanvrager. Iemand kan met een persoonlijke DigiD-inlog ook aangeven namens een
**organisatie** aan te vragen — zonder eHerkenning. Dat scenario wordt bewust pas uitgewerkt nadat de
burger-route volledig staat (zie `Open punten`).

**⚙️ Weblogica:** waar dit icoon staat, gebeurt dat gedrag in het Atabix-webformulier zelf, niet in de
integratie. De integratie ontvangt alleen de uitkomst.

---

## 1. Rol: leerling (`heeftBetrekkingOp`, StUF-ZKN NPS-object)

| Echte naam (StUF-tag) | Vriendelijke naam | Type | Voorbeeldwaarde | Toelichting |
|---|---|---|---|---|
| `BG:inp.bsn` | BSN leerling | Numeriek (9 cijfers) | *Fictief: 111222333* | Verplicht |
| `BG:voornamen` | Roepnaam | Tekst | *Fictief: "Sanne"* | Formulierlabel "Roepnaam" komt binnen als `voornamen` |
| `BG:voorvoegselGeslachtsnaam` | Tussenvoegsel | Tekst | *Fictief: "van der"* | Mag leeg |
| `BG:geslachtsnaam` | Achternaam | Tekst | *Fictief: "Bakker"* | — |
| `BG:geboortedatum` | Geboortedatum | Datum | *Fictief: 12-3-2015 → 20150312* | Formulier levert `D-M-JJJJ`; integratie normaliseert naar `JJJJMMDD` |
| `BG:geslachtsaanduiding` | Geslacht | Code (M/V/O), berekend | Jongen→M, Meisje→V, overig→O | Formulieropties: "Jongen" / "Meisje" / "Anders" / "Wil ik liever niet zeggen", laatste twee vallen beide onder O |
| `BG:verblijfsadres` (`aoa.postcode`/`aoa.huisnummer`/`gor.openbareRuimteNaam`/`wpl.woonplaatsNaam`) | Verblijfsadres leerling | — | *Fictief: Kerkstraat / 12 / — / — / 8601AB / Sneek* | **Voorstel (3 sep. 2026):** altijd versturen, BAG-conform en gesplitst, op basis van het ingevoerde/overgenomen adres (geen BRP-opzoeking voor de leerling). Bij vinkje "adres leerling gelijk aan aanvrager": kopie van het aanvrageradres. Anders: het apart ingevoerde leerlingadres — **bouwpunt de Atabix-formulierbeheerder**, dit formulierveld bestaat nog niet, dus in de praktijk kan dit pas als dat veld er is. CAReL toont zelf een melding als het adres niet in de BAG voorkomt |

## 2. Rol: aanvrager (`heeftAlsInitiator`, StUF-ZKN NPS-object, burger-route)

| Echte naam (StUF-tag) | Vriendelijke naam | Type | Voorbeeldwaarde | Toelichting |
|---|---|---|---|---|
| `BG:inp.bsn` | BSN aanvrager | Numeriek (9 cijfers) | *Fictief: 444555666* | Verplicht: niet om de identiteit vast te stellen (dat staat door DigiD al vast), maar om traceerbaar te houden wie de aanvraag heeft gedaan (rechtmatigheid) |
| `BG:voorletters` | Voorletters | Tekst | — | **Vervalt** — zie principe 1 |
| `BG:voornamen` | Voornamen | Tekst | — | **Vervalt** |
| `BG:voorvoegselGeslachtsnaam` | Voorvoegsel geslachtsnaam | Tekst | — | **Vervalt** |
| `BG:geslachtsnaam` | Geslachtsnaam | Tekst | — | **Vervalt** |
| `BG:geboortedatum` | Geboortedatum | Datum | — | **Vervalt** |
| `BG:inp.geboorteplaats` | Geboorteplaats | Code (gemeentecode) | — | **Vervalt** |
| `BG:geslachtsaanduiding` | Geslachtsaanduiding | Code (M/V/O) | — | **Vervalt** |
| `BG:verblijfsadres` | Verblijfsadres | — | — | **Vervalt** — CAReL vraagt dit zelf op via het BSN. Wordt in het formulier wel getoond aan de aanvrager en kan overgenomen worden naar het leerling-adres (zie sectie 1) |

**Nog niet doorgevoerd:** de huidige mapping stuurt deze velden nog wel mee. Dit moet worden teruggebracht
naar alleen BSN, conform principe 1.

**Let op — nog geen bevestigd besluit:** dit "vervalt" is een architecturale redenering (principe 1),
géén bevestigde afspraak vanuit CAReL/Eljakim. Het staat bovendien haaks op wat op 24 juli 2026 juist is
gebouwd én succesvol getest tegen CAReL-acceptatie: de volledige aanvragergegevens in `heeftAlsInitiator`
zijn toen toegevoegd en geaccepteerd (zaak 1900881353, `Bv03Bericht`-bevestiging, geen fout). Dit
terugbrengen naar alleen BSN mag dus niet zomaar worden doorgevoerd zonder expliciete afstemming met
CAReL/Eljakim — anders lopen we het risico iets terug te draaien dat al aantoonbaar werkt.

**Betrouwbaarheid van de waarden:** deze aanvragergegevens komen niet los binnen, maar via de
DigiD-geauthenticeerde BRP-voorinvulling — dezelfde bron als het BSN zelf. Er is dus geen aparte controle
op de inhoud nodig: als het BSN via DigiD klopt, klopt de bijbehorende BRP-data net zo goed. Dat is een
argument vóór het (voorlopig) blijven meesturen ervan — niet per se vóór het weglaten.

## 3. Vrije velden (`extraElement naam="..."`)

Hier is de "Echte naam" al gelijk aan de kolom "CAReL-veld" — dat is namelijk letterlijk de
`extraElement naam=`-waarde uit de mapping, dus geen aparte kolom nodig.

### Aanvraagcheck

| CAReL-veld (echte naam) | Formuliervraag | Type | Mogelijke waarden | Opmerking Atabix | Toelichting |
|---|---|---|---|---|---|
| `aanvraagcheck_woont_in_swf_op_schooldagen` | Woont de leerling op schooldagen in de gemeente Súdwest-Fryslân? | Keuzeveld (Ja/Nee) | Ja / Nee | — | — |
| `aanvraagcheck_dichtstbijzijnde_toegankelijke_school` | Gaat de leerling naar de dichtstbijzijnde toegankelijke school? | Keuzeveld (Ja/Nee) | Ja / Nee | — | — |
| `aanvraagcheck_welk_onderwijs` | Welk onderwijs volgt de leerling? | Keuzeveld (dropdown) | "Regulier Basis Onderwijs" / "Speciaal Basis Onderwijs (SBO)" / "Speciaal Onderwijs (SO)" / "Voortgezet Speciaal Onderwijs (VSO)" | **⚙️** Bij "Regulier Basis Onderwijs" toont het formulier geen schoolkeuzelijst maar een vrij tekstveld. Bij de andere 3 typen wél een schoolkeuzelijst, met bij een bekende school automatische gesplitste adresinvulling — zie `school_adres` | Relevant omdat bij bijv. "Regulier Basis Onderwijs" wordt nagebeld — leerlingenvervoer is daar standaard niet voor |
| `aanvraagcheck_enkele_reisafstand_meer_dan_6_km` | Is de enkele reisafstand meer dan 6 km? | Keuzeveld (Ja/Nee) | Ja / Nee | — | — |
| `aanvraagcheck_kan_zelfstandig_reizen` | Kan de leerling zelfstandig reizen? | Keuzeveld (dropdown, 4 opties) | Ja / Nee, maar kan het leren / Nee, jonger dan 10 jaar / Nee, handicap — **volledig bevestigd door Doorstroompunt, 1-2 sep 2026** | — | Bepaalt welke vervolgvraag(en) het formulier toont bij `aanvraagcheck_hoe_gaat_leerling_naar_school` |
| `aanvraagcheck_hoe_gaat_leerling_naar_school` | Hoe gaat de leerling naar school? | Keuzeveld (dropdown, beschrijvend) | **Volledig bevestigd, 1-2 sep 2026.** Bij "Ja": Met de fiets (€0,11/km) / Met het OV (OV-pas). Bij de 3 "Nee"-varianten toont het formulier een andere vraag ("Begeleiden de ouders...?") met eigen opties (fiets/OV/eigen vervoer/nee) | **Aanname (voorstel de Solution Innovator (ontwikkelaar), 2 sep 2026):** dit is functioneel dezelfde vraag, hergebruikt onder dezelfde veldnaam met andere getoonde opties per situatie - net als `vervoer_maandagfiets` e.d. Geen mappingwijziging nodig, we sturen nu al door wat er ook binnenkomt. **Nog niet bevestigd met een echte testcapture** (alle beschikbare tests kozen "Ja") | Beschrijvende teksten i.p.v. korte labels |
| `welkesituatiesvantoepassing` (voorgestelde naam) | Welke situatie(s) is/zijn op de leerling van toepassing? | Keuzeveld (meerkeuze/checkbox) | "Autorit minstens de helft korter" / "Begeleiding naar school nodig" / "Door handicap afhankelijk van autovervoer" — verschijnt bij de 3 "Nee"-varianten van `aanvraagcheck_kan_zelfstandig_reizen` | **Aanname (voorstel de Solution Innovator (ontwikkelaar), 2 sep 2026), niet bevestigd:** vermoedelijk een apart, nieuw veld (meerkeuze past niet in hetzelfde enkelvoudige veld als hierboven). Veldnaam is een gok naar Atabix' naamgevingsstijl - **nog te bevestigen bij de Atabix-formulierbeheerder of met een echte testcapture** | Nieuw signaal, stond nog nergens in de mapping |
| `aanvraagcheck_wil_leerlingenvervoer_aanvragen` | Wil je leerlingenvervoer aanvragen? | Keuzeveld (Ja/Nee) | Ja / Nee | — | Puur ter bevestiging |

### Aanvraag

| CAReL-veld (echte naam) | Formuliervraag | Type | Voorbeeldwaarde | Opmerking Atabix | Toelichting |
|---|---|---|---|---|---|
| `aanvraag_schooljaar` | Voor welk schooljaar? | Keuzeveld (dropdown) | *"2026 - 2027"* | **⚙️** Wordt door het Atabix-webformulier bepaald op basis van `aanvraag_vanaf_datum_gebruik_leerlingenvervoer`. Vanaf ca. 1 juni is aanmelden voor het volgende schooljaar ook mogelijk, dus kan die datum tot een jaar vooruit liggen. Een datum tussen ca. juni en de start van het schooljaar (ca. 1 september) kan bij zowel het lopende als het volgende schooljaar horen; dat moet duidelijk getoond worden. Een datum na de start van het schooljaar hoort bij het nieuwe schooljaar | De integratie ontvangt en stuurt dit veld ongewijzigd door |
| `aanvraag_vanaf_datum_gebruik_leerlingenvervoer` | Vanaf welke datum gebruik? | Datum | *1-9-2026 → 20260901* | — | Integratie normaliseert naar `JJJJMMDD` |
| `aanvraag_namens_burger_of_organisatie` | Namens burger of organisatie? | Keuzeveld (radio) | "Burger" / "Organisatie" | — | Blijft staan: bij "Organisatie" moeten aparte adresgegevens ingevuld worden, GBA/BRP levert die niet. Verdere uitwerking uitgesteld — zie `Open punten` |

### Aanvullende vrije velden bij de aanvrager

| CAReL-veld (echte naam) | Type | Voorbeeldwaarde | Toelichting |
|---|---|---|---|
| `aanvrager_telefoonnummer` | Tekst/numeriek | *Fictief: 0612345678* | Vrij invulveld, geen BRP-veld. Bij "Organisatie" komt de waarde uit het telefoonnummer-veld van het organisatieblok i.p.v. het burgerblok — zelfde CAReL-veldnaam, andere bron, want burger/organisatie sluiten elkaar uit |
| `aanvrager_emailadres` | Tekst | *Fictief: voorbeeld@email.nl* | Vrij invulveld |
| `aanvrager_relatie_tot_leerling` | Keuzeveld (dropdown) | "Ouder" / "Voogd" / "Verzorger" / "Bewindvoerder" / "Curator" / "Anders" | **Bouwpunt:** de mapping leest dit uit `relatietotleerling`, het formulierpad heet nu nog (typefout) `realtietotleerling`, vermoedelijk de reden dat dit veld leeg blijft. Besloten: het formulierpad wordt gecorrigeerd naar `relatietotleerling`. Te herstellen in het Atabix-webformulier |
| `aanvrager_organisatie_naam` | Tekst | *Fictief: "Stichting Voorbeeld"* | **Voorstel (3 sep. 2026).** Alleen relevant als `aanvraag_namens_burger_of_organisatie` = "Organisatie". Bedrijfsnaam uit het al bestaande "Gegevens Organisatie"-blok van het formulier (screenshot van de Atabix-formulierbeheerder, 3 sep. — brondveldnaam nog niet met hem geverifieerd) |
| `aanvrager_naam` | Tekst | *Fictief: "J. van der Berg"* | **Voorstel (3 sep. 2026).** Naam van de contactpersoon bij de organisatie (voornamen + tussenvoegsel + achternaam samengevoegd — geen BRP-controle nodig, dus geen aparte velden zoals bij de leerling). Alleen relevant bij "Organisatie" |

**Vervallen, met de echte namen (allemaal BRP-afkomstig, zie principe 1):** `aanvrager_bsn`,
`aanvrager_voornamen` (bevat nu feitelijk de voorletters — bekende bug, wordt irrelevant), `aanvrager_
tussenvoegsel` (staat nu al leeg in de mapping — bekende bug, wordt irrelevant), `aanvrager_achternaam`,
`aanvrager_geboortedatum`, `aanvrager_adres`, `aanvrager_postcode`, `aanvrager_plaats`.

**Organisatie-adres — voorstel om niet mee te sturen (3 sep. 2026):** het Atabix-formulier heeft bij
"namens een organisatie" inmiddels een volledig "Gegevens Organisatie"-blok, inclusief BAG-conform
gesplitst adres van de contactpersoon (bevestigd door de Atabix-formulierbeheerder, screenshot 3 sep. 2026) — dus geen bouwpunt
meer aan formulierkant. Voorstel voor de CAReL-scope: alleen organisatienaam, contactpersoonnaam en
telefoonnummer versturen (zie hierboven); het adres van de organisatie/contactpersoon wordt dan niet als
extraElement verstuurd. eHerkenning blijft, zoals eerder afgesproken, buiten scope.

### IBAN

| CAReL-veld (echte naam) | Formuliervraag | Type | Voorbeeldwaarde | Toelichting |
|---|---|---|---|---|
| `iban_type` | Op welke IBAN moeten wij overmaken? | Keuzeveld (radio) | "Mijn eigen IBAN" / "De IBAN van mijn partner" / "Op het IBAN van de bewindvoerder/curator (beheerrekening)" | Wordt meegenomen als extraElement, net als de overige IBAN-velden |
| `iban_nummer` | Vul hier de IBAN in | Tekst (IBAN-formaat) | *Fictief (bekend testnummer): NL91ABNA0417164300* | Vrij invulveld |
| `iban_naam_rekeninghouder` | Naam op de bankpas | Tekst | *Fictief: "J. de Vries"* | Vrij invulveld |

### School

| CAReL-veld (echte naam) | Type | Voorbeeldwaarde | Opmerking Atabix | Toelichting |
|---|---|---|---|---|
| `school_naam` | Tekst | *Publiek, uit een testcase: "Súdwester"* | Bij SBO/SO/VSO uit de schoolkeuzelijst; bij Regulier Basis Onderwijs vrij tekstveld | Ongewijzigd |
| `school_adres` | Tekst | *Publiek: Kaatsland 5b, 8608CX, Sneek (hoort bij "Súdwester")* | **⚙️** Bij SBO/SO/VSO met bekende school vult het formulier dit automatisch en gesplitst. Bij Regulier Basis Onderwijs/"Andere school" is het een vrij, niet-gesplitst tekstveld | **Bouwpunt:** moet BAG-conform en gesplitst worden aangeleverd (straat/huisnummer/huisletter/toevoeging/postcode/plaats); huidige mapping stuurt alleen straat. Nodig voor routebepaling van het vervoer (bestemmingsadres, niet alleen de locatie van de leerling) |
| `school_postcode` | Tekst | *Publiek: 8608CX* | — | Onderdeel van dezelfde adres-splitsing hierboven |
| `school_plaats` | Tekst | *Publiek: "Sneek"* | — | Onderdeel van dezelfde adres-splitsing hierboven |

### Eigen bijdrage

| CAReL-veld (echte naam) | Formuliervraag | Type | Voorbeeldwaarde | Toelichting |
|---|---|---|---|---|
| `eigenbijdrage_verzamelinkomen_vorig_jaar` | Verdiende u in het vorige jaar minder dan € 33.700? | Keuzeveld (Ja/Nee) | Ja / Nee | Ja/nee-vraag, geen inkomensklasse-dropdown. Bij "ja" moet `eigenbijdrage_upload_belastingaangifte` mee. Jaar-onafhankelijke naam, sluit aan bij de formuliervraag. CAReL-eigen key, uitvoering bij CAReL/Eljakim |
| `eigenbijdrage_upload_belastingaangifte` | Belastingaangifte uploaden | Bestand (upload) | *"belastingaangifte_2025.pdf"* | Alleen de bestandsnaam wordt doorgestuurd, niet de inhoud |

### Vervoer — spoor-3/spoor-2 pijnpunt

| CAReL-veld (echte naam) | Formuliervraag | Type | Mogelijke waarden | Toelichting |
|---|---|---|---|---|
| `vervoer_type` | Voor welk type vervoer wil je een vergoeding? | Keuzeveld (dropdown) | "Fiets" / "Fiets en Openbaar vervoer" / "Openbaar vervoer zelfstandig" / "Openbaar Vervoer onder begeleiding ouder" / "Eigen vervoer (auto)" / "Groepstaxi vervoer" | Verstuurd wordt de tekstwaarde, ongewijzigd. CAReL leidt hier zelf (buiten deze uitwisseling) een aparte ja/nee-vraag "AV aangevraagd" uit af. Optioneel: hoe CAReL specifiek "Openbaar Vervoer onder begeleiding ouder" naar AV/OV/Fiets/EV vertaalt is niet bekend, niet blokkerend voor de integratie |
| `vervoer_upload_routeplanner` | ANWB-routeplanner uploaden | Bestand (upload) | *"routeplanner.pdf"* | **Kan weg** — gebeurt nu in CAReL zelf |
| `vervoer_upload_vervoersverklaring` | Vervoersverklaring/treinbewijs uploaden | Bestand (upload) | *"vervoersverklaring_school.pdf"* | Blijft, en **wordt verplicht** |
| `vervoer_vanaf_datum_nodig` | Vanaf welke datum nodig? | Datum | *1-9-2026* | **Overbodig, kan weg** — dubbel met `aanvraag_vanaf_datum_gebruik_leerlingenvervoer` |

**Dagdeel-velden — voorstel na reactie de Atabix-formulierbeheerder (3 sep. 2026), nog te bevestigen:**

**Vervallen (oude structuur):** 5 velden, één per dag — `vervoer_maandag`, `vervoer_dinsdag`,
`vervoer_woensdag`, `vervoer_donderdag`, `vervoer_vrijdag`. Elk bevatte een **kommagescheiden vrije
tekst** van alle aangevinkte dagdelen (bijv. "Ochtend, Middag") — de mismatch waar CAReL op vastliep,
want CAReL verwacht een ja/nee-structuur, geen vrije tekst.

**Huidig:** per dag drie losse, onafhankelijke Ja/Nee-vlaggen — Brengen / Ophalen / Geen — dus 15 velden
in plaats van 5. Brengen en Ophalen mogen allebei "Ja" zijn (de normale situatie: heen én terug). "Geen"
is een bewuste, expliciete derde optie die de andere twee uitsluit — **weblogica bij Atabix** (niet iets
wat de integratie afdwingt), zodat de aanvrager niet alle blokjes hoeft aan te vinken om aan te geven dat
er die dag geen vervoer nodig is. Atabix is vrij in de exacte visualisatie (checkboxes, of iets anders),
zolang de drie onafhankelijke waarden bij de integratie terugkomen — de integratie converteert zo nodig.
De onderstaande CAReL-veldnamen zijn een **voorstel**, nog te bevestigen zodra Atabix dit
daadwerkelijk bouwt:

| CAReL-veldnaam (`extraElement naam=`) | Type |
|---|---|
| `vervoer_maandag_brengen` | Keuzeveld (Ja/Nee) |
| `vervoer_maandag_ophalen` | Keuzeveld (Ja/Nee) |
| `vervoer_maandag_geen` | Keuzeveld (Ja/Nee) |
| `vervoer_dinsdag_brengen` | Keuzeveld (Ja/Nee) |
| `vervoer_dinsdag_ophalen` | Keuzeveld (Ja/Nee) |
| `vervoer_dinsdag_geen` | Keuzeveld (Ja/Nee) |
| `vervoer_woensdag_brengen` | Keuzeveld (Ja/Nee) |
| `vervoer_woensdag_ophalen` | Keuzeveld (Ja/Nee) |
| `vervoer_woensdag_geen` | Keuzeveld (Ja/Nee) |
| `vervoer_donderdag_brengen` | Keuzeveld (Ja/Nee) |
| `vervoer_donderdag_ophalen` | Keuzeveld (Ja/Nee) |
| `vervoer_donderdag_geen` | Keuzeveld (Ja/Nee) |
| `vervoer_vrijdag_brengen` | Keuzeveld (Ja/Nee) |
| `vervoer_vrijdag_ophalen` | Keuzeveld (Ja/Nee) |
| `vervoer_vrijdag_geen` | Keuzeveld (Ja/Nee) |

*Voorbeeld van een ingevulde week (fictief): een leerling die op maandag, woensdag en vrijdag heen én
terug vervoer nodig heeft, en op dinsdag/donderdag niet — dan staan `vervoer_maandag_brengen`,
`vervoer_maandag_ophalen`, `vervoer_woensdag_brengen`, `vervoer_woensdag_ophalen`,
`vervoer_vrijdag_brengen` en `vervoer_vrijdag_ophalen` op "Ja", en `vervoer_dinsdag_geen`/
`vervoer_donderdag_geen` op "Ja" (de overige 8 op "Nee").*

### Toelichting

| CAReL-veld (echte naam) | Type | Voorbeeldwaarde | Toelichting |
|---|---|---|---|
| `toelichting` | Vrije tekst (meerdere regels) | *Fictief: "Mijn kind kan vanwege een beperking niet zelfstandig fietsen."* | Open vrij tekstveld, geen validatie |

---

## Open punten

**Opgelost:**
- ~~Volledige keuzelijst `aanvraagcheck_hoe_gaat_leerling_naar_school`~~ — beantwoord door Doorstroompunt
  op 1 en 2 september 2026 (alle 4 takken van `aanvraagcheck_kan_zelfstandig_reizen`, inclusief de twee
  vervolgvragen bij de "Nee"-varianten). Zie secties 3 hierboven. Twee onderdelen daarvan zijn een
  aanname (voorstel de Solution Innovator (ontwikkelaar), 2 sep 2026), expliciet zo gemarkeerd: dat "Hoe gaat naar school?" en
  "Begeleiden de ouders...?" hetzelfde veld zijn, en de voorgestelde naam voor het nieuwe
  `welkesituatiesvantoepassing`-veld. Beide nog niet bevestigd met een echte testcapture of door de Atabix-formulierbeheerder.
- ~~`heeftAlsInitiator` terugbrengen naar alleen BSN~~ — inmiddels wél bevestigd door CAReL/Eljakim
  (mailwisseling "260820 toevoeging aanpassing nav overleg vervoer", 1 sep 2026) en al doorgevoerd in de
  mapping (zie `openstaande_punten_integratie.md` in de repo).
- ~~Organisatie als aanvrager, basisrichting~~ — beantwoord door de CAReL-leverancier (Eljakim), 24 augustus 2026: BSN
  om aan een bekende ouder te koppelen; zonder bekende ouder een vrij naamveld, zoveel als nodig uit te
  breiden. Verwerkt als `aanvrager_organisatie_naam` in sectie 3.
- ~~Typefout `realtietotleerling` in het formulierpad~~ — opgelost door de Atabix-formulierbeheerder, 3 september 2026.

**Reactie de Atabix-formulierbeheerder op de overige 4 formulierpunten uit de "260820"-mail** (binnen, 3 september 2026,
`Re_ 260820 toevoeging aanpassing nav overleg vervoer (4).eml`) — dit zijn **voorstellen voor het
contract**, geen afgeronde punten: de precieze brondveldnamen en de scope-keuzes moeten nog met de Atabix-formulierbeheerder
en/of de CAReL-leverancier (Eljakim) worden vastgezet.
1. **Dagen vervoer:** de Atabix-formulierbeheerder bevestigt het model van 3 onafhankelijke checkboxes per dag (Brengen/Ophalen/
   Geen, niet mutueel exclusief tussen Brengen en Ophalen — "Geen" sluit de andere twee uit via
   weblogica bij de Atabix-formulierbeheerder, die zelf de visualisatie mag kiezen zolang de integratie het resultaat kan
   vertalen). De exacte veldnamen die Atabix straks gaat leveren zijn nog niet vastgesteld.
2. **Leerlingadres altijd gesplitst:** voorstel — altijd versturen; bij "gelijk aan aanvrager" een kopie
   van het aanvrageradres. Eigen leerlingadres blijft een bouwpunt bij de Atabix-formulierbeheerder (formulierveld bestaat nog
   niet). Zie sectie 1 hierboven.
3. **Schooladres gesplitst:** de recent (op verzoek van de Doorstroommedewerker en een collega) ingerichte opzet lijkt te
   voldoen — nog te bevestigen.
4. **Organisatie-naamveld:** blijkt al te bestaan (compleet "Gegevens Organisatie"-blok met BAG-conform
   adres, getoond via screenshot). Voorstel voor de CAReL-scope: alleen organisatienaam,
   contactpersoonnaam en telefoonnummer — geen adres, geen eHerkenning. Zie sectie "Aanvullende vrije
   velden bij de aanvrager" hierboven. Brondveldnaam van het organisatieblok nog niet geverifieerd.

**Aangenomen (stilzwijgend akkoord, geen actieve bevestiging):**
- **Dagdeel-structuur (Brengen/Ophalen/Geen × 5 dagen).** Op 24 augustus 2026 kon de CAReL-leverancier (Eljakim) dit nog niet
  direct beoordelen ("nog erg nieuw aan onze kant"). In de mail van 1 september is bewust een
  stilzwijgend-akkoord-afspraak gemaakt: *"we gaan er vanuit dat je dit dagdeel-verhaal aan CAReL-kant
  kunt inrichten - mocht dat niet zo zijn, dan graag even een reactie."* Er is geen tegenspraak ontvangen
  (wel twee reacties van de Doorstroommedewerker sindsdien, niets van de CAReL-leverancier (Eljakim) over dit punt) — onder onze eigen voorwaarden
  gaan we dus door op de aanname dat dit werkt. Geen blokkade meer voor vervolgstappen (bijv. de Atabix-formulierbeheerder aan het
  werk zetten), maar nog geen actieve bevestiging - als de CAReL-leverancier (Eljakim) later toch bezwaar maakt, moet dit
  mogelijk worden aangepast.
- Geboorteplaats aanvrager als gemeentecode i.p.v. plaatsnaam — nog steeds niet met Eljakim afgestemd.
