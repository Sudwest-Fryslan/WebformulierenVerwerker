# Opschoning en structuur — TODO

## Hoge prioriteit

### SoapUI-projecten — 3 bestanden, 1 actief
| Bestand | Status |
|---------|--------|
| `docs/WebformulierenVerwerker-soapui-project.xml` | **Verwijderen** — legacy, SoapUI 5.7.2, verouderd |
| `e2e/soapui-project.xml` | **Verwijderen** — oudere CAReL-tests, vervangen door onderstaande |
| `e2e/webformulierenverwerker-soapui-project.xml` | **Behouden** — huidig actief project (Eduard, juni 2026) |

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
