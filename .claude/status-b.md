# Status Sessie B (Frank-kant)

| Staat | Tijdstip | Wat |
|-------|----------|-----|
| KLAAR | 01-07-2026 | ✅ Betere foutmeldingen SOAP fault + container bijgewerkt (42b6d6f) |
| KLAAR | 01-07-2026 | ✅ UUID whitespace-fix in productaanvraag XSL (24b7132) |
| KLAAR | 01-07-2026 | ✅ SoapUI bijgewerkt voor WSDL redesign (837c4af) |
| KLAAR | 01-07-2026 | ✅ WSDL redesign volledig geïmplementeerd en getest (stap 1/2/3 werken) |
| KLAAR | 30-06-2026 | ✅ INFO_CACHE omschrijving-flow getest en gecommit (c7d1751) |

---

## ✅ Werkafspraken — geldig voor volgende sessies

1. Lees altijd eerst het statusbestand van de andere sessie vóór je schrijft
2. Herhaal nooit instructies die al als ✅ staan in het andere bestand
3. Bevestig ontvangst expliciet bovenaan je statusupdate
4. Consensus voor werkafspraken-wijzigingen

---

## ✅ Frank-kant — volledig overzicht

| Punt | Commit | Status |
|------|--------|--------|
| 3-staps ZAC SOAP-flow | d8c5db2 | ✅ |
| Sectie/veldfilter zaakdata | 2e88282 | ✅ |
| zaakgegevens.omschrijving (fallback) | a7e3370 | ✅ |
| PDF-fix BRP-testdata | 4f416ab | ✅ |
| omschrijving via INFO_CACHE (stap 1→3) | c7d1751 | ✅ |
| WSDL redesign (stap 1 geen aanvraagtype/omschrijving/vertrouwelijkheid; stap 2→toevoegenVerzoekDocument; stap 3 alleen verzoekIdentificatie) | d8c5db2 | ✅ |
| SoapUI ZAC testcase bijgewerkt (stap 1/2/3 nieuwe veldstructuur) | 837c4af | ✅ |
| UUID whitespace-fix: normalize-space op pdf/xml/bijlage UUID in productaanvraag XSL | 24b7132 | ✅ |

---

## 🔴 Hertest gedaan maar zaak niet aangemaakt in ZAC

Eduard heeft 01-07-2026 de SoapUI 3-staps flow opnieuw gedraaid:
- stap 1 ✅ verzoekIdentificatie=`ac15001c--1f0c3f49_19f1aa982d6_-7fbd`
- stap 2 ✅ bijlageUuid=`e59a408d-c17e-4c1f-8283-7b1869fc2a76`
- stap 3 ✅ result=`ac15001c--1f0c3f49_19f1aa982d6_-7fbd`

Frank retourneert success, maar ZAC heeft **geen nieuwe zaak aangemaakt** (hoogste zaak is nog ZAAK-2026-0000000046 van gisteren). Productaanvraag is gepost naar Objecten API maar ZAC-notificatie is niet opgepikt.

**Actie voor Sessie A:** check ZAC-logs op wat er mis ging na de productaanvraag van 01-07-2026.

---

## 🧹 Opruiming gedaan

- `coordination.md` → hernoemd naar `coordination-archief.md` (historisch record bewaard)
- status-a.md en status-b.md zijn de actieve communicatiebestanden
