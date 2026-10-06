# Contract leerlingenvervoer: webformulier → CAReL

Dit contract legt vast welk bericht de integratie naar CAReL verstuurt: de opbouw, de veldnamen en de
waarden. CAReL leest het bericht volgens dit contract. Het webformulier levert de gegevens volgens dit
contract.

## Versiegeschiedenis

| Versie | Datum | Wijziging | Afgesproken met |
|---|---|---|---|
| 1.0 | 2 mrt 2026 | Berichtspecificatie `creeerZaak_Lk01`: stuurgegevens, zaakobject, zaaktype `LV-001`, vrije velden | Opdrachtgever integratie |
| 1.1 | 12 jun 2026 | Leerling als eigen rol (`heeftBetrekkingOp`), personen met `verwerkingssoort="I"` | Leverancier CAReL |
| 1.2 | 24 jul 2026 | Aanvrager: alleen BSN. CAReL haalt de overige gegevens zelf op via de BRP | Leverancier CAReL |
| 1.3 | 20 aug 2026 | Keuzelijsten: onderwijstype, namens burger/organisatie, relatie tot leerling, geslacht, vervoertype, IBAN-type | Functioneel beheerder CAReL |
| 1.4 | 1 sep 2026 | Veldenoverzicht `velden_carel_met_types.md` gedeeld, met alle veldnamen. Keuzelijsten: kan zelfstandig reizen, hoe gaat de leerling naar school | Leverancier CAReL, functioneel beheerder CAReL |
| 1.5 | 3–4 sep 2026 | Alle adressen gesplitst. Adres leerling altijd mee. Vervoer per dag als heen- en terugtijd (`vervoer_<dag>_heentijd` / `_terugtijd`). Organisatie: naam, contactpersoon en telefoon | Leverancier CAReL, functioneel beheerder CAReL, bouwer webformulier |
| 1.6 | 10 sep 2026 | Schooladres gesplitst met BAG-veldnamen, naar aanleiding van de afspraak van 3 sep 2026 en de opmerkingen van de leverancier CAReL ("alle adressen los"): `school_adres` wordt `school_openbare_ruimte_naam`, `school_huisnummer`, `school_huisletter`, `school_huisnummertoevoeging`; `school_plaats` wordt `school_woonplaats`. Geslacht als code M/V/O. Zaakniveau vastgelegd | Opdrachtgever integratie |

**Rollen:** leverancier CAReL (Eljakim), functioneel beheerder CAReL (Doorstroompunt), bouwer webformulier
(TriplEforms/Atabix, SWF), opdrachtgever integratie (IDT SWF), integratiepartij (WeAreFrank).

---

## 0. Zaakniveau

| Element | Waarde |
|---|---|
| `StUF:berichtcode` | `Lk01` |
| `StUF:zender/organisatie` | `1900` |
| `StUF:zender/applicatie` | `WebformulierenKoppeling` |
| `StUF:zender/gebruiker` | `Gebruiker` |
| `StUF:ontvanger/organisatie` | `1900` |
| `StUF:ontvanger/applicatie` | `CAREL` |
| `StUF:referentienummer` | Nieuwe UUID per bericht |
| `StUF:tijdstipBericht` | Verzendmoment, `JJJJMMDDuummsshh` |
| `StUF:entiteittype` | `ZAK` |
| `StUF:mutatiesoort` | `T` |
| `StUF:indicatorOvername` | `V` |
| `ZKN:object` | `entiteittype="ZAK"`, `verwerkingssoort="T"` |
| `StUF:sleutelVerzendend` / `ZKN:identificatie` | Zaakidentificatie uit OpenZaakBrug |
| `ZKN:omschrijving` | `Aanvraag leerlingenvervoer` |
| `ZKN:kenmerk/kenmerk` | Formulierkenmerk, bv. `SWF-f4c0b8ae9934` |
| `ZKN:kenmerk/bron` | `Kodison` |
| `ZKN:startdatum` | Verzenddatum formulier, `JJJJMMDD` |
| `ZKN:registratiedatum` | Verwerkingsdatum, `JJJJMMDD` |
| `ZKN:isVan` | `entiteittype="ZAKZKT"`, `verwerkingssoort="T"` |
| `ZKN:isVan/gerelateerde` | `entiteittype="ZKT"`, `verwerkingssoort="I"` |
| `ZKN:isVan/gerelateerde/code` | `LV-001` |
| `ZKN:isVan/gerelateerde/omschrijving` | `Leerlingenvervoer aanvraag` |
| `ZKN:isVan/gerelateerde/ingangsdatumObject` | Leeg, `noValue="geenWaarde"` |

## 1. Leerling (`ZKN:heeftBetrekkingOp`)

`entiteittype="ZAKOBJ"`, `verwerkingssoort="T"`, met daarin `ZKN:natuurlijkPersoon`
(`entiteittype="NPS"`, `verwerkingssoort="I"`).

| Veld | Waarde |
|---|---|
| `BG:inp.bsn` | BSN leerling, verplicht |
| `BG:voornamen` | Roepnaam |
| `BG:voorvoegselGeslachtsnaam` | Tussenvoegsel, mag leeg |
| `BG:geslachtsnaam` | Achternaam |
| `BG:geboortedatum` | `JJJJMMDD` |
| `BG:geslachtsaanduiding` | `M` (Jongen), `V` (Meisje), `O` (Anders / Wil ik liever niet zeggen / leeg) |
| `BG:verblijfsadres/gor.openbareRuimteNaam` | Straat |
| `BG:verblijfsadres/aoa.huisnummer` | Huisnummer |
| `BG:verblijfsadres/aoa.huisletter` | Huisletter, weggelaten als leeg |
| `BG:verblijfsadres/aoa.huisnummertoevoeging` | Huisnummertoevoeging, weggelaten als leeg |
| `BG:verblijfsadres/aoa.postcode` | Postcode |
| `BG:verblijfsadres/wpl.woonplaatsNaam` | Woonplaats |

Het adres van de leerling is het ophaaladres en gaat altijd mee. Woont de leerling op het adres van de
aanvrager, dan vult het webformulier dat adres in.

## 2. Aanvrager (`ZKN:heeftAlsInitiator`)

`entiteittype="ZAKBTRINI"`, `verwerkingssoort="T"`, met daarin `ZKN:natuurlijkPersoon`
(`entiteittype="NPS"`, `verwerkingssoort="I"`).

| Veld | Waarde |
|---|---|
| `BG:inp.bsn` | BSN aanvrager, verplicht |

Van de aanvrager gaat alleen het BSN mee. De aanvrager logt in met DigiD. CAReL haalt naam en adres zelf
op via de BRP.

## 3. Vrije velden (`StUF:extraElement naam="..."`)

### Aanvraagcheck

| Veld | Waarden |
|---|---|
| `aanvraagcheck_woont_in_swf_op_schooldagen` | Ja / Nee |
| `aanvraagcheck_dichtstbijzijnde_toegankelijke_school` | Ja / Nee |
| `aanvraagcheck_welk_onderwijs` | Regulier Basis Onderwijs / Speciaal Basis Onderwijs (SBO) / Speciaal Onderwijs (SO) / Voortgezet Speciaal Onderwijs (VSO) |
| `aanvraagcheck_enkele_reisafstand_meer_dan_6_km` | Ja / Nee |
| `aanvraagcheck_kan_zelfstandig_reizen` | Ja / Nee, maar kan het leren / Nee, jonger dan 10 jaar / Nee, handicap |
| `aanvraagcheck_hoe_gaat_leerling_naar_school` | Bij "Ja": met de fiets / met het openbaar vervoer. Bij "Nee": fiets / openbaar vervoer / eigen vervoer / nee. De tekst zoals getoond in het formulier |
| `aanvraagcheck_wil_leerlingenvervoer_aanvragen` | Ja / Nee |

### Aanvraag

| Veld | Waarden |
|---|---|
| `aanvraag_schooljaar` | bv. `2026 - 2027` |
| `aanvraag_vanaf_datum_gebruik_leerlingenvervoer` | `JJJJMMDD` |
| `aanvraag_namens_burger_of_organisatie` | Burger / Organisatie |

### Aanvrager, aanvullend

| Veld | Waarden |
|---|---|
| `aanvrager_telefoonnummer` | Telefoonnummer. Bij Organisatie dat van de contactpersoon |
| `aanvrager_emailadres` | E-mailadres |
| `aanvrager_relatie_tot_leerling` | Ouder / Voogd / Verzorger / Bewindvoerder / Curator / Anders |
| `aanvrager_organisatie_naam` | Bedrijfsnaam, alleen bij Organisatie |
| `aanvrager_naam` | Naam contactpersoon, alleen bij Organisatie |

### IBAN

| Veld | Waarden |
|---|---|
| `iban_type` | Mijn eigen IBAN / De IBAN van mijn partner / Op het IBAN van de bewindvoerder/curator (beheerrekening) |
| `iban_nummer` | IBAN |
| `iban_naam_rekeninghouder` | Naam rekeninghouder |

### School

| Veld | Waarden |
|---|---|
| `school_naam` | Naam school |
| `school_openbare_ruimte_naam` | Straat |
| `school_huisnummer` | Huisnummer |
| `school_huisletter` | Huisletter, leeg als niet van toepassing |
| `school_huisnummertoevoeging` | Huisnummertoevoeging, leeg als niet van toepassing |
| `school_postcode` | Postcode |
| `school_woonplaats` | Plaats |

### Eigen bijdrage

| Veld | Waarden |
|---|---|
| `eigenbijdrage_verzamelinkomen_vorig_jaar` | Ja / Nee |
| `eigenbijdrage_upload_belastingaangifte` | Bestandsnaam |

### Vervoer

| Veld | Waarden |
|---|---|
| `vervoer_type` | Fiets / Fiets en Openbaar vervoer / Openbaar vervoer zelfstandig / Openbaar Vervoer onder begeleiding ouder / Eigen vervoer (auto) / Groepstaxi vervoer |
| `vervoer_upload_vervoersverklaring` | Bestandsnaam, verplicht |
| `vervoer_maandag_heentijd` | Tijdstip `uu:mm`, leeg = geen vervoer |
| `vervoer_maandag_terugtijd` | Tijdstip `uu:mm`, leeg = geen vervoer |
| `vervoer_dinsdag_heentijd` | idem |
| `vervoer_dinsdag_terugtijd` | idem |
| `vervoer_woensdag_heentijd` | idem |
| `vervoer_woensdag_terugtijd` | idem |
| `vervoer_donderdag_heentijd` | idem |
| `vervoer_donderdag_terugtijd` | idem |
| `vervoer_vrijdag_heentijd` | idem |
| `vervoer_vrijdag_terugtijd` | idem |

### Toelichting

| Veld | Waarden |
|---|---|
| `toelichting` | Vrije tekst |

## 4. Verplicht

Zonder deze gegevens wordt het bericht niet verstuurd: BSN leerling, BSN aanvrager,
`vervoer_upload_vervoersverklaring`.
