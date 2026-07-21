# ZAC-koppeling: status en overdracht

Dit document beschrijft de stand van zaken van de ZAC-koppeling op branch `feature/zac-koppeling`,
zodat iemand anders (of jijzelf later) dit werk kan oppakken zonder eerst alle geschiedenis te
hoeven doorspitten.

Bijgewerkt: 21 juli 2026.

---

## Status in één zin

De ZAC-koppeling (drie SOAP-stappen: `aanmakenVerzoekNatuurlijkPersoon` → `toevoegenVerzoekDocument`
→ `indienenVerzoek`) is functioneel gebouwd en werkt end-to-end in een lokale ontwikkelomgeving
(Docker Compose met Open Zaak + ZAC + Objecten API). De branch is **nog niet gemerged naar `main`**
en er is nog geen productie-configuratie of livegang geweest.

---

## Wat is af

- Alle drie SOAP-operaties zijn geïmplementeerd als Frank!Framework-adapters
  (`Configuration_AanmakenVerzoekNatuurlijkPersoon.xml`, `Configuration_ToevoegenVerzoekDocument.xml`,
  `Configuration_IndienenVerzoek.xml`) — zie [`zac-koppeling-flow.md`](zac-koppeling-flow.md) voor de
  volledige beschrijving.
- Dynamische JWT-generatie voor Open Zaak (geen statisch token dat kan verlopen) —
  `Configuration_ZacJwtToken.xml`.
- Tijdelijke state (INFO_CACHE, VERZOEK_BIJLAGEN) wordt na `indienenVerzoek` direct opgeruimd;
  een nachtelijke cleanup-job (`CleanupVerlopenVerzoeken`, 02:00) ruimt verweesde entries ouder dan
  7 dagen op — zie [`zac-koppeling-koppelvlak.md`](zac-koppeling-koppelvlak.md#wat-gebeurt-er-als-stap-3-nooit-wordt-aangeroepen).
- Rijkere SOAP Fault-berichten met stap-context en backend-response.
- End-to-end getest via SoapUI tegen een lokale Docker-stack (Open Zaak, ZAC, Objecten API,
  Objecttypen API, Open Notificaties) — testcases in `webformulierenverwerker-soapui-project.xml`.
- 21 issues gevonden tijdens de bouw, waarvan 18 opgelost of met gedocumenteerde workaround —
  zie [`gevonden-issues.md`](gevonden-issues.md).
- De koppeling is generiek per formuliertype (niet hardcoded op leerlingenvervoer) — een nieuw
  Atabix-formulier werkt zonder codewijziging zolang de `<globals>`-sectie klopt, zie
  [`zac-koppeling-koppelvlak.md`](zac-koppeling-koppelvlak.md#verschillende-formuliertypen).

## Wat nog niet af is

Openstaande punten vóórdat dit naar productie of naar `main` kan:

| Punt | Toelichting |
|------|-------------|
| **Monitoring/alertering** | Geen externe alertering bij structurele fouten (Corsa/Objecten API onbereikbaar). Fouten zijn alleen zichtbaar via Ladybug. Zie [`TODO.md`](TODO.md#monitoring-en-foutafhandeling) — prioriteit hoog. |
| **Productieconfiguratie** | Huidige `DeploymentSpecifics.properties`/`credentials.properties`-waarden in [`zac-koppeling-setup.md`](zac-koppeling-setup.md) zijn testwaarden voor de lokale Docker-stack (test-secret, test-RSIN, test-UUID's). Voor SWF-productie moeten deze opnieuw ingericht worden in de echte Open Zaak/ZAC-omgeving. |
| **WSDL-synchronisatie** | Nog handmatig op 3 plekken bijgehouden, actie ligt bij WeAreFrank. Zie [`TODO.md`](TODO.md#wsdl-synchronisatie--actie-bij-wearefrank). |
| **Security review** | Nog niet uitgevoerd op de ZAC-adapters/JWT-flow. |
| **Belasting/schaal** | Alleen los, handmatig getest via SoapUI — geen volumetest gedaan. |
| **Cleanup-logging** | De nachtelijke cleanup-job logt niet hoeveel records worden verwijderd; bij problemen niet te herleiden hoeveel verzoeken zijn verlopen. |

## Hoe dit oppakken

1. Lees eerst [`zac-koppeling-flow.md`](zac-koppeling-flow.md) voor het functionele overzicht.
2. Voor het opnieuw opzetten van de lokale testomgeving: [`zac-koppeling-setup.md`](zac-koppeling-setup.md)
   — let op de Docker Compose profiles (`zac`, `objecten`, `opennotificaties`), dit is de meest
   voorkomende valkuil bij een verse opzet (zie [`gevonden-issues.md`](gevonden-issues.md) ISSUE-7 en ISSUE-8).
3. Voor het koppelvlak richting Kodison/Atabix (Hein): [`zac-koppeling-koppelvlak.md`](zac-koppeling-koppelvlak.md).
4. Bekende valkuilen en workarounds: [`gevonden-issues.md`](gevonden-issues.md).
5. Openstaande actiepunten (ZAC + overige): [`TODO.md`](TODO.md).

## Branch-informatie

- Branch: `feature/zac-koppeling`, gebaseerd op `main`.
- Nog niet gemerged — `main` blijft ongewijzigd totdat hier bewust voor gekozen wordt.
- De release-pipeline (`semantic-release`, Docker-publish) triggert alleen op pushes/PR's naar
  `main`, dus werk op deze branch veroorzaakt geen automatische release.
