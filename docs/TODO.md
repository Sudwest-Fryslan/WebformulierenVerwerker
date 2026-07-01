# Openstaande actiepunten

## WSDL-synchronisatie — actie bij WeAreFrank

Bij elke uitbreiding van de WSDL moeten drie bestanden handmatig bijgewerkt worden:

| Bestand | URL |
|---------|-----|
| `src/.../GeneriekeFormulierAfhandeling.wsdl` | `testtsjinstbus...` (intern Frank) |
| `src/.../webcontent/GeneriekeFormulierAfhandeling.wsdl` | `tsjinstbus...` (productie) |
| `src/.../webcontent/GeneriekeFormulierAfhandelingTest.wsdl` | `testtsjinstbus...` (Atabix TST) |

WeAreFrank heeft toegezegd dit op te lossen met één WSDL en een omgevingsvariabele voor de host-URL. Nog niet gerealiseerd.

---

## Monitoring en foutafhandeling

De huidige foutafhandeling geeft duidelijke SOAP Faults terug aan Kodison. Wat nog ontbreekt:

- Er is geen externe alertering wanneer een verzoek structureel mislukt (bijv. Corsa onbereikbaar, Objecten API geeft 5xx terug). Fouten zijn alleen zichtbaar via Ladybug in de Frank-console.
- De nachtelijke cleanup-job (`CleanupVerlopenVerzoeken`) logt niet hoeveel records worden verwijderd. Bij problemen is niet na te gaan hoeveel verzoeken zijn verlopen.
- Er is geen health check endpoint gedocumenteerd voor monitoring vanuit de infrastructuur.

Prioriteit: hoog — stille fouten zijn moeilijk te signaleren in productie.

---

## CAReL: aanvraagtypen uitbreiden

Momenteel ondersteunt de CAReL-koppeling alleen `leerlingenvervoer`. Meer aanvraagtypen worden in de toekomst toegevoegd. Per type zijn nodig:

1. Nieuwe XSL-mapping in `xsl/OpslaanAanvraag<Type>NatuurlijkPersoon/`
2. Extra forward in `XmlSwitchPipe` in `Configuration_OpslaanAanvraagNatuurlijkPersoon.xml`
3. SoapUI-testcase

---

## Afgehandeld

- SoapUI: opgeschoond naar één actief project (`webformulierenverwerker-soapui-project.xml` in projectroot)
- `e2e/` map verwijderd; ZDS-specificaties staan nu in `docs/carel/`
- `docs/beschrijving in pseudo code.docx` vervangen door `docs/corsa-carel-flow.md`
- ZAC-koppeling gedocumenteerd in `docs/zac-koppeling-flow.md` en `docs/zac-koppeling-koppelvlak.md`
- `Configuration_ToevoegenVerzoekBijlage.xml` verwijderd (dode code, dispatcher gebruikt `toevoegenVerzoekDocument`)
- `indienenVerzoek` geeft nu duidelijke foutmelding als verzoekIdentificatie niet in cache staat
- Docusaurus verwijderd; documentatie staat in `docs/*.md`
