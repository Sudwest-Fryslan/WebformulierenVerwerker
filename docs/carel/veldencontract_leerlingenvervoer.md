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

## 0. Zaakniveau: stuurgegevens en zaakobject

De omhulling om de twee rollen (secties 1 en 2) en de vrije velden (sectie 3) heen. Deze velden komen
niet uit het formulier maar uit vaste waarden, applicatieproperties of het zaaksysteem. Ze stonden tot
10 sep. 2026 alleen in de mapping en in geen enkele afspraak — vandaar dat de statuskolom hier eerlijk
onderscheid maakt tussen "terug te voeren op de CAReL-referentie" en "door ons toegevoegd".

Referentie is `docs/carel/20260302/creeerzaak_carel.xml`, het voorbeeldbericht van CAReL zelf.

### Stuurgegevens en parameters

| Element | Waarde | Herkomst | Status |
|---|---|---|---|
| `StUF:berichtcode` | `Lk01` | vast | Conform CAReL-referentie |
| `StUF:zender/organisatie` | `1900` | property `stuf_zender_organisatie` | Configureerbaar per omgeving |
| `StUF:zender/applicatie` | `WebformulierenKoppeling` | property `stuf_zender_applicatie` | Configureerbaar per omgeving |
| `StUF:zender/gebruiker` | `Gebruiker` | property `stuf_zender_gebruiker` | Configureerbaar per omgeving |
| `StUF:ontvanger/organisatie` | `1900` | property `stuf_ontvanger_organisatie` | Configureerbaar per omgeving |
| `StUF:ontvanger/applicatie` | `CAREL` | property `stuf_ontvanger_applicatie` | Configureerbaar per omgeving |
| `StUF:referentienummer` | UUID per bericht | gegenereerd | Komt terug als `crossRefnummer` in het `Bv03Bericht` |
| `StUF:tijdstipBericht` | `JJJJMMDDuummsshh` | gegenereerd | Verzendmoment, tot op honderdsten |
| `StUF:entiteittype` | `ZAK` | vast | Conform CAReL-referentie |
| `StUF:mutatiesoort` | `T` (toevoeging) | vast | Conform CAReL-referentie |
| `StUF:indicatorOvername` | `V` (volledig) | vast | Conform CAReL-referentie |

### Zaakobject (`ZKN:object`, `entiteittype="ZAK"`, `verwerkingssoort="T"`)

| Element | Waarde | Herkomst | Status |
|---|---|---|---|
| `StUF:sleutelVerzendend` | zaakidentificatie | OpenZaakBrug | Zelfde waarde als `ZKN:identificatie` |
| `ZKN:identificatie` | *bv. `1900887058`* | OpenZaakBrug, `genereerZaakIdentificatie` | Uitgegeven door het zaaksysteem, niet door ons bedacht |
| `ZKN:omschrijving` | `Aanvraag leerlingenvervoer` | vast | Conform CAReL-referentie |
| `ZKN:kenmerk/kenmerk` | *bv. `SWF-f4c0b8ae9934`* | `globals/kenmerkaanvraag` uit het formulier | **Toevoeging door ons** — staat niet in de CAReL-referentie |
| `ZKN:kenmerk/bron` | `Kodison` | vast | **Toevoeging door ons** — staat niet in de CAReL-referentie |
| `ZKN:startdatum` | `JJJJMMDD` | `FORMULIER/DATUMVERZENDING` | Datum waarop de burger het formulier verzond |
| `ZKN:registratiedatum` | `JJJJMMDD` | verwerkingsmoment | Datum waarop de integratie het bericht opbouwt |
| `ZKN:isVan` (relatie-entiteit ZAKZKT) | `verwerkingssoort="T"` | vast | Conform StUF 03.01 §5.2.6, tabel 5.7 |
| `ZKN:isVan/gerelateerde` (ZKT) | `verwerkingssoort="I"` | vast | Zaaktype bestaat al bij CAReL; alleen verwijzen |
| `ZKN:isVan/gerelateerde/code` | `LV-001` | vast | Conform CAReL-referentie |
| `ZKN:isVan/gerelateerde/omschrijving` | `Leerlingenvervoer aanvraag` | vast | Conform CAReL-referentie |
| `ZKN:isVan/gerelateerde/ingangsdatumObject` | leeg (`noValue="geenWaarde"`) | vast | Conform CAReL-referentie |

### Verplichte velden — het bericht wordt niet verstuurd zonder

De integratie stopt met een leesbare fout, in plaats van een half bericht naar CAReL te sturen:

| Controle | Melding bij ontbreken |
|---|---|
| Structuur `FORMULIER/ELEMENTEN/form/answers` aanwezig | noemt het gevonden root-element en verwijst naar de passthrough-stylesheet |
| BSN leerling | noemt veldnaam en bronpad |
| BSN aanvrager | noemt veldnaam en bronpad |
| `vervoer_upload_vervoersverklaring` | noemt veldnaam en bronpad |

Die fout komt via de exception-afhandeling als SOAP Fault met HTTP 500 terug bij Atabix. Velden die het
formulier extra meestuurt en die dit contract niet kent, leveren bewust **geen** fout op: die worden
genegeerd, zodat het formulier vooruit kan lopen zonder de koppeling te breken.

---

## 1. Rol: leerling (`heeftBetrekkingOp`, StUF-ZKN NPS-object)

| Echte naam (StUF-tag) | Vriendelijke naam | Type | Voorbeeldwaarde | Toelichting |
|---|---|---|---|---|
| `BG:inp.bsn` | BSN leerling | Numeriek (9 cijfers) | *Fictief: 111222333* | Verplicht |
| `BG:voornamen` | Roepnaam | Tekst | *Fictief: "Sanne"* | Formulierlabel "Roepnaam" komt binnen als `voornamen` |
| `BG:voorvoegselGeslachtsnaam` | Tussenvoegsel | Tekst | *Fictief: "van der"* | Mag leeg |
| `BG:geslachtsnaam` | Achternaam | Tekst | *Fictief: "Bakker"* | — |
| `BG:geboortedatum` | Geboortedatum | Datum | *Fictief: 12-3-2015 → 20150312* | Formulier levert `D-M-JJJJ`; integratie normaliseert naar `JJJJMMDD` |
| `BG:geslachtsaanduiding` | Geslacht | Code (M/V/O), berekend | Jongen→M, Meisje→V, Anders→O, "Wil ik liever niet zeggen"→O | Deze vier formulieropties zijn de volledige lijst. Een **andere** waarde stopt de verwerking met een foutmelding in plaats van stilzwijgend O op te leveren: dat betekent dat het formulier een optie heeft gekregen die dit contract niet kent, en dan hoort het contract eerst bijgesteld te worden. Een lege waarde levert wel gewoon O op — niets ingevuld is geen nieuwe optie |
| `BG:verblijfsadres` (`aoa.postcode`/`aoa.huisnummer`/`aoa.huisletter`/`aoa.huisnummertoevoeging`/`gor.openbareRuimteNaam`/`wpl.woonplaatsNaam`) | Verblijfsadres leerling | — | *Fictief: Kerkstraat / 12 / — / — / 8601AB / Sneek* | **Besloten (3 sep. 2026, na reactie de CAReL-leverancier (Eljakim)):** altijd versturen, BAG-conform en volledig gesplitst (incl. huisletter/huisnummertoevoeging, zie ook `Open punten`). De integratie maakt zelf **geen** keuze meer op basis van "leerling heeft ander adres dan aanvrager" — dat kopiëren (aanvrageradres → leerlingveld, indien van toepassing) is **weblogica bij Atabix**, niet bij de integratie. De integratie stuurt gewoon wat er in het leerling-adresveld staat. Aanvrageradres wordt zelf nooit los als aanvrager-adres naar CAReL gestuurd (zie sectie 2). **Bouwpunt de Atabix-formulierbeheerder:** dit leerling-adresveld (incl. de kopieerlogica) bestaat nog niet in het formulier |

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
| `aanvraagcheck_welk_onderwijs` | Welk onderwijs volgt de leerling? | Keuzeveld (dropdown) | "Regulier Basis Onderwijs" / "Speciaal Basis Onderwijs (SBO)" / "Speciaal Onderwijs (SO)" / "Voortgezet Speciaal Onderwijs (VSO)" | **⚙️** Bij "Regulier Basis Onderwijs" toont het formulier geen schoolkeuzelijst maar een vrij tekstveld. Bij de andere 3 typen wél een schoolkeuzelijst, met bij een bekende school automatische gesplitste adresinvulling — zie sectie `School` | Relevant omdat bij bijv. "Regulier Basis Onderwijs" wordt nagebeld — leerlingenvervoer is daar standaard niet voor |
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
| `school_openbare_ruimte_naam` | Tekst | *Publiek: "Kaatsland"* | **⚙️** Bij SBO/SO/VSO met bekende school vult het formulier dit automatisch en gesplitst. Bij Regulier Basis Onderwijs/"Andere school" moet de splitsing ook aangeboden worden | Onderdeel van het BAG-conform gesplitste schooladres |
| `school_huisnummer` | Tekst (numeriek) | *Publiek: 5* | **⚙️** Idem | Onderdeel van het BAG-conform gesplitste schooladres |
| `school_huisletter` | Tekst (1 letter) | *Publiek: "b"* | **⚙️** Idem | Onderdeel van het BAG-conform gesplitste schooladres. Leeg = niet van toepassing |
| `school_huisnummertoevoeging` | Tekst | *Leeg in dit voorbeeld* | **⚙️** Idem | Onderdeel van het BAG-conform gesplitste schooladres. Leeg = niet van toepassing |
| `school_postcode` | Tekst | *Publiek: 8608CX* | — | Onderdeel van het BAG-conform gesplitste schooladres |
| `school_woonplaats` | Tekst | *Publiek: "Sneek"* | — | Onderdeel van het BAG-conform gesplitste schooladres |

**Schooladres BAG-conform gesplitst — vastgesteld (3 sep. 2026).** Het samengestelde veld `school_adres`
**vervalt** en wordt vervangen door zes losse velden, met **BAG-naamgeving als leidend principe** voor de
veldnamen. Reden: CAReL zoekt adressen zelf op via de BAG om te controleren of ze kloppen, en heeft
daarvoor alle onderdelen los nodig — zie het besluit bij `Open punten`, punt 3 van de reactie van de
CAReL-leverancier (Eljakim): dit geldt voor **alle** adressen, niet alleen school. Het schooladres is
daarbij het bestemmingsadres voor de routebepaling van het vervoer, niet slechts een registratiegegeven.

**Naamgevingsregel: de BAG is leidend.** De veldnamen volgen de BAG-attribuutnamen, dezelfde die de
StUF/BG-structuur voor het leerlingadres al gebruikt (`gor.openbareRuimteNaam`, `aoa.huisnummer`,
`aoa.huisletter`, `aoa.huisnummertoevoeging`, `aoa.postcode`, `wpl.woonplaatsNaam`), in de
snake_case-schrijfwijze van de overige `extraElementen`. Twee gevolgen ten opzichte van de eerdere
veldenlijst:

- de straat heet `school_openbare_ruimte_naam`, niet `school_straat` of `school_straatnaam` — "openbare
  ruimte" is de BAG-term, een straat is één soort openbare ruimte;
- het bestaande `school_plaats` is hernoemd naar `school_woonplaats`, de BAG-term.

Dat laatste raakt een veld dat er al was: Atabix en CAReL moeten die naam dus meenemen. Dat is een bewuste
keuze — één consistente naamgeving over alle adressen is meer waard dan het sparen van één bestaande naam.

De brondveldnamen aan de Atabix-kant zijn voor de bekende scholen (SBO/SO/VSO) al gesplitst beschikbaar;
welke XML-namen het formulier precies levert is nog niet met een capture geverifieerd. Dat blokkeert dit
contract niet: contract en testberichten gaan voorop, en als het webformulier daarop aangepast moet
worden, dan is dat zo — het proces is iteratief (zie `docs/werkwijze_integraties.md`).

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

**Dagdeel-velden — vastgesteld (8 sep. 2026):**

**Vervallen (oude structuur):** 5 velden, één per dag — `vervoer_maandag`, `vervoer_dinsdag`,
`vervoer_woensdag`, `vervoer_donderdag`, `vervoer_vrijdag`. Elk bevatte een **kommagescheiden vrije
tekst** van alle aangevinkte dagdelen (bijv. "Ochtend, Middag") — de mismatch waar CAReL op vastliep,
want CAReL verwacht een ja/nee-structuur, geen vrije tekst.

**Ook vervallen (tussentijds voorstel, 3 sep., nooit aan de Atabix-formulierbeheerder gevraagd):** 15 losse Ja/Nee-velden
(Brengen/Ophalen/Geen per dag). de CAReL-leverancier (Eljakim) gaf aan dat CAReL's eigen mechanisme werkt met een
heen-tijdstip en een terug-tijdstip, en dat automatisch vullen met alleen Ja/Nee lastig wordt (nieuwe,
bij CAReL nog niet eerder gebruikte functionaliteit). We volgen daarin de lijn van de leverancier i.p.v.
tegen hun systeem in te bouwen.

**Vastgesteld:** per dag twee tijdvelden — een heen-tijdstip (brengen) en een terug-tijdstip (halen) — in
plaats van de Ja/Nee-vlaggen. Leeg = geen vervoer nodig in die richting op die dag. Dit is een
rechtstreekse vertaling van de CAReL-leverancier (Eljakim)'s eigen beschrijving van hoe CAReL dit intern verwerkt, dus 10 velden
in plaats van 15. De veldnamen zijn onze eigen keuze (CAReL-extraElementen, geen afstemming met Eljakim
nodig) — bevestigd door de Atabix-formulierbeheerder (4 sep. 2026), zie hieronder:

| CAReL-veldnaam (`extraElement naam=`) | Type |
|---|---|
| `vervoer_maandag_heentijd` | Tijdstip (bv. "08:15"), leeg = niet nodig |
| `vervoer_maandag_terugtijd` | Tijdstip, leeg = niet nodig |
| `vervoer_dinsdag_heentijd` | Tijdstip, leeg = niet nodig |
| `vervoer_dinsdag_terugtijd` | Tijdstip, leeg = niet nodig |
| `vervoer_woensdag_heentijd` | Tijdstip, leeg = niet nodig |
| `vervoer_woensdag_terugtijd` | Tijdstip, leeg = niet nodig |
| `vervoer_donderdag_heentijd` | Tijdstip, leeg = niet nodig |
| `vervoer_donderdag_terugtijd` | Tijdstip, leeg = niet nodig |
| `vervoer_vrijdag_heentijd` | Tijdstip, leeg = niet nodig |
| `vervoer_vrijdag_terugtijd` | Tijdstip, leeg = niet nodig |

*Voorbeeld van een ingevulde week (fictief): een leerling die op maandag, woensdag en vrijdag om 08:15
naar school en om 15:30 terug moet, en op dinsdag/donderdag geen vervoer nodig heeft — dan staan
`vervoer_maandag_heentijd`/`vervoer_woensdag_heentijd`/`vervoer_vrijdag_heentijd` op "08:15",
`vervoer_maandag_terugtijd`/`vervoer_woensdag_terugtijd`/`vervoer_vrijdag_terugtijd` op "15:30", en alle
dinsdag/donderdag-velden leeg.*

**Bevestigd gebouwd door Atabix (4 sep. 2026):** de Atabix-formulierbeheerder heeft dit exacte model al
in het formulier gebouwd (screenshot: "Maandag heentijdstip", "Maandag terugtijdstip", enz. voor alle 5
dagen) en er een testaanvraag mee ingediend (referentienummer 1900887058, via de toen nog oude,
gedeployde integratie). De echte XML-brondveldnamen zijn inmiddels
geverifieerd met een live testcapture van de Atabix-formulierbeheerder (8 sep. 2026,
`leerlingenvervoer_2026.xml`): de tijden staan genest in een `<taxi>`-container onder
`fleerlingenvervoerv3vervoer`, als `<dag>heentijdstip` / `<dag>terugtijdstip`. De integratie leest die
structuur. Dit punt is daarmee afgerond — geen bouwpunt en geen openstaande check meer.

### Toelichting

| CAReL-veld (echte naam) | Type | Voorbeeldwaarde | Toelichting |
|---|---|---|---|
| `toelichting` | Vrije tekst (meerdere regels) | *Fictief: "Mijn kind kan vanwege een beperking niet zelfstandig fietsen."* | Open vrij tekstveld, geen validatie |

---

## 4. Bronveldnamen Atabix

Geverifieerd met de live testcapture van de Atabix-formulierbeheerder (8 sep. 2026,
`leerlingenvervoer_2026.xml`). Deze kolom hoort **niet** tot het contract met CAReL — CAReL ziet alleen
de linkerkolom — maar staat hier zodat duidelijk is waar de integratie de gegevens vandaan haalt en
welke bronvelden nog ontbreken.

| CAReL-veld | Atabix-bronveld (pad onder `FORMULIER/ELEMENTEN/form/answers`) |
|---|---|
| `aanvraagcheck_*` (7 velden) | `fleerlingenvervoeraanvraagcheckv2/...` |
| `aanvraag_schooljaar` | `fleerlingenvervoerv3aanvraag/welkschooljaar` |
| `aanvraag_vanaf_datum_gebruik_leerlingenvervoer` | `fleerlingenvervoerv3aanvraag/ingangsdatum` |
| `aanvraag_namens_burger_of_organisatie` | `fleerlingenvervoerv3aanvraag/burgerbedrijf` |
| `aanvrager_*` | `fleerlingenvervoerv3gegevensburger/...` |
| leerlinggegevens + verblijfsadres | `fleerlingenvervoerv3gegevensleerling/...` |
| `school_naam` | `fleerlingenvervoeraanvraagcheckv2/welkeschoolkeuze` |
| `school_openbare_ruimte_naam` | `fleerlingenvervoeraanvraagcheckv2/schooladres` (bevat alleen de straatnaam) |
| `school_huisnummer` | `fleerlingenvervoeraanvraagcheckv2/schoolhuisnr` |
| `school_huisletter` | `fleerlingenvervoeraanvraagcheckv2/schoolhuisletter` |
| `school_huisnummertoevoeging` | `fleerlingenvervoeraanvraagcheckv2/schoolhuistoevoeg` |
| `school_postcode` | `fleerlingenvervoeraanvraagcheckv2/schoolpostcode` |
| `school_woonplaats` | `fleerlingenvervoeraanvraagcheckv2/schoolplaats` |
| `vervoer_type` | `fleerlingenvervoerv3vervoer/typevergoedingvervoer` |
| `vervoer_<dag>_heentijd` / `_terugtijd` | `fleerlingenvervoerv3vervoer/taxi/<dag>heentijdstip` / `<dag>terugtijdstip` |
| `toelichting` | `fleerlingenvervoerv3toelichting/extratoelichting` |
| `eigenbijdrage_verzamelinkomen_vorig_jaar` | **ontbreekt in het formulier** — zie `Open punten` |
| `eigenbijdrage_upload_belastingaangifte` | **ontbreekt in het formulier** — zie `Open punten` |

### Naampatroon aan de Atabix-kant

Het formulier volgt een herkenbaar patroon, dat we graag zo houden:

- **Secties** krijgen een `f`-prefix plus de formuliernaam, aaneengeschreven en in kleine letters, met
  het versienummer erin: `fleerlingenvervoeraanvraagcheckv2`, `fleerlingenvervoerv3vervoer`.
- **Velden** staan plat in hun sectie, in kleine letters aaneengeschreven, zonder scheidingstekens:
  `welkonderwijsvolgtleerling`, `typevergoedingvervoer`.
- **Autogen-blokken** (`<sectie>efautogenN`) zijn opmaakcontainers zonder betekenis; de integratie
  gebruikt ze niet en gaat ervan uit dat velden plat in hun sectie leesbaar blijven.

**Afspraak: ook aan de bronkant BAG-termen, voluit.** Het formulier conformeert zich hieraan. De
formulierbeheerder bepaalt de naamgeving binnen zijn eigen systeem, maar waar het contract een term
vastlegt geldt die term aan beide kanten: elke afwijking is een vertaalslag die stilletjes fout kan gaan,
en die willen we niet in de integratie verstoppen. Wijkt een naam af, dan vragen we om aanpassing.

Wordt een afwijking om een goede reden gehandhaafd, dan is dat een **aandachtspunt** (zie hieronder) dat
tot een aanbeveling leidt en zo nodig tot bijstelling van dit contract — niet tot een uitzondering in de
mapping. Tot die bijstelling er is, vangt de integratie de afwijking tijdelijk op zodat het bouwen niet
stilligt. Nu nog inconsistent:

| Waar | Nu | Liever |
|---|---|---|
| school | `schooladres` (= alleen straatnaam) | `schoolopenbareruimtenaam` |
| school | `schoolhuisnr` | `schoolhuisnummer` |
| school | `schoolhuistoevoeg` | `schoolhuisnummertoevoeging` |
| school | `schoolplaats` | `schoolwoonplaats` |
| leerling | `nummer` | `huisnummer` |
| leerling | `nummertoevoeging` | `huisnummertoevoeging` |
| leerling | `straat` | `openbareruimtenaam` |

Deze lijst is de eerste set aandachtspunten voor het formulier.

---

## Open punten

**Nieuw, uit de doorlichting van 10 sep. 2026** (mapping gedraaid tegen de echte capture van 8 sep.,
alle contractvelden nagelopen):

1. **Eigen bijdrage heeft geen bronveld.** `eigenbijdrage_verzamelinkomen_vorig_jaar` en
   `eigenbijdrage_upload_belastingaangifte` staan in het contract en in de testberichten, maar het
   formulier levert ze niet: de sectie waar de mapping ze zocht (`fleerlingenvervoerv3eigenbijdrage`)
   bestaat niet in de capture. Wel aanwezig is `belastingjaar`, op twee plekken en met twee verschillende
   waarden (2017 en 2024) — onduidelijk wat daarvan bedoeld is. **Vraag aan de formulierbeheerder:** in
   welke sectie en onder welke namen komen de Ja/Nee-vraag en de upload straks binnen? Ketenstap 3.
2. ~~**Leerlinggegevens staan dubbel in het bericht.**~~ — **besloten en doorgevoerd (10 sep. 2026).**
   De leerling ging als volledig NPS-object mee in `heeftBetrekkingOp` (sectie 1) én nog eens als zes
   losse `leerling_*`-extraElementen. Die zes zijn verwijderd uit de mapping en uit alle testberichten:
   het contract kent ze niet, en de integratie stuurt alleen door wat is afgesproken, op de afgesproken
   manier. Dat het formulier de gegevens levert is prima — dubbel versturen is dat niet. Zelfde lijn als
   de `aanvrager_*`-opschoning van 2 sep. 2026.
3. **Velden in het formulier die het contract niet kent** — weggezet als **aandachtspunt**. De capture
   bevat `structurelebeperking`, `rekeninghoudenmet`, `bijzonderhedenschooltijdenjaneetaxi` en
   `anderadreswelopderoutejanee`. Die klinken relevant voor het inplannen van vervoer, maar horen bij
   geen enkel CAReL-veld. Gaat mee in de aandachtspuntenronde hieronder; als daar een aanbeveling uit
   komt om ze op te nemen, stellen we dit contract bij.
4. ~~**`verwerkingssoort` op het zaaktype wijkt af van de CAReL-referentie.**~~ — **opgezocht in de
   standaard en gecorrigeerd (10 sep. 2026).** StUF 03.01 §5.2.6, tabel 5.7, rij "Toevoegen relatie bij
   toevoegen object": bij mutatiesoort `T` krijgt de topfundamenteel `T`, de **relatie-entiteit `T`** en
   de gerelateerde `I` of `T`. Onze `ZKN:isVan` (ZAKZKT) stond op `I` en is nu `T`; de gerelateerde ZKT
   blijft `I`, want het zaaktype bestaat al bij CAReL — we voegen er geen toe, we verwijzen ernaar. De
   CAReL-referentie `creeerzaak_carel.xml` gebruikt op beide plekken `T`; dat is voor de gerelateerde
   toegestaan maar niet nodig. Doorgevoerd in de mapping en in alle zes testberichten.

   *Niet aangepast:* `voegZaakdocumentToe_Lk01` houdt op beide plekken `I`. Daar wordt het **document**
   toegevoegd en is de zaak alleen identificerend (`ZAK` met `verwerkingssoort="I"`); tabel 5.7 gaat over
   het object dat wordt toegevoegd, en dat is daar niet de zaak.
5. ~~**`ZKN:kenmerk` is een eigen toevoeging, met een afwijkend gespelde bron.**~~ — **spelling
   gecorrigeerd (10 sep. 2026).** De bronwaarde luidde `Kodision` en is nu `Kodison`, gelijk aan hoe het
   systeem elders in dit project heet. Doorgevoerd in de mapping en in alle zes testberichten. Het blok
   zelf blijft een toevoeging ten opzichte van de CAReL-referentie: het geeft het
   Kodison-formulierkenmerk mee (bv. `SWF-f4c0b8ae9934`). Of CAReL er iets mee doet is niet bevestigd —
   mocht CAReL op de oude spelling matchen, dan komt dat bij de eerstvolgende test naar boven.

---

## Aandachtspunten webformulier

Signalen die uit het bouwen en testen naar boven komen en die het **formulier** raken. Ze zijn geen
blokkade voor de integratie: we verzamelen ze, maken er aanbevelingen van, bespreken die met de
formulierbeheerder, en stellen zo nodig dit contract bij. Daarna volgt de mapping. Dat is de vaste
kringloop — zie `docs/werkwijze_integraties.md`.

| # | Aandachtspunt | Herkomst | Vervolg |
|---|---|---|---|
| A1 | Adresveldnamen wijken af van de BAG-termen (`schoolhuisnr`, `schoolhuistoevoeg`, `schooladres` voor alleen de straatnaam, `nummer`/`nummertoevoeging` bij de leerling) | doorlichting 10 sep. 2026 | Aanbeveling: hernoemen conform de tabel in sectie 4 |
| A2 | Geen bronveld voor de eigen bijdrage; wel een `belastingjaar` dat op twee plekken staat met twee waarden (2017 en 2024) | mapping tegen capture, 10 sep. 2026 | Vraag welke sectie en namen dit worden; contract volgt |
| A3 | Vier formuliervelden zonder CAReL-bestemming (`structurelebeperking`, `rekeninghoudenmet`, `bijzonderhedenschooltijdenjaneetaxi`, `anderadreswelopderoutejanee`) | capture 8 sep. 2026 | Voorleggen aan de CAReL-leverancier: wil CAReL deze hebben? |
| A4 | Waarden bevatten omringende witruimte (`"Wetterwille "` uit de schoolkeuzelijst) | mapping tegen capture, 10 sep. 2026 | Integratie trimt nu zelf; nette invoer blijft wenselijk |
| A5 | `efautogenN`-blokken zijn betekenisloze opmaakcontainers | doorlichting 10 sep. 2026 | Verzoek: velden plat en stabiel benoembaar houden |

**Opgelost:****Opgelost:**
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
   vertalen). De exacte veldnamen die Atabix straks gaat leveren zijn nog niet vastgesteld — en dat is
   **geen blokkade** voor de Atabix-formulierbeheerder om te bouwen: mocht de daadwerkelijke naamgeving/structuur afwijken van
   de aanname in de mapping, dan lossen we dat op in de integratie (XSLT-aanpassing), niet iets waar
   Atabix op hoeft te wachten of aan hoeft te voldoen.
2. **Leerlingadres altijd gesplitst:** **besloten** (na reactie de CAReL-leverancier (Eljakim), zie hieronder) — altijd
   versturen, en de kopieerlogica (aanvrageradres → leerlingveld indien van toepassing) ligt bij Atabix
   (weblogica), niet bij de integratie. Eigen leerlingadresveld blijft een bouwpunt bij de Atabix-formulierbeheerder
   (formulierveld bestaat nog niet). Zie sectie 1 hierboven.
3. **Schooladres gesplitst — vastgesteld.** De recent (op verzoek van de Doorstroommedewerker en een
   collega) ingerichte opzet voldoet. Conform punt 3 van de CAReL-leverancier (Eljakim) hieronder geldt dit
   voor alle adressen, niet alleen school. Het contract legt de CAReL-veldnamen vast in sectie `School`:
   `school_openbare_ruimte_naam` / `school_huisnummer` / `school_huisletter` / `school_huisnummertoevoeging` /
   `school_postcode` / `school_woonplaats`; `school_adres` vervalt.
4. **Organisatie-naamveld:** blijkt al te bestaan (compleet "Gegevens Organisatie"-blok met BAG-conform
   adres, getoond via screenshot). Voorstel voor de CAReL-scope: alleen organisatienaam,
   contactpersoonnaam en telefoonnummer — geen adres, geen eHerkenning. Zie sectie "Aanvullende vrije
   velden bij de aanvrager" hierboven. Brondveldnaam van het organisatieblok nog niet geverifieerd.

**Reactie de CAReL-leverancier (Eljakim), 3 september 2026** (`RE_ 260820 toevoeging aanpassing nav overleg vervoer
(5).eml`), op dezelfde mailwisseling:
1. **Dagen vervoer — vastgesteld op heen-/terugtijd (brengen/halen) per dag.** de CAReL-leverancier (Eljakim) geeft aan dat
   CAReL's eigen mechanisme werkt met een **heen-tijdstip en een terug-tijdstip** per adres, en dat dit
   bij CAReL nieuwe, nog niet bij klanten gebruikte functionaliteit is. Met alleen Ja/Nee (het
   Brengen/Ophalen/Geen-model) wordt automatisch vullen vanuit de e-formulieren-koppeling naar zijn
   zeggen lastig. **Vastgesteld (de Solution Innovator (ontwikkelaar)):** we volgen de lijn van CAReL/Eljakim — alleen dingen gebruiken
   waarvan de leverancier zelf zegt dat het goed en betrouwbaar werkt. Het Ja/Nee-only-model vervalt;
   contract aangepast naar 10 tijdvelden (heen-tijdstip = brengen, terug-tijdstip = halen, per dag),
   rechtstreeks vertaald uit de CAReL-leverancier (Eljakim)'s eigen beschrijving. Zie de bijgewerkte tabel hierboven bij
   "Vervoer". **Update 4 sep.:** de Atabix-formulierbeheerder heeft dit model al gebouwd en getest
   (referentienummer 1900887058) — zie sectie "Vervoer" hierboven. Enige nog openstaande punt: actieve
   bevestiging van de CAReL-leverancier (Eljakim) dat CAReL dit betrouwbaar verwerkt (nog niet ontvangen op de mail van 3 sep.),
   maar dat blokkeert testberichten sturen niet.
2. **Leerlingadres/ophaalpunt.** de CAReL-leverancier (Eljakim)'s technische randvoorwaarde: CAReL vult het standaard ophaalpunt
   met óf het leerlingadres óf het aanvrageradres, niet beide. Zijn voorstel: altijd het leerlingadres
   aanleveren, waarbij Atabix zelf (indien "leerling heeft ander adres dan aanvrager" = Nee) onderwater
   het aanvrageradres al in de leerling-adresvelden zet. **Besloten (de Solution Innovator (ontwikkelaar), 3 sep. 2026):** dit is
   precies de aanpak die we volgen — zie de bijgewerkte rij in sectie 1. Het aanvrageradres wordt zelf
   nooit los naar CAReL gestuurd.
3. **Alle adressen BAG-conform gesplitst.** CAReL zoekt adressen zelf op via de BAG om te controleren of
   alles klopt, en wil daarom voor **alle** adressen (niet alleen school) straat/huisnummer/huisletter/
   huisnummertoevoeging/postcode/plaats los. **Besloten (de Solution Innovator (ontwikkelaar), 3 sep. 2026):** dit passen we toe op
   alle adressen conform BAG. Voor het leerlingadres (sectie 1) betekent dit dat ook huisletter en
   huisnummertoevoeging nog aan de mapping/het formulier toegevoegd moeten worden — nog niet gebouwd.
   Voor het schooladres is dit vastgelegd in sectie `School` (zes losse velden, `school_adres` vervalt);
   het organisatie-adres wordt sowieso niet verstuurd (zie sectie "Aanvullende vrije velden bij de
   aanvrager") en is dus niet van toepassing.

**Aangenomen (stilzwijgend akkoord, geen actieve bevestiging):**
- Geboorteplaats aanvrager als gemeentecode i.p.v. plaatsnaam — nog steeds niet met Eljakim afgestemd.
