# Corsa- en CAReL-koppeling: hoe werkt de flow

Beschrijft de werking van de bestaande (hybride) koppelingen met Corsa (documentbeheer) en CAReL (zaaksysteem via StUF/ZDS). Deze koppelingen draaien naast de nieuwe ZAC-koppeling.

Bijgewerkt: 01 juli 2026.

---

## Overzicht

De WebformulierenVerwerker ontvangt één SOAP-bericht van Kodison en vertaalt dat naar de juiste reeks API-calls richting Corsa en/of CAReL.

```
Kodison → WebformulierenVerwerker (Frank, poort 8090)
  Corsa-flow:  → Corsa SOAP webservice (documentbeheer)
  CAReL-flow:  → OpenZaakBrug (ID-generatie) + CAReL (zaakregistratie via StUF/ZDS)
```

---

## Corsa-flow — inkomende documenten opslaan

Gebruikt voor: `opslaanInkNatuurlijkPersoon`, `opslaanInkNietNatuurlijkPersoon`, `opslaanBijlage`, `opslaanInk`

### Technisch: stateful sessie

Corsa werkt met een **stateful SOAP-sessie**: elke reeks API-calls begint met een `Connect` en eindigt met een `Disconnect`. De verwerker houdt de sessie open zolang de operatie loopt.

> **Locker:** elke adapter heeft een `<Locker>` die voorkomt dat twee gelijktijdige verzoeken dezelfde Corsa-sessie verstoren.

### Authenticatie

Op de TST-omgeving stuurt de verwerker username + password mee in de `Connect`-aanroep. Op andere omgevingen (LOC, DEV, PRD) wordt alleen de username meegegeven — geen wachtwoord.

---

### `opslaanInkNatuurlijkPersoon` — document voor burger

**Doel:** sla een inkomend document op in Corsa, gekoppeld aan een natuurlijk persoon (burger met BSN).

```
Connect (Corsa)
  ↓
[indien afzenderbsn aanwezig]
  QueryPerson (op BSN) → persoon gevonden?
    Ja  → haal intern Corsa-persoonsnummer op (SPNum)
    Nee → CreateMetaPerson → haal nieuw SPNum op
  ↓
CreateMetaDocument (gekoppeld aan SPNum)
  ↓
CreateFileVersion (upload bestandsinhoud)
  ↓
[indien dossiercode aanwezig]
  ModObjectRelation (koppel document aan dossier)
  ↓
Disconnect
  ↓
Sla vertrouwelijkheid op in INFO_CACHE (voor gebruik door CAReL-bijlage-stap)
```

**Persooncheck:** de verwerker zoekt eerst of er al een persoon in Corsa bestaat met dat BSN. Bestaat die niet, dan wordt die aangemaakt. Zo hoeft Kodison zich hier niet om te bekommeren.

**Dossier:** als de aanvraag een `dossiercode` meegeeft, koppelt de verwerker het document aan dat dossier via `ModObjectRelation`. Fouten hierbij worden genegeerd (het document is al opgeslagen; het dossier-koppelen is best-effort).

---

### `opslaanInkNietNatuurlijkPersoon` — document voor organisatie

Identiek aan `opslaanInkNatuurlijkPersoon`, maar dan voor een niet-natuurlijk persoon (bedrijf/organisatie). In plaats van BSN wordt gezocht/aangemaakt op organisatienaam of KvK-nummer via `QueryCompany` / `CreateMetaCompany`.

---

### `opslaanBijlage` — bijlage aan bestaand document

**Doel:** voeg een bijlage toe aan een eerder opgeslagen Corsa-document.

```
Connect (Corsa)
  ↓
CreateMetaDocument (bijlage-metadata)
  ↓
CreateFileVersion (upload bijlage-inhoud)
  ↓
Disconnect
```

Eenvoudiger dan de persoonsvarianten: er is geen persooncheck, geen dossier-koppeling.

---

### `opslaanInk` — generiek document (zonder persoonscheck)

**Doel:** sla een inkomend document op zonder persoonskoppeling. Gebruikt voor formulieren waarbij geen BSN beschikbaar is of niet relevant is.

```
Connect (Corsa)
  ↓
CreateMetaDocument
  ↓
CreateFileVersion
  ↓
Disconnect
```

---

### INFO_CACHE na Corsa-operatie

Na een succesvolle `opslaanInk*`-operatie slaat de verwerker het Corsa-registratienummer (NewObjectID), vertrouwelijkheid, afzender en onderwerp op in de `INFO_CACHE`-tabel. Dit is nodig zodat een latere `opslaanAanvraagBijlage`-aanroep de juiste zaak kan vinden zonder dat Kodison die informatie opnieuw hoeft mee te sturen.

---

## CAReL-flow — aanvragen registreren via StUF/ZDS

Gebruikt voor: `opslaanAanvraagNatuurlijkPersoon`, `opslaanAanvraagBijlage`

### Technisch: twee externe systemen

De CAReL-flow raakt twee systemen:
- **OpenZaakBrug** (`openzaakbrug_zds_vrijbericht.url`) — genereert unieke zaak- en document-ID's via StUF Di02-berichten
- **CAReL** (`carel_zds_ontvangasynchroon.url`) — ontvangt de zaak en documenten via StUF Lk01-berichten (asynchroon)

---

### `opslaanAanvraagNatuurlijkPersoon` — aanvraag aanmaken in CAReL

**Doel:** maak een zaak aan in CAReL voor een burger, inclusief PDF-formulier en XML-aanvraagdata.

```
Decodeer aanvraag-XML (base64 → XML)
  ↓
genereerZaakIdentificatie_Di02 (OpenZaakBrug) → zaakidentificatie
  ↓
Switch op aanvraagtype:
  "leerlingenvervoer" → creeerZaak_Lk01 (CAReL) — zaak aanmaken
  [andere typen] → fout: aanvraagtype not valid
  ↓
genereerDocumentIdentificatie_Di02 (OpenZaakBrug) → PDF-document-ID
  ↓
voegZaakdocumentToe_Lk01 (CAReL) — PDF toevoegen aan zaak
  ↓
genereerDocumentIdentificatie_Di02 (OpenZaakBrug) → XML-document-ID
  ↓
voegZaakdocumentToe_Lk01 (CAReL) — XML-aanvraagdata toevoegen aan zaak
  ↓
Response naar Kodison met zaakidentificatie
```

**Aanvraagtype-switch:** de adapter schakelt op basis van het `aanvraagtype`-veld in het SOAP-verzoek. Momenteel is alleen `leerlingenvervoer` geconfigureerd. Een nieuw aanvraagtype vereist een nieuwe XSL-mapping onder `xsl/OpslaanAanvraag<Type>NatuurlijkPersoon/`.

**Asynchroon:** de CAReL-aanroepen (`creeerZaak_Lk01`, `voegZaakdocumentToe_Lk01`) zijn asynchroon — CAReL bevestigt ontvangst maar verwerkt de zaak pas daarna. De verwerker wacht niet op de definitieve zaakverwerking.

---

### `opslaanAanvraagBijlage` — bijlage toevoegen aan CAReL-aanvraag

**Doel:** voeg een bijlage toe aan een eerder aangemaakte zaak in CAReL.

```
Ontvang zaakidentificatie uit SOAP-verzoek
  ↓
genereerDocumentIdentificatie_Di02 (OpenZaakBrug) → bijlage-document-ID
  ↓
voegZaakdocumentToe_Lk01 (CAReL) — bijlage toevoegen aan zaak
  ↓
Response naar Kodison
```

Kodison moet de `zaakidentificatie` (terug uit `opslaanAanvraagNatuurlijkPersoon`) meegeven.

---

## Hybride gebruik: Corsa én CAReL tegelijk

In de huidige (hybride) situatie kan Kodison voor één aanvraag zowel Corsa als CAReL aanroepen:

1. `opslaanInkNatuurlijkPersoon` → document in Corsa + registratienummer in INFO_CACHE
2. `opslaanAanvraagNatuurlijkPersoon` → zaak in CAReL + zaakidentificatie terug
3. `opslaanAanvraagBijlage` → bijlage aan CAReL-zaak (met de zaakidentificatie uit stap 2)

Corsa en CAReL zijn in deze flow volledig onafhankelijk van elkaar — de verwerker beheert geen toestand tussen de twee systemen.

---

## Externe systemen

| Systeem | URL (property) | Protocol |
|---------|---------------|----------|
| Corsa | `${corsa.url}` | SOAP (eigen BCT-protocol) |
| OpenZaakBrug (ID-generatie) | `${openzaakbrug_zds_vrijbericht.url}` | SOAP / StUF ZDS 0310 |
| CAReL (zaakregistratie) | `${carel_zds_ontvangasynchroon.url}` | SOAP / StUF ZDS 0310 asynchroon |

---

## Bestanden

| Bestand | Inhoud |
|---------|--------|
| `Configuration_OpslaanInkNatuurlijkPersoon.xml` | Corsa-flow voor burger |
| `Configuration_OpslaanInkNietNatuurlijkPersoon.xml` | Corsa-flow voor organisatie |
| `Configuration_OpslaanBijlage.xml` | Corsa-bijlage |
| `Configuration_OpslaanInk.xml` | Corsa generiek (geen persoon) |
| `Configuration_OpslaanAanvraagNatuurlijkPersoon.xml` | CAReL-flow voor burger |
| `Configuration_OpslaanAanvraagBijlage.xml` | CAReL-bijlage |
| `xsl/OpslaanInkNatuurlijkPersoon/` | XSLT voor Corsa-persoon-flow |
| `xsl/OpslaanInkNietNatuurlijkPersoon/` | XSLT voor Corsa-organisatie-flow |
| `xsl/OpslaanAanvraagNatuurlijkPersoon/` | XSLT voor CAReL zaak + documenten |
| `xsl/OpslaanAanvraagBijlage/` | XSLT voor CAReL-bijlage |
| `xsl/OpslaanAanvraagLeerlingenVervoerNatuurlijkPersoon/` | Leerlingenvervoer-specifieke zaak-mapping |
| `xsl/Common/Message2Connect.xsl` | Corsa Connect-bericht |
| `xsl/Common/Message2Disconnect.xsl` | Corsa Disconnect-bericht |
| `xsl/Common/Message2CreateFileVersion.xsl` | Corsa bestandsupload |
| `xsl/Common/Message2ModObjectRelationDossier.xsl` | Corsa dossier-koppeling |
| `docs/Corsa72WS4j.xml` | Corsa WSDL (referentie) |
| `docs/Corsa_Webservice_Technical_Description_v1.0.60.pdf` | Corsa API-specificatie (referentie) |
| `docs/carel/Zaak_DocumentServices_1_1_02/` | ZDS 1.1.02 specificaties (StUF/ZDS WSDLs en XSDs) |
