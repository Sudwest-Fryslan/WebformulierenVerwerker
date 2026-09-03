# Meerwerk: berichtformaat CAReL — concrete specificatie

**Achterhaald (3 september 2026):** dit document dateert van 15 juni 2026 en is op meerdere punten
ingehaald door latere besluiten (o.a. `heeftAlsInitiator` alleen-BSN i.p.v. volledig, de
dagdeel-structuur Brengen/Ophalen/Geen i.p.v. Ja/Nee+tijden). Voor de actuele, veld-voor-veld stand van
zaken: zie `docs/carel/veldencontract_leerlingenvervoer.md` en sectie 10 van `scopedocument.md`. Dit
document blijft staan als historisch uitgangspunt van de meerwerk-discussie.

**Datum:** 15 juni 2026  
**Status:** meerwerk — buiten de oorspronkelijke opdracht  
**Aanleiding:** Eljakim heeft op 12 juni 2026 referentie-XML aangeleverd (`docs/carel/eljakim/Voorbeeld_bericht.xml`) die laat zien welk formaat CAReL daadwerkelijk verwacht. Dit wijkt op meerdere punten af van de oorspronkelijke spec (`docs/carel/20260302/creeerzaak_carel.xml`).

**Doel van dit document:**  
Een specificatie die volledig genoeg is zodat:
1. Atabix weet welke aanpassingen in het webformulier nodig zijn (sectie voor sectie, veld voor veld)
2. WeAreFrank weet wat er in de XSLT moet veranderen
3. De nieuwe Kodison-XML met de nieuwe XSLT de juiste creeerZaak_Lk01 oplevert voor CAReL

**Referentiedocumenten:**
- Oorspronkelijke spec: `docs/carel/20260302/creeerzaak_carel.xml`
- Eljakim referentie: `docs/carel/eljakim/Voorbeeld_bericht.xml`
- Huidig formulier: referentiecapture (intern gearchiveerd, git.sudwestfryslan.net - bevat persoonsgegevens, niet in deze publieke repo)
- Huidige XSLT: `xsl/OpslaanAanvraagLeerlingenVervoerNatuurlijkPersoon/creeerZaak_Lk01_mapping.xsl`

---

## Deel 1 — Wat verandert er in het CAReL-bericht

### 1.1 heeftBetrekkingOp — volledig nieuw toevoegen

**Huidig:** `heeftBetrekkingOp` ontbreekt volledig in het bericht.

**Gewenst:** `heeftBetrekkingOp` toevoegen met daarin de **leerling** als natuurlijk persoon:

```xml
<ZKN:heeftBetrekkingOp StUF:entiteittype="ZAKOBJ" StUF:verwerkingssoort="T">
    <ZKN:gerelateerde>
        <ZKN:natuurlijkPersoon StUF:entiteittype="NPS" StUF:verwerkingssoort="I">
            <BG:inp.bsn>{leerling BSN}</BG:inp.bsn>
            <BG:voorletters>{leerling voorletters}</BG:voorletters>
            <BG:voornamen>{leerling roepnaam}</BG:voornamen>
            <BG:voorvoegselGeslachtsnaam>{leerling tussenvoegsel}</BG:voorvoegselGeslachtsnaam>
            <BG:geslachtsnaam>{leerling achternaam}</BG:geslachtsnaam>
            <BG:geboortedatum>{leerling geboortedatum, formaat YYYYMMDD}</BG:geboortedatum>
            <BG:inp.geboorteplaats>{leerling geboorteplaats}</BG:inp.geboorteplaats>
            <BG:geslachtsaanduiding>{leerling geslacht}</BG:geslachtsaanduiding>
            <BG:verblijfsadres>
                <aoa.postcode>{leerling postcode}</aoa.postcode>
                <aoa.huisnummer>{leerling huisnummer}</aoa.huisnummer>
                <gor.openbareRuimteNaam>{leerling straat}</gor.openbareRuimteNaam>
                <wpl.woonplaatsNaam>{leerling woonplaats}</wpl.woonplaatsNaam>
            </BG:verblijfsadres>
        </ZKN:natuurlijkPersoon>
    </ZKN:gerelateerde>
</ZKN:heeftBetrekkingOp>
```

Brondata voor verblijfsadres leerling:
- Als `leerlinganderadres = "Ja"` (adres gelijk aan aanvrager) → aanvrageradres overnemen uit BRP-prefill
- Als `leerlinganderadres = "Nee"` → nieuwe leerlingadresvelden in formulier (zie sectie 3)

### 1.2 heeftAlsInitiator — uitbreiden

**Huidig:** bevat alleen BSN + `authentiek=J` (XSLT regels 66–73).

**Gewenst:** uitbreiden met volledige persoonsgegevens aanvrager — zelfde structuur als heeftBetrekkingOp maar met aanvragerdata uit BRP-prefill:

```xml
<ZKN:heeftAlsInitiator StUF:entiteittype="ZAKBTRINI" StUF:verwerkingssoort="T">
    <ZKN:gerelateerde>
        <ZKN:natuurlijkPersoon StUF:entiteittype="NPS" StUF:verwerkingssoort="I">
            <BG:inp.bsn>{globals/stuf/inp/bsn}</BG:inp.bsn>
            <BG:voorletters>{globals/stuf/voorletters}</BG:voorletters>
            <BG:voornamen>{globals/stuf/voornamen}</BG:voornamen>
            <BG:voorvoegselGeslachtsnaam>{globals/stuf/voorvoegselgeslachtsnaam}</BG:voorvoegselGeslachtsnaam>
            <BG:geslachtsnaam>{globals/stuf/geslachtsnaam}</BG:geslachtsnaam>
            <BG:geboortedatum>{globals/stuf/geboortedatum}</BG:geboortedatum>
            <BG:inp.geboorteplaats>{globals/stuf/inp/geboorteplaats}</BG:inp.geboorteplaats>
            <BG:geslachtsaanduiding>{globals/stuf/geslachtsaanduiding}</BG:geslachtsaanduiding>
            <BG:verblijfsadres>
                <aoa.postcode>{globals/stuf/verblijfsadres/postcode}</aoa.postcode>
                <aoa.huisnummer>{globals/stuf/verblijfsadres/huisnummer}</aoa.huisnummer>
                <gor.openbareRuimteNaam>{globals/stuf/verblijfsadres/straat}</gor.openbareRuimteNaam>
                <wpl.woonplaatsNaam>{globals/stuf/verblijfsadres/woonplaats}</wpl.woonplaatsNaam>
            </BG:verblijfsadres>
        </ZKN:natuurlijkPersoon>
    </ZKN:gerelateerde>
</ZKN:heeftAlsInitiator>
```

Alle data is beschikbaar uit de BRP-prefill. Geen formulierwijziging nodig voor de aanvrager.

> **Aandachtspunt geboorteplaats aanvrager:** de BRP levert `globals/stuf/inp/geboorteplaats` als gemeentecode (bijv. `0091`), niet als plaatsnaam. Afstemmen met Eljakim/CAReL of een code acceptabel is.

### 1.3 verwerkingssoort NPS wijzigen

**Huidig:** `StUF:verwerkingssoort="T"` op `natuurlijkPersoon` in `heeftAlsInitiator`.  
**Gewenst:** `StUF:verwerkingssoort="I"` (Identificatie) — in zowel `heeftBetrekkingOp` als `heeftAlsInitiator`.

### 1.4 Adresvelden splitsen in extraElementen

Drie gecombineerde velden worden opgesplitst in losse extraElementen.

**Aanvrager-adres** (huidig `aanvrager_adres` bevat alleen straat, huisnummer ontbreekt):

| Oud | Nieuw |
|-----|-------|
| `aanvrager_adres` = `"Kerkstraat"` (incompleet) | `aanvrager_straat` = `"Kerkstraat"` |
| — | `aanvrager_huisnummer` = `"30"` |
| — | `aanvrager_huisletter` = `""` |
| — | `aanvrager_huisnummertoevoeging` = `""` |
| `aanvrager_postcode` = `"8601AB"` | `aanvrager_postcode` = `"8601AB"` (behouden) |
| `aanvrager_plaats` = `"Sneek"` | `aanvrager_woonplaats` = `"Sneek"` (hernoemen) |

**School-adres** (huidig `school_adres` bevat alleen straat):

| Oud | Nieuw |
|-----|-------|
| `school_adres` = `"Marktstraat"` (incompleet) | `school_straatnaam` = `"Marktstraat"` |
| — | `school_huisnummer` = `"15"` |
| — | `school_huisletter` = `""` |
| — | `school_huisnummertoevoeging` = `""` |
| `school_postcode` = `"8601CR"` | `school_postcode` = `"8601CR"` (behouden) |
| `school_plaats` = `"Sneek"` | `school_woonplaats` = `"Sneek"` (hernoemen) |

**Leerling-adres** (huidig alleen boolean):

| Oud | Nieuw |
|-----|-------|
| `leerling_adres_gelijk_aan_aanvrager` = `"Ja"` | `leerling_adres_gelijk_aan_aanvrager` = `"Ja"` (behouden) |
| — | `leerling_straat` (altijd gevuld: bij Ja = aanvrageradres, bij Nee = eigen adres leerling) |
| — | `leerling_huisnummer` |
| — | `leerling_huisletter` |
| — | `leerling_huisnummertoevoeging` |
| — | `leerling_postcode` |
| — | `leerling_woonplaats` |

### 1.5 Dagstructuur vervoer

**Huidig:** één extraElement per dag, kommagescheiden tekst.

| Oud extraElement | Waarde (voorbeeld) |
|------------------|-------------------|
| `vervoer_maandag` | `""` (leeg = niet) of `"Ochtend, Middag"` |

**Gewenst:** drie extraElementen per dag.

| Nieuw extraElement | Waarde |
|-------------------|--------|
| `maandag` | `"Ja"` of `"Nee"` |
| `begintijd_maandag` | `"08:30"` (leeg als dag = Nee) |
| `eindtijd_maandag` | `"14:00"` (leeg als dag = Nee) |

Idem voor `dinsdag`, `woensdag`, `donderdag`, `vrijdag`.

**Actie Atabix (de Atabix-formulierbeheerder):** begintijd- en eindtijdveld toevoegen per dag, zichtbaar als de dag geselecteerd is.

### 1.6 Nieuw: aantalBijlagen

**Huidig:** niet aanwezig.  
**Gewenst:** `aantalBijlagen` = aantal geüploade bijlagen.  
**XSLT:** `count(/FORMULIER/ELEMENTEN/form/attachments/attachment[@type='Upload'])` — geen formulierwijziging nodig.

---

## Deel 2 — Aanpassingen in de WebformulierenVerwerker (XSLT)

Bestand: `xsl/OpslaanAanvraagLeerlingenVervoerNatuurlijkPersoon/creeerZaak_Lk01_mapping.xsl`

| Regel(s) | Wat | Actie |
|----------|-----|-------|
| 66–73 | `heeftAlsInitiator` — alleen BSN | Vervangen door volledig NPS-object (zie 1.2) |
| Vóór regel 66 | `heeftBetrekkingOp` — ontbreekt | Nieuw blok toevoegen (zie 1.1) |
| 68 | `verwerkingssoort="T"` op NPS | Wijzigen naar `"I"` |
| 91 | `aanvrager_voornamen` ← `globals/stuf/voorletters` | **Bug:** naam klopt niet; veld hernoemen naar `aanvrager_voorletters` én tussenvoegsel-bug oplossen (zie tabel deel 3) |
| 91 | `aanvrager_tussenvoegsel` hardcoded leeg | Vullen met `globals/stuf/voorvoegselgeslachtsnaam` |
| 94 | `aanvrager_adres` ← alleen straat | Splitsen naar 4 losse velden (zie 1.4) |
| 96 | `aanvrager_plaats` | Hernoemen naar `aanvrager_woonplaats` |
| 99 | `aanvrager_relatie_tot_leerling` ← `relatietotleerling` | **Bug:** formulier-veld heet `realtietotleerling` (typefout in formulier); XSLT-pad aanpassen |
| 114 | `school_adres` ← alleen straat | Splitsen naar losse velden (zie 1.4) |
| 116 | `school_plaats` | Hernoemen naar `school_woonplaats` |
| 111 | `leerling_adres_gelijk_aan_aanvrager` | Behouden; leerlingadresvelden toevoegen (zie 1.4) |
| 136–150 | Dagtemplate: kommagescheiden tekst | Vervangen: Ja/Nee + begintijd + eindtijd per dag (zie 1.5) |
| Na toelichting | `aantalBijlagen` ontbreekt | Nieuw extraElement toevoegen (zie 1.6) |

---

## Deel 3 — Atabix-webformulier: veld voor veld

Het formulier wordt hieronder doorlopen in de volgorde zoals de burger het invult. Per veld:
- **Behouden** — geen wijziging
- **Hernoemen** — data blijft, naam in extraElement verandert
- **Splitsen** — één veld wordt meerdere extraElementen
- **Toevoegen** — nieuw veld in het formulier
- **Verwijderen** — veld wordt niet meer meegestuurd naar CAReL

> Veldnamen gemarkeerd met ⚠️ moeten worden bevestigd door de Doorstroommedewerker / CAReL-beheer voor de SWF-configuratie.

---

### 3.1 Aanvraagcheck

| Formulierveld (Kodison) | Actie | CAReL extraElement naam | Bronpad in XSLT |
|-------------------------|-------|------------------------|-----------------|
| `leerlingverblijftswf` | Behouden ⚠️ | `aanvraagcheck_woont_in_swf_op_schooldagen` | `fleerlingenvervoeraanvraagcheck/leerlingverblijftswf` |
| `dichtstbijzijndetoegankelijkeschool` | Behouden ⚠️ | `aanvraagcheck_dichtstbijzijnde_toegankelijke_school` | `fleerlingenvervoeraanvraagcheck/dichtstbijzijndetoegankelijkeschool` |
| `welkonderwijsvolgtleerling` | Behouden ⚠️ | `aanvraagcheck_welk_onderwijs` | `fleerlingenvervoeraanvraagcheck/welkonderwijsvolgtleerling` |
| `reisafstandmeerdan6km` | Behouden ⚠️ | `aanvraagcheck_enkele_reisafstand_meer_dan_6_km` | `fleerlingenvervoeraanvraagcheck/reisafstandmeerdan6km` |
| `leerlingkanzelfstandigreizen` | Behouden ⚠️ | `aanvraagcheck_kan_zelfstandig_reizen` | `fleerlingenvervoeraanvraagcheck/leerlingkanzelfstandigreizen` |
| `hoegaatdeleerlingnaarschool` | Behouden ⚠️ | `aanvraagcheck_hoe_gaat_leerling_naar_school` | `fleerlingenvervoeraanvraagcheck/hoegaatdeleerlingnaarschool` |
| `leerlingenvervoeraanvragen` | Behouden ⚠️ | `aanvraagcheck_wil_leerlingenvervoer_aanvragen` | `fleerlingenvervoeraanvraagcheck/leerlingenvervoeraanvragen` |

---

### 3.2 Aanvraag

| Formulierveld (Kodison) | Actie | CAReL extraElement naam | Bronpad in XSLT |
|-------------------------|-------|------------------------|-----------------|
| `welkschooljaar` | Behouden ⚠️ | `aanvraag_schooljaar` | `fleerlingenvervoerv3aanvraag/ditjaar/welkschooljaar` |
| `ingangsdatum` | Behouden ⚠️ | `aanvraag_vanaf_datum_gebruik_leerlingenvervoer` | `fleerlingenvervoerv3aanvraag/ingangsdatum` |
| `burgerbedrijf` | Behouden ⚠️ | `aanvraag_namens_burger_of_organisatie` | `fleerlingenvervoerv3aanvraag/burgerbedrijf` |

---

### 3.3 Persoonsgegevens aanvrager (BRP-prefill — geen formuliervragen)

Deze gegevens worden door DigiD-prefill ingevuld vanuit de BRP. De burger ziet ze ter controle maar vult ze niet in. De XSLT leest ze direct uit `globals/stuf/`.

| Gegeven | Actie | CAReL extraElement naam | Bronpad in XSLT | Opmerking |
|---------|-------|------------------------|-----------------|-----------|
| BSN | Hernoemen | `aanvrager_bsn` ⚠️ | `globals/stuf/inp/bsn` | |
| Voorletters | **Bug: hernoemen** | `aanvrager_voorletters` ⚠️ | `globals/stuf/voorletters` | Huidig XSLT heet dit `aanvrager_voornamen` — fout |
| Tussenvoegsel | **Bug: vullen** | `aanvrager_tussenvoegsel` ⚠️ | `globals/stuf/voorvoegselgeslachtsnaam` | Huidig XSLT is hardcoded leeg |
| Achternaam | Behouden | `aanvrager_achternaam` ⚠️ | `globals/stuf/geslachtsnaam` | |
| Geboortedatum | Behouden ⚠️ | `aanvrager_geboortedatum` | `globals/stuf/geboortedatum` | Normaliseren naar YYYYMMDD |
| Straat | **Splitsen** | `aanvrager_straat` ⚠️ | `globals/stuf/verblijfsadres/straat` | Was `aanvrager_adres` (incompleet) |
| Huisnummer | **Toevoegen** | `aanvrager_huisnummer` ⚠️ | `globals/stuf/verblijfsadres/huisnummer` | Ontbrak volledig |
| Huisletter | **Toevoegen** | `aanvrager_huisletter` ⚠️ | `globals/stuf/verblijfsadres/huisletter` | |
| Huisnummertoevoeging | **Toevoegen** | `aanvrager_huisnummertoevoeging` ⚠️ | `globals/stuf/verblijfsadres/huisnummertoevoeging` | |
| Postcode | Behouden | `aanvrager_postcode` ⚠️ | `globals/stuf/verblijfsadres/postcode` | |
| Woonplaats | Hernoemen | `aanvrager_woonplaats` ⚠️ | `globals/stuf/verblijfsadres/woonplaats` | Was `aanvrager_plaats` |
| Geslacht | Behouden ⚠️ | `aanvrager_geslacht` | `globals/stuf/geslachtsaanduiding` | Alleen in heeftAlsInitiator-structuur, niet als extraElement |
| Geboorteplaats | Aandachtspunt | — | `globals/stuf/inp/geboorteplaats` | BRP levert gemeentecode (`0091`), niet plaatsnaam; alleen in heeftAlsInitiator-structuur |

---

### 3.4 Contactgegevens aanvrager (door burger ingevuld)

| Formulierveld (Kodison) | Actie | CAReL extraElement naam | Bronpad in XSLT |
|-------------------------|-------|------------------------|-----------------|
| `telefoonnummer` | Behouden ⚠️ | `aanvrager_telefoonnummer` | `fleerlingenvervoerv3gegevensburger/telefoonnummer` |
| `emailadres` | Behouden ⚠️ | `aanvrager_emailadres` | `fleerlingenvervoerv3gegevensburger/emailadres` |
| `welkeibannummer` | Behouden ⚠️ | `iban_type` | `fleerlingenvervoerv3gegevensburger/welkeibannummer` |
| `iban` | Behouden ⚠️ | `iban_nummer` | `fleerlingenvervoerv3gegevensburger/iban` |
| `ibannaam` | Behouden ⚠️ | `iban_naam_rekeninghouder` | `fleerlingenvervoerv3gegevensburger/ibannaam` |

---

### 3.5 Relatie tot leerling

| Formulierveld (Kodison) | Actie | CAReL extraElement naam | Bronpad in XSLT | Opmerking |
|-------------------------|-------|------------------------|-----------------|-----------|
| `realtietotleerling` | **Bug: pad corrigeren** | `aanvrager_relatie_tot_leerling` ⚠️ | `fleerlingenvervoerv3gegevensburger/realtietotleerling` | XSLT gebruikt nu `relatietotleerling` (zonder typo) — veld wordt niet gevuld |

---

### 3.6 Gegevens leerling

| Formulierveld (Kodison) | Actie | CAReL extraElement naam | Bronpad in XSLT | Opmerking |
|-------------------------|-------|------------------------|-----------------|-----------|
| `bsnleerling` | Hernoemen ⚠️ | `leerling_bsn` | `fleerlingenvervoerv3gegevensleerling/bsnleerling` | |
| `voornamen` (roepnaam) | Hernoemen ⚠️ | `leerling_roepnaam` | `fleerlingenvervoerv3gegevensleerling/voornamen` | |
| *(ontbreekt)* | **Toevoegen** | `leerling_voorletters` ⚠️ | `fleerlingenvervoerv3gegevensleerling/voorletters` | Nieuw formulierveld bij Atabix |
| `tussenvoegsel` | Hernoemen ⚠️ | `leerling_tussenvoegsel` | `fleerlingenvervoerv3gegevensleerling/tussenvoegsel` | |
| `achternaam` | Hernoemen ⚠️ | `leerling_achternaam` | `fleerlingenvervoerv3gegevensleerling/achternaam` | |
| `geslacht` | Hernoemen ⚠️ | `leerling_geslacht` | `fleerlingenvervoerv3gegevensleerling/geslacht` | |
| `geboortedatum` | Hernoemen ⚠️ | `leerling_geboortedatum` | `fleerlingenvervoerv3gegevensleerling/geboortedatum` | Normaliseren naar YYYYMMDD |
| *(ontbreekt)* | **Toevoegen** | `leerling_geboorteplaats` ⚠️ | `fleerlingenvervoerv3gegevensleerling/geboorteplaats` | Nieuw formulierveld bij Atabix |
| `leerlinganderadres` | Hernoemen ⚠️ | `leerling_adres_gelijk_aan_aanvrager` | `fleerlingenvervoerv3gegevensleerling/leerlinganderadres` | Waarde: "Ja"/"Nee" |
| *(ontbreekt)* | **Toevoegen** (conditioneel, toon als adres afwijkt) | `leerling_straat` ⚠️ | `fleerlingenvervoerv3gegevensleerling/straat` | Als Ja: overnemen uit BRP-prefill |
| *(ontbreekt)* | **Toevoegen** (conditioneel) | `leerling_huisnummer` ⚠️ | `fleerlingenvervoerv3gegevensleerling/huisnummer` | |
| *(ontbreekt)* | **Toevoegen** (conditioneel) | `leerling_huisletter` ⚠️ | `fleerlingenvervoerv3gegevensleerling/huisletter` | |
| *(ontbreekt)* | **Toevoegen** (conditioneel) | `leerling_huisnummertoevoeging` ⚠️ | `fleerlingenvervoerv3gegevensleerling/huisnummertoevoeging` | |
| *(ontbreekt)* | **Toevoegen** (conditioneel) | `leerling_postcode` ⚠️ | `fleerlingenvervoerv3gegevensleerling/postcode` | |
| *(ontbreekt)* | **Toevoegen** (conditioneel) | `leerling_woonplaats` ⚠️ | `fleerlingenvervoerv3gegevensleerling/woonplaats` | |

---

### 3.7 Schoolgegevens

Het formulier heeft de schooladresvelden al gesplitst. Alleen de extraElement-namen veranderen.

| Formulierveld (Kodison) | Actie | CAReL extraElement naam | Bronpad in XSLT |
|-------------------------|-------|------------------------|-----------------|
| `naamschool` | Hernoemen ⚠️ | `school_naam` | `fleerlingenvervoerv3regulier/naamschool` |
| `straat` | Hernoemen ⚠️ | `school_straatnaam` | `fleerlingenvervoerv3regulier/straat` |
| `nummer` | **Toevoegen** ⚠️ | `school_huisnummer` | `fleerlingenvervoerv3regulier/nummer` | Was niet meegestuurd |
| `huisletter` | **Toevoegen** ⚠️ | `school_huisletter` | `fleerlingenvervoerv3regulier/huisletter` | Was niet meegestuurd |
| `nummertoevoeging` | **Toevoegen** ⚠️ | `school_huisnummertoevoeging` | `fleerlingenvervoerv3regulier/nummertoevoeging` | Was niet meegestuurd |
| `postcode` | Behouden ⚠️ | `school_postcode` | `fleerlingenvervoerv3regulier/postcode` |
| `woonplaats` | Hernoemen ⚠️ | `school_woonplaats` | `fleerlingenvervoerv3regulier/woonplaats` | Was `school_plaats` |

---

### 3.8 Eigen bijdrage

| Formulierveld (Kodison) | Actie | CAReL extraElement naam | Bronpad in XSLT |
|-------------------------|-------|------------------------|-----------------|
| `hetverzamelinkomen` | Behouden ⚠️ | `eigenbijdrage_verzamelinkomen_2023` | `fleerlingenvervoerv3eigenbijdrage/newyear/hetverzamelinkomen` |
| `belastingaangifte` | Behouden ⚠️ | `eigenbijdrage_upload_belastingaangifte` | `fleerlingenvervoerv3eigenbijdrage/belastingaangifte` |

---

### 3.9 Soort vervoer en bijlagen

| Formulierveld (Kodison) | Actie | CAReL extraElement naam | Bronpad in XSLT |
|-------------------------|-------|------------------------|-----------------|
| `typevergoedingvervoer` | Behouden ⚠️ | `vervoer_type` | `fleerlingenvervoerv3vervoer/typevergoedingvervoer` |
| `uploadfiets` | Behouden ⚠️ | `vervoer_upload_routeplanner` | `fleerlingenvervoerv3vervoer/uploadfiets` |
| `bijlagen` | Behouden ⚠️ | `vervoer_upload_vervoersverklaring` | `fleerlingenvervoerv3vervoer/bijlagen` |
| *(berekend)* | **Toevoegen** (XSLT) | `aantalBijlagen` | `count(attachments/attachment[@type='Upload'])` |

---

### 3.10 Vervoerdagen

De dagstructuur verandert volledig. Per dag: van één veld naar drie velden.

**Actie Atabix (de Atabix-formulierbeheerder):** begintijd en eindtijd toevoegen per dag, zichtbaar als de dag geselecteerd is.

| Formulierveld (Kodison) | Actie | CAReL extraElement naam | Bronpad in XSLT | Opmerking |
|-------------------------|-------|------------------------|-----------------|-----------|
| `maandagvervoer{type}` | Hernoemen + omzetten | `maandag` | Aanwezig en niet leeg → `"Ja"`, anders `"Nee"` | |
| *(ontbreekt)* | **Toevoegen** | `begintijd_maandag` ⚠️ | `fleerlingenvervoerv3vervoer/begintijd_maandag` | Nieuw formulierveld |
| *(ontbreekt)* | **Toevoegen** | `eindtijd_maandag` ⚠️ | `fleerlingenvervoerv3vervoer/eindtijd_maandag` | Nieuw formulierveld |
| `dinsdagvervoer{type}` | Hernoemen + omzetten | `dinsdag` | Idem | |
| *(ontbreekt)* | **Toevoegen** | `begintijd_dinsdag` ⚠️ | `fleerlingenvervoerv3vervoer/begintijd_dinsdag` | |
| *(ontbreekt)* | **Toevoegen** | `eindtijd_dinsdag` ⚠️ | `fleerlingenvervoerv3vervoer/eindtijd_dinsdag` | |
| `woensdagvervoer{type}` | Hernoemen + omzetten | `woensdag` | Idem | |
| *(ontbreekt)* | **Toevoegen** | `begintijd_woensdag` ⚠️ | `fleerlingenvervoerv3vervoer/begintijd_woensdag` | |
| *(ontbreekt)* | **Toevoegen** | `eindtijd_woensdag` ⚠️ | `fleerlingenvervoerv3vervoer/eindtijd_woensdag` | |
| `donderdagvervoer{type}` | Hernoemen + omzetten | `donderdag` | Idem | |
| *(ontbreekt)* | **Toevoegen** | `begintijd_donderdag` ⚠️ | `fleerlingenvervoerv3vervoer/begintijd_donderdag` | |
| *(ontbreekt)* | **Toevoegen** | `eindtijd_donderdag` ⚠️ | `fleerlingenvervoerv3vervoer/eindtijd_donderdag` | |
| `vrijdagvervoer{type}` | Hernoemen + omzetten | `vrijdag` | Idem | |
| *(ontbreekt)* | **Toevoegen** | `begintijd_vrijdag` ⚠️ | `fleerlingenvervoerv3vervoer/begintijd_vrijdag` | |
| *(ontbreekt)* | **Toevoegen** | `eindtijd_vrijdag` ⚠️ | `fleerlingenvervoerv3vervoer/eindtijd_vrijdag` | |

---

### 3.11 Toelichting

| Formulierveld (Kodison) | Actie | CAReL extraElement naam | Bronpad in XSLT |
|-------------------------|-------|------------------------|-----------------|
| `extratoelichting` | Hernoemen ⚠️ | `toelichting` | `fleerlingenvervoerv3toelichting/extratoelichting` |

---

## Openstaande punten

| # | Punt | Actie bij |
|---|------|-----------|
| 1 | Alle met ⚠️ gemarkeerde veldnamen bevestigen voor SWF-configuratie in CAReL | de Doorstroommedewerker / Eljakim |
| 2 | Geboorteplaats aanvrager: gemeentecode (`0091`) of plaatsnaam? | Eljakim / CAReL |
| 3 | Geboorteplaats leerling: veld toevoegen aan formulier | de Atabix-formulierbeheerder / Atabix |
| 4 | Voorletters leerling: veld toevoegen aan formulier | de Atabix-formulierbeheerder / Atabix |
| 5 | Leerlingadresvelden (6 stuks): conditioneel toevoegen aan formulier | de Atabix-formulierbeheerder / Atabix |
| 6 | Begin/eindtijden per dag (10 stuks): toevoegen aan formulier | de Atabix-formulierbeheerder / Atabix |
| 7 | Co-ouderschap: verplicht veld in CAReL of niet? | Eljakim / CAReL |
