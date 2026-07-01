# ZAC-koppeling: hoe werkt de flow

Beschrijft de volledige gegevensstroom van Kodison (webformulieren) naar ZAC (zaakafhandelcomponent) via de WebformulierenVerwerker.

Bijgewerkt: 01 juli 2026.

---

## Overzicht in één zin

Kodison doet drie SOAP-calls naar de WebformulierenVerwerker; die slaat documenten op in Open Zaak en plaatst een productaanvraag-JSON in de Objecten API; ZAC pikt dat op via een Notificaties-event en maakt automatisch een zaak aan.

---

## De drie SOAP-stappen

```
Kodison                       WebformulierenVerwerker (Frank)        Open Zaak / ZAC
  │                                     │
  │── stap 1: aanmakenVerzoekNatuurlijkPersoon ──►│
  │   (BSN, PDF base64, XML base64)              │── POST PDF ──► Documenten API
  │                                              │── POST XML ──► Documenten API
  │                                              │   (UUID pdf + UUID xml opgeslagen in INFO_CACHE)
  │◄── verzoekIdentificatie (UUID) + DRC-urls ──│
  │
  │── stap 2: toevoegenVerzoekDocument (0..n) ──►│
  │   (verzoekIdentificatie, bijlage base64)     │── POST bijlage ──► Documenten API
  │                                              │   (UUID bijlage opgeslagen in VERZOEK_BIJLAGEN)
  │◄── DRC-url bijlage ─────────────────────────│
  │
  │── stap 3: indienenVerzoek ──────────────────►│
  │   (verzoekIdentificatie)                     │   (leest INFO_CACHE + VERZOEK_BIJLAGEN)
  │                                              │── POST productaanvraag-JSON ──► Objecten API
  │                                              │                                     │
  │◄── bevestiging ─────────────────────────────│              Notificaties API ◄──────┘
  │                                                                    │
  │                                                               ZAC maakt zaak aan
```

---

## Stap 1 — aanmakenVerzoekNatuurlijkPersoon

**SOAP-input van Kodison:**
| Veld | Inhoud |
|------|--------|
| `afzenderbsn` | BSN van de aanvrager |
| `aanvraagpdfname` | Bestandsnaam van het PDF-formulier |
| `aanvraagpdfdata` | PDF-bestand als base64 |
| `aanvraagxmlname` | Bestandsnaam van de XML-aanvraagdata |
| `aanvraagxmldata` | XML-aanvraagdata als base64 |

**Wat Frank doet:**
1. Decodeert de XML (base64 → leesbare XML)
2. Leest `aanvraagtype`, `omschrijving` en `vertrouwelijkheid` uit de `<globals>` sectie van de XML
3. Upload PDF naar Documenten API → ontvangt UUID
4. Upload XML naar Documenten API → ontvangt UUID
5. Genereert een `verzoekIdentificatie` (UUID)
6. Slaat alles op in de `INFO_CACHE` tabel:
   - REGISTRATIENUMMER = verzoekIdentificatie
   - VERTROUWELIJKHEID, AFZENDER (BSN), ONDERWERP (omschrijving), AANVRAAGTYPE
   - PDF_UUID, XML_UUID
   - AANVRAAG_XML (de volledige gedecodeerde XML, voor gebruik in stap 3)

**SOAP-response naar Kodison:**
- `verzoekIdentificatie` — UUID, te bewaren voor stap 2 en stap 3
- `pdfDocumentUrl` — DRC-url van het opgeslagen PDF-document
- `xmlDocumentUrl` — DRC-url van het opgeslagen XML-document

---

## Stap 2 — toevoegenVerzoekDocument (optioneel, herhaalbaar)

**SOAP-input van Kodison:**
| Veld | Inhoud |
|------|--------|
| `verzoekIdentificatie` | UUID uit stap 1 |
| `bestandsnaam` | Naam van de bijlage |
| `inhoud` | Bijlage als base64 |

**Wat Frank doet:**
1. Upload bijlage naar Documenten API → ontvangt UUID
2. Slaat UUID op in de `VERZOEK_BIJLAGEN` tabel

**SOAP-response:** DRC-url van de opgeslagen bijlage

> Stap 2 kan nul of meerdere keren worden aangeroepen. Elke aanroep voegt één bijlage toe.

---

## Stap 3 — indienenVerzoek

**SOAP-input van Kodison:**
| Veld | Inhoud |
|------|--------|
| `verzoekIdentificatie` | UUID uit stap 1 |

**Wat Frank doet:**
1. Leest alle metadata op uit `INFO_CACHE` (op basis van verzoekIdentificatie)
2. Leest alle bijlage-UUIDs op uit `VERZOEK_BIJLAGEN`
3. Verwijdert beide rijen uit de database (stateless na afloop)
4. Bouwt een productaanvraag-JSON en POST die naar de Objecten API
5. De Objecten API stuurt een notificatie naar ZAC via de Notificaties API
6. ZAC maakt automatisch een zaak aan

---

## De productaanvraag-JSON

Dit is de JSON die Frank naar de Objecten API POST (vereenvoudigd):

```json
{
  "type": "<objecttype url>",
  "record": {
    "typeVersion": 1,
    "startAt": "2026-07-01",
    "data": {
      "bron": {
        "naam": "WebformulierenVerwerker",
        "kenmerk": "<verzoekIdentificatie>"
      },
      "type": "webformulier-aanvraag",
      "zaakgegevens": {
        "omschrijving": "Aanvraag leerlingenvervoer voor Jan Staart"
      },
      "aanvraaggegevens": { ... },
      "betrokkenen": [
        {
          "inpBsn": "123456789",
          "rolOmschrijvingGeneriek": "initiator"
        }
      ],
      "pdf":     "http://.../enkelvoudiginformatieobjecten/<pdf-uuid>",
      "csv":     "http://.../enkelvoudiginformatieobjecten/<xml-uuid>",
      "bijlagen": [
        "http://.../enkelvoudiginformatieobjecten/<bijlage-uuid>"
      ]
    }
  }
}
```

### Veldtoelichting

| Veld | Waarde | Bron |
|------|--------|------|
| `type` | URL van het Productaanvraag-Dimpact objecttype | `zac.objecten.objecttype` in properties |
| `data.type` | Aanvraagtype bijv. `webformulier-aanvraag` | `<globals><aanvraagtype>` in de XML |
| `data.zaakgegevens.omschrijving` | Omschrijving van de aanvraag | `<globals><omschrijving>` in de XML (fallback: `"Aanvraag " + aanvraagtype`) |
| `data.aanvraaggegevens` | Formulierinhoud als JSON-object | Zie hieronder |
| `data.betrokkenen[0].inpBsn` | BSN van de aanvrager | `afzenderbsn` uit SOAP stap 1 |
| `data.pdf` | URL naar PDF-document in Documenten API | Opgeslagen in INFO_CACHE.PDF_UUID |
| `data.csv` | URL naar XML-aanvraagdata in Documenten API | Opgeslagen in INFO_CACHE.XML_UUID |
| `data.bijlagen` | URLs naar bijlagen in Documenten API | Opgeslagen in VERZOEK_BIJLAGEN |

---

## Overdracht van JSON-zaakdata: het `aanvraaggegevens` veld

De formulierinhoud (alle antwoorden van de burger) wordt overgedragen via het **`aanvraaggegevens`** veld in de productaanvraag-JSON.

**Hoe het werkt:**
1. Kodison stuurt de formulierdata als XML (base64) in stap 1
2. Frank decodeert de XML en slaat die op in `INFO_CACHE.AANVRAAG_XML`
3. In stap 3 parseert Frank de XML en serialiseert de relevante secties als JSON

**Wat er in `aanvraaggegevens` zit:**
- Alle secties uit de `<answers>` van het formulier (behalve systeemblokken)
- Gefilterd: secties die beginnen met `sc`, `digid`, of heten `globals` worden weggelaten
- Veldniveau-filter: Atabix-systeemvelden (`digid*`, `stuf`, `nps*`, `sss_*`, `procstuf*`, `xslt_*`, `xsp_*`, `*efautogen*`) worden weggelaten
- Resultaat: een geneste JSON-structuur met de zuivere gebruikersdata

**Voorbeeld:**
```json
"aanvraaggegevens": {
  "aanvraaggegevens": {
    "naamKind": "Jan Staart",
    "geboortedatumKind": "2018-03-15",
    "adresVanSchool": "Schoolstraat 1"
  }
}
```

---

## Database (tijdelijke opslag tussen de drie stappen)

| Tabel | Kolommen | Doel |
|-------|----------|------|
| `INFO_CACHE` | REGISTRATIENUMMER (PK), VERTROUWELIJKHEID, AFZENDER, ONDERWERP, AANVRAAGTYPE, PDF_UUID, XML_UUID, AANVRAAG_XML, STOREDATE | Metadata van stap 1, gelezen in stap 3 |
| `VERZOEK_BIJLAGEN` | REGISTRATIENUMMER, BIJLAGE_UUID | Bijlage-UUIDs van stap 2, gelezen in stap 3 |

Na stap 3 worden beide tabellen opgeschoond voor het betreffende verzoek.

---

## Bestanden

| Bestand | Doel |
|---------|------|
| `Configuration_AanmakenVerzoekNatuurlijkPersoon.xml` | Stap 1 adapter |
| `Configuration_ToevoegenVerzoekDocument.xml` | Stap 2 adapter |
| `Configuration_IndienenVerzoek.xml` | Stap 3 adapter |
| `xsl/IndienenVerzoek/productaanvraag_request.xsl` | Bouwt de productaanvraag-JSON |
| `xsl/AanmakenVerzoekNatuurlijkPersoon/uploadPdf_request.xsl` | JSON-body voor PDF-upload |
| `xsl/AanmakenVerzoekNatuurlijkPersoon/uploadXml_request.xsl` | JSON-body voor XML-upload |
| `DeploymentSpecifics.properties` | ZAC API URLs en bronorganisatie |
| `src/main/secrets/credentials.properties` | ZAC JWT-secret en Objecten API token (gitignored) |
| `DatabaseChangelog.xml` | Liquibase schema: INFO_CACHE + VERZOEK_BIJLAGEN |
