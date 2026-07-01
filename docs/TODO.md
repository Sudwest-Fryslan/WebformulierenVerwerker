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

## Docusaurus — vullen of verwijderen

`docusaurus/` bevat een complete scaffolding maar nauwelijks content. De actuele documentatie staat in `docs/*.md`. Keuze: nieuwe MD-documenten ook in Docusaurus publiceren, of de hele map verwijderen.

---

## Afgehandeld

- SoapUI: opgeschoond naar één actief project (`webformulierenverwerker-soapui-project.xml` in projectroot)
- `e2e/` map verwijderd; ZDS-specificaties staan nu in `docs/carel/`
- `docs/beschrijving in pseudo code.docx` vervangen door `docs/corsa-carel-flow.md`
- ZAC-koppeling gedocumenteerd in `docs/zac-koppeling-flow.md` en `docs/zac-koppeling-koppelvlak.md`
