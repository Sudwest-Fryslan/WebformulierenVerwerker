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
| 7 | CAReL `heeftBetrekkingOp` / `verwerkingssoort` | **Ja** | ✅ Opgelost | Gedaan | Check bij Petra/Eljakim nog nodig (geen code-actie) |

**Kernpunt:** 6 van de 7 punten zijn opgelost en getest (#2 t/m #5 generieke Corsa/integratiekwaliteit,
#7 CAReL-mapping). Nog open: **#1** (WSDL structureel — al toegezegd door WeAreFrank; een werkende
technische oplossing is gebouwd, live getest, en weer teruggedraaid omdat het te veel eigen mechanisme
was — zie sectie 1 voor een eenvoudiger XInclude-alternatief, nog niet gebouwd) en **#6** (CAReL
adres-splitsing + dagstructuur — wacht op nieuwe formuliervelden van Hein, en op afstemming met Eljakim
over de vrije velden, zie sectie 6). Alles is gecommit op branch `fix/integratie-openstaande-punten-juli-2026`
(nog niet gepusht/gemerged).

**Update 24 juli 2026:** de #7-fix is handmatig, rechtstreeks tegen de CAReL-testomgeving getest (los van
de WebformulierenVerwerker, via SoapUI) — zaak 1900881353, met `heeftBetrekkingOp` (leerling) en de
volledige `heeftAlsInitiator` (aanvrager). CAReL accepteerde het bericht (`Bv03Bericht`-bevestiging, geen
SOAP Fault). Zie sectie 7 voor details. Diezelfde dag heeft Eljakim (Lorenzo van den Oudenrijn) drie
concrete bevindingen teruggekoppeld over de eerdere testzaken — zie secties 6 en 7 voor de uitwerking.

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

**Update 19 augustus 2026 — definitieve lijst na terugkoppeling Lorenzo (Eljakim, via Petra):** Lorenzo
bevestigt dat de berichtstructuur verder in orde is ("de mapping in CARel is in ieder geval in orde") en
geeft een concrete prioriteitenlijst van velden. Daaruit blijven twee concrete, losse acties over:

1. **Adres-splitsing** — expliciet bevestigd door Lorenzo voor zowel het leerling- als het
   schooladres: straat, huisnummer, huisletter, huisnummertoevoeging apart i.p.v. gecombineerd. De
   aanvrager-kant (uit de BRP-prefill) levert dit al gesplitst aan; nog na te gaan of het webformulier
   deze velden voor leerling/school ook los uitvraagt (vraag aan Hein).
2. **Volledige keuzelijsten voor de twee bekende mismatch-velden** — `vervoer_type` en de
   dag/dagdeel-velden (`vervoer_maandag` t/m `vervoer_vrijdag`, momenteel samengevoegd tot één
   tekstwaarde per dag). CAReL loopt hier specifiek op vast (ja/nee-vertaling lukt niet zonder de
   volledige lijst mogelijke antwoorden). Vraag aan Hein: welke keuzeopties bestaan er per veld.

- **Zelf te doen?** De adres-splitsing technisch ja, zodra bekend is welke formuliervelden er zijn. De
  vervoer-/dagstructuur-mapping ook zelf te bouwen zodra de volledige optielijst van Hein binnen is —
  hangt dus niet meer op een principiële CAReL-vraag, alleen nog op formulier-informatie.
- **Tijdsinschatting:** ~0,5-1 dag voor de adres-splitsing; dagstructuur-mapping vergelijkbare orde van
  grootte zodra de optielijst bekend is.
- **Gesprek met WeAreFrank?** Al benoemd als meerwerk (overleg geweest **dat** het meerwerk is), maar
  niet over wie het uitvoert of wanneer — dat ligt bij de pauze/evaluatie in september. **Niet
  aangeraakt.**

---

## 7. CAReL-mapping — `heeftBetrekkingOp` ontbreekt, `verwerkingssoort` moet "I" zijn, verblijfsadres ontbreekt bij betrokkenen — ✅ **Opgelost**

Vastgestelde afwijkingen t.o.v. de Eljakim-referentie: de leerling werd niet als `heeftBetrekkingOp`
meegestuurd, `heeftAlsInitiator` (aanvrager) had alleen BSN, en `verwerkingssoort` stond op `"T"` i.p.v.
`"I"`.

**Gedaan, op verzoek van Eduard:**
- `heeftBetrekkingOp` (leerling) toegevoegd met alle leerlinggegevens die het formulier al levert (BSN,
  voornamen, tussenvoegsel, achternaam, geboortedatum, geslachtsaanduiding), `verwerkingssoort="I"`.
  Verblijfsadres conditioneel: aanvrageradres overnemen als `leerlinganderadres = "Ja"`, anders bewust
  weggelaten (formulier heeft nog geen eigen leerlingadresvelden — zie #6).
- `heeftAlsInitiator` (aanvrager) uitgebreid van alleen BSN naar volledige persoonsgegevens + adres,
  ook `verwerkingssoort="I"` — alles uit de BRP-prefill, **geen formulierwijziging nodig** voor dit deel.

**Getest** met Saxon, oude én nieuwe formulierformaat — steeds correcte, volledig gevulde XML, geen
regressie op de rest van het bericht.

**Empirisch bevestigd tegen echte CAReL-testomgeving (24 juli 2026):** handmatig, los van de
WebformulierenVerwerker, een bericht met deze nieuwe mapping rechtstreeks naar CAReL-acceptatie gestuurd
(`https://testtsjinstbus.sudwestfryslan.nl/CARELLG/stuf-zkn/sudwestfryslan`) — zaak 1900881353, leerling
BSN 197642378 via `heeftBetrekkingOp`, aanvrager BSN 900106505 met volledige gegevens via
`heeftAlsInitiator`. CAReL accepteerde het bericht: HTTP 200, `Bv03Bericht`-bevestiging met matchend
`referentienummer`/`crossRefnummer`, geen SOAP Fault. Bevestigt dat de berichtstructuur (twee losse
rollen, volledige NPS-objecten) door CAReL wordt geaccepteerd.

**Nog open, geen code-actie:**
1. ~~Of CAReL's eigen software akkoord gaat met "BSN + basisgegevens"~~ — **bijgesteld, 24 juli 2026:**
   Eljakim (Lorenzo van den Oudenrijn) meldt dat CAReL het BSN prima herkent en zelf een BRP-bevraging
   doet om de persoonsgegevens aan te vullen; bij de eerdere testzaak (1900881137, verstuurd met de oude,
   BSN-only mapping) faalde die BRP-bevraging met een **HTTP 500 "proxy niet gevonden"** op de
   CAReL-acceptatieomgeving. Dit is een **infrastructuurprobleem aan de kant van Eljakim/CAReL**, los van
   hoeveel gegevens wij meesturen. Nog te bevestigen: of onze nu volledig gevulde `heeftAlsInitiator`/
   `heeftBetrekkingOp` de persoon ook zonder werkende BRP-koppeling al met de juiste gegevens vult (test
   hierboven toont aan dat CAReL het bericht in elk geval accepteert; of de persoon nu wél gegevens heeft
   moet Pieter/Eljakim nog in CAReL zelf controleren voor zaak 1900881353).
2. BRP levert `inp.geboorteplaats` als gemeentecode, niet als plaatsnaam — **eveneens af te stemmen,
   nog open.**
3. De extraElementen `aanvrager_adres` (mist huisnummer), `aanvrager_tussenvoegsel` (hardcoded leeg) en
   `samenvatting_datum`/`samenvatting_tijd` (ontbreken) zijn een **apart** punt, horen bij #6
   (adres-splitsing) en zijn niet meegenomen in deze fix.

Zie `docs/carel/scopedocument.md` §3 voor de volledige onderbouwing.

- **Zelf te doen?** Ja, gedaan.
- **Gesprek met WeAreFrank?** Niet nodig geweest voor de implementatie zelf — wel nog een check bij
  Petra/Eljakim nodig of de gekozen aanpak (BSN-plus, geen volledig adres) door CAReL geaccepteerd wordt.
