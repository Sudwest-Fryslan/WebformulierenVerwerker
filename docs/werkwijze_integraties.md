# Werkwijze: hoe we koppelingen bouwen

Deze werkwijze geldt voor alle koppelingen in dit project (CAReL, Corsa, ZAC) en is algemeen genoeg
voor integratiewerk daarbuiten. Ze is ontstaan uit de CAReL-leerlingenvervoerkoppeling, waar de omgekeerde
volgorde — eerst bouwen, dan pas afspreken — herhaaldelijk tot herwerk leidde.

## Het uitgangspunt: het contract is de basis

Het **veldencontract** is de bron van waarheid. Niet de mapping-XSLT, niet een scopedocument, niet een
mailwisseling. Voor de CAReL-koppeling is dat `docs/carel/veldencontract_leerlingenvervoer.md`.

- Bij elke vraag over een veld ("moet X erin?", "is Y al opgelost?") beantwoord je die **eerst uit het
  contract**, en pas daarna kijk je wat de code doet.
- Lopen code en contract uit elkaar, dan is het contract leidend en is de code fout — niet andersom.
- Code die toevallig al iets doet, maakt een punt niet "afgesproken". Zolang een afspraak niet met de
  betrokken partij is bevestigd, staat ze in de documentatie als **voorstel/aanname**, expliciet zo
  gemarkeerd.
- **De integratie stuurt alleen door wat het contract kent, op de manier die het contract voorschrijft.**
  Dat het bronsysteem een gegeven aanlevert, is geen reden om het door te sturen; dat een gegeven ook
  ergens anders in het bericht staat, is een reden om het juist níét nog eens los mee te sturen. Wat niet
  in het contract staat, gaat niet mee — hoogstens wordt het een aandachtspunt.

## De vier stappen

**1. Contract bepalen.** Leg de veldnamen en hun betekenis vast in het contractdocument. Dit gebeurt
samen met de ontvangende partij (voor CAReL: de leverancier), want zij moeten er iets mee kunnen.

**2. Testbericht maken.** Zet die velden in een echt voorbeeldbericht in het SoapUI-project
(`e2e/webformulierenverwerker-soapui-project.xml`) en stuur dat naar de ontvangende partij. Zonder
voorbeeldbericht is het contract niet toetsbaar en kan de ontvanger er niets mee — een veld dat alleen
beschreven staat, bestaat in de praktijk nog niet.

**3. Bronsysteem laat aanleveren.** Pas daarna vraag je het bronsysteem (voor CAReL: het Atabix-
webformulier) om de input zo goed mogelijk conform het contract te leveren. Moet het formulier daarvoor
aangepast worden, dan is dat zo — dat is een normale uitkomst van stap 1 en 2, geen probleem.

**4. Integratie bouwen.** De mapping (XSLT) vertaalt wat stap 3 levert naar wat stap 1 en 2 vastleggen.
Dit is de laatste stap, niet de eerste.

## Bij een fout: terug de keten in

Gaat er iets mis, dan zoek je **waar in de keten de aanpassing thuishoort**. Een mismatch is niet
automatisch een integratieprobleem:

| Symptoom | Hoort thuis bij |
|---|---|
| Veld ontbreekt of heet anders dan afgesproken | stap 1, contract |
| Ontvanger kan het veld niet uitproberen | stap 2, testbericht |
| Bronsysteem levert het gegeven niet (of samengevoegd) | stap 3, formulier |
| Bron en contract kloppen, vertaling niet | stap 4, integratie |

De integratie is de laatste plek waar je repareert, niet de eerste. Anders compenseert de mapping
aannames die verderop in de keten thuishoren, en verdwijnt de afspraak uit het zicht.

## De kringloop: aandachtspunten → aanbevelingen → contract

Bouwen en testen levert voortdurend signalen op die niet in de huidige afspraak passen: een veldnaam die
afwijkt, een gegeven dat het bronsysteem wel heeft maar het contract niet kent, invoer die niet netjes
binnenkomt. Die verdwijnen niet in de mapping en ook niet in iemands hoofd — ze krijgen een vaste plek:

1. **Aandachtspunt** — vastgelegd in een genummerde lijst bij het contract (voor CAReL: sectie
   "Aandachtspunten webformulier"), met herkomst en beoogd vervolg. Verzamelen kost niets en blokkeert
   niets.
2. **Aanbeveling** — periodiek maak je van die punten concrete voorstellen aan de partij die erover gaat
   (formulierbeheerder, leverancier).
3. **Contract bijstellen** — komt er een besluit uit, dan gaat dat eerst het contract in, niet meteen de
   code.
4. **Keten opnieuw** — daarna volgen testbericht, bronsysteem en integratie, in die volgorde.

Zo blijft de afspraak sturend en wordt de integratie geen verzamelplaats van uitzonderingen. Een
afwijking die om een goede reden blijft bestaan, hoort thuis in het contract als expliciete keuze — niet
als stille compensatie in de XSLT. Tot een bijstelling rond is mag de integratie een afwijking tijdelijk
opvangen, zodat het bouwen doorloopt; dat is een overbrugging, geen eindstation.

## Het proces is iteratief

Stap 1 en 2 wachten niet op stap 3. We stellen het contract vast en sturen testberichten; blijkt daaruit
dat het webformulier iets moet toevoegen of splitsen, dan volgt die aanpassing daarna. Zo stuurt de
afspraak het bouwwerk aan, in plaats van andersom.

## Naamgeving: volg de standaard van het domein

Veldnamen volgen de vaktermen van het domein, niet het spraakgebruik van het formulier. Voor adressen is
dat de **BAG**: `openbare_ruimte_naam` (niet "straat"), `huisnummer`, `huisletter`,
`huisnummertoevoeging`, `postcode`, `woonplaats` — dezelfde termen die de StUF/BG-structuur al gebruikt
(`gor.openbareRuimteNaam`, `aoa.huisnummer`, `wpl.woonplaatsNaam`, …).

Dat kan betekenen dat een bestaand veld hernoemd moet worden. Eén consistente naamgeving over alle
adressen heen is dat waard: de ontvangende partij zoekt adressen zelf op in de BAG, en herkent de
onderdelen dan zonder vertaalslag.

Dezelfde regel geldt aan de **bronkant**, maar dan als verzoek. Het bronsysteem mag zijn velden zelf een
naam geven, en wijkt die af, dan vangt de integratie dat op — daar hoeft niemand op te wachten. Maar we
leggen het gewenste patroon wel vast en vragen erom, omdat elke afwijking een vertaalslag is die stilletjes
fout kan gaan. Houdt het bronsysteem zich er niet aan, dan vragen we alsnog om aanpassing. Documenteer
daarom altijd, naast de contractvelden, **welk bronveld waar vandaan komt** — zie het veldencontract,
sectie "Bronveldnamen Atabix".

## Omgevingen en begrippen

Er zijn veel dingen die "test" heten en dat leidt tot misverstanden. We gebruiken daarom **acceptatie**
voor de omgeving waarop we vóór productie de keten beproeven, en houden de naamgeving per partij uit
elkaar:

| Wat | Waar | Waarvoor |
|---|---|---|
| **VDI-ontwikkelmachine** | binnen het SWF-netwerk | De enige plek van waaruit we CAReL-acceptatie kunnen bereiken. Hier draaien SoapUI én een lokale integratie |
| **Ontwikkellaptop / WeAreFrank intern** | buiten het SWF-netwerk | Het echte bouwwerk: code, XSLT, configuratie. Geen verbinding met CAReL |
| **CAReL-acceptatie** | `https://testtsjinstbus.sudwestfryslan.nl/CARELLG/stuf-zkn/sudwestfryslan` | Ontvangende kant, beheerd door Eljakim |
| **SWF-acceptatie** | interne SWF-omgeving | Draait de gepubliceerde Docker-image; hier testen we de hele keten |
| **Kodison/Atabix-acceptatie** | Atabix | Het webformulier waar de aanvraag begint |
| **Productie** | — | Pas aan de beurt als acceptatie volledig goed gaat |

De endpoints staan op twee plekken, en dat is een valkuil: de SoapUI-projectproperty
`CarelZdsOntvangAsynchroonEndpoint` wijst naar CAReL-acceptatie, maar
`DeploymentSpecifics.properties` van de applicatie wijst standaard naar een **lokale mock**
(`host.docker.internal:7771`). Wie de integratie op de VDI echt naar CAReL wil laten sturen, moet die
property overschrijven — anders test je tegen de mock en lijkt alles te werken.

---

## De testladder

Vier trappen, in deze volgorde. Elke trap voegt precies één onbekende toe, zodat een fout altijd
toewijsbaar is aan wat er nieuw bij kwam.

### Trap 1 — SoapUI rechtstreeks naar CAReL-acceptatie

Vanaf de VDI-ontwikkelmachine, met de testberichten uit
`e2e/webformulierenverwerker-soapui-project.xml`. De integratie doet niet mee.

Dit toetst het **contract**: accepteert CAReL de berichtstructuur en de veldnamen? Een `Bv03Bericht` met
matchend `crossRefnummer` betekent goedgekeurd; een SOAP Fault wijst op het contract, niet op onze code.
Zo is op 24 juli zaak 1900881353 beproefd.

### Trap 2 — SoapUI naar de integratie op de VDI, die doorstuurt naar CAReL-acceptatie

Integratie én SoapUI draaien op de VDI (`docker compose -f compose.frank.dev.yaml up`). Nieuwe onbekende:
**onze mapping**. Het contract is in trap 1 al goedgekeurd, dus wat hier misgaat komt van de vertaling.

Vergeet de CAReL-URL in `DeploymentSpecifics.properties` niet om te zetten van de mock naar
CAReL-acceptatie. Ladybug (in de Frank!Console) laat zien wat er werkelijk de deur uit ging.

### Trap 3 — Heins aangepaste formulier door dezelfde integratie

Hein past het webformulier aan, wij krijgen de resulterende aanvraag-XML en spelen die via SoapUI door de
integratie op de VDI. Nieuwe onbekende: **de echte invoer**.

Dit is de trap die in juli en september de meeste fouten opleverde — hernoemde secties, ontbrekende
velden, een afwijkende structuur. Zie ook de mapping-controles: een aanvraag met een onverwachte
structuur hoort een leesbare fout op te leveren, geen leeg bericht.

### Trap 4 — de hele keten op SWF-acceptatie

Kan pas ná de releasestraat hieronder, want hiervoor moet de nieuwe versie gedeployed zijn:
**Kodison-acceptatie → integratie op SWF-acceptatie → CAReL-acceptatie**. Nieuwe onbekenden: de echte
omgeving, echte netwerkpaden, echte credentials.

### Daarna pas productie

Alleen als trap 4 volledig goed gaat. Zelfde route, zelfde image, andere omgeving.

---

## Voordat je een pull request opent

Trap 1 tot en met 3 tonen aan dat de koppeling **functioneel** klopt. Deze controles tonen aan dat de
wijziging **bouwbaar** is. Ze kosten samen een paar minuten en voorkomen dat de reviewer of de
build-pipeline een fout vindt die je zelf had kunnen zien. Loop ze in deze volgorde af.

Voor de eerste twee is Saxon nodig — dezelfde XSLT-processor die het Frank!Framework gebruikt. Download
Saxon-HE plus `xmlresolver.jar` en `xmlresolver-data.jar`, en zet ze samen op het classpath (Saxon 12
start niet zonder de resolver).

### 1. Draait de mapping op echte formulierdata?

```bash
java -cp "<saxon>/Saxon-HE-12.5.jar;<saxon>/xmlresolver.jar;<saxon>/xmlresolver-data.jar"   net.sf.saxon.Transform   -s:<echte-capture>.xml   -xsl:src/main/configurations/WebformulierenVerwerker/xsl/OpslaanAanvraagLeerlingenVervoerNatuurlijkPersoon/creeerZaak_Lk01_mapping.xsl   randomuuid=test zaakid=1900999999 stuf_zender_organisatie=1900   stuf_zender_applicatie=WFK stuf_zender_gebruiker=G   stuf_ontvanger_organisatie=1900 stuf_ontvanger_applicatie=CAREL
```

Gebruik een **echte capture**, geen zelfgemaakt bestand — juist de afwijkingen in echte data leggen
fouten bloot. Controleer daarna niet alleen of het draait, maar of er velden **leeg** terugkomen:

```bash
grep -oE '<StUF:extraElement naam="[^"]+"/>' uitvoer.xml
```

Een leeg veld is geen detail. In september kwamen er zo zeventien leeg terug omdat een formuliersectie
was hernoemd — de transformatie draaide zonder klagen. Elk leeg veld moet je kunnen verklaren.

### 2. Compileren alle XSLT's?

```bash
for x in $(find src/main/configurations -name "*.xsl"); do
  java -cp "<saxon-classpath>" net.sf.saxon.Transform -xsl:"$x" -it:nonexistent 2>&1     | grep -E "Static error|XPST|XTSE" && echo "FOUT in $x"
done
```

Vangt typefouten in XPath en verkeerde parametertypes die je anders pas in de draaiende applicatie ziet.

### 3. Is alle XML welgevormd?

Configuratiebestanden, WSDL's en het SoapUI-project. Dat laatste is een groot bestand dat vaak met
scripts bewerkt wordt, dus juist daar loont de controle:

```bash
python -c "import xml.dom.minidom, glob; [xml.dom.minidom.parse(f) for f in
  glob.glob('src/main/configurations/**/*.xml', recursive=True) +
  glob.glob('src/main/configurations/**/*.wsdl', recursive=True) +
  glob.glob('e2e/*.xml')]; print('alles welgevormd')"
```

### 4. Lopen contract, mapping en testberichten gelijk?

De veldenset in het veldencontract, in de mapping en in elk CAReL-testbericht hoort identiek te zijn.
Vergelijk ze scriptmatig in plaats van met het oog: haal de `extraElement naam="..."`-waarden uit de
XSLT, uit elk testbericht en uit het contract, en verschil de verzamelingen. Een veld dat in de mapping
zit maar niet in het contract betekent dat de integratie iets stuurt wat niemand heeft afgesproken.

### 5. Werkt de JAR-stap uit de release-job?

Dezelfde regel die de pipeline draait:

```bash
jar cvf /tmp/WebformulierenVerwerker.jar -C src/main/configurations WebformulierenVerwerker
```

### 6. Bouwt de Docker-image?

```bash
docker compose -f compose.frank.dev.yaml build
```

Dit is de enige controle die een draaiende Docker-daemon vereist en dus niet overal kan. Kun je het niet
draaien, **zeg dat dan** in de pull request in plaats van het stilzwijgend over te slaan — de pipeline
bouwt hem alsnog bij de PR, maar de reviewer moet weten wat er wel en niet lokaal is nagegaan.

### 7. Staan er geen persoonsgegevens in de diff?

Deze repo is publiek.

```bash
git diff main...HEAD | grep -E '^\+' | grep -ioE "[a-z0-9._%-]+@[a-z0-9.-]+\.[a-z]{2,}" | sort -u
git diff --name-status main...HEAD | grep -E "^A" | grep -iE "\.eml|\.pdf"
```

Verwacht alleen de vaste fictieve testset. Ruwe formuliercaptures, e-mailexports en PDF-samenvattingen
horen hier niet in; die blijven intern gearchiveerd.

### 8. Levert je commit-geschiedenis de bedoelde versie op?

```bash
git log --format='%s' main..HEAD | sed 's/:.*//' | sort | uniq -c
```

Zit er geen `feat:` of `fix:` tussen en alleen `chore:`, dan komt er **geen release** en dus geen image om
te deployen. Zie de versietabel hieronder.

---

## Van pull request naar acceptatieomgeving

Gaan trap 1 tot en met 3 goed, dan pas een pull request. Wat er daarna gebeurt:

1. **Pull request op `main`.** De build draait al bij een PR, maar publiceert nog niets.
2. **WeAreFrank reviewt en keurt goed.** Zij nemen de applicatie in beheer, dus alles gaat langs hen —
   zie `README.md`, sectie Reviewproces.
3. **Merge naar `main`.** Dat is de trigger; niets ervoor publiceert.
4. **GitHub Actions** (`.github/workflows/ci-build.yml`) bepaalt de versie, bouwt de Docker-image,
   maakt een GitHub-release met de configuratie-JAR en pusht de image naar Docker Hub als
   `wearefrank/webformulierenverwerker`, met tags voor de volledige versie, `major.minor`, `major` en
   `latest`.
5. **Technisch beheer (WeAreFrank)** zet de juiste versie op de SWF-acceptatieomgeving. Wij deployen niet
   zelf; wij geven door welke versie erop moet.
6. **Trap 4** kan draaien.

---

## Versienummers: automatisch, niet handmatig

Het versienummer wordt **niet met de hand opgehoogd**. `semantic-release` leidt het af uit de
commit-berichten sinds de vorige release, en werkt `CHANGELOG.md`, `src/main/resources/BuildInfo.properties`
en `publiccode.yaml` zelf bij. Die bestanden zelf aanpassen levert alleen een merge-conflict op.

| Commit-type | Ophoging |
|---|---|
| `BREAKING CHANGE` in de footer | major |
| `feat:` | minor |
| `fix:`, `perf:`, `revert:`, `docs:`, `style:`, `refactor:`, `test:`, `build:`, `ci:` | patch |
| `chore:` | geen release |

Het gevolg: **hoe je je commit-bericht schrijft, bepaalt het versienummer.** Een mappingwijziging als
`chore:` labelen betekent geen nieuwe image, en dus niets om te deployen.

---

## Waarom zo

- De ontvangende partij kan pas meedenken als er een concreet bericht ligt, niet bij een beschrijving.
- Het bronsysteem hoeft maar één keer te bouwen, tegen een vastgelegde afspraak.
- Bij een storing is meteen duidelijk wie aan zet is, omdat elke stap een eigen eigenaar heeft.
- De integratie blijft een vertaling, geen verzameling stille aannames.
