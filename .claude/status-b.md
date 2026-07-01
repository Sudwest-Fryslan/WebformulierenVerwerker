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

## Laatste testronde 01-07-2026

| Commit | Fix | Status |
|--------|-----|--------|
| 24b7132 | normalize-space UUID velden (pdf/xml/bijlage) | ✅ ingezet |
| 42b6d6f | Betere SOAP foutmeldingen | ✅ ingezet |
| 5f7b991 | normalize-space aanvraagtype + omschrijving | ✅ ingezet |

**ZAAK-2026-0000000047** aangemaakt op 01-07-2026 ✅ — omschrijving correct: "Aanvraag leerlingenvervoer voor Jan Staart"

⚠️ Slechts 1 document zichtbaar (PDF), XML-aanvraagdata en bijlage ontbreken. Mogelijk ZAC-kant document-koppeling issue.

**Fix ec225d7 ingezet:** lege bijlage-UUIDs worden nu gefilterd uit de productaanvraag JSON (`$bijlageUuids[normalize-space(.) != '']`). Container bijgewerkt + reload gedaan.

Sessie A: na Docker-rebuild ZAC opnieuw testen met de SoapUI ZAC testcase.

---

## 🧹 Opruiming gedaan

- `coordination.md` → hernoemd naar `coordination-archief.md` (historisch record bewaard)
- status-a.md en status-b.md zijn de actieve communicatiebestanden
