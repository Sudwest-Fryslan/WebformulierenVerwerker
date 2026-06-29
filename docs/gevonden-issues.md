# Gevonden issues tijdens ZAC-koppeling

Issues gevonden tijdens het opzetten en testen van de ZAC-koppeling (feature/zac-koppeling).
Kunnen worden gemeld als bugs of verbeteringen in de respectievelijke projecten.

---

## dimpact-zaakafhandelcomponent (ZAC)

### ISSUE-1: ZTC cache wordt niet automatisch geleegd na Open Zaak config-wijzigingen

**Project:** dimpact-zaakafhandelcomponent
**Type:** Bug / UX-verbetervoorstel

**Beschrijving:**
ZAC cached statustypen, zaaktypen en andere ZTC-data via Infinispan JCache. Als je in Open Zaak
een nieuw statustype toevoegt (bijv. 'Intake') aan een gepubliceerd zaaktype, gebruikt ZAC nog
de gecachte (verouderde) lijst. Dit leidt tot fouten als:

```
StatusTypeNotFoundException: Status type with description 'Intake' not found
for zaaktype with URI: 'http://openzaak.local:8000/catalogi/api/v1/zaaktypen/...'
```

De fout is bijzonder misleidend: het statustype bestaat aantoonbaar in Open Zaak (via API
opvraagbaar), maar ZAC vindt het niet doordat de cache verouderd is.

**Workaround:**
```bash
curl -X DELETE "http://localhost:8080/rest/health-check/ztc-cache" \
  -H "Authorization: Bearer <keycloak-beheerder-token>"
```

**Voorstel:**
- Toon een duidelijkere foutmelding die aangeeft dat het een cachingprobleem kan zijn
- Of: zorg dat de cache automatisch wordt geleegd wanneer Open Zaak een notificatie stuurt
  over een gewijzigd zaaktype/statustype

---

### ISSUE-2: StatusTypeNotFoundException geeft geen hint over caching

**Project:** dimpact-zaakafhandelcomponent
**Type:** Verbetervoorstel (DX)
**Gerelateerd aan:** ISSUE-1

**Beschrijving:**
De foutmelding `StatusTypeNotFoundException: Status type with description 'Intake' not found`
geeft geen enkele hint dat de oorzaak een verouderde cache kan zijn. Ontwikkelaars
verliezen veel tijd met debuggen van de Open Zaak-configuratie terwijl de werkelijke
oorzaak de ZTC-cache is.

**Voorstel:**
Voeg in de exception message of het log-statement een hint toe:
> "Status type 'Intake' not found. If the status type was recently added to Open Zaak,
> try clearing the ZTC cache via DELETE /rest/health-check/ztc-cache"

**Code-locatie:**
`src/main/kotlin/nl/info/client/zgw/shared/ZgwApiService.kt` — `readStatustype()` rond regel 357-365

---

### ISSUE-3: CMMN model 'generiek-zaakafhandelmodel' vereist statustype 'Intake' — niet gedocumenteerd

**Project:** dimpact-zaakafhandelcomponent
**Type:** Documentatie-issue

**Beschrijving:**
Als je een zaaktype aanmaakt in Open Zaak en koppelt aan het `generiek-zaakafhandelmodel` in ZAC,
moet het zaaktype een statustype met de naam `Intake` hebben. Dit is nergens gedocumenteerd.
Zonder dit statustype faalt het aanmaken van elke zaak met een cryptische exception.

**Voorstel:**
Voeg toe aan de ZAC-documentatie / zaakafhandelparameters UI:
> "Vereiste statustypen voor het generiek zaakafhandelmodel: Intake, In behandeling, Afgerond (of Eindstatus)"

---

## Open Zaak

### ISSUE-4: PostgreSQL sequences niet gereset na initieel laden van testdata

**Project:** Open Zaak (dimpact-zaakafhandelcomponent docker-compose setup)
**Type:** Bug in Docker setup

**Beschrijving:**
Na het initieel laden van Open Zaak testdata (via fixtures) zijn de PostgreSQL sequences
niet correct gereset. Hierdoor kan het aanmaken van nieuwe objecten (zaaktypen, statustypen,
etc.) mislukken met een `duplicate key value violates unique constraint` fout.

**Workaround:**
```powershell
docker exec dimpact-zaakafhandelcomponent-openzaak.local-1 python /app/src/manage.py sqlsequencereset catalogi 2>&1 |
  Where-Object { $_ -match "^SELECT|^BEGIN|^COMMIT|^--" } |
  docker exec -i dimpact-zaakafhandelcomponent-openzaak-database-1 psql -U openzaak openzaak
```

---

### ISSUE-5: Statustypen toevoegen via Open Zaak API lukt niet voor gepubliceerde zaaktypen

**Project:** Open Zaak
**Type:** Onduidelijk gedrag / documentatie

**Beschrijving:**
Gepubliceerde zaaktypen in Open Zaak kunnen normaal gesproken niet worden gewijzigd.
Statustypen toevoegen via de Catalogi API (`POST /catalogi/api/v1/statustypen`) faalt
als het zaaktype al gepubliceerd is.

Echter: het toevoegen via de Django shell (`manage.py shell`) werkt wel, ook voor
gepubliceerde zaaktypen. Dit is inconsistent en omzeilt de API-validatie.

**Workaround:**
Gebruik de Django shell (of Django admin) om statustypen toe te voegen aan gepubliceerde zaaktypen.

**Voorstel:**
Documenteer hoe statustypen kunnen worden toegevoegd aan gepubliceerde zaaktypen, of bied
een "concept maken" → "aanpassen" → "opnieuw publiceren" workflow aan in de admin-UI.

---

## Frank!Framework / WebformulierenVerwerker

### ISSUE-6: Objecten API gebruikt Token-authenticatie, niet JWT Bearer

**Project:** WebformulierenVerwerker-zac (Frank!Framework configuratie)
**Type:** Documentatie / configuratie-valkuil

**Beschrijving:**
De Objecten API (Django REST Framework) gebruikt `Token <waarde>` authenticatie, niet
`Bearer <JWT>` zoals Open Zaak. Dit verschil is niet duidelijk gedocumenteerd. Pogingen
om de Open Zaak JWT te gebruiken voor de Objecten API resulteren in HTTP 401.

**Token-formaat voor Objecten API:**
```
Authorization: Token cd63e158f3aca276ef284e3033d020a22899c728
```

**Configuratie:**
Property `zac.objecten.token` in `DeploymentSpecifics.properties`

---

### ISSUE-7: objecttypes-api container draait niet standaard mee

**Project:** dimpact-zaakafhandelcomponent Docker Compose setup
**Type:** Configuratie-valkuil

**Beschrijving:**
De `objecttypes-api` container zit onder het Docker Compose profile `openformulieren`,
niet onder `objecten`. De Objecten API container heeft de objecttypes-api nodig voor
typevalidatie bij POST requests. Als objecttypes-api niet draait, mislukt elke POST
naar de Objecten API met:
```json
{"non_field_errors": ["Object type version can not be retrieved."]}
```

**Workaround:**
```bash
COMPOSE_PROFILES=openformulieren APP_ENV=devlocal OTEL_SDK_DISABLED=true \
  docker compose up -d objecttypes-api objecttypes-api-database objecttypes-api-import
```

**Voorstel:**
Voeg `objecttypes-api` toe als dependency van de `objecten` profile, of documenteer
dit als vereiste bij de ZAC-koppeling setup.

---

### ISSUE-8: Open Notificaties draait niet mee in standaard ZAC docker-compose profiel

**Project:** dimpact-zaakafhandelcomponent Docker Compose setup
**Type:** Configuratie-valkuil

**Beschrijving:**
Open Notificaties zit onder het profile `opennotificaties`. Zonder Open Notificaties
ontvangt ZAC nooit de webhook-notificatie van de Objecten API over een nieuw object,
waardoor de productaanvraag-flow nooit wordt gestart. Er is geen foutmelding — ZAC
blijft gewoon stil.

**Workaround:**
```bash
COMPOSE_PROFILES=opennotificaties APP_ENV=devlocal OTEL_SDK_DISABLED=true \
  docker compose up -d opennotificaties opennotificaties-database \
  opennotificaties-celery opennotificaties-init
```

**Voorstel:**
Documenteer dat `opennotificaties` vereist is voor de productaanvraag/webformulieren-flow.

---

### ISSUE-9: ZAC JWT token verloopt snel, geen automatische verlenging

**Project:** WebformulierenVerwerker-zac (Frank!Framework configuratie)
**Type:** Verbetervoorstel

**Beschrijving:**
De Open Zaak JWT tokens (`iat`-based, HS256) verlopen snel. In de huidige implementatie
staat het token als statische property in `DeploymentSpecifics.properties`. Hierdoor
moeten tokens handmatig worden vernieuwd bij elke ontwikkelsessie.

**Voorstel:**
Implementeer dynamische JWT-generatie in Frank!Framework:
- Genereer een nieuw token bij elke request (of cache met korte TTL)
- Gebruik `clientId` + `secret` als configuratie-properties i.p.v. het token zelf

---

---

## Frank!Framework / WebformulierenVerwerker (XML/XSL bugs)

### ISSUE-10: Frank!Framework 10.2.0 bug: XML-declaratie in `method="text"` output ondanks `omitXmlDeclaration="true"`

**Project:** WebformulierenVerwerker-zac / Frank!Framework
**Type:** Bug in Frank!Framework 10.2.0

**Beschrijving:**
Frank!Framework 10.2.0 voegt altijd `<?xml version="1.0" encoding="UTF-8"?>` toe als prefix
wanneer een XSLT stylesheet `method="text"` gebruikt — ook als `omitXmlDeclaration="true"` is
ingesteld op de XsltPipe. Dit maakt de output ongeldig als JSON.

Open Zaak DRC geeft bij een dergelijke request:
```
{"detail": "JSON parse error - Expecting value: line 1 column 1 (char 0)"}
```

**Geverifieerd:** echo-server bevestigde dat de request body begon met
`<?xml version="1.0" encoding="UTF-8"?>{"bronorganisatie": "..."}`.

**Oorzaak:**
Frank!Framework 10.2.0 serialiseert `method="text"` XSLT-output altijd als XML-document
(inclusief declaratie), ongeacht het pipe-attribuut `omitXmlDeclaration`.

**Fix:**
XSLT output method omgezet naar `method="xml" omit-xml-declaration="yes"` met de JSON gewrapped
in een XML-element `<json>`. Daarna een extra `XsltPipe xpathExpression="string(json)"` toegevoegd
om de pure JSON-string te extraheren.

**Gewijzigde bestanden:**
- `xsl/AanmakenVerzoekNatuurlijkPersoon/uploadPdf_request.xsl`
- `xsl/AanmakenVerzoekNatuurlijkPersoon/uploadXml_request.xsl`
- `Configuration_AanmakenVerzoekNatuurlijkPersoon.xml` (Extract_UploadPdf_Json en Extract_UploadXml_Json pipes toegevoegd)

---

### ISSUE-11: `formaat` veld ontbrak in upload-request voor bijlagen

**Project:** WebformulierenVerwerker-zac
**Type:** Bug

**Beschrijving:**
De Documenten API vereist het `formaat` veld (MIME-type) bij het uploaden van documenten.
Dit ontbrak in `uploadBijlage_request.xsl`, waardoor uploads van bijlagen faalden.

**Fix:**
`formaat` veld toegevoegd aan `uploadBijlage_request.xsl`, afgeleid van de bestandsextensie.

---

### ISSUE-12: Incorrecte objecttype URL in configuratie (`host.docker.internal` i.p.v. interne hostname)

**Project:** WebformulierenVerwerker-zac
**Type:** Configuratie-bug

**Beschrijving:**
De configuratie-property `zac.objecten.objecttype` gebruikte `http://host.docker.internal:8011/...`
als URL voor het objecttype in de Objecten API. Vanuit de objecten-api container is
`host.docker.internal` niet bereikbaar voor validatie.

**Fix:**
URL aangepast naar de interne Docker-hostname:
```
http://objecttypes-api:8000/api/v2/objecttypes/021f685e-9482-4620-b157-34cd4003da6b
```

---

### ISSUE-13: `Content-Crs` header vereist door Objecten API

**Project:** WebformulierenVerwerker-zac
**Type:** Bug / ontbrekende documentatie

**Beschrijving:**
De Objecten API vereist de header `Content-Crs: EPSG:4326` bij POST-requests.
Dit was niet gedocumenteerd en ontbrak in de initiële Frank!Framework configuratie.
Zonder deze header weigerde de Objecten API het verzoek.

**Fix:**
`Content-Crs: EPSG:4326` header toegevoegd aan de HttpSender in `Configuration_IndienenVerzoek.xml`.

---

---

### ISSUE-14: Statustype 'Intake' met hoog volgnummer wordt automatisch als eindstatus behandeld

**Project:** Open Zaak / dimpact-zaakafhandelcomponent setup
**Type:** Valkuil / onduidelijk gedrag

**Beschrijving:**
In Open Zaak wordt de `is_eindstatus` van een statustype (in deze versie) bepaald door het volgnummer:
het statustype met het **hoogste volgnummer** wordt behandeld als eindstatus.
Toen 'Intake' werd aangemaakt met `statustypevolgnummer=4` (hoger dan 'Afgerond' met volgnr=3),
werd Intake de eindstatus. ZAC kon daarna geen zaak aanmaken:

```
ZgwValidationErrorException: eindstatus-not-allowed
Het is niet toegestaan om een zaak te sluiten via deze endpoint
```

**Fix:**
Volgnummer van 'Intake' gewijzigd naar 0 (vóór alle andere statustypen):
- Intake (volgnr 0) — initiële status
- Ontvangen (volgnr 1)
- In behandeling (volgnr 2)
- Afgerond (volgnr 3) — eindstatus

**Workaround:**
```python
# Django shell in openzaak container
intake = StatusType.objects.get(zaaktype=zt, statustype_omschrijving='Intake')
intake.statustypevolgnummer = 0
intake.save()
```
Daarna ZTC cache legen via `DELETE /rest/health-check/ztc-cache`.

---

---

### ISSUE-15: PDF-koppeling aan zaak mislukt door onbekende DRC service URL

**Project:** dimpact-zaakafhandelcomponent / Open Zaak setup
**Type:** Configuratie-valkuil

**Beschrijving:**
Frank!Framework uploadt documenten via `http://host.docker.internal:8001/documenten/...`.
Open Zaak geeft de document-URL terug met diezelfde hostname.
Wanneer ZAC daarna de zaak-informatieobjectkoppeling aanmaakt, stuurt het die URL door:
```
POST /zaken/api/v1/zaakinformatieobjecten
{ "informatieobject": "http://host.docker.internal:8001/documenten/api/v1/..." }
```
Open Zaak valideert of de URL een bekende DRC service is. `host.docker.internal:8001` staat
niet geregistreerd → `[unknown-service] De service voor deze URL is niet bekend`.

**Fix:**
DRC service toevoegen via Django shell:
```python
from zgw_consumers.models import Service
from zgw_consumers.constants import APITypes
Service.objects.create(
    label='Open Zaak DRC host.docker.internal',
    slug='openzaak-drc-host-docker',
    api_root='http://host.docker.internal:8001/documenten/api/v1/',
    api_type=APITypes.drc,
    auth_type='no_auth'
)
```
Daarna ZTC cache legen.

---

### ISSUE-16: hosts file met LAN IP is locatie-afhankelijk

**Project:** dimpact-zaakafhandelcomponent (installatie-documentatie)
**Type:** Documentatie-valkuil

**Beschrijving:**
De ZAC-documentatie (`installDockerCompose.md`) instrueert om `host.docker.internal` toe te voegen
aan de hosts file, maar specificeert niet welk IP-adres gebruikt moet worden.
Als een ontwikkelaar het eigen LAN IP (bijv. `192.168.1.171`) invult in plaats van `127.0.0.1`,
werkt de setup alleen op die specifieke locatie/netwerk. Op kantoor, thuis of via VPN
is het LAN IP anders, waardoor:
- Keycloak niet meer bereikbaar is via de browser (`http://host.docker.internal:8081`)
- Login mislukt met een cryptische netwerkfout

**Workaround:**
Gebruik altijd `127.0.0.1` (localhost) voor `host.docker.internal` in de hosts file:
```
127.0.0.1 host.docker.internal
```

**Voorstel:**
Verander de documentatie om expliciet `127.0.0.1` voor te schrijven, niet een LAN IP.

---

### ISSUE-17: Solr-index loopt niet meer in sync na CMMN-fouten bij zaak aanmaken

**Project:** dimpact-zaakafhandelcomponent
**Type:** Bug / betrouwbaarheid

**Beschrijving:**
Als het aanmaken van een zaak in ZAC mislukt door CMMN-fouten (bijv. `eindstatus-not-allowed`,
`unknown-service`), wordt de zaak wél aangemaakt in Open Zaak maar NIET geïndexeerd in Solr.
Dit leidt tot een stille desynchronisatie:
- De zaak is opvraagbaar via de Open Zaak API
- Maar is niet zichtbaar in de ZAC-zoekresultaten
- Geen foutmelding suggereert dat er iets mis is met de index

**Reproduceerstappen:**
1. Maak een zaak aan met een zaaktype waarbij het CMMN-model fouten bevat
2. De zaak verschijnt in Open Zaak maar niet in ZAC zoekresultaten

**Workaround:**
Herindexeer Solr handmatig via het interne endpoint:
```bash
curl -X GET "http://localhost:8080/rest/internal/indexeren/herindexeren/ZAAK" \
  -H "X-API-KEY: <waarde uit .env: ZAC_INTERNAL_ENDPOINTS_API_KEY>"
```

**Voorstel:**
- Log een waarschuwing wanneer Solr-indexering mislukt, inclusief de zaak-UUID
- Of: implementeer een periodieke consistentiecheck tussen Open Zaak en Solr

---

### ISSUE-18: Behandelaar ziet lege zaaktype-lijst op aanmaken-pagina

**Project:** dimpact-zaakafhandelcomponent
**Type:** UX-probleem

**Beschrijving:**
De pagina `/zaken/create` is bereikbaar voor gebruikers met de `behandelaar`-rol,
maar de endpoint `/rest/zaken/zaaktypes-for-creation` geeft een lege lijst terug.
Hierdoor is het formulier volledig onbruikbaar: geen zaaktype-opties, geen foutmelding.

De gebruiker ziet een leeg "Zaaktype"-veld en kan niets doen.

**Oorzaak:**
De `behandelaar`-rol heeft geen recht om zaken aan te maken; dat is voorbehouden aan
`coordinator` of `beheerder`. Maar de UI geeft hier geen duidelijke melding over.

**Voorstel:**
- Toon een duidelijke melding als de gebruiker geen zaaktypen mag aanmaken
- Of: verberg de "Zaak aanmaken" knop voor gebruikers die dat recht niet hebben

---

### ISSUE-19: `PropertyFileCredentialFactory` credentials niet toegankelijk via `${property}` substitutie

**Project:** WebformulierenVerwerker-zac / Frank!Framework
**Type:** Configuratie-valkuil

**Beschrijving:**
Wanneer `credentialFactory.class=org.frankframework.credentialprovider.PropertyFileCredentialFactory`
wordt gebruikt, zijn de waarden uit `credentials.properties` NIET beschikbaar via de normale
`${property.name}` substitutie in pipe-attributen (bijv. `secret="${zac.api.secret}"`).
De property resolveert naar een lege string, waardoor pipes falen.

**Voorbeeld fout:**
```
java.lang.IllegalArgumentException: Empty key at javax.crypto.spec.SecretKeySpec.<init>
```

**Fix voor `HashPipe`:**
Gebruik `authAlias` in plaats van `secret="${...}"`:
```xml
<!-- Fout: -->
<HashPipe name="ComputeHmac" secret="${zac.api.secret}" .../>
<!-- Goed: -->
<HashPipe name="ComputeHmac" authAlias="zac.api.secret" .../>
```

**Fix voor andere pipes/params:**
Voor `Param name="Authorization" value="Token ${zac.objecten.token}"` is geen directe
`authAlias`-variant beschikbaar. Workaround: voeg de property toe aan `DeploymentSpecifics.properties`
zodat het WEL via `${...}` opgelost kan worden (niet ideaal voor production-secrets).

**Gewijzigd bestand:**
`Configuration_ZacJwtToken.xml` — HashPipe gebruikt nu `authAlias="zac.api.secret"`

---

### ISSUE-20: `zac.api.client_id` ontbrak in Docker image `DeploymentSpecifics.properties`

**Project:** WebformulierenVerwerker-zac
**Type:** Ontbrekende configuratie in Docker image

**Beschrijving:**
De property `zac.api.client_id` (de JWT `iss`/`client_id` claim voor Open Zaak) was aanwezig
in de lokale broncode maar niet in het gebouwde Docker image. Hierdoor resolveert
`${zac.api.client_id}` naar een lege string in de `BuildPayloadJson` XsltPipe, waardoor
de JWT een leeg `client_id` bevat:
```json
{"iss":"","iat":...,"client_id":"","user_id":"","user_representation":""}
```

Open Zaak geeft dan: `"Client identifier bestaat niet"` (HTTP 403), ook al is de user
wél geregistreerd.

**Fix:**
`zac.api.client_id=webformulierenverwerker` toegevoegd aan `DeploymentSpecifics.properties`.

---

### ISSUE-21: Objecttype URL mismatch: `host.docker.internal` vs. `objecttypes-api` hostnaam

**Project:** WebformulierenVerwerker-zac / dimpact-zaakafhandelcomponent Docker Compose setup
**Type:** Configuratie-bug

**Beschrijving:**
De Objecten API slaat objecttype-URLs intern op als `http://objecttypes-api:8000/...` (Docker
service naam). Wanneer Frank!Framework een POST stuurt met
`"type": "http://host.docker.internal:8011/..."`, vindt de Objecten API geen overeenkomst
in de permissietabel en weigert het request:
```json
{"detail": "You do not have permission to perform this action."}
```

De waarde van `zac.objecten.objecttype` in `DeploymentSpecifics.properties` bepaalt welke
URL in de POST body wordt gezet. Deze URL hoeft door Frank!Framework NIET bereikbaar te zijn
(het is alleen een identificatie-string), maar moet EXACT overeenkomen met de URL zoals
opgeslagen in de Objecten API-database.

**Fix:**
```properties
# Fout:
zac.objecten.objecttype=http://host.docker.internal:8011/api/v2/objecttypes/021f685e-...
# Goed:
zac.objecten.objecttype=http://objecttypes-api:8000/api/v2/objecttypes/021f685e-...
```

---

*Bijgewerkt: 29-06-2026*
