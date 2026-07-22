# Delta formulierversie leerlingenvervoer: 2025 vs. 2026

**Datum:** 22 juli 2026
**Bron nieuwe versie:** Ladybug-capture `tmp/Pipeline WebformulierenVerwerker_WebformulierenVerwerker-opslaanAanvraagNatuurlijkPersoon.xml`
(testaanvraag verzonden door Hein Vlietstra, 21 juli 2026, zie ook `tmp/Re_ Xml.eml`).
**Bron oude versie:** `docs/carel/20260302/Leerlingenvervoer.xml` (voorbeeld-capture 29 januari 2026,
schooljaar 2025-2026).

## Samenvatting

De nieuwe formulierversie (schooljaar 2026-2027) levert de `aanvraagxmldata` (het XML-deel van de
`opslaanAanvraagNatuurlijkPersoon`-aanroep) in een **structureel andere vorm** aan dan de oude versie.
Dit is niet cosmetisch: de bestaande XSLT-mapping naar CAReL (`creeerZaak_Lk01_mapping.xsl`) selecteert
op het oude pad en levert bij de nieuwe XML **niets** op. Zonder aanpassing van de XSLT zal een
CAReL-aanvraag met de nieuwe formulierversie een (grotendeels) lege zaak opleveren.

## 1. Structuurverandering

**Oud (2025-2026, geëxporteerd 29-1-2026):**
```xml
<FORMULIER>
  <FORMULIERID>Aanvraag Leerlingenvervoer</FORMULIERID>
  <DATUMVERZENDING>2026-01-29T09:35:46</DATUMVERZENDING>
  <ELEMENTEN>
    <form ...>
      <answers uniqueId="...">
        <globals>
          <bsn key="900106505">900106505</bsn>
          <stuf><geslachtsnaam key="">Witteveen</geslachtsnaam> ...</stuf>
        </globals>
        <fleerlingenvervoerv3gegevensburger>
          <telefoonnummer key="">0515123456</telefoonnummer>
          <emailadres key="">h.vlietstra@sudwestfryslan.nl</emailadres>
          ...
        </fleerlingenvervoerv3gegevensburger>
        ...
      </answers>
    </form>
  </ELEMENTEN>
</FORMULIER>
```
Genest, met een vaste padstructuur per formulierpagina/veld — precies wat de XSLT verwacht.

**Nieuw (2026-2027, geëxporteerd 21-7-2026):**
```xml
<output>
  <transformedData>
    <element><name>form</name><value>[... 14.941 tekens, alle configwaarden aan elkaar geplakt zonder scheiding ...]</value></element>
    <element><name>answers</name><value>[... 11.654 tekens, zelfde probleem ...]</value></element>
    <element><name>globals</name><value>...</value></element>
    <element><name>bsn</name><value>900106505</value></element>
    <element><name>geslachtsnaam</name><value>Witteveen</value></element>
    <element><name>telefoonnummer</name><value>0515123456</value></element>
    ...
  </transformedData>
</output>
```
Plat: geen pad meer, alleen een lijst van `<name>`/`<value>`-paren. Er is geen `FORMULIER`,
`ELEMENTEN`, `form` of `answers`-*element* meer in de zin van een container — dat zijn nu zelf
losse `<name>`-waarden geworden, met als `<value>` een grote, onleesbare aaneenschakeling van tekst
(zie hieronder, punt 3).

## 2. Bevestigde breuk: XSLT-mapping selecteert niets meer

`src/main/configurations/WebformulierenVerwerker/xsl/OpslaanAanvraagLeerlingenVervoerNatuurlijkPersoon/creeerZaak_Lk01_mapping.xsl:21`:
```xslt
<xsl:apply-templates select="/FORMULIER/ELEMENTEN/form/answers"/>
```
Dit pad matcht niets meer in de nieuwe XML — de root is nu `/output/transformedData/element/...`.
Het volledige `answers`-template (regels 27 e.v.), dat alle StUF-velden opbouwt (`ZKN:kenmerk`,
`BG:inp.bsn`, alle `aanvrager_*`-extraElementen, `fleerlingenvervoerv3vervoer`, etc. — regels 53, 56,
69, 89-103, 136), wordt dus **niet meer aangeroepen**. Praktisch gevolg: met de nieuwe formulierversie
komt er geen (of een nagenoeg lege) zakLk01-bericht bij CAReL aan, ook al bevat de binnenkomende
SOAP-call verder gewoon een geldige PDF en XML.

Dit is met de code geverifieerd (XPath-selectie tegen de nieuwe root levert een lege node-set op), niet
alleen afgeleid — maar **niet getest tegen een echt draaiende Frank!Framework-instantie**. Dat zou de
laatste bevestiging zijn.

## 3. Extra risico: platte structuur is ambigu, ook na een eventuele fix

Zelfs als de XSLT wordt herschreven om vanaf `/output/transformedData/element` te werken, is de nieuwe
data zelf lastiger éénduidig te mappen:

- **629 naam/waarde-paren, maar slechts 212 unieke namen** — 89 namen komen meer dan één keer voor.
  Voorbeelden: `bsn` (7×), `telefoonnummer` (5×), `emailadres` (4×), `code` (4×). Zonder padcontext is
  met een simpele naam-lookup niet te bepalen welke `telefoonnummer` bij de aanvrager hoort en welke bij
  bijvoorbeeld het gemeentelijk contactnummer.
- De elementen `form`, `answers` en `globals` zijn zelf ook `<name>`-waarden geworden, met als inhoud een
  aaneengeplakte tekstbrij van duizenden tekens (14.941 / 11.654 / 3.197 tekens) zonder scheidingstekens
  tussen de oorspronkelijke veldwaarden — deze drie zijn functioneel onbruikbaar als databron.
- Sommige waarden lijken de vraagtekst en het antwoord samengevoegd te bevatten (bv.
  `welkschooljaar` komt zowel voor als schone waarde `"2026 - 2027"` als (elders) `"Voor welk
  schooljaar wil je leerlingenvervoer aanvragen?2026 - 2027"`), wat wijst op een samenvattings-/displaylaag
  die door elkaar loopt met de ruwe formulierdata.

**Dit patroon (containers die zelf als platte waarde verschijnen, gecombineerd met losse leaf-velden)
lijkt niet op een bewuste ontwerpkeuze, maar op een exportfout aan de kant van het formulierenplatform
(Atabix/TriplEforms/Kodison)** — het is het overwegen waard om dit als vraag/bugmelding bij die leverancier
neer te leggen, in plaats van er meteen een nieuwe XSLT-mapping op te bouwen. Dit is een inschatting, geen
bevestigd feit — ik heb geen inzicht in hoe dat platform zijn export genereert.

## 4. Wat NIET veranderd is

- De SOAP-operatie en het schema van `opslaanAanvraagNatuurlijkPersoon` zelf zijn ongewijzigd
  (`afzenderbsn`, `aanvraagtype`, `omschrijving`, `vertrouwelijkheid`, `aanvraagpdfname`,
  `aanvraagpdfdata`, `aanvraagxmldata` — zie `GeneriekeFormulierAfhandeling.wsdl:144-156`).
- `aanvraagpdfdata` is in de nieuwe capture nog steeds een geldige, leesbare PDF (82.738 bytes,
  begint met `%PDF-1.7`).
- Testgegevens gebruiken hetzelfde BSN (900106505) en dezelfde naam (Witteveen) als de oude
  referentievoorbeelden — dit is duidelijk dezelfde interne testidentiteit, geen nieuwe/onbekende
  burger.

## 5. Gevolg voor de nieuwe SoapUI-testcase

De testcase **"WebformulierenVerwerker Carel TestCase (2026)"** (nieuw toegevoegd aan
`e2e/webformulierenverwerker-soapui-project.xml`) gebruikt bewust de hierboven beschreven nieuwe,
structureel afwijkende `aanvraagxmldata`. **Verwacht daarom dat deze testcase faalt of een leeg/onvolledig
CAReL-bericht oplevert totdat de XSLT-mapping is aangepast** — dat is niet een fout in de test, maar
precies het probleem dat deze analyse blootlegt.

## Openstaande vragen

- Is deze exportvorm bewust gewijzigd door Atabix/Kodison, of is dit een fout in de nieuwe
  formulierversie? (navragen bij Hein Vlietstra / leverancier)
- Zo bewust: is er een stabiel, gedocumenteerd schema voor deze nieuwe vorm, of moet WeAreFrank de XSLT
  baseren op deze ene capture?
- Moet de XSLT-mapping worden herzien voordat de nieuwe formulierversie live mag, of blijft de oude
  formulierversie nog in gebruik totdat dit is opgelost?
