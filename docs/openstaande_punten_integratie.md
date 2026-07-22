# Openstaande punten WebformulierenVerwerker-integratie

Overzicht van technische openstaande punten in de WebformulierenVerwerker-repo (dus niet de punten die
bij Hein/Atabix, Petra/CAReL-beheer of Eljakim liggen — dat staat in `docs/carel/scopedocument.md`).
Per punt: kunnen we dit zelf oplossen, hoeveel tijd zou dat kosten, en is hier al met WeAreFrank over
gesproken.

**Nog niets van onderstaande is opgepakt of gewijzigd** — dit is alleen het overzicht. De SoapUI-testcases
die de problemen bij #4 aantonen staan al klaar (zie `e2e/webformulierenverwerker-soapui-project.xml`,
testcase "Foutscenarios opslaanAanvraagNatuurlijkPersoon").

---

## 1. WSDL — 3 losse bestanden, handmatig gesynchroniseerd

Er zijn drie kopieën van `GeneriekeFormulierAfhandeling.wsdl` die alleen verschillen in de host-URL. Bij
elke uitbreiding moeten alle drie handmatig bijgewerkt worden (ging al eens mis in mei 2026).

- **Zelf te doen?** Twijfelachtig. De schone oplossing (1 WSDL, omgevingsafhankelijke URL) vraagt
  waarschijnlijk om een wijziging in de build/deploy-pipeline (WSDL's zijn statische bestanden, geen
  runtime-property-substitutie), niet alleen een XML-edit. Dat ligt buiten wat we vanavond hebben
  gedaan.
- **Tijdsinschatting:** 1-2 dagen, met onzekerheid (onderzoek naar de juiste aanpak telt mee).
- **Gesprek met WeAreFrank?** **Ja** — Alexander Raccuglia heeft dit expliciet toegezegd ("WeAreFrank zal
  hier naar kijken"). Zelf oppakken zou die toezegging doorkruisen.

---

## 2. WSDL — operatie `opslaanInk` ontbreekt in portType/binding

`opslaanInk` (de variant zonder BSN én zonder KVK-nummer, broertje van `opslaanInkNatuurlijkPersoon` /
`opslaanInkNietNatuurlijkPersoon`) heeft wel het schema-element, maar geen `wsdl:message`,
`portType`-operatie of `binding`-operatie. De dispatcher routeert 'm intern wel, maar een partij die de
WSDL gebruikt om een client te genereren (Atabix) kan de operatie niet zien.

- **Zelf te doen?** Ja — mechanische, additieve wijziging: exact het patroon van
  `opslaanInkNatuurlijkPersoon` kopiëren naar `opslaanInk`, in alle drie WSDL-bestanden.
- **Tijdsinschatting:** 1-2 uur, inclusief testen dat de dispatcher-validatie nog klopt.
- **Gesprek met WeAreFrank?** Nee, onbekend bij hen voor zover ik kan zien.

---

## 3. WSDL — dode legacy-operaties in portType/binding

`maakInkomendDocumentregistratie` en `bewaarDocument` staan nog in het contract, maar worden nergens meer
gerouteerd door de dispatcher.

- **Zelf te doen?** Ja, na een keuze: eruit halen, of laten staan (met het risico dat een aanroep erop
  faalt).
- **Tijdsinschatting:** 30 min - 1 uur (de wijziging zelf; het besluit erover kost meer tijd dan de edit).
- **Gesprek met WeAreFrank?** Nee.

---

## 4. Foutafhandeling — geen kloppende HTTP/SOAP-foutcode, inconsistente hoeveelheid detail

Live getest vanavond: bij fouten die de invoervalidatie voorbij zijn (dus niet meer een simpel ontbrekend
veld) stuurt de integratie **HTTP 200** met een zelfgebouwd Fault-achtig element, in plaats van een echte
SOAP Fault met HTTP 500. Daarnaast varieert de hoeveelheid detail onbedoeld: soms "No Error Info" (te
karig), soms een volledige stacktrace (prima, want dat blijft binnen de Atabix-integratie en meer detail
is juist gewenst) — maar dat verschil is toeval, geen bewuste keuze.

- **Zelf te doen?** Ja, maar het meest bewerkelijke punt van de vier "eigen" punten — raakt de
  exception-routing in meerdere Configuration-bestanden (Corsa- én CAReL-adapters) en vraagt bredere
  regressietest.
- **Tijdsinschatting:** 1-3 dagen (onderzoek naar hoe Frank!Framework een echte SOAP Fault + HTTP-status
  aanstuurt, wijziging, en testen met de nieuwe SoapUI-foutscenario's + de bestaande testcases).
- **Gesprek met WeAreFrank?** Nee.

---

## 5. Copy-paste-typo `username`/`password` in 3 Corsa-auth Params

`Configuration_OpslaanInk.xml`, `...OpslaanInkNietNatuurlijkPersoon.xml` en `...OpslaanBijlage.xml` hebben
`username="NO_PASS"` waar `password="NO_PASS"` bedoeld is (zoals in `...OpslaanInkNatuurlijkPersoon.xml`
wél goed staat).

- **Zelf te doen?** Ja — triviale eenregelige fix in 3 bestanden.
- **Tijdsinschatting:** 15-30 min, inclusief een korte test.
- **Gesprek met WeAreFrank?** Nee.

---

## 6. CAReL-mapping — adres-splitsing + dagstructuur (bevestigd meerwerk)

Aanvrager/leerling/school-adres moeten gesplitst worden (straat, huisnummer, huisletter, toevoeging apart
i.p.v. gecombineerd), en de vervoersdagen moeten als Ja/Nee + begin-/eindtijd per dag aangeleverd worden
i.p.v. de huidige kommagescheiden waarde.

- **Zelf te doen?** Technisch ja — we hebben vanavond precies dit soort XSLT-wijzigingen gemaakt en met
  Saxon getest. Praktisch onzeker: de dagstructuur-wijziging hangt af van formuliervelden voor
  begin-/eindtijd die mogelijk nog niet bestaan (open punt bij Hein, zie scopedocument §6).
- **Tijdsinschatting:** ~0,5-1 dag voor de adres-splitsing; dagstructuur onbekend totdat bevestigd is
  welke formuliervelden er zijn — schat voorlopig ook 0,5-1 dag, met een reëel risico op meer als velden
  nog toegevoegd moeten worden aan het formulier.
- **Gesprek met WeAreFrank?** Dit is al benoemd als meerwerk (dus er is overleg geweest **dat** het
  meerwerk is), maar niet over wie het uitvoert of wanneer — dat ligt bij de pauze/evaluatie in september.

---

## 7. CAReL-mapping — `heeftBetrekkingOp` ontbreekt, `verwerkingssoort` moet "I" zijn, verblijfsadres ontbreekt bij betrokkenen

Vastgestelde afwijkingen t.o.v. de Eljakim-referentie: de leerling wordt niet als `heeftBetrekkingOp`
meegestuurd, `verwerkingssoort="T"` moet `"I"` zijn voor de NPS-referenties, en `verblijfsadres` ontbreekt
bij de betrokkenen.

- **Zelf te doen?** Technisch ja, zelfde onderbouwing als #6.
- **Tijdsinschatting:** ~0,5 dag (`verwerkingssoort` is triviaal; `heeftBetrekkingOp` toevoegen kost het
  meeste tijd, naar analogie van de bestaande `heeftAlsInitiator`-structuur).
- **Gesprek met WeAreFrank?** Zelfde status als #6 — benoemd als afwijking, geen concrete afspraak over
  uitvoering.

---

## Samenvatting

| # | Punt | Zelf te doen? | Tijdsinschatting | WeAreFrank-gesprek |
|---|------|---------------|-------------------|---------------------|
| 1 | WSDL structureel (1 bestand + omgevingsvariabele) | Twijfelachtig (build-pipeline) | 1-2 dagen | Ja, toegezegd |
| 2 | WSDL `opslaanInk` ontbreekt | Ja | 1-2 uur | Nee |
| 3 | WSDL dode legacy-operaties | Ja (na keuze) | 30 min - 1 uur | Nee |
| 4 | Foutafhandeling HTTP/SOAP-conventie | Ja | 1-3 dagen | Nee |
| 5 | Typo username/password | Ja | 15-30 min | Nee |
| 6 | CAReL adres-splitsing + dagstructuur | Ja (technisch), scope onzeker | 0,5-1 dag+ | Alleen dat het meerwerk is |
| 7 | CAReL heeftBetrekkingOp / verwerkingssoort | Ja | ~0,5 dag | Alleen dat het afwijking is |

**Totaal als we alles zelf zouden doen (excl. #1):** grofweg 3-6 dagen, met de meeste onzekerheid bij #4
(foutafhandeling) en #6 (dagstructuur, afhankelijk van Hein).
