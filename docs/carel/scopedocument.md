# Scopedocument CAReL-koppeling WebformulierenVerwerker

Dit document legt de oorspronkelijke opdracht en de gerealiseerde implementatie vast.
Het dient als nulmeting voor het beoordelen van meerwerk.

---

## 1. De opdracht

**Bron:** e-mail Eduard Witteveen → Jaco (WeAreFrank), 20 februari 2026  
**Referentiedocumenten:**
- `docs/carel/20260302/FB_WebformulierenVerwerker_CareL_v1.2.docx` — functionele beschrijving
- `docs/carel/20260302/creeerzaak_carel.xml` — gewenste zakLk01-berichtstructuur richting CAReL
- `docs/carel/20260302/Leerlingenvervoer.xml` — voorbeeld aanvraag-XML zoals Kodison die aanlevert
- `docs/carel/20260302/Aanvraag Leerlingenvervoer.pdf` — voorbeeld PDF-samenvatting

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

**Gerealiseerd door:** Alexander Raccuglia (WeAreFrank)  
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
| 3 | `aanvrager_adres` (extraElement) | Straat + huisnummer (`Snekerstraat 30`) | Alleen straat (`Snekerstraat`) — huisnummer niet meegenomen | Incompleet |
| 4 | `aanvrager_tussenvoegsel` (extraElement) | Gevuld vanuit persoonsgegevens | Hardcoded leeg | Incompleet |
| 5 | `samenvatting_datum` en `samenvatting_tijd` | Aanwezig als extraElement | Afwezig | Ontbreekt |

**Afwijking #1 is het meest kritisch:** zonder `heeftBetrekkingOp` ontvangt CAReL geen leerlinggegevens in de zaakstructuur zelf.

---

## 4. Aanvullende scope-opmerkingen

- Het formuliertype `leerlingenvervoer` is hardcoded via een `XmlSwitchPipe` op het veld `aanvraagtype`. Voor andere formuliertypes (buiten scope fase 1) geeft de adapter een foutmelding.
- De PDF-bijlage en XML-aanvraag worden beide als document aan de zaak gehangen (`voegZaakdocumentToe_Lk01`). Losse bijlagen gaan via de aparte operatie `opslaanAanvraagBijlage`.
- OpenZaakBrug wordt gebruikt voor ID-generatie; CAReL ontvangt de zaak en documenten.

---

## 5. Deployment en open punten (e-mailthread juni 2026)

**Bron:** e-mailthread Alexander Raccuglia ↔ Eduard Witteveen, 21 mei – 12 juni 2026

### Deployment status en testverloop (chronologisch)

- Origineel gepland: deploy op **ACC**-omgeving (aankondiging Alexander, 21 mei 2026).
- Feitelijk uitgerold op **TST** — Eduard trof de service aan op `https://testtsjinstbus.sudwestfryslan.nl/`.
- Versie 6.22.2 kon niet worden gepulld (ontbreken pull-rechten op `openzksbrugt001` e.a. — Bernardus Jansen gevraagd dit op te lossen).
- Op TST draait versie 6.21.7 met de nieuwe adapters handmatig aanwezig.
- TST-omgeving URLs bijgewerkt door Alexander (28 mei):
  - `carel_zds_ontvangasynchroon.url` = `https://testtsjinstbus.sudwestfryslan.nl/CARELLG/stuf-zkn/sudwestfryslan`
  - `openzaakbrug_zds_vrijbericht.url` = `http://openzksbrugt001.iszf.local/translate/generic/zds/VrijBericht`
- **Let op:** versie 6.22.2 heeft de property `carel_zds_vrijbericht.url` hernoemd naar `openzaakbrug_zds_vrijbericht.url`. Bij deployment moet de TST-configuratie hierop worden bijgewerkt.

**4 juni 2026 — eerste gedeeltelijke doorbraak:**  
Bernardus en Eduard sturen testberichten. Berichten komen aan bij Eljakim maar worden niet correct verwerkt. Petra schakelt met Manuel (Eljakim). Diezelfde middag (14:06): eerste succesvol signaal — testbericht goed aangekomen in CAReL acceptatie.

**11 juni 2026 — nieuwe blokkade:**  
Eljakim heeft een nieuwe server in gebruik genomen; serverconflict én datumconflict waardoor berichten niet doorkomen.

**12 juni 2026 (donderdag) — positief signaal, nog niet geverifieerd:**  
Petra en Lorenzo testen samen. Serverissue opgelost, bericht zou binnengekomen zijn in CAReL testomgeving volgens Lorenzo. Actie van Mark/Eduard: testberichten sturen met BSN `123456789` (fictief) en `426670231` (bestaand). Bespreking gepland via Teams (vrijdag of dinsdagmiddag). **Keten is pas bewezen werkend als Eduard dit zelf heeft getest en bevestigd.**

**4 juni 2026 — Eduard Witteveen (git commit `0674020`):**  
Nieuw bestand `e2e/webformulierenverwerker-soapui-project.xml` aangemaakt en gecommit. Bevat de SoapUI-testopzet voor de CAReL-koppeling, inclusief het aangepaste creeerZaak-berichtformaat. Verstuurd naar Eljakim voor validatie.

### Open punt: WSDL per omgeving (gesignaleerd door Eduard, 10 juni 2026)

**Situatie:**  
Er bestaan twee WSDL-bestanden:
- `GeneriekeFormulierAfhandeling.wsdl` — bevat de nieuwe functies, maar verwijst hardcoded naar de productie-host (`tsjinstbus.sudwestfryslan.nl`)
- `GeneriekeFormulierAfhandelingTest.wsdl` — verwijst naar de TST-host, maar bevat de nieuwe functies **nog niet**

Atabix/Triple Forms gebruikt voor test de `...Test.wsdl`, waardoor `opslaanAanvraagNatuurlijkPersoon` e.d. daar niet zichtbaar zijn.

**Oplossing ad hoc (binnen huidige scope):** `GeneriekeFormulierAfhandelingTest.wsdl` bijwerken met de nieuwe functies — dit is gedaan in commit `5d46a13`.

**Structurele oplossing (gevraagd door Eduard, nog niet gerealiseerd):** één WSDL die per omgeving naar de juiste host verwijst, zodat dit niet bij elke uitbreiding opnieuw handmatig moet worden gesynchroniseerd. Alexander heeft bevestigd dat WeAreFrank hier naar zal kijken. **Status: open.**

---

## 6. Feedback van CAReL-kant (Eljakim / Lorenzo van den Oudenrijn)

**Bron:** bericht Jorn Kemker (Súdwest-Fryslân), doorgegeven vanuit Lorenzo van den Oudenrijn (Eljakim Information Technology), ~5–10 juni 2026

### Concrete veldwijzigingen gevraagd door Jorn Kemker (namens CAReL/Eljakim)

De volgende wijzigingen in de `extraElementen` zijn gevraagd. Dit zijn afwijkingen ten opzichte van de oorspronkelijke spec — **meerwerk**.

| Huidig veld (spec) | Vervangen door |
|--------------------|----------------|
| `aanvrager_adres` (straat + huisnummer gecombineerd) | `aanvrager_straat`, `aanvrager_huisnummer`, `aanvrager_huisletter`, `aanvrager_huisnummertoevoeging` |
| `leerling_adres_gelijk_aan_aanvrager` (boolean) | `leerling_straat`, `leerling_huisnummer`, `leerling_huisletter`, `leerling_huisnummertoevoeging` |
| `school_adres` (gecombineerd) | `school_straat`, `school_huisnummer`, `school_huisletter`, `school_huisnummertoevoeging` |

**Status: bevestigd meerwerk** — vereist aanpassingen in `creeerZaak_Lk01_mapping.xsl`.

### Open punt A: meerdere opties bij keuzevragen

Jorn vraagt of voor vragen waarbij meerdere opties mogelijk zijn (bijv. `aanvrager_relatie_tot_leerling`) alle opties aangeleverd kunnen worden — niet alleen de geselecteerde waarde. Jorn heeft Hein Vlietstra gevraagd hier meer over te zeggen.

**Status: open** — wachten op reactie Hein Vlietstra. Afhankelijk van zijn antwoord bepaalt dit of en hoeveel aanpassing in de XSLT nodig is.

### Actie WeAreFrank: SoapUI-project voor directe CAReL-test (donderdag 12 juni 2026)

Uit een chatbericht (donderdag 12 juni, Eduard Witteveen):

> "Ik zal een soapui project maken met daarin de benodigde aanpassing, zodat we kunnen testen of de nieuwe berichten goed aankomen bij Carel."

**Gedaan:** Eduard heeft dit gerealiseerd — commit `0674020` (4 juni 2026) voegt `e2e/webformulierenverwerker-soapui-project.xml` toe. Bestand verstuurd naar Eljakim.

**Status: gedaan** — SoapUI-project aangemaakt door Eduard, verstuurd naar Eljakim. Keten-validatie door Eduard nog niet bevestigd.

### Open punt B: velden in XML waarvoor CAReL geen vraag heeft ingesteld

CAReL ontvangt `extraElementen` waarvoor aan hun kant geen corresponderende vraag is geconfigureerd in de applicatie. Petra Schaap (CAReL-beheer) moet aangeven welke velden alsnog in CAReL moeten worden ingericht.

**Toelichting:**  
Dit is primair een **CAReL-configuratievraagstuk**, geen aanpassing aan de WebformulierenVerwerker. Als CAReL bepaalde velden niet herkent, moet CAReL-beheer die velden inrichten — tenzij wordt besloten dat bepaalde velden helemaal niet verstuurd hoeven te worden (dan is het wél een aanpassing in de XSLT).

**Status: open** — wachten op input van Petra Schaap / CAReL-beheer.

---

## 7. Referentie-XML van Eljakim (12 juni 2026)

**Bron:** e-mail Lorenzo van den Oudenrijn (Eljakim) → Alexander Raccuglia (WeAreFrank), 12 juni 2026  
**Bestand:** `docs/carel/eljakim/Voorbeeld_bericht.xml`  
**Afzenders e-mail:** Lorenzo van den Oudenrijn, CC: Petra Schaap, Eduard Witteveen, Jorn Kemker, Marijn van Stralen, Manuel de Kleine

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
De Eljakim-referentie stuurt `straatnaam` en `huisnummer` als afzonderlijke extraElementen. De SWF-spec combineert deze (`aanvrager_adres` = `"Snekerstraat 30"`). Dit sluit aan bij afwijking #3 maar suggereert dat de definitieve oplossing een splitsing is, niet combinatie.

**Opmerking over veldnamen:**  
De veldnamen in de extraElementen van de Eljakim-referentie zijn gemeente-specifiek (andere gemeente, ander formulier) en zijn **niet** maatgevend voor de SWF-veldnamen. De SWF-veldnamen zijn vastgelegd in `creeerzaak_carel.xml` en moeten worden afgestemd met CAReL-beheer (Petra Schaap). Dit raakt open punt B uit sectie 6.

---

## 8. Tijdlijn

Datums met `git` zijn bevestigd uit git-geschiedenis. Overige datums zijn afkomstig uit e-mail of Teams-chat en daarin zijn ze exact; niet zelf geschat.

| Datum | Bron | Gebeurtenis |
|-------|------|-------------|
| 20 feb 2026 | e-mail | Eduard → Jaco (WeAreFrank): opdracht CAReL-koppeling, inschatting gevraagd |
| 2 mrt 2026 | directory naam | Specificaties vastgesteld: `creeerzaak_carel.xml`, `Leerlingenvervoer.xml`, `FB_...docx` |
| 21 mei 2026 | `git b68ec41` | Alexander Raccuglia: implementatie gecommit — feat: implementatie integratie Kodision-2-CAReL (#105) |
| 22 mei 2026 | `git 48b4862` | MLenterman: property `carel_zds_vrijbericht.url` hernoemd naar `openzaakbrug_zds_vrijbericht.url` (#106) |
| 22 mei 2026 | `git 5d46a13` | Fix: ontbrekende CAReL resources in `GeneriekeFormulierAfhandelingTest.wsdl` (#107) — beide nieuwe operaties nu ook in test-WSDL |
| 22 mei 2026 | `git 682ffbd` | Release 6.22.2 aangemaakt |
| 4 jun 2026 | `git 0674020` | Eduard Witteveen: `e2e/webformulierenverwerker-soapui-project.xml` aangemaakt en gecommit |
| 4 jun 2026 | Teams-chat | Eerste testberichten Bernardus & Eduard richting CAReL; diezelfde middag eerste succesvol ontvangen bericht in CAReL acceptatie |
| ~5–10 jun 2026 | Teams-chat | Jorn Kemker (namens Lorenzo/Eljakim) meldt vereiste veldwijzigingen (adressplitsing, dagstructuur) |
| 10 jun 2026 | e-mail | Eduard signaleert WSDL-probleem: `...Test.wsdl` had nieuwe functies nog niet |
| 11 jun 2026 | Teams-chat | Nieuwe blokkade: Eljakim serverconflict + datumconflict |
| 12 jun 2026 | e-mail + Teams-chat | Lorenzo + Petra testen; serverissue opgelost; Eljakim stuurt referentie-XML (`Voorbeeld_bericht.xml`) |
| 15 jun 2026 | Teams-chat | Eduard stuurt aangepast SoapUI-project naar Eljakim; keten nog niet door Eduard zelf bevestigd |
