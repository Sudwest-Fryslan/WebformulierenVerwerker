# Scopedocument CAReL-koppeling WebformulierenVerwerker

Dit document legt de oorspronkelijke opdracht en de gerealiseerde implementatie vast.
Het dient als nulmeting voor het beoordelen van meerwerk.

---

## 1. De opdracht

**Bron:** e-mail van de Solution Innovator (ontwikkelaar) → WeAreFrank, 20 februari 2026  
**Referentiedocumenten:**
- `docs/carel/20260302/FB_WebformulierenVerwerker_CareL_v1.2.docx` — functionele beschrijving
- `docs/carel/20260302/creeerzaak_carel.xml` — gewenste zakLk01-berichtstructuur richting CAReL
- Referentiecapture van een voorbeeld aanvraag-XML zoals Kodison die aanlevert — intern gearchiveerd (git.sudwestfryslan.net), bevat persoonsgegevens, niet in deze publieke repo
- Referentie PDF-samenvatting van een testaanvraag — intern gearchiveerd (git.sudwestfryslan.net), bevat persoonsgegevens, niet in deze publieke repo

**Samenvatting opdracht:**  
De bestaande WebformulierenVerwerker koppelt Kodison aan Corsa. De nieuwe variant koppelt Kodison aan CAReL (vakapplicatie leerlingenvervoer) via StUF-ZKN. De Frank!Framework-structuur blijft gelijk; de Corsa-adapters worden vervangen door CAReL-adapters.

**Fase 1 (in scope):** Koppeling Kodison → CAReL  
**Fase 2 (buiten scope):** Uitbreiding naar OpenZaak

**Gevraagde operaties:**
- `opslaanAanvraagNatuurlijkPersoon` — aanvraag leerlingenvervoer opslaan inclusief PDF en XML
- `opslaanAanvraagBijlage` — losse bijlage koppelen aan een bestaande zaak

**Gewenste berichtenstroom per operatie (`opslaanAanvraagNatuurlijkPersoon`):**
1. Zaakidentificatie genereren via OpenZaakBrug (`genereerZaakIdentificatie_Di02`)
2. Zaak aanmaken in CAReL (`creeerZaak_Lk01`) met betrokkenen en formulierantwoorden
3. Document-ID genereren via OpenZaakBrug (`genereerDocumentIdentificatie_Di02`)
4. PDF-samenvatting koppelen aan zaak in CAReL (`voegZaakdocumentToe_Lk01`)
5. Document-ID genereren voor XML (`genereerDocumentIdentificatie_Di02`)
6. Aanvraag-XML koppelen aan zaak in CAReL (`voegZaakdocumentToe_Lk01`)

**Gewenste inhoud `zakLk01` (conform `creeerzaak_carel.xml`):**
- Zaaktype: code `LV-001`, omschrijving `Leerlingenvervoer aanvraag`
- Betrokkene kind/leerling via `heeftBetrekkingOp` (ZAKOBJ) met BSN, naam, geslacht, geboortedatum, rol `Leerling`
- Betrokkene aanvrager (ouder/verzorger) via `heeftAlsInitiator` (ZAKBTRINI) met BSN, naam, geslacht, geboortedatum
- Alle formulierantwoorden als `extraElementen` (aanvraagcheck, aanvraag, aanvrager, IBAN, leerling, school, eigen bijdrage, vervoer, dagen, toelichting)

---

## 2. De implementatie

**Gerealiseerd door:** WeAreFrank  
**Opgeleverd in:** commit `b68ec41`, 21 mei 2026 (PR #105)  
**Bugfix:** commit `5d46a13` (ontbrekende CAReL resources in test-WSDL)

**Gerealiseerde operaties:**
- `opslaanAanvraagNatuurlijkPersoon` — `Configuration_OpslaanAanvraagNatuurlijkPersoon.xml`
- `opslaanAanvraagBijlage` — `Configuration_OpslaanAanvraagBijlage.xml`

**Berichtenstroom is geïmplementeerd** conform de opdracht (6 stappen, zie boven).

**Inhoud `zakLk01` — wat er wél is:**
- Stuurgegevens, parameters, object-structuur correct
- Zaaktype `LV-001` aanwezig
- `heeftAlsInitiator` aanwezig (aanvrager met BSN)
- Alle formulierantwoorden als `extraElementen` aanwezig en correct gemapped
- Extra toevoeging (niet in spec): `ZKN:kenmerk` met Kodison-formulierkenmerk en bron `Kodision`

---

## 3. Vastgestelde afwijkingen ten opzichte van de opdracht

De onderstaande punten zijn geconstateerd bij vergelijking van `creeerzaak_carel.xml` met de geïmplementeerde XSLT (`creeerZaak_Lk01_mapping.xsl`).

| # | Onderdeel | Spec | Implementatie | Beoordeling |
|---|-----------|------|---------------|-------------|
| 1 | `heeftBetrekkingOp` (leerling als ZAKOBJ) | Aanwezig: BSN, naam, geslacht, geboortedatum, rol `Leerling` | **Volledig afwezig** | Ontbreekt |
| 2 | `heeftAlsInitiator` persoonsdetails | BSN + geslachtsnaam, voorletters, voornamen, geslachtsaanduiding, geboortedatum | Alleen BSN + `authentiek=J` | Vereenvoudigd |
| 3 | `aanvrager_adres` (extraElement) | Straat + huisnummer (`Kerkstraat 12`) | Alleen straat (`Kerkstraat`) — huisnummer niet meegenomen | Incompleet |
| 4 | `aanvrager_tussenvoegsel` (extraElement) | Gevuld vanuit persoonsgegevens | Hardcoded leeg | Incompleet |
| 5 | `samenvatting_datum` en `samenvatting_tijd` | Aanwezig als extraElement | Afwezig | Ontbreekt |

**Afwijking #1 is het meest kritisch:** zonder `heeftBetrekkingOp` ontvangt CAReL geen leerlinggegevens in de zaakstructuur zelf.

**Update 22 juli 2026 — afwijking #1 opgelost, op verzoek van de Solution Innovator (ontwikkelaar):** `heeftBetrekkingOp` is toegevoegd
in `creeerZaak_Lk01_mapping.xsl`, met alle leerlinggegevens die het formulier al levert: BSN, voornamen,
tussenvoegsel, achternaam, geboortedatum (genormaliseerd), geslachtsaanduiding (`Jongen`/`Meisje` →
`M`/`V`, `O` als fallback). `verwerkingssoort="I"` gebruikt op het NPS-object, conform de Eljakim-referentie
en de StUF-schema-analyse (zie hieronder). Verblijfsadres wordt **conditioneel** meegenomen: als
`leerlinganderadres = "Ja"` (leerling-adres gelijk aan aanvrager, per meerwerk-document) wordt het
aanvrageradres uit de BRP-prefill gebruikt; bij `"Nee"` blijft verblijfsadres bewust weg, omdat het
formulier nog geen eigen leerlingadresvelden heeft (zie meerwerk-document §1.1) — beter niets sturen dan
onjuiste data.

**Schema-onderzoek (vraag van de Solution Innovator (ontwikkelaar): is BSN-alleen genoeg?):** de StUF-XSD (`NPS-kerngegevens` in
`bg0310_ent_basis.xsd`) heeft **geen enkel verplicht veld** — alles staat op `minOccurs="0"`, ook BSN
zelf. Functioneel is BSN wel het praktische minimum voor `verwerkingssoort="I"` (Identificatie = alleen
verwijzen naar een bekend persoon). Kanttekening: de Eljakim-referentie stuurt bij `"I"` toch volledige
naam/geboortedatum/adres mee — CAReL's eigen acceptatielogica (los van de generieke schema-validatie) is
daarmee niet met zekerheid vastgesteld. **Nog te bevestigen met de Doorstroommedewerker/Eljakim** of onze implementatie
(BSN + bekende basisgegevens, adres alleen conditioneel) voldoet.

**Getest** (Saxon, drie scenario's): oude formulierformaat, nieuwe formulierformaat, en de
`leerlinganderadres = "Nee"`-situatie — in alle gevallen correcte, valide XML; verblijfsadres verschijnt
alleen in de eerste twee (waar `"Ja"` geldt), terecht afwezig in het derde scenario.

**Update 22 juli 2026 — afwijking #2 ook opgelost, op verzoek van de Solution Innovator (ontwikkelaar):** `heeftAlsInitiator`
(aanvrager) is uitgebreid van alleen BSN + `authentiek=J` naar volledige persoonsgegevens:
voorletters, voornamen, voorvoegselGeslachtsnaam, geslachtsnaam, geboortedatum, geboorteplaats,
geslachtsaanduiding en verblijfsadres — allemaal uit `globals/stuf/*` (BRP-prefill), **geen
formulierwijziging nodig** voor de aanvrager (in tegenstelling tot de leerling bij afwijking #1).
`verwerkingssoort="I"` gezet op het NPS-object, conform meerwerk-document §1.2.

**Kanttekening geboorteplaats:** de BRP levert `inp.geboorteplaats` als gemeentecode (bv. `0091`), niet
als plaatsnaam — nog af te stemmen met Eljakim/CAReL of een code acceptabel is (staat ook al zo in het
meerwerk-document).

**Getest** (Saxon, oude en nieuwe formulierformaat): in beide gevallen correcte, volledig gevulde
`heeftAlsInitiator` (BSN, naam, geboortedatum, adres), geen regressie op de rest van het bericht (nog
steeds 47 extraElementen).

**Nog open van deze sectie:** afwijking #3 (`aanvrager_adres`-extraElement mist huisnummer) en #4
(`aanvrager_tussenvoegsel` hardcoded leeg) — dat zijn de extraElementen, niet de `heeftAlsInitiator`-
structuur, en horen bij punt #6 (adres-splitsing) in `docs/openstaande_punten_integratie.md`, nog niet
aangepast. #5 (`samenvatting_datum`/`samenvatting_tijd`) ook nog niet opgepakt.

---

## 4. Aanvullende scope-opmerkingen

- Het formuliertype `leerlingenvervoer` is hardcoded via een `XmlSwitchPipe` op het veld `aanvraagtype`. Voor andere formuliertypes (buiten scope fase 1) geeft de adapter een foutmelding.
- De PDF-bijlage en XML-aanvraag worden beide als document aan de zaak gehangen (`voegZaakdocumentToe_Lk01`). Losse bijlagen gaan via de aparte operatie `opslaanAanvraagBijlage`.
- OpenZaakBrug wordt gebruikt voor ID-generatie; CAReL ontvangt de zaak en documenten.

---

## 5. Deployment en open punten (e-mailthread juni 2026)

**Bron:** e-mailthread WeAreFrank ↔ de Solution Innovator (ontwikkelaar), 21 mei – 12 juni 2026

### Deployment status en testverloop (chronologisch)

- Origineel gepland: deploy op **ACC**-omgeving (aankondiging WeAreFrank, 21 mei 2026).
- Feitelijk uitgerold op **TST** — de Solution Innovator (ontwikkelaar) trof de service aan op `https://testtsjinstbus.sudwestfryslan.nl/`.
- Versie 6.22.2 kon niet worden gepulld (ontbreken pull-rechten op `openzksbrugt001` e.a. — Bernardus Jansen gevraagd dit op te lossen).
- Op TST draait versie 6.21.7 met de nieuwe adapters handmatig aanwezig.
- TST-omgeving URLs bijgewerkt door WeAreFrank (28 mei):
  - `carel_zds_ontvangasynchroon.url` = `https://testtsjinstbus.sudwestfryslan.nl/CARELLG/stuf-zkn/sudwestfryslan`
  - `openzaakbrug_zds_vrijbericht.url` = `http://openzksbrugt001.iszf.local/translate/generic/zds/VrijBericht`
- **Let op:** versie 6.22.2 heeft de property `carel_zds_vrijbericht.url` hernoemd naar `openzaakbrug_zds_vrijbericht.url`. Bij deployment moet de TST-configuratie hierop worden bijgewerkt.

**4 juni 2026 — eerste gedeeltelijke doorbraak:**  
Bernardus en de Solution Innovator (ontwikkelaar) sturen testberichten. Berichten komen aan bij Eljakim maar worden niet correct verwerkt. de Doorstroommedewerker schakelt met de CAReL-leverancier (Eljakim) (Eljakim). Diezelfde middag (14:06): eerste succesvol signaal — testbericht goed aangekomen in CAReL acceptatie.

**11 juni 2026 — nieuwe blokkade:**  
Eljakim heeft een nieuwe server in gebruik genomen; serverconflict én datumconflict waardoor berichten niet doorkomen.

**12 juni 2026 (donderdag) — positief signaal, nog niet geverifieerd:**  
de Doorstroommedewerker en de CAReL-leverancier (Eljakim) testen samen. Serverissue opgelost, bericht zou binnengekomen zijn in CAReL testomgeving volgens de CAReL-leverancier (Eljakim). Actie van de informatieadviseur sociaal domein/de Solution Innovator (ontwikkelaar): testberichten sturen met BSN `123456789` (fictief) en `426670231` (bestaand). Bespreking gepland via Teams (vrijdag of dinsdagmiddag). **Keten is pas bewezen werkend als de Solution Innovator (ontwikkelaar) dit zelf heeft getest en bevestigd.**

**4 juni 2026 — de Solution Innovator (ontwikkelaar) (git commit `0674020`):**  
Nieuw bestand `e2e/webformulierenverwerker-soapui-project.xml` aangemaakt en gecommit. Bevat de SoapUI-testopzet voor de CAReL-koppeling, inclusief het aangepaste creeerZaak-berichtformaat. Verstuurd naar Eljakim voor validatie.

### Open punt: WSDL per omgeving (gesignaleerd door de Solution Innovator (ontwikkelaar), 10 juni 2026)

**Situatie:**  
Er bestaan twee WSDL-bestanden:
- `GeneriekeFormulierAfhandeling.wsdl` — bevat de nieuwe functies, maar verwijst hardcoded naar de productie-host (`tsjinstbus.sudwestfryslan.nl`)
- `GeneriekeFormulierAfhandelingTest.wsdl` — verwijst naar de TST-host, maar bevat de nieuwe functies **nog niet**

Atabix/Triple Forms gebruikt voor test de `...Test.wsdl`, waardoor `opslaanAanvraagNatuurlijkPersoon` e.d. daar niet zichtbaar zijn.

**Oplossing ad hoc (binnen huidige scope):** `GeneriekeFormulierAfhandelingTest.wsdl` bijwerken met de nieuwe functies — dit is gedaan in commit `5d46a13`.

**Structurele oplossing (gevraagd door de Solution Innovator (ontwikkelaar), nog niet gerealiseerd):** één WSDL die per omgeving naar de juiste host verwijst, zodat dit niet bij elke uitbreiding opnieuw handmatig moet worden gesynchroniseerd. WeAreFrank heeft bevestigd dat WeAreFrank hier naar zal kijken. **Status: open.**

---

## 6. Feedback van CAReL-kant (Eljakim)

**Bron:** bericht van de adviseur informatiemanagement (WeAreFrank-contact) (Súdwest-Fryslân), doorgegeven vanuit de CAReL-leverancier (Eljakim Information Technology), ~5–10 juni 2026

### Concrete veldwijzigingen gevraagd door de adviseur informatiemanagement (WeAreFrank-contact) (namens CAReL/Eljakim)

De volgende wijzigingen in de `extraElementen` zijn gevraagd. Dit zijn afwijkingen ten opzichte van de oorspronkelijke spec — **meerwerk**.

| Huidig veld (spec) | Vervangen door |
|--------------------|----------------|
| `aanvrager_adres` (straat + huisnummer gecombineerd) | `aanvrager_straat`, `aanvrager_huisnummer`, `aanvrager_huisletter`, `aanvrager_huisnummertoevoeging` |
| `leerling_adres_gelijk_aan_aanvrager` (boolean) | `leerling_straat`, `leerling_huisnummer`, `leerling_huisletter`, `leerling_huisnummertoevoeging` |
| `school_adres` (gecombineerd) | `school_straat`, `school_huisnummer`, `school_huisletter`, `school_huisnummertoevoeging` |

**Status: bevestigd meerwerk** — vereist aanpassingen in `creeerZaak_Lk01_mapping.xsl`.

### Open punt A: meerdere opties bij keuzevragen

de adviseur informatiemanagement (WeAreFrank-contact) vraagt of voor vragen waarbij meerdere opties mogelijk zijn (bijv. `aanvrager_relatie_tot_leerling`) alle opties aangeleverd kunnen worden — niet alleen de geselecteerde waarde. de adviseur informatiemanagement (WeAreFrank-contact) heeft de Atabix-formulierbeheerder gevraagd hier meer over te zeggen.

**Status: open** — wachten op reactie de Atabix-formulierbeheerder. Afhankelijk van zijn antwoord bepaalt dit of en hoeveel aanpassing in de XSLT nodig is.

### Actie WeAreFrank: SoapUI-project voor directe CAReL-test (donderdag 12 juni 2026)

Uit een chatbericht (donderdag 12 juni, de Solution Innovator (ontwikkelaar)):

> "Ik zal een soapui project maken met daarin de benodigde aanpassing, zodat we kunnen testen of de nieuwe berichten goed aankomen bij Carel."

**Gedaan:** de Solution Innovator (ontwikkelaar) heeft dit gerealiseerd — commit `0674020` (4 juni 2026) voegt `e2e/webformulierenverwerker-soapui-project.xml` toe. Bestand verstuurd naar Eljakim.

**Status: gedaan** — SoapUI-project aangemaakt door de Solution Innovator (ontwikkelaar), verstuurd naar Eljakim. Keten-validatie door de Solution Innovator (ontwikkelaar) nog niet bevestigd.

### Open punt B: velden in XML waarvoor CAReL geen vraag heeft ingesteld

CAReL ontvangt `extraElementen` waarvoor aan hun kant geen corresponderende vraag is geconfigureerd in de applicatie. de Doorstroommedewerker (CAReL-beheer) moet aangeven welke velden alsnog in CAReL moeten worden ingericht.

**Toelichting:**  
Dit is primair een **CAReL-configuratievraagstuk**, geen aanpassing aan de WebformulierenVerwerker. Als CAReL bepaalde velden niet herkent, moet CAReL-beheer die velden inrichten — tenzij wordt besloten dat bepaalde velden helemaal niet verstuurd hoeven te worden (dan is het wél een aanpassing in de XSLT).

**Status: open** — wachten op input van de Doorstroommedewerker / CAReL-beheer.

---

## 7. Referentie-XML van Eljakim (12 juni 2026)

**Bron:** e-mail de CAReL-leverancier (Eljakim) (Eljakim) → WeAreFrank, 12 juni 2026  
**Bestand:** `docs/carel/eljakim/Voorbeeld_bericht.xml`  
**Afzenders e-mail:** de CAReL-leverancier (Eljakim), CC: de Doorstroommedewerker, de Solution Innovator (ontwikkelaar), de adviseur informatiemanagement (WeAreFrank-contact), de CAReL-leverancier (Eljakim), de CAReL-leverancier (Eljakim)

Eljakim heeft als referentie een werkend voorbeeld gestuurd van een bestaande koppeling (INTRACTO/Drupal → CAReL, andere gemeente). Dit toont het structurele formaat dat CAReL verwacht.

### Wat dit bevestigt en toevoegt t.o.v. de vastgestelde afwijkingen

**Bevestigt afwijking #1 (`heeftBetrekkingOp` ontbreekt):**  
De Eljakim-referentie heeft `heeftBetrekkingOp` met volledige persoonsgegevens (BSN, voorletters, voornamen, voorvoegsel, geslachtsnaam, geboortedatum, geboorteplaats, geslachtsaanduiding, verblijfsadres). `verwerkingssoort="I"` voor de NPS-referentie. Dit is het patroon dat CAReL verwacht.

**Bevestigt afwijking #2 (`heeftAlsInitiator` vereenvoudigd):**  
De Eljakim-referentie heeft `heeftAlsInitiator` met dezelfde volledige persoonsgegevens inclusief verblijfsadres. Alleen BSN sturen is niet voldoende — CAReL verwacht een volledig ingevuld NPS-object.

**Nieuw inzicht: `verwerkingssoort="I"` voor NPS-gerelateerden:**  
Zowel in `heeftBetrekkingOp` als in `heeftAlsInitiator` gebruikt de Eljakim-referentie `verwerkingssoort="I"` (Identificatie) voor de `natuurlijkPersoon`. De huidige implementatie gebruikt `"T"`. Dit moet worden aangepast.

**Nieuw inzicht: verblijfsadres in de betrokkenen:**  
De betrokkenen in de Eljakim-referentie bevatten een `verblijfsadres` met `aoa.postcode`, `aoa.huisnummer`, `gor.openbareRuimteNaam`, `wpl.woonplaatsNaam`. Dit ontbreekt volledig in de huidige implementatie.

**Nieuw inzicht: dagen-structuur met begin- en eindtijden:**  
De Eljakim-referentie stuurt per dag drie aparte extraElementen: `maandag` (Ja/Nee), `begintijd_maandag`, `eindtijd_maandag`. De huidige implementatie stuurt per dag één kommagescheiden waarde (bijv. `vervoer_maandag` = `"Ochtend, Middag"`). Dit verklaart vermoedelijk open punt A uit sectie 6 — CAReL is ingericht op het Ja/Nee + tijden-patroon. **Waarschijnlijk meerwerk.**

**Nieuw inzicht: huisnummer als apart extraElement:**  
De Eljakim-referentie stuurt `straatnaam` en `huisnummer` als afzonderlijke extraElementen. De SWF-spec combineert deze (`aanvrager_adres` = `"Kerkstraat 12"`). Dit sluit aan bij afwijking #3 maar suggereert dat de definitieve oplossing een splitsing is, niet combinatie.

**Opmerking over veldnamen:**  
De veldnamen in de extraElementen van de Eljakim-referentie zijn gemeente-specifiek (andere gemeente, ander formulier) en zijn **niet** maatgevend voor de SWF-veldnamen. De SWF-veldnamen zijn vastgelegd in `creeerzaak_carel.xml` en moeten worden afgestemd met CAReL-beheer (de Doorstroommedewerker). Dit raakt open punt B uit sectie 6.

---

## 8. Tijdlijn

Datums met `git` zijn bevestigd uit git-geschiedenis. Overige datums zijn afkomstig uit e-mail of Teams-chat en daarin zijn ze exact; niet zelf geschat.

| Datum | Bron | Gebeurtenis |
|-------|------|-------------|
| 20 feb 2026 | e-mail | de Solution Innovator (ontwikkelaar) → WeAreFrank: opdracht CAReL-koppeling, inschatting gevraagd |
| 2 mrt 2026 | directory naam | Specificaties vastgesteld: `creeerzaak_carel.xml`, `Leerlingenvervoer.xml`, `FB_...docx` |
| 21 mei 2026 | `git b68ec41` | WeAreFrank: implementatie gecommit — feat: implementatie integratie Kodision-2-CAReL (#105) |
| 22 mei 2026 | `git 48b4862` | MLenterman: property `carel_zds_vrijbericht.url` hernoemd naar `openzaakbrug_zds_vrijbericht.url` (#106) |
| 22 mei 2026 | `git 5d46a13` | Fix: ontbrekende CAReL resources in `GeneriekeFormulierAfhandelingTest.wsdl` (#107) — beide nieuwe operaties nu ook in test-WSDL |
| 22 mei 2026 | `git 682ffbd` | Release 6.22.2 aangemaakt |
| 4 jun 2026 | `git 0674020` | de Solution Innovator (ontwikkelaar): `e2e/webformulierenverwerker-soapui-project.xml` aangemaakt en gecommit |
| 4 jun 2026 | Teams-chat | Eerste testberichten Bernardus & de Solution Innovator (ontwikkelaar) richting CAReL; diezelfde middag eerste succesvol ontvangen bericht in CAReL acceptatie |
| ~5–10 jun 2026 | Teams-chat | de adviseur informatiemanagement (WeAreFrank-contact) (namens de CAReL-leverancier, Eljakim) meldt vereiste veldwijzigingen (adressplitsing, dagstructuur) |
| 10 jun 2026 | e-mail | de Solution Innovator (ontwikkelaar) signaleert WSDL-probleem: `...Test.wsdl` had nieuwe functies nog niet |
| 11 jun 2026 | Teams-chat | Nieuwe blokkade: Eljakim serverconflict + datumconflict |
| 12 jun 2026 | e-mail + Teams-chat | de CAReL-leverancier (Eljakim) + de Doorstroommedewerker testen; serverissue opgelost; Eljakim stuurt referentie-XML (`Voorbeeld_bericht.xml`) |
| 15 jun 2026 | Teams-chat | de Solution Innovator (ontwikkelaar) stuurt aangepast SoapUI-project naar Eljakim; keten nog niet door de Solution Innovator (ontwikkelaar) zelf bevestigd |
| 17 jun 2026 | e-mail | Project gepauzeerd tot na de zomer (besluit de Doorstroommedewerker, akkoord de teamleider); evaluatiegesprek gepland week 38 (14-16 sept 2026) |
| 21 jul 2026 | e-mail (`tmp/Re_ Xml.eml`) | de Atabix-formulierbeheerder verstuurt testaanvraag met het nieuwe formulier (schooljaar 2026-2027) |
| 22 jul 2026 | analyse + e-mail | de Solution Innovator (ontwikkelaar) constateert gewijzigd exportformaat van de aanvraag-XML (boomstructuur → platte naam/waarde-lijst), bevestigt dat dit de CAReL-mapping breekt (`creeerZaak_Lk01_mapping.xsl:21`), en meldt dit per e-mail aan de Atabix-formulierbeheerder en de informatieadviseur sociaal domein |
| 22 jul 2026 | mondeling/chat | de Doorstroommedewerker nog bezig met bekijken/verwerken in CAReL van de eerdere (2025-)testaanvragen die de Solution Innovator (ontwikkelaar) vanuit SoapUI had verstuurd — los van de formaatkwestie hierboven |

---

## 9. Nieuwe formulierversie 2026-2027: exportformaat van de aanvraag-XML gewijzigd

**Bron:** testaanvraag de Atabix-formulierbeheerder, 21 juli 2026 (`tmp/Re_ Xml.eml`, Ladybug-capture), vergeleken met
de referentiecapture van schooljaar 2025-2026 (intern gearchiveerd, git.sudwestfryslan.net).

Het Atabix-formulier voor schooljaar 2026-2027 levert de `aanvraagxmldata` (het XML-deel van
`opslaanAanvraagNatuurlijkPersoon`) aan in een **andere structuur** dan voorheen:
- **Oud:** boomstructuur `FORMULIER/ELEMENTEN/form/answers/...`, elk antwoord op een vaste plek.
- **Nieuw:** platte lijst `output/transformedData/element` met losse `name`/`value`-paren, zonder pad.

**Concreet, bevestigd gevolg:** `creeerZaak_Lk01_mapping.xsl:21` selecteert met
`/FORMULIER/ELEMENTEN/form/answers` — dat pad bestaat niet meer in de nieuwe export, dus de volledige
mapping naar `zakLk01` (regels 27 e.v.) wordt niet meer aangeroepen. Zonder aanpassing levert een
aanvraag met het nieuwe formulier een lege of onvolledige CAReL-zaak op.

**Genuanceerd:** dit is geen dataverlies — 136 van de 156 velden die de XSLT gebruikt staan onder
dezelfde naam nog in de nieuwe export. Wel is een deel van de veldnamen niet meer eenduidig
(`bsn` komt 7×, `telefoonnummer` 5×, `emailadres` 4× voor, zonder padcontext om te bepalen welke bij de
aanvrager hoort). De vergelijkingsbestanden (oude en nieuwe formulierversie) zijn intern gearchiveerd (git.sudwestfryslan.net, bevatten persoonsgegevens); volledige analyse in
`docs/carel/delta_formulierversie_2025_2026.md`.

**Actie:** de Solution Innovator (ontwikkelaar) heeft dit per e-mail (22 juli 2026) gemeld aan de Atabix-formulierbeheerder en de informatieadviseur sociaal domein, met het
verzoek bij de formulierleverancier na te vragen of dit een bewuste, blijvende wijziging is of een
neveneffect, en hoe destijds aan de oude versie is gekomen.

**Status: open** — wachten op reactie de Atabix-formulierbeheerder / formulierleverancier. Bepaalt of dit meerwerk
richting WeAreFrank wordt (XSLT aanpassen aan nieuw formaat) of dat de bron wordt gecorrigeerd.

**Update 22 juli 2026 — oorzaak gevonden, waarschijnlijk géén meerwerk:**
de Atabix-formulierbeheerder meldt dat hij zelf een generieke XSLT-stylesheet heeft gemaakt om de XML vanuit het
scenario naar buiten te krijgen voor deze test. Die stylesheet zet elk element, hoe diep ook genest, om
naar een los `<element><name>/<value></element>` en laat daarbij ook de tussenliggende containers zelf
als apart element staan (met alle onderliggende tekst aan elkaar geplakt als waarde). Dit verklaart het
waargenomen patroon exact (dubbele veldnamen, lange tekstbrij-waarden) en is dus **niet** een wijziging
vanuit Atabix/CAReL/het formulierenplatform zelf, maar een bijproduct van Heins eigen teststap.

**Open vraag (uitstaand bij de Atabix-formulierbeheerder, 22 juli 2026):** was deze stylesheet-stap nodig omdat de Atabix-formulierbeheerder handmatig
vanuit de scenario-editor testte (in plaats van een echte aanvraag via de live site)? Zo ja, dan komt een
echte aanvraag waarschijnlijk nog steeds in het oude, geneste formaat binnen en is er aan de
WebformulierenVerwerker-kant niets aan te passen. Gevraagd aan de Atabix-formulierbeheerder: (1) waarom de stylesheet nodig was,
(2) of de rauwe XML uit het scenario (zonder stylesheet) beschikbaar is ter vergelijking, (3) of een
live/productie-aanvraag ook via deze stylesheet zou gaan.

**Update 22 juli 2026, later — Kodison bevestigt: er moet altijd een XSLT tussen zitten** in de
scenario-exportstap (dit is dus geen keuze van de Atabix-formulierbeheerder, maar een vaste eis van het platform). Daarmee
verschuift de vraag van "kan de stylesheet weg" naar "welke stylesheet moet de Atabix-formulierbeheerder gebruiken". Op basis van
een volledige doorlichting van `creeerZaak_Lk01_mapping.xsl` is een voorstel gemaakt:
`docs/carel/WebformulierenVerwerker_Passthrough.xml` — een **pure identity-transform** (kopieert de XmlAnswers
ongewijzigd door, zonder enige veldnaam of formulierstructuur te veronderstellen). Dit is bewust
onvoorwaardelijk generiek gehouden: het werkt voor elk Kodison-formulier, niet alleen leerlingenvervoer,
en laat altijd alle ingevulde waarden meekomen. Een optionele, formulier-specifieke opschoning (twee
platform-boilerplate-onderdelen "defaults" en "summary" weglaten, aantoonbaar ongebruikt door de mapping)
staat als aparte, duidelijk gemarkeerde toevoeging in het bestand — alleen te gebruiken als bevestigd is
dat dat patroon voor elk scenario geldt.

**Waarom niet selectief velden doorgeven:** binnen `fleerlingenvervoerv3vervoer` construeert de mapping
de veldnaam per dag dynamisch op basis van het gekozen vervoertype (bv. `maandagvervoerfiets`). Een
vooraf vastgestelde veldenlijst zou dat soort dynamische lookup breken, dus moet de volledige boom
worden doorgegeven in plaats van een uitgekozen subset.

**Update 22 juli 2026, screenshot Atabix-scenario (`tmp/screenshot atabix.png`):** de processorstap
"Xslt transformation" in het scenario heeft `Source` en `Stylesheet` als verplichte velden — bevestigt
visueel dat een XSLT-stap hier niet optioneel is. Source staat op `[*XmlAnswers]` (de ingebouwde
platformvariabele met alle formulierantwoorden), Stylesheet verwijst naar `data/Stylesheet1.xml`.
Opvallend: het Namespace-veld van deze stap staat op `xml_BerichtCorsa` — wijst erop dat deze stap
mogelijk gekopieerd is vanuit een oudere (Corsa-gerelateerde) configuratie, met alleen de
stylesheet-inhoud vervangen. **Actie:** eerst bij de Atabix-formulierbeheerder navragen of de `data/`-map in het scenario nog een
ander, ouder stylesheet-bestand bevat dat bij het oude (2025-2026) scenario al correct werkte — dan is
"deze stap terugwijzen naar dat bestand" simpeler dan een nieuwe stylesheet invoeren.

**Update 22 juli 2026, definitief bevestigd via Ladybug-capture ("nieuwe-xsl"):** de Atabix-formulierbeheerder had inmiddels
zijn flatten-stylesheet vervangen (de nesting-structuur per veld is terug), maar de root van de
`XmlAnswers` is `<form>` zelf, **zonder** de omliggende `FORMULIER`/`ELEMENTEN`-laag. Gevolg, hard
bevestigd in de capture: `creeerZaak_Lk01_mapping.xsl` levert een leeg resultaat op (alleen de
XML-declaratie), en er wordt een **volledig lege SOAP-body** (`<soapenv:Body></soapenv:Body>`) naar
CAReL gestuurd — vandaar de generieke fout "Something went wrong... No Error Info".

**Fix:** `docs/carel/WebformulierenVerwerker_Passthrough.xml` is aangepast: zet alleen de ontbrekende
`FORMULIER`/`FORMULIERID`/`DATUMVERZENDING`/`ELEMENTEN`-laag om het binnenkomende `<form>`-element heen
(gebruikt `form/@startDateTime` voor DATUMVERZENDING en `form/scenarioName` voor FORMULIERID — geen
formulier-specifieke veldnamen, dus generiek voor elk Kodison-scenario), en kopieert de rest ongewijzigd
door. Getest tegen de echte data uit Heins laatste testaanvraag (lxml/XPath): alle paden die de mapping
nodig heeft (`globals/bsn`, `globals/stuf/...`, `fleerlingenvervoerv3gegevensburger/telefoonnummer`,
etc.) resolven na deze wrap naar de juiste waarden. **Status: klaar om naar de Atabix-formulierbeheerder te sturen.**

**Update 22 juli 2026, scope van de fix expliciet vastgelegd:** de huidige, op TST gedeployde versie van
WebformulierenVerwerker begrijpt alléén het oude, gewrapte formaat en kan momenteel niet bijgewerkt
worden. Daarom moet de hybride (oud/nieuw-formaat herkennen tijdens de overgang) **uitsluitend aan de
Atabix-kant** zitten — in `docs/carel/WebformulierenVerwerker_Passthrough.xml` — en niet in
`creeerZaak_Lk01_mapping.xsl`. Er is kort een wijziging in de integratie-XSLT geweest om dit ook daar te
laten werken; die is teruggedraaid (`git checkout`) zodra dit duidelijk werd — de integratie blijft
ongewijzigd. Eind-tot-eind getest met Saxon: native (nieuwe) formulier-XML → ongewijzigde
`WebformulierenVerwerker_Passthrough.xml` v1.1 → **onaangepaste** `creeerZaak_Lk01_mapping.xsl` levert
een volledig correct `zakLk01`-bericht op (alle velden gevuld, `startdatum` juist via de
`@startDateTime`-fallback in de Atabix-stylesheet). De hybride-laag zit dus volledig op de plek waar hij
op elk moment losstaand aangepast/getest kan worden, zonder de gedeployde integratie te raken.

**Update 22 juli 2026, cross-check:** de Solution Innovator (ontwikkelaar) leverde extra bewijsmateriaal aan (`tmp/leerlingenvervoer_hvl.xml`
en de bijbehorende ruwe SOAP-request uit de Ladybug-testomgeving) — via sha256-hash geverifieerd: dit is
exact dezelfde testaanvraag als de "nieuwe-xsl"-capture hierboven (zelfde `startDateTime` en `uniqueId`),
gegenereerd met de eerste (pre-wrapper) versie van de voorstel-stylesheet. Bevestigt de diagnose, geen
nieuw incident. Op verzoek van de Solution Innovator (ontwikkelaar) is aan `WebformulierenVerwerker_Passthrough.xml` een
versie-commentaar toegevoegd (`<!-- Gegenereerd door ..., versie 1.1 -->`, zichtbaar in elke output) zodat
een volgende Ladybug-capture direct laat zien welke stylesheet-versie een aanvraag heeft geproduceerd.

**Update 22 juli 2026, bevestigd geslaagd:** de Atabix-formulierbeheerder heeft met versie 1.1 van
`WebformulierenVerwerker_Passthrough.xml` vier testaanvragen ingevuld (13:34, 14:10, 14:14, 14:24 uur).
Alle vier zijn end-to-end gecontroleerd via de Ladybug-logs (niet alleen op het antwoord vertrouwd): in
elk geval bouwt de mapping een compleet `zakLk01`, antwoordt CAReL met een positieve StUF-bevestiging
(`Bv03Bericht`, geen `Fo03`), worden PDF én XML correct aan de zaak gekoppeld, en sluit de pipeline af
met `exitState: SUCCESS` en een echte `opslaanAanvraagNatuurlijkPersoonResponse` met resultaat-ID (bv.
`1900881137`) terug naar Kodison. **Dit onderdeel is hiermee werkend bevestigd** — de gedeployde
(ongewijzigde) integratie verwerkt de nieuwe formulierversie nu correct via de aangepaste Atabix-stylesheet.

**Controlemechanisme toegevoegd, twee lagen (22 juli 2026):**

1. **In SoapUI:** de 4 teststappen met echte Atabix-data (`WebformulierenVerwerker Carel TestCase (2026)`)
   hebben elk een Script Assertion die de `aanvraagxmldata` decodeert, het versie-commentaar van
   `WebformulierenVerwerker_Passthrough.xml` opzoekt, en de test laat falen met een duidelijke boodschap
   als de versie ontbreekt of lager is dan de minimaal vereiste. Logica gevalideerd door de
   regex/vergelijking los in Python te herhalen tegen de 4 echte captures.

2. **Live, in de integratie zelf** (op verzoek van de Solution Innovator (ontwikkelaar) — dit hoort wél bij de dingen die de
   integratie zelf mag controleren, in tegenstelling tot het daadwerkelijk *verwerken* van het nieuwe
   formaat): een nieuwe, puur diagnostische stap `CheckAtabixStylesheetVersion`
   (`xsl/OpslaanAanvraagNatuurlijkPersoon/CheckAtabixStylesheetVersion.xsl`) direct na het decoderen van
   de aanvraag-XML, die bij elke binnenkomende aanvraag logt of de gebruikte Atabix-stylesheetversie
   voldoet. Verandert geen data en blokkeert niets — puur een logregel.

   **Belangrijke les tijdens het bouwen hiervan:** de eerste versie controleerde het `xsl:comment` met
   de versie-tekst — dat werkte foutloos bij direct testen met Saxon, maar gaf **live, via de
   Frank!Framework-pipeline, altijd "geen versie gevonden"**, ook bij correcte input. Reden:
   Frank!Framework's eigen XSLT-verwerking geeft XML-commentaar niet door aan de XSLT — een verschil
   tussen "los een stylesheet draaien" en "een stylesheet laten draaien binnen de pipeline" dat alleen
   met een levende testomgeving aan het licht kwam. Opgelost door de versie in een **attribuut**
   (`passthroughVersion` op `FORMULIER`) te zetten in plaats van een commentaar — dat overleeft normale
   XML-parsing altijd. `WebformulierenVerwerker_Passthrough.xml` is daarom naar **versie 1.2** gegaan
   (versie 1.1, waarmee de Atabix-formulierbeheerder zijn 4 geslaagde tests draaide, had dit attribuut nog niet — die captures
   tonen dus terecht "geen attribuut gevonden" bij de live check, dat is geen nieuw probleem).

   Live getest met drie scenario's (Docker + curl): v1.2 → "OK"; oud formulierformaat (geen attribuut) →
   neutrale melding, geen fout; gesimuleerde verouderde versie (1.0) → duidelijke waarschuwing met
   gevonden versus vereiste versie.

**Losstaand, parallel lopend:** de Doorstroommedewerker is nog bezig met het bekijken en verwerken in CAReL van de
eerdere (2025-)testaanvragen die de Solution Innovator (ontwikkelaar) vanuit SoapUI had verstuurd (zie sectie 6, "Actie WeAreFrank:
SoapUI-project"). Dit is onafhankelijk van de bovenstaande formaatkwestie van het nieuwe formulier.

---

## 10. Nieuwe formulierversie 2026-2027: veldencontract afgerond met de Atabix-formulierbeheerder (3 september 2026)

**Bron:** e-mail de Atabix-formulierbeheerder → de Solution Innovator (ontwikkelaar) e.a., 3 september 2026
(`Re_ 260820 toevoeging aanpassing nav overleg vervoer (4).eml`), reactie op de 5 openstaande
formulierpunten uit de "260820"-mailwisseling. Volledig veld-voor-veld contract:
`docs/carel/veldencontract_leerlingenvervoer.md` (opvolger van `meerwerk_berichtformaat_eljakim.md` in
sectie 7, dat inmiddels op meerdere punten is achterhaald).

**Uitkomst per punt, na afstemming met de Solution Innovator (ontwikkelaar):**
1. **Dagen vervoer:** bevestigd als 3 onafhankelijke checkboxes per dag (Brengen/Ophalen/Geen, Brengen
   én Ophalen mogen beide "Ja" zijn — de normale situatie). "Geen" sluit de andere twee uit via
   weblogica bij de Atabix-formulierbeheerder, die zelf de visualisatie mag kiezen zolang de integratie
   het resultaat kan vertalen. Dit was al zo geïmplementeerd in `creeerZaak_Lk01_mapping.xsl`
   (15 velden `vervoer_<dag>_brengen/_ophalen/_geen`) — geen mappingwijziging nodig, alleen bevestiging.
2. **Leerlingadres:** besloten dat dit altijd verstuurd moet worden (niet meer alleen bij "gelijk aan
   aanvrager"). Bij het vinkje: kopie van het aanvrageradres. Bij een eigen adres: blijft een bouwpunt
   bij de Atabix-formulierbeheerder (formulierveld bestaat nog niet). Mapping aangepast: de conditionele
   `xsl:if` is een `xsl:choose` geworden met een fallback-tak voor het (nog te bouwen) eigen
   leerlingadres — tot dat veld bestaat is het praktische resultaat ongewijzigd.
3. **Schooladres:** bevestigd, de recent (op verzoek van de Doorstroommedewerker) ingerichte
   gesplitste opzet voldoet — geen wijziging nodig.
4. **Typefout `realtietotleerling` → `relatietotleerling`:** opgelost door de Atabix-formulierbeheerder.
5. **Organisatie-naamveld:** bleek al volledig te bestaan (compleet "Gegevens Organisatie"-blok,
   inclusief BAG-conform gesplitst adres — meer dan verwacht). Scope voor CAReL vastgesteld: alleen
   organisatienaam, contactpersoonnaam en telefoonnummer nodig; adres wordt bewust niet verstuurd,
   eHerkenning blijft buiten scope. Mapping uitgebreid met twee nieuwe extraElementen
   (`aanvrager_organisatie_naam`, `aanvrager_naam`) en een omgeschakelde bron voor
   `aanvrager_telefoonnummer` bij de organisatieroute — brondveldnamen van het organisatieblok zijn nog
   een aanname, te bevestigen bij de Atabix-formulierbeheerder.

**Getest** (Saxon): bestaande testcapture (burger-route) ongewijzigd correct, plus een nieuw synthetisch
scenario (organisatie-aanvrager + eigen leerlingadres) — beide leveren het verwachte `zakLk01` op.

**Nog open:** de exacte brondveldnamen voor zowel de dagdeel-checkboxes als het organisatieblok zijn
aannames totdat de Atabix-formulierbeheerder ze daadwerkelijk bouwt/bevestigt; de actieve CAReL-kant
bevestiging van de dagdeel-structuur door de CAReL-leverancier (Eljakim) staat nog open (zie
`docs/carel/veldencontract_leerlingenvervoer.md`, sectie "Open punten").
