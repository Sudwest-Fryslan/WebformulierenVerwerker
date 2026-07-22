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

### WSDL — operatie `opslaanInk` toegevoegd aan portType/binding (22 juli 2026, branch `fix/integratie-openstaande-punten-juli-2026`)
Was aanwezig als schema-element maar niet als callable operatie in alle drie WSDL-bestanden. Toegevoegd
(`wsdl:message` + `portType`-operatie + `binding`-operatie), naar het patroon van
`opslaanInkNatuurlijkPersoon`. **Getest met `zeep`** (een echte WSDL-consumerende Python SOAP-client,
zoals Atabix dat ook zou doen): `opslaanInk` is nu een gegenereerde, aanroepbare operatie in alle drie
bestanden, en een testaanroep komt correct door de invoervalidatie. SoapUI-dekking toegevoegd
("WebformulierenVerwerker Corsa TestCase" → `01-opslaanInk-zonder-bsn-en-kvk`).

### WSDL — dode legacy-operaties verwijderd (22 juli 2026, zelfde branch)
`maakInkomendDocumentregistratie` en `bewaarDocument` verwijderd uit `wsdl:message`, `portType` en
`binding` in alle drie WSDL-bestanden (schema-elementen blijven staan, zijn nu gewoon ongebruikte types).
**Getest met `zeep`**: beide operaties zijn niet meer aanwezig als callable operatie.

### Foutafhandeling — echte SOAP Fault + HTTP 500, consistent Corsa/CAReL (22 juli 2026, zelfde branch)
- Alle `EXCEPTION`-exits (9 Configuration-bestanden) hebben nu `code="500"` — Frank!Framework's
  `PipeLineExit.setCode()` stuurt hiermee de HTTP-statuscode, bevestigd via bronresearch
  (`org.frankframework.core.PipeLineExit`, `@ff.default 200`).
- `xsl/Common/CreateErrorResponse.xsl` en `CreateAanvraagErrorResponse.xsl` bouwen nu een structureel
  correcte `<SOAP-ENV:Fault>` (unqualified `faultcode`/`faultstring`/`detail`, zoals Frank!Framework's
  eigen automatische SOAP-faults) in plaats van het niet-standaard `<tns:Fault>`.
- De drie Corsa-adapters (`Configuration_OpslaanInkNatuurlijkPersoon.xml`,
  `...OpslaanInkNietNatuurlijkPersoon.xml`, `...OpslaanBijlage.xml`) routeren de 6 gevonden
  rechtstreeks-naar-`EXCEPTION`-forwards nu via `isErrorXML`, consistent met de CAReL-adapters. De twee
  legitieme afsluitende `success → EXCEPTION`-forwards (na de foutopbouw zelf) zijn ongewijzigd gelaten.
- **Getest, dubbel bevestigd:** curl toont nu `HTTP_STATUS:500` + `<SOAP-ENV:Fault>` voor het scenario dat
  eerst HTTP 200 + stacktrace gaf; `zeep` (Python SOAP-client) herkent de respons nu correct als
  `zeep.exceptions.Fault` met bruikbare `.code`/`.message` — kon dat met de oude vorm niet.
- SoapUI-testcase "Foutscenarios opslaanAanvraagNatuurlijkPersoon" bijgewerkt: de "geen stacktrace"-assertie
  is verwijderd (bleek gebaseerd op een onjuiste aanname — de fout gaat terug naar de Atabix-integratie
  zelf, geen burger/extern systeem, en meer detail is juist gewenst); de SOAP-Fault-assertie zou nu moeten
  slagen.
- **Kleine bijvangst, niet apart opgelost:** de fallback-teksten "No Error Info" (CAReL) vs "No Error
  Message" (Corsa) verschillen nog qua bewoording tussen de twee bijna-identieke XSLT's — cosmetisch, geen
  actie ondernomen.

### Copy-paste-typo `username`/`password` gecorrigeerd (22 juli 2026, zelfde branch)
`Configuration_OpslaanInk.xml`, `...OpslaanInkNietNatuurlijkPersoon.xml`, `...OpslaanBijlage.xml`:
`username="NO_PASS"` → `password="NO_PASS"`, consistent met `...OpslaanInkNatuurlijkPersoon.xml`. Betreft
een fallback die alleen relevant is als de `corsa-soap.connect`-credential ooit faalt — nu al werkt dat
prima, dus geen waarneembaar effect op de huidige werking.

---

## Hoge prioriteit

### CAReL-mapping breekt op nieuwe formulierversie 2026-2027 (bevestigd 22 juli 2026)
De aanvraag-XML (`aanvraagxmldata`) van het Atabix-formulier voor schooljaar 2026-2027 heeft een andere
structuur dan waarop `creeerZaak_Lk01_mapping.xsl:21` selecteert (`/FORMULIER/ELEMENTEN/form/answers` —
bestaat niet meer, nieuwe export is een platte `output/transformedData/element` naam/waarde-lijst).
Zonder aanpassing levert een aanvraag met het nieuwe formulier een lege/onvolledige CAReL-zaak op.
Volledige analyse: `docs/carel/delta_formulierversie_2025_2026.md`, achtergrond in
`docs/carel/scopedocument.md` §9. Test die dit blootlegt: SoapUI-testcase "WebformulierenVerwerker Carel
TestCase (2026)".

**Update 22 juli 2026:** waarschijnlijk géén meerwerk — Hein Vlietstra gebruikte voor deze test een eigen
XSLT-stylesheet om de scenario-XML platter te maken; dat verklaart de afwijkende structuur, niet een
wijziging bij Atabix/CAReL. Kodison bevestigt dat er altijd een XSLT in de exportstap moet zitten, dus
niet weglaten maar vervangen.

**Update 22 juli 2026, later, definitief bevestigd:** een nieuwe testpoging van Hein (met een aangepaste
stylesheet) faalde met een lege SOAP-body naar CAReL — hard bevestigd via Ladybug-capture. Oorzaak: de
`XmlAnswers` levert `<form>` als root zonder de `FORMULIER`/`ELEMENTEN`-laag die de mapping verwacht.
**Actie:** `docs/carel/WebformulierenVerwerker_Passthrough.xml` bevat nu een generieke stylesheet die
alleen die ontbrekende laag om `<form>` heen zet en de rest ongewijzigd doorgeeft — getest tegen de
echte formulierdata, alle door de mapping gebruikte paden resolven correct. Klaar om naar Hein te
sturen.

**Update 22 juli 2026, scope bevestigd:** de gedeployde TST-versie begrijpt alleen het oude formaat en
kan nu niet aangepast worden — dus blijft `creeerZaak_Lk01_mapping.xsl` (de integratie) volledig
ongewijzigd. De hybride oud/nieuw-formaat-herkenning zit uitsluitend in
`WebformulierenVerwerker_Passthrough.xml` aan de Atabix-kant. Eind-tot-eind getest met Saxon door de
onaangepaste integratie-XSLT — compleet, correct `zakLk01`-bericht.

**Update 22 juli 2026, bevestigd geslaagd door Hein's eigen tests:** vier testaanvragen (13:34-14:24 uur)
met versie 1.1, alle vier end-to-end gecontroleerd in de Ladybug-logs — CAReL bevestigt positief
(`Bv03Bericht`), PDF+XML correct gekoppeld, `exitState: SUCCESS`, correcte respons met resultaat-ID naar
Kodison. **Dit punt is afgerond.** Verplaatst naar "Afgehandeld" zodra Hein dit ook zelf bevestigt.

**Update 22 juli 2026, SoapUI bijgewerkt met bevestigd-werkende data:** de `01a`-stap van
"WebformulierenVerwerker Carel TestCase (2026)" gebruikte tot nu toe de kapotte data van Heins eerste
(mislukte) poging. Vervangen door de echte, geslaagde aanvraag van 13:34 uur. Daarnaast 3 losse
teststappen toegevoegd met Heins overige geslaagde tests (14:10, 14:14, 14:24 uur) — elk met een ander
vervoertype (Fiets, Fiets+OV, OV zelfstandig), voor regressiedekking op de vervoertype-afhankelijke
dag-velden-logica in `creeerZaak_Lk01_mapping.xsl`. Alle payloads byte-voor-byte geverifieerd tegen de
Ladybug-captures.

### WSDL's — 3 bestanden met URL-verschil, handmatig gesynchroniseerd
| Bestand | URL | Bedoeling |
|---------|-----|-----------|
| `src/.../GeneriekeFormulierAfhandeling.wsdl` | `testtsjinstbus...` | Intern (Frank!Framework gebruikt dit) |
| `src/.../webcontent/GeneriekeFormulierAfhandeling.wsdl` | `tsjinstbus...` (productie) | Atabix productie |
| `src/.../webcontent/GeneriekeFormulierAfhandelingTest.wsdl` | `testtsjinstbus...` | Atabix TST |

**Probleem:** bij elke uitbreiding moeten alle drie handmatig bijgewerkt worden (was al mis bij de CAReL-operaties in mei 2026 — dat specifieke incident is inmiddels opgelost, de drie bestanden zijn nu weer gelijk buiten de URL).
**Oplossing (toegezegd door WeAreFrank):** één WSDL met omgevingsvariabele voor de host-URL. Nog niet gerealiseerd.

### WSDL — operatie `opslaanInk` ontbreekt in portType/binding (bevestigd 21 juli 2026)
`GeneriekeFormulierAfhandeling.wsdl` heeft wél de schema-elementen `opslaanInk`/`opslaanInkResponse`
(regel 123-140), maar geen `wsdl:message`, `portType`-operatie of `binding`-operatie voor `opslaanInk` —
in alle drie kopieën. `opslaanInkNatuurlijkPersoon` en `opslaanInkNietNatuurlijkPersoon` hebben die laag
wél volledig (regel 249-304).
De dispatcher (`Configuration_WebformulierenVerwerkerDispatcher.xml`) routeert `opslaanInk` zelf gewoon
(regel 31, 55, 86-87, 159-162), dus de app werkt — maar een partij die de WSDL gebruikt om een client te
genereren (Atabix/Kodison) kan de operatie niet zien. **Actie:** `wsdl:message`, `portType`-operatie en
`binding`-operatie voor `opslaanInk` toevoegen aan alle drie WSDL-bestanden.

### WSDL — dode legacy-operaties in portType/binding
`maakInkomendDocumentregistratie` en `bewaarDocument` staan nog in portType/binding van alle drie WSDL's,
maar worden nergens meer gerouteerd door de dispatcher (niet in de `soapBody`-lijst, geen `XmlSwitchPipe`-
forward). **Actie:** beslissen of dit legacy-contract eruit mag, of dat een externe partij deze operaties
nog kan aanroepen (dan blijven ze staan, maar dan moet duidelijk zijn dat een aanroep hierop faalt).

### Foutafhandeling — geen HTTP-foutcode + mogelijk datalek bij fouten dieper in de keten (bevestigd 22 juli 2026, live getest)
Lokaal getest (`docker compose -f compose.frank.dev.yaml up`) tegen `opslaanAanvraagNatuurlijkPersoon` met
diverse kapotte requests:
- **Schema-validatiefouten** (ontbrekend verplicht veld, ongeldige base64) → nette `soap:Fault`, **HTTP 500**,
  duidelijke boodschap. Dit gaat goed.
- **Fouten die de WSDL-validatie voorbij zijn** (getest: lege `aanvraagxmldata`, die lokaal al bij de
  OpenZaakBrug-aanroep faalt omdat die hier niet bereikbaar is) → **HTTP 200**, met een zelfgebouwd
  `<tns:Fault>`-element (niet een echte SOAP-fault — geen `<soap:Fault>` in de envelope-namespace). Dit is
  vermoedelijk waarom Hein op 22 juli geen HTTP-foutcode terugkreeg bij zijn mislukte test: de integratie
  stuurt op dit pad principieel geen foutcode, dus een consument kan dit alleen via de inhoud detecteren.
- **Inconsistente hoeveelheid detail:** in dat geval bevatte de faultstring een **volledige Java-stacktrace
  + interne infrastructuurdetails** (interne hostnamen, framework-versie). Dit gaat terug naar de
  Atabix-integratie zelf (dezelfde plek waar Hein de eerdere "No Error Info"-fout las) — geen burger of
  extern systeem ziet dit, en meer detail bij fouten is expliciet gewenst voor troubleshooting. Het
  probleem is dus niet dat er te veel informatie teruggaat, maar dat het **inconsistent** is: de ene keer
  "No Error Info" (te karig om iets mee te doen), de andere keer een volledige stacktrace — afhankelijk
  van welke onderliggende Frank!Framework-exceptie toevallig optreedt, niet van een bewuste keuze.

**Actie:**
1. Op dit pad een echte SOAP Fault + passende HTTP-statuscode (500) laten teruggeven in plaats van de
   huidige HTTP 200 met business-object — zodat Atabix (of eender welke consument) fouten ook op
   transportniveau kan herkennen, niet alleen door de inhoud te inspecteren.
2. Zorgen dat er **consistent voldoende diagnostische informatie** in de foutmelding komt (in elk geval:
   welke stap faalde en waarom) — nu varieert dit onbedoeld van "niets" tot "alles inclusief stacktrace".

Vastgelegd als SoapUI-testcase **"Foutscenarios opslaanAanvraagNatuurlijkPersoon (22 juli 2026)"** — de
eerste twee stappen (schema-fouten) slagen nu al; de derde stap (dieper-in-de-keten) faalt bewust op beide
assertions, als regressietest voor als dit wordt opgelost.

### Foutafhandeling — inconsistent tussen Corsa- en CAReL-adapters (bevestigd 21 juli 2026)
Er is een nette gedeelde foutafhandeling (`xsl/Common/CreateErrorResponse.xsl`) die een opgeschoonde
SOAP-Fault teruggeeft aan Kodison zonder interne Corsa-details te lekken. De CAReL-adapters
(`Configuration_OpslaanAanvraagNatuurlijkPersoon.xml`, `...AanvraagBijlage.xml`) routeren vrijwel elke
fout consequent via dit pad.
De **oudere Corsa-adapters doen dat niet overal**: in `Configuration_OpslaanInkNatuurlijkPersoon.xml`,
`...OpslaanInkNietNatuurlijkPersoon.xml` en `...OpslaanBijlage.xml` forwarden meerdere pipes exceptions
rechtstreeks naar een `EXCEPTION`-exit, zonder via de nette Fault-XSLT. Concreet reëel scenario: in
`Configuration_OpslaanBijlage.xml` (regel 72) gaat een ontbrekend registratienummer in de cache direct
naar `EXCEPTION` — mogelijk een rauwe Frank!Framework-melding richting Kodison in plaats van een nette
foutmelding. **Actie:** de Corsa-adapters gelijktrekken met de CAReL-adapters — alle exception-forwards
via `isErrorXML`/de gedeelde Fault-XSLT laten lopen. Nog te verifiëren met een draaiende app: wat Kodison
exact ontvangt op deze bypass-paden (stacktrace, generieke Frank!Framework-wrapper, of iets anders).

### Copy-paste-typo — `username` i.p.v. `password` in Corsa-auth Param
`Configuration_OpslaanInk.xml:33`, `...OpslaanInkNietNatuurlijkPersoon.xml:33` en
`...OpslaanBijlage.xml:31` hebben `<Param name="password" authAlias="corsa-soap.connect"
pattern="{password}" username="NO_PASS"/>` — het fallback-attribuut heet `username` in plaats van
`password`. `Configuration_OpslaanInkNatuurlijkPersoon.xml:33` heeft het wél goed
(`password="NO_PASS"`). **Actie:** `username="NO_PASS"` naar `password="NO_PASS"` corrigeren in de drie
foutieve bestanden. Effect op de fallback-waarde nog niet bevestigd zonder draaiende app.

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
