# ZAC-koppeling setup (feature/zac-koppeling)

Documentatie van de configuratie die gedaan is voor de ZAC-integratie.
Bijgewerkt: 28 juni 2026.

## Overzicht

Webformulieren van SWF worden verwerkt via de Frank!Framework WebformulierenVerwerker.
De flow is:

```
Kodison (burger) → Frank!Framework (poort 8090)
  → Documenten API (Open Zaak, poort 8001): PDF + XML opslaan
  → Objecten API (poort 8010): productaanvraag plaatsen
  → Notificaties API → ZAC (poort 8080): zaak aanmaken
```

## Open Zaak configuratie (http://localhost:8001/admin)

### Catalogus
- **Naam:** SWF Webformulieren
- **Domein:** SWF
- **RSIN:** 823288444
- **ID:** 2

### Informatieobjecttypen
| Naam | UUID | Gebruik |
|------|------|---------|
| Aanvraagformulier | `3db94ec7-8c34-4680-9f72-719a424be922` | PDF + XML van het webformulier |
| Bijlage | `0b682ad9-75aa-47a9-b3ec-395e3ee4d85e` | Overige bijlagen |

### Zaaktype
- **Naam:** Webformulier aanvraag
- **Identificatie:** `webformulier-aanvraag`
- **UUID:** `f21412fe-463b-40de-8bf9-ca619169a0eb`
- **Doel:** Verwerken van een aanvraag ingediend via een gemeentelijk webformulier
- **Selectielijst procestype:** 6 — Verzoeken behandelen
- **Statustypen:** Intake (0), Ontvangen (1), In behandeling (2), Afgerond (3)
  - Intake heeft volgnr 0 — dit is verplicht voor het generiek zaakafhandelmodel (zie ISSUE-3 en ISSUE-14)
- **Roltypen:** Initiator, Behandelaar
- **Resultaattype:** Afgehandeld
- **ZaakType-IOT koppelingen:** Aanvraagformulier (volgnr 1), Bijlage (volgnr 2)

### API-applicatie voor Frank!Framework
- **Label:** WebformulierenVerwerker
- **Client-ID:** `webformulierenverwerker`
- **Secret:** `webformulierenverwerkerSecret`
- **Autorisaties:** Heeft alle autorisaties (testomgeving)

JWT tokens worden **dynamisch gegenereerd** door de `ZacJwtToken` sub-adapter in Frank!Framework.
Geen handmatige tokengeneratie nodig — configureer alleen `zac.api.client_id` en `zac.api.secret`.

## ZAC configuratie (http://localhost:8080/admin)

### Zaakafhandelparameters — Webformulier aanvraag
- **CMMN model:** Generiek zaakafhandelmodel
- **Groep:** Test group behandelaars domein test 1
- **Productaanvraagtype:** `webformulier-aanvraag`
- **Mailafzender (default):** E-mailadres van de gemeente
- **Zaakbeëindiging:** "Zaak is niet ontvankelijk" → Afgehandeld
- **Valide:** true (bevestigd via REST API)

## Frank!Framework configuratie (http://localhost:8090)

### DeploymentSpecifics.properties (relevante ZAC-instellingen)
```properties
zac.documenten.url=http://host.docker.internal:8001/documenten/api/v1
zac.documenten.informatieobjecttype=http://host.docker.internal:8001/catalogi/api/v1/informatieobjecttypen/3db94ec7-8c34-4680-9f72-719a424be922
zac.documenten.informatieobjecttype.bijlage=http://host.docker.internal:8001/catalogi/api/v1/informatieobjecttypen/0b682ad9-75aa-47a9-b3ec-395e3ee4d85e
zac.objecten.url=http://host.docker.internal:8010/api/v2
# Let op: gebruik de interne Docker-hostname, niet host.docker.internal — moet overeenkomen
# met de URL zoals opgeslagen in de Objecten API-database (zie ISSUE-21)
zac.objecten.objecttype=http://objecttypes-api:8000/api/v2/objecttypes/021f685e-9482-4620-b157-34cd4003da6b
zac.bronorganisatie=823288444
zac.bron.naam=WebformulierenVerwerker
zac.api.client_id=webformulierenverwerker
```

### credentials.properties (gitignored — src/main/secrets/)
```properties
# JWT-generatie voor Documenten API (Open Zaak)
zac.api.secret=webformulierenverwerkerSecret
# Statisch token voor Objecten API (Django REST Framework: Token <waarde>)
zac.objecten.token=<token uit objecten-api admin>
```

### Adapters

| Adapter | Doel |
|---------|------|
| `ZacJwtToken` | Sub-adapter: genereert vers ZGW JWT Bearer token per aanvraag (HmacSHA256) |
| `aanmakenVerzoekNatuurlijkPersoon` | PDF + XML uploaden naar Documenten API; DRC-URLs + UUID terug naar Kodison |
| `toevoegenVerzoekDocument` | Bijlage uploaden naar Documenten API; DRC-URL terug naar Kodison |
| `indienenVerzoek` | Productaanvraag posten naar Objecten API → triggert ZAC via Notificaties API |

## Docker stack opstarten

De ZAC-stack heeft meerdere Docker Compose profiles:

```bash
# Alle benodigde services voor de ZAC-koppeling:
COMPOSE_PROFILES=zac,objecten APP_ENV=devlocal OTEL_SDK_DISABLED=true docker compose up -d

# Of via het script (vanuit WSL/Git Bash):
./start-docker-compose.sh -z -e -o
```

> **Let op:** Na een Docker Desktop herstart komen niet alle services automatisch terug.
> De `zac` service (WildFly) en `objecten` (Objecten API) hebben hun profile nodig.
> Controleer met `docker ps` of alle services draaien.

### Benodigde services
| Service | Poort | Profile |
|---------|-------|---------|
| ZAC (WildFly) | 8080 | `zac` |
| Open Zaak | 8001 | (default) |
| Keycloak | 8081 | (default) |
| Objecten API | 8010 | `objecten` |
| Objecttypen API | 8011 | `objecten` |
| Notificaties | - | `opennotificaties` |
| Frank!Framework | 8090 | apart project |

## ZAC ZTC cache legen (na config-wijzigingen)

Als je statustypen, informatieobjecttypen of zaaktypen wijzigt in Open Zaak, moet je de ZAC cache leegmaken. ZAC cached deze data via Infinispan JCache.

```bash
# Haal Keycloak token op (beheerder1newiam heeft beheer-rechten)
TOKEN=$(curl -s -X POST "http://localhost:8081/realms/zaakafhandelcomponent/protocol/openid-connect/token" \
  -d "grant_type=password&client_id=zaakafhandelcomponent&client_secret=keycloakZaakafhandelcomponentClientSecret&username=beheerder1newiam&password=beheerder1newiam" \
  | python3 -c "import json,sys; print(json.load(sys.stdin)['access_token'])")

# Flush ZTC cache
curl -X DELETE "http://localhost:8080/rest/health-check/ztc-cache" \
  -H "Authorization: Bearer $TOKEN"
```

## Bekende problemen

### PostgreSQL sequence bug
Na initieel laden van Open Zaak testdata zijn de sequences niet gereset.
Oplossing:
```powershell
docker exec dimpact-zaakafhandelcomponent-openzaak.local-1 python /app/src/manage.py sqlsequencereset catalogi 2>&1 |
  Where-Object { $_ -match "^SELECT|^BEGIN|^COMMIT|^--" } |
  docker exec -i dimpact-zaakafhandelcomponent-openzaak-database-1 psql -U openzaak openzaak
```

### Zaakafhandelparameters lijst leeg in UI
De lijst toont alleen zaaktypen die als "geldig" worden beschouwd (nuGeldig=true voor het zaaktype).
De parameters zelf zijn wél aanwezig — verifiëren via:
```
GET http://localhost:8080/rest/zaakafhandelparameters/f21412fe-463b-40de-8bf9-ca619169a0eb
```
