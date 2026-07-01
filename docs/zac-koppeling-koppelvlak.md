# Koppelvlakspecificatie: Kodison → WebformulierenVerwerker → ZAC

Technische afspraken tussen het Kodison-webformuliersysteem (Hein) en de WebformulierenVerwerker voor het aanmaken van zaken in ZAC.

Bijgewerkt: 02 juli 2026.

---

## Samenvatting

Kodison roept drie SOAP-operaties aan in volgorde. De WebformulierenVerwerker slaat documenten op in Open Zaak (Documenten API) en plaatst daarna een productaanvraag in de Objecten API. ZAC pikt dit automatisch op via een notificatie en maakt de zaak aan.

```
Stap 1  aanmakenVerzoekNatuurlijkPersoon   →  upload PDF + XML, ontvang verzoekIdentificatie
Stap 2  toevoegenVerzoekDocument           →  upload bijlage (0..n keer herhaalbaar)
Stap 3  indienenVerzoek                    →  dien de aanvraag in, zaak wordt aangemaakt in ZAC
```

---

## Waarom werkt het zo? — De architectuurkeuze

### Uitgangspunt: zo stateless mogelijk

Het uitgangspunt bij het ontwerp van de ZAC-koppeling is dat de WebformulierenVerwerker zo **stateless** mogelijk moet werken — net zoals de bestaande Corsa-koppeling. Geen opgeslagen toestand, geen database-afhankelijkheid, gewoon een pass-through die een SOAP-bericht omzet naar API-calls.

**Toch slaat de WebformulierenVerwerker tijdelijk gegevens op.** Hieronder staat precies waarom dat onvermijdelijk is en waarom de opgeslagen hoeveelheid zo klein mogelijk is gehouden.

---

### Beperking 1: ZAC reageert eenmalig op het aanmaken van het productaanvraag-object

ZAC luistert via de **Notificaties API** naar events op de Objecten API. Zodra een nieuw object wordt aangemaakt (`POST`) met objecttype `Productaanvraag-Dimpact`, ontvangt ZAC een notificatie, leest het object, bepaalt het zaaktype op basis van `data.type`, en maakt de zaak aan — inclusief het koppelen van alle documenten die in het object staan (`pdf`, `csv`, `bijlagen`).

> **ZAC reageert op de aanmaak (CREATE-event) — niet op latere updates (PATCH/PUT).**

Dit heeft een directe implicatie: het productaanvraag-object in de Objecten API mag **pas worden aangemaakt als alle documenten al klaarstaan** in de Documenten API. Anders maakt ZAC een zaak aan zonder de bijlagen die er nog niet in zitten. Latere updates aan het object bereiken ZAC niet meer.

Het is dus onmogelijk om alvast een "leeg" productaanvraag-object in de Objecten API te zetten en dat later te completeren. De ene POST in stap 3 moet alles bevatten.

---

### Beperking 2: Kodison doet drie losse SOAP-calls, maar de Objecten API verwacht één complete POST

Kodison stuurt de aanvraagdata in drie afzonderlijke SOAP-calls:
- Stap 1: PDF + XML (de kern van de aanvraag)
- Stap 2: Bijlagen (0..n keer, elk in een aparte call)
- Stap 3: De opdracht om in te dienen

Die drie calls kunnen minuten uit elkaar liggen. De WebformulierenVerwerker moet de resultaten van alle vorige calls kennen op het moment dat stap 3 binnenkomt, zodat hij de complete productaanvraag-JSON kan samenstellen.

**Hier is state onvermijdelijk.** Er is geen manier om de resultaten van stap 1 en stap 2 door te geven aan stap 3 zonder ze ergens tussentijds op te slaan — tenzij Kodison dat zelf doet.

---

### Waarom doet Kodison dat niet zelf? — De alternatieven

**Alternatief A: Kodison geeft alles opnieuw mee in stap 3**

Stap 3 zou alle verzamelde URLs en metadata kunnen ontvangen van Kodison:

```
indienenVerzoek(
  afzenderbsn, aanvraagtype, omschrijving, vertrouwelijkheid,
  pdfDocumentUuid, xmlDocumentUuid,
  bijlageUuids[]
)
```

Dit zou de WebformulierenVerwerker volledig stateless maken. Het is echter afgewezen omdat:

1. **De aanvraag-XML moet opnieuw worden verwerkt.** De `aanvraaggegevens` in de productaanvraag-JSON (de gefilterde formulierinhoud als JSON) worden gegenereerd uit de volledige XML-inhoud. Kodison zou die XML dus opnieuw moeten meesturen in stap 3 — terwijl die al als document is opgeslagen in Open Zaak. Dat is dubbele overdracht van soms grote bestanden.
2. **Kodison moet XML parsen.** De `aanvraagtype`, `omschrijving` en `vertrouwelijkheid` zitten embedded in de XML (in de `<globals>` sectie). Als Kodison die als losse velden meegeeft in stap 3, moet Kodison zelf de XML parsen — dat is logica die thuishoort in de WebformulierenVerwerker.
3. **Stap 3 wordt onnodig complex voor Kodison.** De huidige stap 3 is één veld (`verzoekIdentificatie`). Dat is bewust simpel gehouden.

**Alternatief B: de WebformulierenVerwerker haalt de XML op uit Open Zaak in stap 3**

Stap 3 ontvangt alleen de UUIDs van Kodison, en de verwerker haalt de XML-inhoud zelf op via de Documenten API. Dit vermijdt de dubbele overdracht. Maar ook dit is afgewezen omdat:

1. Het vereist nóg een API-call in stap 3 (Documenten API download), wat de latency verhoogt en een extra afhankelijkheid introduceert.
2. Kodison moet de UUIDs van stap 1 en 2 bijhouden en meegeven in stap 3 — dat is ook een vorm van toestandsbeheer, maar dan aan de Kodison-kant.

---

### Conclusie: minimale, tijdelijke state

De huidige oplossing slaat precies de minimale hoeveelheid op die nodig is:

| Wat wordt opgeslagen | Waarom |
|----------------------|--------|
| Document-UUIDs (PDF, XML) | Nodig in stap 3 voor de productaanvraag-JSON |
| BSN, aanvraagtype, omschrijving, vertrouwelijkheid | Uit de XML geëxtraheerd in stap 1; anders moet de XML opnieuw worden verwerkt in stap 3 |
| Aanvraag-XML (volledig) | Nodig in stap 3 om `aanvraaggegevens` te genereren (gefilterde formulierdata als JSON) |
| Bijlage-UUIDs (per bijlage uit stap 2) | Opgeslagen per stap-2-call; pas in stap 3 compleet |

**De state is strikt tijdelijk:** na stap 3 worden alle rijen direct verwijderd. Er blijft niets achter in de database. De WebformulierenVerwerker houdt na afloop geen toestand bij over de verwerkte aanvragen.

```
Stap 1  →  Documenten API (PDF + XML uploaden)
           INFO_CACHE ← BSN, aanvraagtype, omschrijving, vertrouwelijkheid, PDF_UUID, XML_UUID, aanvraag-XML

Stap 2  →  Documenten API (bijlage uploaden)
           VERZOEK_BIJLAGEN ← bijlage-UUID

Stap 3  →  INFO_CACHE + VERZOEK_BIJLAGEN lezen
           → productaanvraag-JSON samenstellen
           Objecten API ← POST  (triggert ZAC via Notificaties API)
           INFO_CACHE + VERZOEK_BIJLAGEN ← DELETE  (direct opruimen)
```

De `verzoekIdentificatie` die Kodison terugkrijgt uit stap 1 is geen ID uit ZAC of de Objecten API, maar een lokale UUID die de WebformulierenVerwerker zelf genereert als koppelsleutel tussen de drie SOAP-calls. Na stap 3 heeft die UUID geen betekenis meer.

### Wanneer komt ZAC in actie?

Uitsluitend op het moment van de POST in stap 3 — nooit eerder. Tot dat moment weet ZAC niet eens dat er een aanvraag in behandeling is.

---

### Wat gebeurt er als stap 3 nooit wordt aangeroepen?

Als Kodison na stap 1 (en eventueel stap 2) stap 3 nooit aanroept — door een fout in Kodison, een sessie-timeout, of een gebruiker die halverwege afhaakt — blijven de tussenliggende gegevens in de database staan:

- **INFO_CACHE**: de metadata en de volledige aanvraag-XML blijven bewaard
- **VERZOEK_BIJLAGEN**: de bijlage-UUIDs blijven bewaard
- **Documenten API (Open Zaak)**: de geüploade documenten (PDF, XML, bijlagen) blijven bestaan als wees-documenten — zij zijn niet gekoppeld aan een zaak

Er wordt **geen zaak aangemaakt** in ZAC — stap 3 is de enige trigger daarvoor. De situatie is dus niet verkeerd afgelopen voor de burger, maar de geüploade documenten zijn niet verwerkt en de tussenliggende data neemt ruimte in.

**Oplossing: nachtelijkse opruiming**

De WebformulierenVerwerker draait elke nacht om 02:00 een cleanup-adapter (`CleanupVerlopenVerzoeken`) die entries ouder dan 7 dagen verwijdert uit INFO_CACHE en VERZOEK_BIJLAGEN. De bijbehorende documenten in Open Zaak worden hierbij **niet** automatisch verwijderd — dat valt buiten de scope van de WebformulierenVerwerker.

De bewaartermijn van 7 dagen is gekozen zodat:
- Een tijdelijk technisch probleem bij Kodison zichzelf kan herstellen (bijv. retry volgende dag)
- De tussenliggende data niet onbeperkt groeit
- Er voldoende tijd is voor handmatig ingrijpen als dat nodig is

> **Aandachtspunt voor Kodison:** Als stap 3 om welke reden dan ook mislukt, moet Kodison de burger de mogelijkheid bieden de aanvraag opnieuw in te dienen (opnieuw starten vanaf stap 1). De `verzoekIdentificatie` uit een mislukte sessie mag niet worden hergebruikt.

---

**Endpoint:**
```
http://<host>:8090/WebformulierenVerwerker/services/GeneriekeFormulierAfhandeling
WSDL: http://<host>:8090/webcontent/WebformulierenVerwerker/GeneriekeFormulierAfhandeling.wsdl
```

---

## Stap 1 — `aanmakenVerzoekNatuurlijkPersoon`

### SOAP-request

```xml
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"
                  xmlns:tem="http://tempuri.org/">
  <soapenv:Body>
    <tem:aanmakenVerzoekNatuurlijkPersoon>
      <tem:afzenderbsn>123456789</tem:afzenderbsn>
      <tem:aanvraagpdfname>leerlingenvervoer-aanvraag.pdf</tem:aanvraagpdfname>
      <tem:aanvraagpdfdata><!-- PDF als base64 --></tem:aanvraagpdfdata>
      <tem:aanvraagxmlname>leerlingenvervoer-aanvraagdata.xml</tem:aanvraagxmlname>
      <tem:aanvraagxmldata><!-- XML als base64, zie hieronder --></tem:aanvraagxmldata>
    </tem:aanmakenVerzoekNatuurlijkPersoon>
  </soapenv:Body>
</soapenv:Envelope>
```

### Velden

| Veld | Type | Verplicht | Toelichting |
|------|------|-----------|-------------|
| `afzenderbsn` | string | ja | BSN van de burger die de aanvraag indient |
| `aanvraagpdfname` | string | ja | Bestandsnaam van het PDF-formulier (inclusief `.pdf`) |
| `aanvraagpdfdata` | base64Binary | ja | Ingevuld PDF-formulier als base64 |
| `aanvraagxmlname` | string | ja | Bestandsnaam van de XML-aanvraagdata (inclusief `.xml`) |
| `aanvraagxmldata` | base64Binary | ja | XML-aanvraagdata als base64 (zie XML-formaat hieronder) |

### SOAP-response

```xml
<tem:aanmakenVerzoekNatuurlijkPersoonResponse>
  <tem:verzoekIdentificatie>ac15001c-1234-5678-abcd-ef0123456789</tem:verzoekIdentificatie>
  <tem:pdfDocumentUrl>http://.../enkelvoudiginformatieobjecten/&lt;uuid&gt;</tem:pdfDocumentUrl>
  <tem:xmlDocumentUrl>http://.../enkelvoudiginformatieobjecten/&lt;uuid&gt;</tem:xmlDocumentUrl>
</tem:aanmakenVerzoekNatuurlijkPersoonResponse>
```

| Veld | Toelichting |
|------|-------------|
| `verzoekIdentificatie` | UUID waarmee stap 2 en stap 3 worden gekoppeld — bewaren! |
| `pdfDocumentUrl` | Volledige URL van het opgeslagen PDF-document in Open Zaak |
| `xmlDocumentUrl` | Volledige URL van de opgeslagen XML-aanvraagdata in Open Zaak |

---

## Stap 2 — `toevoegenVerzoekDocument` *(optioneel, herhaalbaar)*

Voeg één bijlage toe. Roep deze stap 0, 1 of meerdere keren aan vóór stap 3.

### SOAP-request

```xml
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"
                  xmlns:tem="http://tempuri.org/">
  <soapenv:Body>
    <tem:toevoegenVerzoekDocument>
      <tem:verzoekIdentificatie>ac15001c-1234-5678-abcd-ef0123456789</tem:verzoekIdentificatie>
      <tem:documenttype>Bijlage</tem:documenttype>
      <tem:vertrouwelijkheid>openbaar</tem:vertrouwelijkheid>
      <tem:filename>paspoort-jan-staart.pdf</tem:filename>
      <tem:filedata><!-- bijlage als base64 --></tem:filedata>
    </tem:toevoegenVerzoekDocument>
  </soapenv:Body>
</soapenv:Envelope>
```

### Velden

| Veld | Type | Verplicht | Toelichting |
|------|------|-----------|-------------|
| `verzoekIdentificatie` | string | ja | UUID uit de response van stap 1 |
| `documenttype` | string | ja | Beschrijving van het type bijlage (vrije tekst, wordt opgeslagen als `beschrijving` in Open Zaak) |
| `vertrouwelijkheid` | string | ja | Vertrouwelijkheidniveau: `openbaar`, `intern`, `vertrouwelijk`, `geheim`, `zeer_geheim` |
| `filename` | string | ja | Bestandsnaam (inclusief extensie) |
| `filedata` | base64Binary | ja | Bestand als base64 |

### SOAP-response

```xml
<tem:toevoegenVerzoekDocumentResponse>
  <tem:toevoegenVerzoekDocumentResult>http://.../enkelvoudiginformatieobjecten/&lt;uuid&gt;</tem:toevoegenVerzoekDocumentResult>
</tem:toevoegenVerzoekDocumentResponse>
```

---

## Stap 3 — `indienenVerzoek`

Sluit de aanvraag af. De WebformulierenVerwerker maakt de productaanvraag aan in de Objecten API, waarna ZAC automatisch een zaak aanmaakt.

### SOAP-request

```xml
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"
                  xmlns:tem="http://tempuri.org/">
  <soapenv:Body>
    <tem:indienenVerzoek>
      <tem:verzoekIdentificatie>ac15001c-1234-5678-abcd-ef0123456789</tem:verzoekIdentificatie>
    </tem:indienenVerzoek>
  </soapenv:Body>
</soapenv:Envelope>
```

### SOAP-response

```xml
<tem:indienenVerzoekResponse>
  <tem:indienenVerzoekResult>ac15001c-1234-5678-abcd-ef0123456789</tem:indienenVerzoekResult>
</tem:indienenVerzoekResponse>
```

Na een succesvolle response is de zaak aangemaakt in ZAC.

---

## XML-aanvraagdata (Atabix-formaat)

De `aanvraagxmldata` is de formulierdata van Atabix, base64-gecodeerd. Dit is het formaat dat Atabix standaard produceert.

### Volledig voorbeeld (vóór base64-codering)

```xml
<?xml version="1.0" encoding="UTF-8"?>
<FORMULIER>
  <FORMULIERID>Aanvraag Leerlingenvervoer</FORMULIERID>
  <DATUMVERZENDING>2026-01-29T09:35:46</DATUMVERZENDING>
  <ELEMENTEN>
    <form url="http://..." scenarioID="scLeerlingenVervoerV3" xml:lang="nl-nl">
      <answers uniqueId="1fcee389-69bb-4cbc-97ac-9b731dc236a5">

        <!-- VERPLICHT: globals-sectie met ZAC-metadata -->
        <globals>
          <aanvraagtype key="webformulier-aanvraag">webformulier-aanvraag</aanvraagtype>
          <omschrijving key="Aanvraag leerlingenvervoer voor Jan Staart">Aanvraag leerlingenvervoer voor Jan Staart</omschrijving>
          <vertrouwelijkheid key="openbaar">openbaar</vertrouwelijkheid>
          <!-- overige globals (dossiercode, behandelaar, etc.) worden genegeerd door de verwerker -->
        </globals>

        <!-- Formuliersecties: worden als JSON doorgegeven aan ZAC -->
        <fleerlgingenvervoerv3gegevensleerlling>
          <voornamen key="">Jan</voornamen>
          <achternaam key="">Staart</achternaam>
          <geboortedatum key="">01-01-2015</geboortedatum>
        </fleerlgingenvervoerv3gegevensleerlling>

        <fleerlgingenvervoerv3regulier>
          <naamschool key="">Testschool</naamschool>
          <postcode key="">8601CR</postcode>
        </fleerlgingenvervoerv3regulier>

        <fleerlgingenvervoerv3toelichting>
          <extratoelichting key="">Aanvullende informatie</extratoelichting>
        </fleerlgingenvervoerv3toelichting>

      </answers>
    </form>
  </ELEMENTEN>
</FORMULIER>
```

### Verplichte velden in `<globals>`

| Element | Toelichting | Voorbeeld |
|---------|-------------|-----------|
| `<aanvraagtype>` | Type aanvraag — **moet overeenkomen met de zaakafhandelparameters in ZAC** | `webformulier-aanvraag` |
| `<omschrijving>` | Zaakbeschrijving die in ZAC verschijnt | `Aanvraag leerlingenvervoer voor Jan Staart` |
| `<vertrouwelijkheid>` | Vertrouwelijkheidniveau van de documenten | `openbaar` |

> **Let op:** Als `<omschrijving>` leeg is, gebruikt de verwerker automatisch `"Aanvraag " + aanvraagtype` als fallback.

### Gefilterde velden

De verwerker filtert de XML automatisch. Nooit meegestuurd naar ZAC:
- De gehele `<globals>` sectie (alleen gebruikt voor metadata)
- Secties waarvan de naam begint met `sc` of `digid`
- Velden die beginnen met: `digid`, `nps`, `sss_`, `procstuf`, `xslt_`, `xsp_`
- Velden die `efautogen` bevatten
- Het systeemveld `stuf`

Alles wat overblijft wordt als JSON doorgegeven in het `aanvraaggegevens` veld van de productaanvraag.

---

## Verschillende formuliertypen

De koppeling is **generiek** — elk Atabix-formulier werkt zonder aanpassing aan de WebformulierenVerwerker, zolang de `globals` correct zijn ingevuld.

### Hoe een nieuw formuliertype aan ZAC toe te voegen

1. **Kodison (Hein):** Zet in de `<globals>` van het formulier:
   - `<aanvraagtype>` → de gewenste zaaktypeidentificatie (bijv. `aanvraag-gehandicaptenparkeerkaart`)
   - `<omschrijving>` → beschrijvende zin (bijv. `"Aanvraag gehandicaptenparkeerkaart voor Petra Visser"`)
   - `<vertrouwelijkheid>` → `openbaar` of ander niveau

2. **Open Zaak:** Maak een zaaktype aan met dezelfde identificatie als `aanvraagtype`.

3. **ZAC:** Voeg zaakafhandelparameters toe voor dit zaaktype (zaakafhandelmodel, groep, productaanvraagtype = de `aanvraagtype` waarde).

4. **WebformulierenVerwerker:** Geen aanpassingen nodig — de verwerker stuurt de `aanvraagtype` waarde door en ZAC zoekt het bijpassende zaaktype op.

### Voorbeeld: ander formuliertype

```xml
<globals>
  <aanvraagtype key="aanvraag-bijzondere-bijstand">aanvraag-bijzondere-bijstand</aanvraagtype>
  <omschrijving key="Aanvraag bijzondere bijstand voor Marie Jansen">Aanvraag bijzondere bijstand voor Marie Jansen</omschrijving>
  <vertrouwelijkheid key="vertrouwelijk">vertrouwelijk</vertrouwelijkheid>
</globals>
```

ZAC kijkt naar de waarde van `aanvraagtype` en gebruikt de zaakafhandelparameters die horen bij `aanvraag-bijzondere-bijstand`.

---

## Foutafhandeling

Bij een fout geeft de WebformulierenVerwerker een SOAP Fault terug:

```xml
<SOAP-ENV:Fault>
  <faultcode>SOAP-ENV:Server</faultcode>
  <faultstring>[aanmakenVerzoekNatuurlijkPersoon] Foutmelding van de backend</faultstring>
  <detail>
    <ErrorInfo>Technische details</ErrorInfo>
    <BackendResponse>Ruwe response van Documenten API / Objecten API</BackendResponse>
  </detail>
</SOAP-ENV:Fault>
```

De `faultstring` bevat altijd de operatienaam (tussen `[` en `]`) en de foutmelding. De `BackendResponse` bevat de ruwe respons van de achterliggende API.

**Veelvoorkomende fouten:**

| Situatie | Foutmelding |
|----------|-------------|
| Ongeldig BSN-formaat | HTTP 400 van Documenten API |
| Onbekend `aanvraagtype` | ZAC maakt geen zaak aan (geen SOAP fout in stap 3, maar zaak ontbreekt in ZAC) |
| `verzoekIdentificatie` niet gevonden in stap 2/3 | SQL: no rows returned |
| Verkeerde `vertrouwelijkheid` waarde | HTTP 400 van Documenten API |

---

## Technische details

### Volgorde is verplicht

Stap 2 en stap 3 vereisen de `verzoekIdentificatie` uit stap 1. Er is geen mogelijkheid om stap 3 aan te roepen zonder eerst stap 1 te hebben gedaan.

### Stateless na stap 3

Na een succesvolle `indienenVerzoek` (stap 3) worden alle tussenliggende gegevens verwijderd uit de database van de WebformulierenVerwerker. Een tweede aanroep van stap 3 met hetzelfde `verzoekIdentificatie` zal geen data meer vinden.

### Documenten in Open Zaak

| Document | MIME-type | Informatieobjecttype |
|----------|-----------|----------------------|
| PDF-formulier | `application/pdf` | Aanvraagformulier |
| XML-aanvraagdata | `application/xml` | Aanvraagformulier |
| Bijlagen (stap 2) | Vrij (bepaald door bestandsnaam) | Bijlage |

### Productaanvraag-JSON naar Objecten API

De WebformulierenVerwerker stuurt naar de Objecten API:

```json
{
  "type": "<objecttype url>",
  "record": {
    "typeVersion": 1,
    "startAt": "2026-07-01",
    "data": {
      "bron": { "naam": "WebformulierenVerwerker", "kenmerk": "<verzoekIdentificatie>" },
      "type": "<aanvraagtype uit globals>",
      "zaakgegevens": { "omschrijving": "<omschrijving uit globals>" },
      "aanvraaggegevens": { "<gefilterde formulierdata als JSON>" },
      "betrokkenen": [{ "inpBsn": "<afzenderbsn>", "rolOmschrijvingGeneriek": "initiator" }],
      "pdf":     "<url naar PDF in Documenten API>",
      "csv":     "<url naar XML in Documenten API>",
      "bijlagen": ["<url bijlage 1>", "<url bijlage 2>"]
    }
  }
}
```

ZAC koppelt de documenten automatisch aan de zaak via de velden `pdf`, `csv` en `bijlagen`.
