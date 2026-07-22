# Openstaande punten WebformulierenVerwerker-integratie

Overzicht van technische punten in de WebformulierenVerwerker-repo (dus niet de punten die bij
Hein/Atabix, Petra/CAReL-beheer of Eljakim liggen — dat staat in `docs/carel/scopedocument.md`).

**Samenvatting, op volgorde:**

| # | Punt | CAReL-specifiek? | Status | Tijdsinschatting | WeAreFrank-gesprek |
|---|------|:---:|--------|-------------------|---------------------|
| 1 | WSDL structureel (1 bestand + omgevingsvariabele) | Nee | **Open** | 1-2 dagen (poging met entrypoint.sh gedaan en teruggedraaid) | Ja, toegezegd |
| 2 | WSDL `opslaanInk` ontbreekt | Nee (Corsa) | ✅ Opgelost | 1-2 uur | Nee |
| 3 | WSDL dode legacy-operaties | Nee (Corsa) | ✅ Opgelost | 30 min - 1 uur | Nee |
| 4 | Foutafhandeling HTTP/SOAP-conventie | Nee | ✅ Opgelost | 1-3 dagen | Nee |
| 5 | Typo username/password | Nee (Corsa) | ✅ Opgelost | 15-30 min | Nee |
| 6 | CAReL adres-splitsing + dagstructuur | **Ja** | **Open** | 0,5-1 dag+ | Alleen dat het meerwerk is |
| 7 | CAReL `heeftBetrekkingOp` / `verwerkingssoort` | **Ja** | **Open** | ~0,5 dag | Alleen dat het afwijking is |

**Kernpunt:** van de 7 punten zijn er maar twee (#6, #7) echt CAReL-inhoudelijk — die staan nog open, en
raken de lopende meerwerk-discussie met WeAreFrank. #1 staat ook nog open — al toegezegd door WeAreFrank,
en een werkende technische oplossing (custom `entrypoint.sh`) is gebouwd, live getest, en weer
teruggedraaid: te veel eigen mechanisme voor dit probleem. Zie sectie 1 voor een eenvoudiger alternatief
(XInclude) dat nog niet gebouwd is. #2 t/m #5 zijn generieke Corsa/integratiekwaliteit, geen
CAReL-inhoud, en zijn al opgelost en getest op branch `fix/integratie-openstaande-punten-juli-2026` (nog
niet gepusht/gemerged).

---

## 1. WSDL — 3 losse bestanden, handmatig gesynchroniseerd — **Open**

Er zijn drie kopieën van `GeneriekeFormulierAfhandeling.wsdl` die alleen verschillen in de host-URL. Bij
elke uitbreiding moeten alle drie handmatig bijgewerkt worden (ging al eens mis in mei 2026).

**Uitgezocht waarom dit niet met een standaard framework-feature kan:** Frank!Framework heeft een eigen
automatische WSDL-generator, maar die ondersteunt geen meerdere operaties per WSDL — een bekend, open,
sinds juli 2023 onopgelost upstream-issue
([frankframework/frankframework#5115](https://github.com/frankframework/frankframework/issues/5115)).
Dat verklaart waarom WeAreFrank dit niet simpelweg kon "aanzetten". `webcontent/`-bestanden worden
bovendien puur statisch geserveerd, zonder property-substitutie — dus ook geen ingebouwde oplossing daar.

**Poging gedaan en teruggedraaid:** een custom `entrypoint.sh` die bij elke containerstart de twee
`webcontent/`-WSDL's genereert uit de ene bronwaarheid — werkend gebouwd en getest (met `zeep`: correct
alle 8 operaties, `diff` toonde precies 1 regel verschil), maar op verzoek van Eduard teruggedraaid: te
veel eigen mechanisme (custom Docker-entrypoint, sed-substitutie) voor dit probleem. De twee
hostnaam-waarden waren daarbij hardcoded in het script — geen dynamische omgevingsdetectie, dat kan ook
niet zuiver: de container zelf weet niet via welke publieke hostname hij benaderd wordt, dat weet alleen
de frontproxy.

**Alternatief, nog niet gebouwd:** XInclude — 1 gedeeld WSDL-fragment (schema + operaties) plus 3 dunne
bestanden die alleen het adres verschillen en de rest includen. Eenvoudiger dan een runtime-script, maar
vereist wel een resolutiestap (XInclude wordt niet automatisch opgelost bij statische bestand-serving) —
bijvoorbeeld één `xmllint --xinclude`-stap tijdens de Docker-build, eenmalig, geen custom
runtime-logica. **Niet aangeraakt, nog te bouwen en te testen.**

---

## 2. WSDL — operatie `opslaanInk` ontbreekt in portType/binding — ✅ **Opgelost**

`opslaanInk` (de variant zonder BSN én zonder KVK-nummer, broertje van `opslaanInkNatuurlijkPersoon` /
`opslaanInkNietNatuurlijkPersoon`) had wel het schema-element, maar geen `wsdl:message`,
`portType`-operatie of `binding`-operatie. De dispatcher routeerde 'm intern al wel, maar een partij die
de WSDL gebruikt om een client te genereren (Atabix) kon de operatie niet zien.

**Gedaan:** toegevoegd aan alle drie WSDL-bestanden, naar het patroon van `opslaanInkNatuurlijkPersoon`.
**Getest** met `zeep` (een echte WSDL-consumerende SOAP-client, zoals Atabix dat ook zou doen):
`opslaanInk` is nu een gegenereerde, aanroepbare operatie. SoapUI-dekking toegevoegd.

---

## 3. WSDL — dode legacy-operaties in portType/binding — ✅ **Opgelost**

`maakInkomendDocumentregistratie` en `bewaarDocument` stonden nog in het contract, maar werden nergens
meer gerouteerd door de dispatcher.

**Gedaan:** verwijderd uit `wsdl:message`, `portType` en `binding` in alle drie WSDL-bestanden (de
schema-elementen zelf blijven staan, zijn nu ongebruikte types — geen functioneel risico).
**Getest** met `zeep`: beide operaties zijn niet meer aanwezig als callable operatie.

---

## 4. Foutafhandeling — geen kloppende HTTP/SOAP-foutcode, inconsistente hoeveelheid detail — ✅ **Opgelost**

Live getest: bij fouten die de invoervalidatie voorbij zijn stuurde de integratie **HTTP 200** met een
zelfgebouwd Fault-achtig element, in plaats van een echte SOAP Fault met HTTP 500. Daarnaast varieerde de
hoeveelheid detail onbedoeld: soms "No Error Info" (te karig), soms een volledige stacktrace (an sich
prima — dat blijft binnen de Atabix-integratie en meer detail is juist gewenst) — maar dat verschil was
toeval, geen bewuste keuze.

**Gedaan:**
- Alle `EXCEPTION`-exits (9 Configuration-bestanden) krijgen nu `code="500"`.
- De gedeelde Fault-XSLT's bouwen nu een structureel correcte `<SOAP-ENV:Fault>` in plaats van het
  non-standaard `<tns:Fault>`.
- De drie Corsa-adapters routeren nu ook consistent via `isErrorXML`, net als de CAReL-adapters (6
  gevonden inconsistenties gecorrigeerd).

**Getest, dubbel bevestigd:** curl toont nu HTTP 500 + correcte `<SOAP-ENV:Fault>`; `zeep` herkent de
respons nu als `zeep.exceptions.Fault` met bruikbare `.code`/`.message`. SoapUI-testcase
"Foutscenarios opslaanAanvraagNatuurlijkPersoon" bijgewerkt.

---

## 5. Copy-paste-typo `username`/`password` in 3 Corsa-auth Params — ✅ **Opgelost**

`Configuration_OpslaanInk.xml`, `...OpslaanInkNietNatuurlijkPersoon.xml` en `...OpslaanBijlage.xml` hadden
`username="NO_PASS"` waar `password="NO_PASS"` bedoeld is.

**Gedaan:** gecorrigeerd in alle drie bestanden. Betreft een fallback die alleen relevant is als de
`corsa-soap.connect`-credential ooit faalt — nu werkt dat prima, dus geen waarneembaar effect op de
huidige werking.

---

## 6. CAReL-mapping — adres-splitsing + dagstructuur (bevestigd meerwerk) — **Open**

Aanvrager/leerling/school-adres moeten gesplitst worden (straat, huisnummer, huisletter, toevoeging apart
i.p.v. gecombineerd), en de vervoersdagen moeten als Ja/Nee + begin-/eindtijd per dag aangeleverd worden
i.p.v. de huidige kommagescheiden waarde.

- **Zelf te doen?** Technisch ja. Praktisch onzeker: de dagstructuur-wijziging hangt af van
  formuliervelden voor begin-/eindtijd die mogelijk nog niet bestaan (open punt bij Hein, zie
  scopedocument §6).
- **Tijdsinschatting:** ~0,5-1 dag voor de adres-splitsing; dagstructuur onbekend totdat bevestigd is
  welke formuliervelden er zijn.
- **Gesprek met WeAreFrank?** Al benoemd als meerwerk (overleg geweest **dat** het meerwerk is), maar
  niet over wie het uitvoert of wanneer — dat ligt bij de pauze/evaluatie in september. **Niet
  aangeraakt.**

---

## 7. CAReL-mapping — `heeftBetrekkingOp` ontbreekt, `verwerkingssoort` moet "I" zijn, verblijfsadres ontbreekt bij betrokkenen — **Open**

Vastgestelde afwijkingen t.o.v. de Eljakim-referentie: de leerling wordt niet als `heeftBetrekkingOp`
meegestuurd, `verwerkingssoort="T"` moet `"I"` zijn voor de NPS-referenties, en `verblijfsadres` ontbreekt
bij de betrokkenen.

- **Zelf te doen?** Technisch ja, zelfde onderbouwing als #6.
- **Tijdsinschatting:** ~0,5 dag (`verwerkingssoort` is triviaal; `heeftBetrekkingOp` toevoegen kost het
  meeste tijd).
- **Gesprek met WeAreFrank?** Zelfde status als #6 — benoemd als afwijking, geen concrete afspraak over
  uitvoering. **Niet aangeraakt.**
