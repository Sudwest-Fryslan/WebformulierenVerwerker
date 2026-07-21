# Opschoning en structuur — TODO

## Afgehandeld

### SoapUI-projecten — opgeschoond naar 1 actief bestand (21 juli 2026)
`docs/WebformulierenVerwerker-soapui-project.xml` (interface-only, geen testcases) en
`e2e/soapui-project.xml` (volledig opgenomen in het nieuwe project) zijn verwijderd.
Ook een los toegevoegd back-upbestand (`docs/20260615-WebformulierenVerwerker-soapui-project.xml`,
van een ander systeem) is gecontroleerd en weggegooid: de testinhoud was al aanwezig in het actieve
project, op één plek zelfs met een regressie (hardcoded `zaakidentificatie` i.p.v. de correcte
`${Properties#ZaakIdentificatie}`-doorgifte).

`e2e/webformulierenverwerker-soapui-project.xml` is het enige actieve project: 3 testcases
(**Corsa**, **CAReL**, CAReL endpoint direct), inclusief de CAReL creeerZaak-berichtformaat-update
van 15 juni 2026.

---

## Hoge prioriteit

### WSDL's — 3 bestanden met URL-verschil, handmatig gesynchroniseerd
| Bestand | URL | Bedoeling |
|---------|-----|-----------|
| `src/.../GeneriekeFormulierAfhandeling.wsdl` | `testtsjinstbus...` | Intern (Frank!Framework gebruikt dit) |
| `src/.../webcontent/GeneriekeFormulierAfhandeling.wsdl` | `tsjinstbus...` (productie) | Atabix productie |
| `src/.../webcontent/GeneriekeFormulierAfhandelingTest.wsdl` | `testtsjinstbus...` | Atabix TST |

**Probleem:** bij elke uitbreiding moeten alle drie handmatig bijgewerkt worden (was al mis bij de CAReL-operaties in mei 2026).  
**Oplossing (toegezegd door WeAreFrank):** één WSDL met omgevingsvariabele voor de host-URL. Nog niet gerealiseerd.

---

## Lage prioriteit

### Docusaurus — ingericht maar leeg
- `docusaurus/` bevat volledige scaffolding maar nauwelijks content (124 regels markdown, `index.md` is leeg)
- Keuze: vullen of opruimen
- Huidige documentatie staat in `docs/carel/` (markdown)

### Documentatie verspreid over twee plekken
- `docs/` — mix van CAReL-docs (actueel), oude Corsa-PDF (2023, 3.6 MB), legacy SoapUI-project
- Corsa-specificatie PDF (`docs/`) is waarschijnlijk niet meer relevant nu CAReL de nieuwe richting is — controleren of weg kan

---

## Geen actie nodig

- Alle `Configuration_*.xml` adapters zijn actief en correct gereferenced — geen orphans
- `DeploymentSpecifics.properties` commentaarregels zijn bewust als Docker-referentie — laten staan
- `e2e/Zaak_DocumentServices_1_1_02/` WSDLs zijn testfixtures — horen daar
