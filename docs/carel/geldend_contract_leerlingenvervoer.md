# Geldend contract leerlingenvervoer: webformulier → CAReL

Dit document beschrijft **wat de integratie naar CAReL verstuurt**, en per onderdeel **wanneer dat is
afgesproken en wie (welke rol) ermee akkoord is gegaan**. Het is de korte, geldende versie van
[`veldencontract_leerlingenvervoer.md`](veldencontract_leerlingenvervoer.md). Achtergrond, toelichting en
historie staan daar.

Stand: zoals op `main` na het mergen van #115. Wijzigingen gaan eerst in dit contract, daarna in de code.

## Rollen

| Rol | Wie (organisatie) |
|---|---|
| **Leverancier CAReL** | Eljakim, bouwt en richt CAReL in |
| **Functioneel beheerder CAReL** | Doorstroompunt, gebruikt CAReL en levert de inhoud van de aanvraag |
| **Bouwer webformulier** | Functioneel beheer Communicatie SWF, bouwt het formulier in TriplEforms (Atabix) |
| **Opdrachtgever integratie** | IDT SWF, stelt het contract op en beheert de koppeling |
| **Integratiepartij** | WeAreFrank, bouwt en reviewt de integratie |

## Status

| Status | Betekenis |
|---|---|
| ✅ **Akkoord** | De genoemde rol heeft dit aangeleverd of uitdrukkelijk bevestigd |
| 📤 **Gedeeld** | Vastgelegd door de opdrachtgever en gedeeld met de genoemde rollen, maar geen uitdrukkelijke bevestiging teruggevonden |
| 💬 **Voorstel** | Voorstel van de opdrachtgever, nog niet bevestigd |

De datums komen uit de mailwisseling en de vastlegging in deze repository. Bij "bron niet herleid" is de
afspraak niet terug te voeren op een concrete mail. Die moet nog worden nagelopen.

**"Specificatie 2 mrt 2026"** is de oorspronkelijke berichtspecificatie
(`docs/carel/20260302/creeerzaak_carel.xml`), waarop de integratie is gebouwd. Velden daaruit staan op
✅, omdat CAReL-acceptatie een bericht met deze opbouw op 24 jul 2026 heeft geaccepteerd en de leverancier
op 19 aug 2026 (via de functioneel beheerder CAReL) liet weten dat "de mapping in CAReL in orde" is.

---

## 0. Zaakniveau

| Onderdeel | Waarde | Afgesproken | Rol | Status |
|---|---|---|---|---|
| Stuurgegevens (`Lk01`, zender, ontvanger `CAREL`, `mutatiesoort T`, `indicatorOvername V`) | Vast, organisatie `1900` | Specificatie 2 mrt 2026. Technisch geaccepteerd door CAReL-acceptatie op 24 jul 2026 (`Bv03Bericht`) | Opdrachtgever integratie | ✅ geaccepteerd door CAReL |
| `referentienummer`, `tijdstipBericht` | Per bericht gegenereerd | Specificatie 2 mrt 2026 | Opdrachtgever integratie | ✅ |
| Zaaktype: `code` `LV-001`, `omschrijving` "Leerlingenvervoer aanvraag" | Vast | Specificatie 2 mrt 2026. Geaccepteerd op 24 jul 2026 | Opdrachtgever integratie | ✅ geaccepteerd door CAReL |
| `verwerkingssoort`: relatie `isVan` = `T`, zaaktype = `I` | Vast | 10 sep 2026, volgens StUF 03.01 §5.2.6 | Opdrachtgever integratie | 💬 niet met leverancier besproken |
| `kenmerk` (formulierkenmerk) + `bron` `Kodison` | Uit het formulier | Toegevoegd bij de bouw | Opdrachtgever integratie | 💬 open vraag aan leverancier (#113) |
| `startdatum` / `registratiedatum` | Verzenddatum formulier / verwerkingsdatum | Specificatie 2 mrt 2026 | Opdrachtgever integratie | ✅ |

## 1. Leerling (`heeftBetrekkingOp`)

| Veld | Inhoud | Afgesproken | Rol | Status |
|---|---|---|---|---|
| Structuur: leerling als `natuurlijkPersoon` met `verwerkingssoort="I"` | — | 12 jun 2026: voorbeeldbericht van de leverancier. Geaccepteerd door CAReL op 24 jul 2026 | Leverancier CAReL | ✅ |
| `inp.bsn` | BSN leerling, verplicht | Specificatie 2 mrt 2026 | Opdrachtgever integratie | ✅ |
| `voornamen` (roepnaam), `voorvoegselGeslachtsnaam`, `geslachtsnaam` | Tekst | Specificatie 2 mrt 2026 | Opdrachtgever integratie | ✅ |
| `geboortedatum` | `JJJJMMDD` | Specificatie 2 mrt 2026 | Opdrachtgever integratie | ✅ |
| `geslachtsaanduiding` | `M` / `V` / `O` (Jongen / Meisje / Anders, Wil ik liever niet zeggen) | Opties formulier: 20 aug 2026. Codering M/V/O: 10 sep 2026 | Functioneel beheerder CAReL (opties). Opdrachtgever integratie (codering) | ✅ opties / 💬 codering niet met leverancier besproken |
| `verblijfsadres`: `gor.openbareRuimteNaam`, `aoa.huisnummer`, `aoa.huisletter`, `aoa.huisnummertoevoeging`, `aoa.postcode`, `wpl.woonplaatsNaam` | Adres leerling = ophaaladres. Altijd meegestuurd, volledig gesplitst. Woont de leerling op het adres van de aanvrager, dan vult het formulier dat adres zelf in | 3 sep 2026: voorstel van de leverancier, overgenomen door de opdrachtgever. 4 sep 2026: formulier vraagt het leerlingadres altijd uit | Leverancier CAReL, opdrachtgever integratie, bouwer webformulier | ✅ |

## 2. Aanvrager (`heeftAlsInitiator`)

| Veld | Inhoud | Afgesproken | Rol | Status |
|---|---|---|---|---|
| `inp.bsn` | **Alleen het BSN.** De aanvrager logt in met DigiD. CAReL haalt naam en adres zelf op via de BRP wanneer dat nodig is | 24 jul 2026: leverancier meldt dat CAReL het BSN herkent en zelf de BRP bevraagt. Afgesproken met de leverancier volgens de opdrachtgever | Leverancier CAReL, opdrachtgever integratie | ✅ Afgesproken. Let op: een schriftelijke bevestiging van de leverancier is niet teruggevonden. Op 1 okt 2026 vraagt de leverancier toch om het adres van de aanvrager (#117) |

## 3. Vrije velden (`extraElement naam="..."`)

### Aanvraagcheck

| Veld | Waarden | Afgesproken | Rol | Status |
|---|---|---|---|---|
| `aanvraagcheck_woont_in_swf_op_schooldagen` | Ja / Nee | Specificatie 2 mrt 2026 | Opdrachtgever integratie | ✅ |
| `aanvraagcheck_dichtstbijzijnde_toegankelijke_school` | Ja / Nee | Specificatie 2 mrt 2026 | Opdrachtgever integratie | ✅ |
| `aanvraagcheck_welk_onderwijs` | Regulier Basis Onderwijs / Speciaal Basis Onderwijs (SBO) / Speciaal Onderwijs (SO) / Voortgezet Speciaal Onderwijs (VSO) | 20 aug 2026 | Functioneel beheerder CAReL | ✅ |
| `aanvraagcheck_enkele_reisafstand_meer_dan_6_km` | Ja / Nee | Specificatie 2 mrt 2026 | Opdrachtgever integratie | ✅ |
| `aanvraagcheck_kan_zelfstandig_reizen` | Ja / Nee, maar kan het leren / Nee, jonger dan 10 jaar / Nee, handicap | 1–2 sep 2026 | Functioneel beheerder CAReL | ✅ |
| `aanvraagcheck_hoe_gaat_leerling_naar_school` | Bij "Ja": met de fiets / met het OV. Bij de drie "Nee"-varianten: fiets / OV / eigen vervoer / nee | Opties: 24 aug en 1–2 sep 2026. Dat bij "Nee" hetzelfde veld wordt gebruikt: 2 sep 2026 | Functioneel beheerder CAReL (opties). Opdrachtgever integratie (zelfde veld) | ✅ opties / 💬 zelfde veld |
| `aanvraagcheck_wil_leerlingenvervoer_aanvragen` | Ja / Nee | Specificatie 2 mrt 2026 | Opdrachtgever integratie | ✅ |

### Aanvraag

| Veld | Waarden | Afgesproken | Rol | Status |
|---|---|---|---|---|
| `aanvraag_schooljaar` | bv. "2026 - 2027", bepaald door het formulier | Specificatie 2 mrt 2026 | Opdrachtgever integratie | ✅ |
| `aanvraag_vanaf_datum_gebruik_leerlingenvervoer` | `JJJJMMDD` | Specificatie 2 mrt 2026 | Opdrachtgever integratie | ✅ |
| `aanvraag_namens_burger_of_organisatie` | Burger / Organisatie | 20 aug 2026: blijft staan | Functioneel beheerder CAReL | ✅ |

### Aanvrager, aanvullend

| Veld | Waarden | Afgesproken | Rol | Status |
|---|---|---|---|---|
| `aanvrager_telefoonnummer` | Vrij veld. Bij Organisatie uit het organisatieblok | Specificatie 2 mrt 2026. Bron bij Organisatie: 3 sep 2026 | Opdrachtgever integratie | ✅ |
| `aanvrager_emailadres` | Vrij veld | Specificatie 2 mrt 2026 | Opdrachtgever integratie | ✅ |
| `aanvrager_relatie_tot_leerling` | Ouder / Voogd / Verzorger / Bewindvoerder / Curator / Anders | Opties: 20 aug 2026. Typefout in het formulier hersteld: 3 sep 2026 | Functioneel beheerder CAReL (opties). Bouwer webformulier (herstel) | ✅ |
| `aanvrager_organisatie_naam` | Bedrijfsnaam, alleen bij Organisatie | 24 aug 2026: leverancier wil bij organisatie een vrij naamveld. 3 sep 2026: voorstel naam, contactpersoon en telefoon, zonder adres en zonder eHerkenning | Leverancier CAReL (richting). Opdrachtgever integratie (voorstel) | 💬 Voorstel |
| `aanvrager_naam` | Naam contactpersoon, alleen bij Organisatie | idem | idem | 💬 Voorstel |

### IBAN

| Veld | Waarden | Afgesproken | Rol | Status |
|---|---|---|---|---|
| `iban_type` | Mijn eigen IBAN / De IBAN van mijn partner / Op het IBAN van de bewindvoerder/curator (beheerrekening) | 20 aug 2026 | Functioneel beheerder CAReL | ✅ |
| `iban_nummer` | IBAN | Specificatie 2 mrt 2026 | Opdrachtgever integratie | ✅ |
| `iban_naam_rekeninghouder` | Tekst | Specificatie 2 mrt 2026 | Opdrachtgever integratie | ✅ |

### School

| Veld | Waarden | Afgesproken | Rol | Status |
|---|---|---|---|---|
| `school_naam` | Tekst | Specificatie 2 mrt 2026 | Opdrachtgever integratie | ✅ |
| `school_openbare_ruimte_naam` (straat) | Tekst | Gesplitst schooladres: 19 aug 2026 (via functioneel beheerder CAReL) en 3 sep 2026 (leverancier: "alle adressen los"). Formulier ingericht op verzoek van de functioneel beheerder CAReL (bevestigd door bouwer webformulier, 3 sep 2026). Veldnamen volgens BAG: 3 sep 2026, vastgelegd 10 sep 2026 | Leverancier CAReL (splitsing). Functioneel beheerder CAReL en bouwer webformulier (formulier). Opdrachtgever integratie (veldnamen) | ✅ splitsing / 📤 veldnamen |
| `school_huisnummer` | Tekst | idem | idem | ✅ splitsing / 📤 veldnamen |
| `school_huisletter` | Tekst, leeg = n.v.t. | idem | idem | ✅ splitsing / 📤 veldnamen |
| `school_huisnummertoevoeging` | Tekst, leeg = n.v.t. | idem | idem | ✅ splitsing / 📤 veldnamen |
| `school_postcode` | Tekst | idem | idem | ✅ splitsing / 📤 veldnamen |
| `school_woonplaats` | Tekst (was `school_plaats`) | idem | idem | ✅ splitsing / 📤 veldnamen |

### Eigen bijdrage

| Veld | Waarden | Afgesproken | Rol | Status |
|---|---|---|---|---|
| `eigenbijdrage_verzamelinkomen_vorig_jaar` | Ja / Nee | Opgenomen in het contract op 3 sep 2026. Bron niet herleid | — | 📤 |
| `eigenbijdrage_upload_belastingaangifte` | Bestandsnaam | idem | — | 📤 |

### Vervoer

| Veld | Waarden | Afgesproken | Rol | Status |
|---|---|---|---|---|
| `vervoer_type` | Fiets / Fiets en Openbaar vervoer / Openbaar vervoer zelfstandig / Openbaar Vervoer onder begeleiding ouder / Eigen vervoer (auto) / Groepstaxi vervoer | 20 aug 2026 | Functioneel beheerder CAReL | ✅ |
| `vervoer_upload_vervoersverklaring` | Bestandsnaam, verplicht | Opgenomen in het contract op 3 sep 2026. Bron niet herleid | — | 📤 |
| `vervoer_<dag>_heentijd` / `vervoer_<dag>_terugtijd` (maandag t/m vrijdag, 10 velden) | Tijdstip, bv. "08:15". Leeg = geen vervoer in die richting | 3 sep 2026: leverancier beschrijft het model (heen- en terugtijd per dag). 3 sep 2026: opdrachtgever neemt het over. 4 sep 2026: formulier gebouwd (bouwer webformulier) | Leverancier CAReL (model). Opdrachtgever integratie (veldnamen). Bouwer webformulier (formulier) | ✅ model / 📤 veldnamen |

**Vervallen:** `vervoer_upload_routeplanner` (gebeurt in CAReL zelf) en `vervoer_vanaf_datum_nodig`
(dubbel met `aanvraag_vanaf_datum_gebruik_leerlingenvervoer`). Opgenomen in het contract op 3 sep 2026,
bron niet herleid.

### Toelichting

| Veld | Waarden | Afgesproken | Rol | Status |
|---|---|---|---|---|
| `toelichting` | Vrije tekst | Specificatie 2 mrt 2026 | Opdrachtgever integratie | ✅ |

---

## Gedeeld met de leverancier

- **20 aug 2026:** het overzicht van alle CAReL-velden, "inclusief de exacte veldnamen uit onze eigen
  koppeling", gedeeld met de leverancier CAReL en de functioneel beheerder CAReL.
- **3 sep 2026:** samenvatting van de keuzes (tijden per dag, leerlingadres, schooladres, organisatie,
  alle adressen los) gedeeld met de leverancier CAReL, de functioneel beheerder CAReL en de bouwer
  webformulier. Hierin stonden de keuzes, maar niet de nieuwe veldnamen van school en vervoerstijden.

## Openstaand

Zie #117 en #113. Kort samengevat:
- De leverancier CAReL moet CAReL inrichten op de veldnamen in dit contract. Bij de test van 1 okt 2026
  vond CAReL de velden niet.
- De BRP-bevraging door CAReL op acceptatie moet nog bevestigd worden. Daarop leunt "aanvrager alleen BSN".
