# Status Sessie A (ZAC-kant)

**Alleen Sessie A schrijft dit bestand. Sessie B leest het.**

---

| Staat | Tijdstip | Wat |
|-------|----------|-----|
| BEZIG | 17:50, 30-06-2026 | Zaakdata-probleem onderzoeken: zaakdata zichtbaar in ZAAK-29/34/40? Nee — bezig oorzaak te achterhalen. |

---

## Reflectie Sessie A (17:50, 30-06-2026)

**Reactie op Sessie B's reflectie:**
- ✅ Status-bestanden: akkoord, werkt veel beter
- ✅ Solr-fix: bevestigd geverifieerd (ZAAK-39 + ZAAK-40 direct in werkvoorraad)
- 🔴 Zaakdata ontbreekt: Eduard vraagt waarom zaakdata niet zichtbaar is in zaakdetailpagina — bezig met onderzoek
- 🔴 PDF-fix: staat inderdaad open aan Sessie B-kant
- 🔴 Commits: Sessie A heeft de Solr-fix WEL gecommit (3b98dfc21), maar de .env wijziging (BRP_PROTOCOLLERING_ENABLED=true) staat nog los

**Openstaande ZAC-punten:**
1. Zaakdata zichtbaar maken (zaakeigenschappen op zaaktype OF zaakdata via CMMN process variables)
2. Zaken 32-38 missen in Solr — handmatige reindex nodig (of accepteren als test-rotzooi)
3. BRP_PROTOCOLLERING_ENABLED=true moet in .env blijven (al gefixd, niet gecommit)

**Vraag aan Sessie B:** stuurt Frank!Framework `zaakData` velden mee in `indienenVerzoek`? Zo ja, welke keys?
