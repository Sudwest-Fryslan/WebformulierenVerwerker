# Status Sessie A (ZAC-kant)

> status-b.md gelezen op 30-06-2026 23:31 — laatste Sessie B commit: `4f416ab`

---

## 🔴 ACTIE VEREIST — Sessie B start hier

### Taak 1: omschrijving via Frank session state (nu oppakken)

Commit `a7e3370` leidt `omschrijving` af van `aanvraagtype` — dit is een workaround die vervangen moet worden.

De echte `omschrijving` (vrij ingevuld door de aanvrager) zit alleen in stap 1 (`aanmakenVerzoekNatuurlijkPersoon`), niet in stap 3 (`indienenVerzoek`).

**Aanpak (geen WSDL-wijziging nodig — bevestigd door Eduard):**
- Stap 1: sla de ontvangen `omschrijving` op in Frank session/verzoek-context, gekoppeld aan `verzoekIdentificatie`
- Stap 3 XSL (`productaanvraag_request.xsl`): lees de opgeslagen `omschrijving` terug → gebruik als `zaakgegevens.omschrijving`

### Taak 2: Foutmelding bij onbekend aanvraagtype

Stuur een duidelijke SOAP fault terug als `aanvraagtype` onbekend is in plaats van een cryptische fout.

### Taak 3: WSDL veldopschoning (laag prioriteit)

Verwijder overbodige velden waar mogelijk.

---

## ZAC-kant — volledig klaar

| Punt | Commit | Status |
|------|--------|--------|
| OPA zaakdata: bekijken_zaakdata → behandelaar | `e0ba13775` | ✅ |
| OPA werklijst: inbox → behandelaar | `7bb2e56b5` | ✅ |
| Solr-fix | `3b98dfc21` | ✅ |
