# WebformulierenVerwerker

[![Build](https://github.com/Sudwest-Fryslan/WebformulierenVerwerker/actions/workflows/ci-build.yml/badge.svg?branch=main)](https://github.com/Sudwest-Fryslan/WebformulierenVerwerker/actions/workflows/ci-build.yml)
[![Licentie: EUPL v1.2](https://img.shields.io/badge/Licentie-EUPL_v1.2-blue.svg)](LICENSE.md)
[![Platform: Frank!Framework](https://img.shields.io/badge/Platform-Frank!Framework-orange.svg)](https://frankframework.org)

Integratiebrug tussen het webformulierenplatform van Súdwest-Fryslân (Atabix/Kodison) en de gemeentelijke zaak- en documentbeheersystemen. De verwerker ontvangt aanvragen via SOAP, transformeert ze en stuurt ze door naar Corsa, CAReL of ZAC.

De applicatie bevat geen eigen Java-code. Alle logica zit in **Frank!Framework** XML-adapters en XSLT-stylesheets.

---

## Hoe het werkt

```
Atabix / Kodison  ──SOAP──►  WebformulierenVerwerker (Frank!Framework, :8090)
                                        │
                          ┌─────────────┼──────────────┐
                          ▼             ▼               ▼
                        Corsa         CAReL            ZAC
                   (documentbeheer)  (StUF/ZDS)  (Dimpact productaanvraag)
```

Alle inkomende berichten komen binnen via één SOAP-listener. De dispatcher valideert het bericht, bepaalt de operatie en roept de bijbehorende adapter aan. Elke adapter verwerkt één operatie volledig: verzoek transformeren → backend aanroepen → respons transformeren.

---

## Ondersteunde koppelingen

### Corsa — documentbeheer

| Operatie | Beschrijving |
|----------|-------------|
| `opslaanInkNatuurlijkPersoon` | Document opslaan voor een burger (BSN-opzoeken of aanmaken) |
| `opslaanInkNietNatuurlijkPersoon` | Document opslaan voor een organisatie (KvK-opzoeken of aanmaken) |
| `opslaanBijlage` | Bijlage toevoegen aan een bestaand Corsa-document |
| `opslaanInk` | Document opslaan zonder persoonskoppeling |

### CAReL — zaakregistratie via StUF/ZDS

| Operatie | Beschrijving |
|----------|-------------|
| `opslaanAanvraagNatuurlijkPersoon` | Zaak aanmaken in CAReL voor een burger, inclusief PDF en XML |
| `opslaanAanvraagBijlage` | Bijlage toevoegen aan een bestaande CAReL-zaak |

> Momenteel ondersteund aanvraagtype: `leerlingenvervoer`. Meer typen volgen.

### ZAC — zaakregistratie via Dimpact productaanvraag

| Operatie | Beschrijving |
|----------|-------------|
| `aanmakenVerzoekNatuurlijkPersoon` | PDF en XML uploaden naar de Documenten API |
| `toevoegenVerzoekDocument` | Aanvullende bijlage uploaden (optioneel, herhaalbaar) |
| `indienenVerzoek` | Productaanvraag indienen → ZAC maakt automatisch een zaak aan |

---

## Lokaal draaien

```bash
# Ontwikkeling met hot-reload (voorkeur)
docker compose -f compose.frank.dev.yaml up --build --force-recreate --watch

# Productie-image
docker compose up
```

| Dienst | Poort |
|--------|-------|
| Frank!Framework console | `8090` |
| Mockservices (voor testen) | `8081` |

Wijzigingen in XML-adapters en XSL-bestanden worden automatisch opgepakt zonder herstart.

---

## Testen

Testen gaan via **SoapUI**. Het projectbestand staat in de repository-root:

```
webformulierenverwerker-soapui-project.xml
```

Het bevat testcases voor alle koppelingen (Corsa, CAReL, ZAC). Voor lokaal testen moet de mockservice in het SoapUI-project actief zijn.

Gebruik **Ladybug** (ingebouwd in de Frank!Framework-console op `:8090`) voor het debuggen van berichtstromen.

---

## Documentatie

| Document | Inhoud |
|----------|--------|
| [`docs/corsa-carel-flow.md`](docs/corsa-carel-flow.md) | Werking Corsa- en CAReL-koppeling |
| [`docs/zac-koppeling-flow.md`](docs/zac-koppeling-flow.md) | Overzicht ZAC-koppeling (3 stappen) |
| [`docs/zac-koppeling-koppelvlak.md`](docs/zac-koppeling-koppelvlak.md) | Koppelvlakspecificatie voor Atabix/Kodison |
| [`docs/zac-koppeling-setup.md`](docs/zac-koppeling-setup.md) | Configuratiehandleiding ZAC-koppeling |
| [`docs/gevonden-issues.md`](docs/gevonden-issues.md) | Bekende issues en workarounds |
| [`docs/Corsa_Webservice_Technical_Description_v1.0.60.pdf`](docs/Corsa_Webservice_Technical_Description_v1.0.60.pdf) | Corsa API-referentie |

---

## Licentie

[EUPL v1.2](LICENSE.md) — Europese Unie Publieke Licentie
