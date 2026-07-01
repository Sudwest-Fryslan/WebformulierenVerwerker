# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Project Does

WebformulierenVerwerker is a **Frank!Framework** ESB/integration application that acts as a SOAP bridge between Kodison (a web forms system) and Corsa (a document management system). It receives incoming SOAP requests, transforms them via XSLT, calls Corsa's web service, and returns transformed SOAP responses. It also integrates with CAReL and OpenZaakBrug.

This is a **configuration-driven application** — there is no custom Java code. All logic is expressed in Frank!Framework XML adapter configurations and XSLT stylesheets.

## Running Locally

```bash
# Development with hot-reload (preferred)
docker compose -f compose.frank.dev.yaml up --build --force-recreate --watch

# Production image
docker compose up
```

The app runs on **port 8090**. Mock services (for e2e tests) run on **port 8081**.

Hot-reload works via `ScanningDirectoryClassLoader` — changes to XML configs and XSL files are picked up automatically without restart.

## Testing

There are no unit tests. Testing is integration-based via **SoapUI**:
- `webformulierenverwerker-soapui-project.xml` — alle testcases (Corsa, CAReL, ZAC)

Use the **Ladybug** tool (built into Frank!Framework) for debugging message flows at runtime.

## Build / Release

Semantic-release is used with conventional commits. Version bumps are automatic:
- `feat:` → minor bump
- `fix:` → patch bump
- `BREAKING:` footer → major bump

The CI pipeline (`.github/workflows/ci-build.yml`) handles Docker image publishing and JAR artifact creation.

To create the configuration JAR manually:
```bash
jar cvf WebformulierenVerwerker.jar -C src/main/configurations WebformulierenVerwerker
```

## Architecture

### Request Flow

1. **Dispatcher** (`Configuration_WebformulierenVerwerkerDispatcher.xml`) — single SOAP listener validates against `GeneriekeFormulierAfhandeling.wsdl`, unwraps the SOAP envelope, and routes to action-specific adapters via XPath on the operation name.
2. **Action adapters** (e.g. `Configuration_OpslaanInkNatuurlijkPersoon.xml`) — each handles one operation end-to-end:
   - Transform incoming request to Corsa format (XSLT)
   - Connect to Corsa SOAP service
   - Query/create person or company record
   - Store document
   - Disconnect
   - Transform Corsa response back to Kodison format (XSLT)
3. **Common adapters** — shared logic for Corsa Connect/Disconnect and error handling (`xsl/Common/`).

### Key File Locations

| What | Where |
|------|-------|
| Main config entry point | `src/main/configurations/WebformulierenVerwerker/Configuration.xml` |
| Dispatcher (SOAP routing) | `Configuration_WebformulierenVerwerkerDispatcher.xml` |
| Corsa/CAReL adapters | `Configuration_Opslaan*.xml`, `Configuration_Version.xml`, `Configuration_Info.xml` |
| ZAC adapters | `Configuration_AanmakenVerzoekNatuurlijkPersoon.xml`, `Configuration_ToevoegenVerzoekDocument.xml`, `Configuration_IndienenVerzoek.xml` |
| ZAC JWT token | `Configuration_ZacJwtToken.xml` — generates fresh HS256 JWT per request |
| Nightly cleanup | `Configuration_CleanupVerlopenVerzoeken.xml` — deletes expired INFO_CACHE entries |
| XSLT transformations | `src/main/configurations/WebformulierenVerwerker/xsl/` (per-action subfolders + `Common/`) |
| App properties (URLs, StUF headers) | `src/main/configurations/WebformulierenVerwerker/DeploymentSpecifics.properties` |
| Framework properties | `src/main/resources/DeploymentSpecifics.properties` |
| Credentials (gitignored) | `src/main/secrets/credentials.properties` |
| WSDL for Kodison interface | `GeneriekeFormulierAfhandeling.wsdl` |
| WSDL for Corsa interface | `Corsa72WS4j.xml_1.wsdl` |
| Database migrations | `src/main/configurations/WebformulierenVerwerker/DatabaseChangelog.xml` |

### Supported Operations

**Corsa flow (existing):**
- `Version` / `Info` — metadata endpoints
- `opslaanInkNatuurlijkPersoon` — store document for natural person
- `opslaanInkNietNatuurlijkPersoon` — store document for organization
- `opslaanBijlage` — store attachment
- `opslaanInk` — store generic document
- `opslaanAanvraagNatuurlijkPersoon` — store request for natural person
- `opslaanAanvraagBijlage` — store request attachment

**ZAC flow (new — feature/zac-koppeling):**
- `aanmakenVerzoekNatuurlijkPersoon` — uploads PDF + XML to Documenten API, stores UUIDs in INFO_CACHE, returns `verzoekIdentificatie` (UUID) + DRC URLs to Kodison
- `toevoegenVerzoekDocument` — uploads a single attachment to Documenten API, stores UUID in VERZOEK_BIJLAGEN, returns DRC URL
- `indienenVerzoek` — reads INFO_CACHE + VERZOEK_BIJLAGEN, POSTs a complete `productaanvraag` JSON to the Objecten API, then cleans up DB rows; ZAC picks this up via Notificaties API and creates the zaak automatically
- `CleanupVerlopenVerzoeken` — nightly scheduler (02:00) that deletes INFO_CACHE and VERZOEK_BIJLAGEN entries older than 7 days

The ZAC flow uses **minimal temporary state**: document UUIDs and metadata are stored between the three Kodison calls (INFO_CACHE + VERZOEK_BIJLAGEN tables). After `indienenVerzoek` the rows are deleted. If Frank restarts between step 1 and step 3, `indienenVerzoek` returns a clear SOAP fault.

### External Systems

- **Corsa** (`http://swfkvt01/wsCorsa7/Corsa72WS4j.asmx`) — document management
- **CAReL** — StUF/ZDS services (URLs in `DeploymentSpecifics.properties`)
- **OpenZaakBrug** — zaak/document identification generation
- **ZAC Documenten API** (`${zac.documenten.url}`, Open Zaak port 8001) — stores informatieobjecten (PDF/XML)
- **ZAC Objecten API** (`${zac.objecten.url}`, port 8010) — receives productaanvraag; triggers dimpact-ZAC via Notificaties API
- **ZAC Objecttypen API** (`${zac.objecten.objecttype}`, port 8011) — provides the Productaanvraag-Dimpact objecttype URL

ZAC API calls require a Bearer token. Configure it in `src/main/secrets/credentials.properties` (gitignored).

### Database

H2 in-memory by default (development). PostgreSQL is supported (driver in `src/main/drivers/`). Schema managed by Liquibase via `DatabaseChangelog.xml`.

## Documentation

Project documentation lives in `docs/`:
- `docs/corsa-carel-flow.md` — Corsa en CAReL koppeling
- `docs/zac-koppeling-flow.md` — ZAC koppeling overzicht
- `docs/zac-koppeling-koppelvlak.md` — koppelvlakspecificatie voor Kodison/Hein
- `docs/carel/` — ZDS 1.1.02 specificaties (WSDLs, XSDs)
- `docs/Corsa_Webservice_Technical_Description_v1.0.60.pdf` — Corsa API-referentie
