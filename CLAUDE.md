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

The app runs on **port 8080**. Mock services (for e2e tests) run on **port 8081**.

Hot-reload works via `ScanningDirectoryClassLoader` — changes to XML configs and XSL files are picked up automatically without restart.

## Testing

There are no unit tests. Testing is integration-based via **SoapUI**:
- `e2e/webformulierenverwerker-soapui-project.xml` — the single active project (Corsa, CAReL, CAReL-endpoint testcases)

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
| Action adapters | `Configuration_Opslaan*.xml`, `Configuration_Version.xml`, `Configuration_Info.xml` |
| XSLT transformations | `src/main/configurations/WebformulierenVerwerker/xsl/` (per-action subfolders + `Common/`) |
| App properties (URLs, StUF headers) | `src/main/configurations/WebformulierenVerwerker/DeploymentSpecifics.properties` |
| Framework properties | `src/main/resources/DeploymentSpecifics.properties` |
| Credentials (gitignored) | `src/main/secrets/credentials.properties` |
| WSDL for Kodison interface | `GeneriekeFormulierAfhandeling.wsdl` |
| WSDL for Corsa interface | `Corsa72WS4j.xml_1.wsdl` |
| Database migrations | `src/main/configurations/WebformulierenVerwerker/DatabaseChangelog.xml` |

### Supported Operations

- `Version` / `Info` — metadata endpoints
- `opslaanInkNatuurlijkPersoon` — store document for natural person
- `opslaanInkNietNatuurlijkPersoon` — store document for organization
- `opslaanBijlage` — store attachment
- `opslaanInk` — store generic document
- `opslaanAanvraagNatuurlijkPersoon` — store request for natural person
- `opslaanAanvraagBijlage` — store request attachment

### External Systems

- **Corsa** (`http://swfkvt01/wsCorsa7/Corsa72WS4j.asmx`) — document management
- **CAReL** — StUF/ZDS services (URLs in `DeploymentSpecifics.properties`)
- **OpenZaakBrug** — zaak/document identification generation

### Database

H2 in-memory by default (development). PostgreSQL is supported (driver in `src/main/drivers/`). Schema managed by Liquibase via `DatabaseChangelog.xml`.

## Documentation Site

```bash
cd docusaurus && yarn install && yarn start
```
