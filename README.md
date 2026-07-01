# WebformulierenVerwerker

De WebformulierenVerwerker verwerkt aanvragen uit gemeentelijke webformulieren en registreert deze, inclusief documenten en metadata, in de daarvoor bestemde zaak- en documentbeheersystemen. Het onderdeel werkt als integratiebrug tussen Atabix/Kodison (het webformulierenplatform van SWF) en de backendkoppelingen met Corsa, CAReL en ZAC.

De applicatie bevat geen eigen Java-code. Alle verwerkingslogica is beschreven in Frank!Framework XML-adapters en XSLT-stylesheets.

## Ondersteunde koppelingen

**Corsa** (documentbeheer):
- `opslaanInkNatuurlijkPersoon` — document opslaan voor een burger (BSN-opzoeken of aanmaken)
- `opslaanInkNietNatuurlijkPersoon` — document opslaan voor een organisatie (KvK-opzoeken of aanmaken)
- `opslaanBijlage` — bijlage toevoegen aan een bestaand Corsa-document
- `opslaanInk` — document opslaan zonder persoonskoppeling

**CAReL** (zaakregistratie via StUF/ZDS):
- `opslaanAanvraagNatuurlijkPersoon` — zaak aanmaken in CAReL voor een burger, inclusief PDF en XML-aanvraagdata
- `opslaanAanvraagBijlage` — bijlage toevoegen aan een bestaande CAReL-zaak

**ZAC** (zaakregistratie via Dimpact productaanvraag-flow):
- `aanmakenVerzoekNatuurlijkPersoon` — PDF en XML uploaden naar de Documenten API
- `toevoegenVerzoekDocument` — aanvullende bijlage uploaden naar de Documenten API
- `indienenVerzoek` — productaanvraag plaatsen in de Objecten API, waarna ZAC automatisch een zaak aanmaakt via de Notificaties API

## Hoe het werkt

Alle inkomende berichten komen binnen via één SOAP-listener in `Configuration_WebformulierenVerwerkerDispatcher.xml`. De dispatcher valideert het bericht tegen de WSDL, haalt de operatienaam op en roept de bijbehorende adapter aan.

Elke adapter verwerkt één operatie van begin tot eind: verzoek transformeren → backend aanroepen → respons transformeren.

```
Atabix/Kodison → Frank!Framework (SOAP, poort 8090)
  Corsa-flow    → Corsa SOAP webservice (documentbeheer)
  CAReL-flow    → OpenZaakBrug (ID-generatie) + CAReL (zaakregistratie via StUF/ZDS)
  ZAC-flow      → Documenten API + Objecten API → Notificaties API → ZAC
```

## Lokaal draaien

```bash
# Ontwikkeling met hot-reload (voorkeur)
docker compose -f compose.frank.dev.yaml up --build --force-recreate --watch

# Productie-image
docker compose up
```

De Frank!Framework-console is bereikbaar op **poort 8090**. Mockservices voor testen draaien op **poort 8081**.

Hot-reload werkt via `ScanningDirectoryClassLoader` — wijzigingen in XML-adapters en XSL-bestanden worden automatisch opgepakt zonder herstart.

## Testen

Testen gaan via SoapUI. Het projectbestand staat in de repository-root:

```
webformulierenverwerker-soapui-project.xml
```

Het bevat testcases voor alle koppelingen (Corsa, CAReL, ZAC). Voor lokaal testen moet de mockservice in het SoapUI-project actief zijn.

Gebruik **Ladybug** (ingebouwd in de Frank!Framework-console) voor het debuggen van berichtstromen.

## Documentatie

- [`docs/corsa-carel-flow.md`](docs/corsa-carel-flow.md) — werking Corsa- en CAReL-koppeling
- [`docs/zac-koppeling-flow.md`](docs/zac-koppeling-flow.md) — overzicht ZAC-koppeling
- [`docs/zac-koppeling-koppelvlak.md`](docs/zac-koppeling-koppelvlak.md) — koppelvlakspecificatie voor Atabix/Kodison
- [`docs/zac-koppeling-setup.md`](docs/zac-koppeling-setup.md) — configuratiehandleiding ZAC-koppeling
- [`docs/gevonden-issues.md`](docs/gevonden-issues.md) — bekende issues en workarounds
- [`docs/Corsa_Webservice_Technical_Description_v1.0.60.pdf`](docs/Corsa_Webservice_Technical_Description_v1.0.60.pdf) — Corsa API-referentie

## Licentie

EUPL v1.2 — zie [LICENSE.md](LICENSE.md).
