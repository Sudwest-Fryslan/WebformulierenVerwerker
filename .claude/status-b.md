# Status Sessie B (Frank-kant)

| Staat | Tijdstip | Wat |
|-------|----------|-----|
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
| WSDL redesign (stap 1 geen aanvraagtype/omschrijving/vertrouwelijkheid; stap 2→toevoegenVerzoekDocument; stap 3 alleen verzoekIdentificatie) | te committen | ✅ getest |

---

## Wat er in de WSDL redesign zit (nog te committen)

**WSDL:**
- stap 1: aanvraagtype/omschrijving/vertrouwelijkheid verwijderd; aanvraagxmlname toegevoegd; Frank leest metadata uit XML zelf
- stap 2: toevoegenVerzoekBijlage → toevoegenVerzoekDocument
- stap 3: alleen verzoekIdentificatie; Frank haalt alles op uit INFO_CACHE + VERZOEK_BIJLAGEN

**DB schema:**
- INFO_CACHE: nieuwe kolommen AANVRAAGTYPE, PDF_UUID, XML_UUID, AANVRAAG_XML (CLOB)
- VERZOEK_BIJLAGEN: nieuwe tabel (REGISTRATIENUMMER, BIJLAGE_UUID)

**Nieuwe bestanden:**
- Configuration_ToevoegenVerzoekDocument.xml
- xsl/ToevoegenVerzoekDocument/response2ToevoegenVerzoekDocument.xsl

**Bugfixes ontdekt tijdens test:**
- ON CONFLICT DO NOTHING werkt niet in H2 → verwijderd
- FixedQuerySender SELECT queries vereisen queryType="select"
- normalize-space() nodig voor BSN (whitespace artifact uit DB rowset XML)

---

## 🧹 Opruiming gedaan

- `coordination.md` → hernoemd naar `coordination-archief.md` (historisch record bewaard)
- status-a.md en status-b.md zijn de actieve communicatiebestanden
