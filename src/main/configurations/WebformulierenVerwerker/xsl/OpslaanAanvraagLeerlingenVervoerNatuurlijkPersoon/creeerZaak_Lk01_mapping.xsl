<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                xmlns:StUF="http://www.egem.nl/StUF/StUF0301"
                xmlns:ZKN="http://www.egem.nl/StUF/sector/zkn/0310"
                xmlns:BG="http://www.egem.nl/StUF/sector/bg/0310"
                exclude-result-prefixes="#all">
    
    <xsl:output method="xml" indent="yes"/>
    <xsl:param name="randomuuid" as="xs:string"/>
    <xsl:param name="zaakid" as="xs:string"/>
    <xsl:param name="stuf_zender_organisatie" as="xs:string"/>
    <xsl:param name="stuf_zender_applicatie" as="xs:string"/>
    <xsl:param name="stuf_zender_gebruiker" as="xs:string"/>
    <xsl:param name="stuf_ontvanger_organisatie" as="xs:string"/>
    <xsl:param name="stuf_ontvanger_applicatie" as="xs:string"/>
    
    <xsl:template match="/">
        <xsl:apply-templates select="/FORMULIER/ELEMENTEN/form/answers"/>
    </xsl:template>
    
    <xsl:template match="@*|node()"/>
    
    <!-- Main template -->
    <xsl:template match="answers">
        <!-- Verplichte velden conform veldencontract (tmp/20260901-velden_carel_met_types.md):
             BSN leerling, BSN aanvrager en vervoer_upload_vervoersverklaring. Ontbreekt een van
             deze, dan stopt de mapping direct met een duidelijke foutmelding i.p.v. een onvolledig
             bericht naar CAReL te sturen - komt via de bestaande foutafhandeling (isErrorXML) terug
             als SOAP-fault naar Atabix/Hein. Extra, hier onbekende velden die Hein meestuurt leveren
             bewust geen fout op: xsl:template match="@*|node()" hierboven negeert die stilzwijgend. -->
        <xsl:call-template name="require-field">
            <xsl:with-param name="veldnaam" select="'BSN leerling (fleerlingenvervoerv3gegevensleerling/bsnleerling)'"/>
            <xsl:with-param name="waarde" select="string(fleerlingenvervoerv3gegevensleerling/bsnleerling)"/>
        </xsl:call-template>
        <xsl:call-template name="require-field">
            <xsl:with-param name="veldnaam" select="'BSN aanvrager (globals/stuf/inp/bsn)'"/>
            <xsl:with-param name="waarde" select="string(globals/stuf/inp/bsn)"/>
        </xsl:call-template>
        <xsl:call-template name="require-field">
            <xsl:with-param name="veldnaam" select="'vervoer_upload_vervoersverklaring (fleerlingenvervoerv3vervoer/bijlagen)'"/>
            <xsl:with-param name="waarde" select="string(fleerlingenvervoerv3vervoer/bijlagen)"/>
        </xsl:call-template>
        <ZKN:zakLk01>
            <ZKN:stuurgegevens>
                <StUF:berichtcode>Lk01</StUF:berichtcode>
                <StUF:zender>
                    <StUF:organisatie><xsl:value-of select="$stuf_zender_organisatie"/></StUF:organisatie>
                    <StUF:applicatie><xsl:value-of select="$stuf_zender_applicatie"/></StUF:applicatie>
                    <StUF:gebruiker><xsl:value-of select="$stuf_zender_gebruiker"/></StUF:gebruiker>
                </StUF:zender>
                <StUF:ontvanger>
                    <StUF:organisatie><xsl:value-of select="$stuf_ontvanger_organisatie"/></StUF:organisatie>
                    <StUF:applicatie><xsl:value-of select="$stuf_ontvanger_applicatie"/></StUF:applicatie>
                </StUF:ontvanger>
                <StUF:referentienummer><xsl:value-of select="$randomuuid"/></StUF:referentienummer><!-- {messageid} -->
                <StUF:tijdstipBericht><xsl:value-of select="let $dt := current-dateTime() return concat(format-dateTime($dt, '[Y0001][M01][D01][H01][m01][s01]'), substring(format-dateTime($dt, '[f]'), 1, 2))"/></StUF:tijdstipBericht>
                <StUF:entiteittype>ZAK</StUF:entiteittype>
            </ZKN:stuurgegevens>
            <ZKN:parameters>
                <StUF:mutatiesoort>T</StUF:mutatiesoort>
                <StUF:indicatorOvername>V</StUF:indicatorOvername>
            </ZKN:parameters>
            <ZKN:object StUF:sleutelVerzendend="{$zaakid}" StUF:entiteittype="ZAK" StUF:verwerkingssoort="T">
                <!-- Zaakidentificatie zoals door zaaksysteem uitgegeven -->
                <ZKN:identificatie><xsl:value-of select="$zaakid"/></ZKN:identificatie><!-- {Zaakidentificatie} -->
                <ZKN:omschrijving>Aanvraag leerlingenvervoer</ZKN:omschrijving>
                <ZKN:kenmerk>
                    <ZKN:kenmerk><xsl:value-of select="globals/kenmerkaanvraag"/></ZKN:kenmerk>
                    <ZKN:bron>Kodision</ZKN:bron>
                </ZKN:kenmerk>
                <ZKN:startdatum><xsl:value-of select="format-dateTime(/FORMULIER/DATUMVERZENDING, '[Y0001][M01][D01]')"/></ZKN:startdatum><!-- {atribuut startDateTime} -->
                <ZKN:registratiedatum><xsl:value-of select="format-dateTime(current-dateTime(), '[Y0001][M01][D01]')"/></ZKN:registratiedatum><!-- {atribuut startDateTime} -->
                <ZKN:isVan StUF:entiteittype="ZAKZKT" StUF:verwerkingssoort="I">
                    <ZKN:gerelateerde StUF:entiteittype="ZKT" StUF:verwerkingssoort="I">
                        <ZKN:code>LV-001</ZKN:code>
                        <ZKN:omschrijving>Leerlingenvervoer aanvraag</ZKN:omschrijving>
                        <ZKN:ingangsdatumObject xsi:nil="true" StUF:noValue="geenWaarde"/>
                    </ZKN:gerelateerde>
                </ZKN:isVan>
                <!-- Rol volgens standaard: leerling (kind waarvoor vervoer wordt aangevraagd).
                     verwerkingssoort="I" op het NPS-object (Identificatie): dit is bewust alleen een
                     verwijzing naar een bekend persoon, geen volledige persoonsregistratie - vandaar
                     dat schema-technisch niets hier verplicht is (zie docs/carel/scopedocument.md §7).
                     Verblijfsadres leerling: bevestigd besluit (3 sep. 2026, na reactie Lorenzo) dat dit
                     altijd verstuurd moet worden, zie tmp/20260901-velden_carel_met_types_baseline.md
                     sectie 1. Het kopiëren van het aanvrageradres naar het leerlingveld (indien "leerling
                     heeft ander adres dan aanvrager" = Nee) is weblogica bij Atabix, niet bij de
                     integratie - de mapping stuurt daarom altijd gewoon het leerling-adresveld, zonder
                     eigen Ja/Nee-keuze. Dat veld bestaat nog niet in het formulier (bouwpunt bij Hein),
                     dus dit blok levert tot die tijd niets op. -->
                <ZKN:heeftBetrekkingOp StUF:entiteittype="ZAKOBJ" StUF:verwerkingssoort="T">
                    <ZKN:gerelateerde>
                        <ZKN:natuurlijkPersoon StUF:entiteittype="NPS" StUF:verwerkingssoort="I">
                            <BG:inp.bsn><xsl:value-of select="fleerlingenvervoerv3gegevensleerling/bsnleerling"/></BG:inp.bsn>
                            <BG:voornamen><xsl:value-of select="fleerlingenvervoerv3gegevensleerling/voornamen"/></BG:voornamen>
                            <BG:voorvoegselGeslachtsnaam><xsl:value-of select="fleerlingenvervoerv3gegevensleerling/tussenvoegsel"/></BG:voorvoegselGeslachtsnaam>
                            <BG:geslachtsnaam><xsl:value-of select="fleerlingenvervoerv3gegevensleerling/achternaam"/></BG:geslachtsnaam>
                            <BG:geboortedatum><xsl:call-template name="normalize-date"><xsl:with-param name="input" select="fleerlingenvervoerv3gegevensleerling/geboortedatum"/></xsl:call-template></BG:geboortedatum>
                            <BG:geslachtsaanduiding>
                                <xsl:choose>
                                    <xsl:when test="fleerlingenvervoerv3gegevensleerling/geslacht = 'Jongen'">M</xsl:when>
                                    <xsl:when test="fleerlingenvervoerv3gegevensleerling/geslacht = 'Meisje'">V</xsl:when>
                                    <xsl:otherwise>O</xsl:otherwise>
                                </xsl:choose>
                            </BG:geslachtsaanduiding>
                            <!-- Adres leerling: altijd sturen, zonder eigen Ja/Nee-keuze (zie toelichting
                                 hierboven). AANNAME voor de brondveldnamen
                                 (fleerlingenvervoerv3gegevensleerling/verblijfsadres/*, zelfde structuur
                                 als globals/stuf/verblijfsadres) - dit formulierveld bestaat nog niet,
                                 dus dit blok levert tot die tijd niets op. Huisletter/huisnummertoevoeging
                                 ontbreken hier ook nog (Open punt, BAG-conform per reactie Lorenzo). -->
                            <xsl:if test="fleerlingenvervoerv3gegevensleerling/verblijfsadres/postcode">
                                <BG:verblijfsadres>
                                    <BG:aoa.postcode><xsl:value-of select="fleerlingenvervoerv3gegevensleerling/verblijfsadres/postcode"/></BG:aoa.postcode>
                                    <BG:aoa.huisnummer><xsl:value-of select="fleerlingenvervoerv3gegevensleerling/verblijfsadres/huisnummer"/></BG:aoa.huisnummer>
                                    <BG:gor.openbareRuimteNaam><xsl:value-of select="fleerlingenvervoerv3gegevensleerling/verblijfsadres/straat"/></BG:gor.openbareRuimteNaam>
                                    <BG:wpl.woonplaatsNaam><xsl:value-of select="fleerlingenvervoerv3gegevensleerling/verblijfsadres/woonplaats"/></BG:wpl.woonplaatsNaam>
                                </BG:verblijfsadres>
                            </xsl:if>
                        </ZKN:natuurlijkPersoon>
                    </ZKN:gerelateerde>
                </ZKN:heeftBetrekkingOp>
                <!-- Rol volgens standaard: aanvrager (ouder/verzorger). Alleen BSN: de aanvrager is
                     zelf ingelogd met DigiD, die authenticatie legt de identiteit al vast, en CAReL
                     haalt de overige persoonsgegevens zelf op via GBAV op basis van het BSN. Overige
                     NPS-velden zouden hoe dan ook dezelfde waarde opleveren, en zijn dus overbodig
                     (principe 1, zie tmp/20260901-velden_carel_met_types_baseline.md - bevestigd door
                     CAReL/Eljakim, mailwisseling "260820 toevoeging aanpassing nav overleg vervoer",
                     1 sep 2026). verwerkingssoort="I" op het NPS-object: alleen een verwijzing naar een
                     bekend persoon. -->
                <ZKN:heeftAlsInitiator StUF:entiteittype="ZAKBTRINI" StUF:verwerkingssoort="T">
                    <ZKN:gerelateerde>
                        <ZKN:natuurlijkPersoon StUF:entiteittype="NPS" StUF:verwerkingssoort="I">
                            <BG:inp.bsn><xsl:value-of select="globals/stuf/inp/bsn"/></BG:inp.bsn>
                        </ZKN:natuurlijkPersoon>
                    </ZKN:gerelateerde>
                </ZKN:heeftAlsInitiator>
                <!-- Formulierantwoorden (alles wat niet netjes in vaste zaakvelden past) -->
                <StUF:extraElementen>
                    <!-- Aanvraagcheck -->
                    <StUF:extraElement naam="aanvraagcheck_woont_in_swf_op_schooldagen"><xsl:value-of select="fleerlingenvervoeraanvraagcheck/leerlingverblijftswf"/></StUF:extraElement>
                    <StUF:extraElement naam="aanvraagcheck_dichtstbijzijnde_toegankelijke_school"><xsl:value-of select="fleerlingenvervoeraanvraagcheck/dichtstbijzijndetoegankelijkeschool"/></StUF:extraElement><!-- {zie bovenstaande structuur} -->
                    <StUF:extraElement naam="aanvraagcheck_welk_onderwijs"><xsl:value-of select="fleerlingenvervoeraanvraagcheck/welkonderwijsvolgtleerling"/></StUF:extraElement>
                    <StUF:extraElement naam="aanvraagcheck_enkele_reisafstand_meer_dan_6_km"><xsl:value-of select="fleerlingenvervoeraanvraagcheck/reisafstandmeerdan6km"/></StUF:extraElement>
                    <StUF:extraElement naam="aanvraagcheck_kan_zelfstandig_reizen"><xsl:value-of select="fleerlingenvervoeraanvraagcheck/leerlingkanzelfstandigreizen"/></StUF:extraElement>
                    <StUF:extraElement naam="aanvraagcheck_hoe_gaat_leerling_naar_school"><xsl:value-of select="fleerlingenvervoeraanvraagcheck/hoegaatdeleerlingnaarschool"/></StUF:extraElement>
                    <StUF:extraElement naam="aanvraagcheck_wil_leerlingenvervoer_aanvragen"><xsl:value-of select="fleerlingenvervoeraanvraagcheck/leerlingenvervoeraanvragen"/></StUF:extraElement>
                    <!-- Aanvraag -->
                    <StUF:extraElement naam="aanvraag_schooljaar"><xsl:value-of select="fleerlingenvervoerv3aanvraag/ditjaar/welkschooljaar"/></StUF:extraElement>
                    <StUF:extraElement naam="aanvraag_vanaf_datum_gebruik_leerlingenvervoer"><xsl:call-template name="normalize-date"><xsl:with-param name="input" select="fleerlingenvervoerv3aanvraag/ingangsdatum"/></xsl:call-template></StUF:extraElement>
                    <StUF:extraElement naam="aanvraag_namens_burger_of_organisatie"><xsl:value-of select="fleerlingenvervoerv3aanvraag/burgerbedrijf"/></StUF:extraElement>
                    <!-- Gegevens aanvrager - alleen wat niet al via heeftAlsInitiator/BSN bekend is bij
                         CAReL (GBAV). De dubbele BRP-velden (bsn/voornamen/tussenvoegsel/achternaam/
                         geboortedatum/adres/postcode/plaats) zijn vervallen, zie principe 1 hierboven.
                         Bij "Organisatie" komt telefoonnummer uit het organisatieblok i.p.v. het
                         burgerblok - zelfde CAReL-veldnaam, andere bron, want burger/organisatie sluiten
                         elkaar uit (aanvraag_namens_burger_of_organisatie). -->
                    <StUF:extraElement naam="aanvrager_telefoonnummer">
                        <xsl:choose>
                            <xsl:when test="fleerlingenvervoerv3aanvraag/burgerbedrijf = 'Organisatie'">
                                <xsl:value-of select="fleerlingenvervoerv3gegevensorganisatie/telefoonnummer"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="fleerlingenvervoerv3gegevensburger/telefoonnummer"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </StUF:extraElement>
                    <StUF:extraElement naam="aanvrager_emailadres"><xsl:value-of select="fleerlingenvervoerv3gegevensburger/emailadres"/></StUF:extraElement>
                    <!-- Organisatiegegevens - alleen relevant bij aanvraag_namens_burger_of_organisatie
                         = "Organisatie". Scope bevestigd 3 sep. 2026: alleen naam en contactpersoonnaam,
                         geen adres (bestaat al gesplitst in het formulier, maar CAReL heeft het niet
                         nodig) en geen eHerkenning. AANNAME voor de brondveldnamen (container
                         fleerlingenvervoerv3gegevensorganisatie met bedrijfsnaam/voornamen/
                         tussenvoegsel/achternaam, naar het "Gegevens Organisatie"-blok uit Heins
                         screenshot van 3 sep. 2026) - nog niet met Hein geverifieerd. Bij "Burger"
                         bestaat dit blok niet, dus leveren deze velden gewoon leeg op. -->
                    <StUF:extraElement naam="aanvrager_organisatie_naam"><xsl:value-of select="fleerlingenvervoerv3gegevensorganisatie/bedrijfsnaam"/></StUF:extraElement>
                    <StUF:extraElement naam="aanvrager_naam"><xsl:value-of select="string-join((fleerlingenvervoerv3gegevensorganisatie/voornamen, fleerlingenvervoerv3gegevensorganisatie/tussenvoegsel, fleerlingenvervoerv3gegevensorganisatie/achternaam)[normalize-space(.) != ''], ' ')"/></StUF:extraElement>
                    <StUF:extraElement naam="aanvrager_relatie_tot_leerling"><xsl:value-of select="fleerlingenvervoerv3gegevensburger/relatietotleerling"/></StUF:extraElement>
                    <!-- IBAN gegevens -->
                    <StUF:extraElement naam="iban_type"><xsl:value-of select="fleerlingenvervoerv3gegevensburger/welkeibannummer"/></StUF:extraElement>
                    <StUF:extraElement naam="iban_nummer"><xsl:value-of select="fleerlingenvervoerv3gegevensburger/iban"/></StUF:extraElement>
                    <StUF:extraElement naam="iban_naam_rekeninghouder"><xsl:value-of select="fleerlingenvervoerv3gegevensburger/ibannaam"/></StUF:extraElement>
                    <!-- Gegevens leerling -->
                    <StUF:extraElement naam="leerling_bsn"><xsl:value-of select="fleerlingenvervoerv3gegevensleerling/bsnleerling"/></StUF:extraElement>
                    <StUF:extraElement naam="leerling_roepnaam"><xsl:value-of select="fleerlingenvervoerv3gegevensleerling/voornamen"/></StUF:extraElement>
                    <StUF:extraElement naam="leerling_tussenvoegsel"><xsl:value-of select="fleerlingenvervoerv3gegevensleerling/tussenvoegsel"/></StUF:extraElement>
                    <StUF:extraElement naam="leerling_achternaam"><xsl:value-of select="fleerlingenvervoerv3gegevensleerling/achternaam"/></StUF:extraElement>
                    <StUF:extraElement naam="leerling_geslacht"><xsl:value-of select="fleerlingenvervoerv3gegevensleerling/geslacht"/></StUF:extraElement>
                    <StUF:extraElement naam="leerling_geboortedatum"><xsl:call-template name="normalize-date"><xsl:with-param name="input" select="fleerlingenvervoerv3gegevensleerling/geboortedatum"/></xsl:call-template></StUF:extraElement>
                    <StUF:extraElement naam="leerling_adres_gelijk_aan_aanvrager"><xsl:value-of select="fleerlingenvervoerv3gegevensleerling/leerlinganderadres"/></StUF:extraElement>
                    <!-- School -->
                    <StUF:extraElement naam="school_naam"><xsl:value-of select="fleerlingenvervoerv3regulier/naamschool"/></StUF:extraElement>
                    <StUF:extraElement naam="school_adres"><xsl:value-of select="fleerlingenvervoerv3regulier/straat"/></StUF:extraElement>
                    <StUF:extraElement naam="school_postcode"><xsl:value-of select="fleerlingenvervoerv3regulier/postcode"/></StUF:extraElement>
                    <StUF:extraElement naam="school_plaats"><xsl:value-of select="fleerlingenvervoerv3regulier/woonplaats"/></StUF:extraElement>
                    <!-- Eigen bijdrage. Hernoemd per contract (was eigenbijdrage_verzamelinkomen_2023,
                         nu jaar-onafhankelijk Ja/Nee i.p.v. inkomensklasse), zie
                         tmp/20260901-velden_carel_met_types_baseline.md. -->
                    <StUF:extraElement naam="eigenbijdrage_verzamelinkomen_vorig_jaar"><xsl:value-of select="fleerlingenvervoerv3eigenbijdrage/newyear/hetverzamelinkomen"/></StUF:extraElement>
                    <StUF:extraElement naam="eigenbijdrage_upload_belastingaangifte"><xsl:value-of select="fleerlingenvervoerv3eigenbijdrage/belastingaangifte"/></StUF:extraElement>
                    <!-- Soort vervoer. vervoer_upload_routeplanner en vervoer_vanaf_datum_nodig zijn
                         vervallen (routeplanner-check gebeurt nu bij CAReL zelf; vanaf-datum was dubbel
                         met aanvraag_vanaf_datum_gebruik_leerlingenvervoer), zie
                         tmp/20260901-velden_carel_met_types_baseline.md. -->
                    <StUF:extraElement naam="vervoer_type"><xsl:value-of select="fleerlingenvervoerv3vervoer/typevergoedingvervoer"/></StUF:extraElement>
                    <StUF:extraElement naam="vervoer_upload_vervoersverklaring"><xsl:value-of select="fleerlingenvervoerv3vervoer/bijlagen"/></StUF:extraElement>

                    <!-- Dagdeel-structuur: heen-/terugtijdstip per dag (10 velden), per besluit van
                         3 sep. 2026 na reactie Lorenzo (Eljakim) - CAReL verwerkt Ja/Nee-vlaggen niet
                         betrouwbaar, wél tijden. Vervangt het eerdere Brengen/Ophalen/Geen-voorstel
                         (15 Ja/Nee-velden), dat nooit aan Hein is gevraagd. Het formulier heeft deze
                         tijdvelden nog niet (groter bouwpunt dan het vorige voorstel) - de bronveldnamen
                         hieronder zijn een AANNAME van Eduard, nog niet door Hein bevestigd. -->
                    <xsl:apply-templates select="fleerlingenvervoerv3vervoer"/>
                    
                    <!-- Toelichting -->
                    <StUF:extraElement naam="toelichting"><xsl:value-of select="fleerlingenvervoerv3toelichting/extratoelichting"/></StUF:extraElement>
                </StUF:extraElementen>
            </ZKN:object>
        </ZKN:zakLk01>
    </xsl:template>
    
    <!-- Special case: dagdeel vervoer (heen-/terugtijdstip per dag).
         AANNAME (nog niet door Hein bevestigd): Atabix levert per dag twee velden aan volgens
         dezelfde naamconventie als de bestaande <dag>vervoer<type>-checkboxvelden, namelijk
         <dag>vervoerheentijd / <dag>vervoerterugtijd. Leeg/ontbrekend veld = geen vervoer nodig
         in die richting op die dag. Wijkt de daadwerkelijke naamgeving af, dan hoeven alleen de
         twee xsl:variable-selects hieronder aangepast te worden. -->
    <xsl:template match="fleerlingenvervoerv3vervoer">
        <xsl:variable name="vervoer" select="."/>
        <xsl:for-each select="('maandag', 'dinsdag', 'woensdag', 'donderdag', 'vrijdag')">
            <xsl:variable name="dag" select="."/>
            <xsl:variable name="heentijd" select="$vervoer/*[local-name() = concat($dag, 'vervoerheentijd')]"/>
            <xsl:variable name="terugtijd" select="$vervoer/*[local-name() = concat($dag, 'vervoerterugtijd')]"/>

            <StUF:extraElement naam="{concat('vervoer_', $dag, '_heentijd')}"><xsl:value-of select="normalize-space(string($heentijd[1]))"/></StUF:extraElement>
            <StUF:extraElement naam="{concat('vervoer_', $dag, '_terugtijd')}"><xsl:value-of select="normalize-space(string($terugtijd[1]))"/></StUF:extraElement>
        </xsl:for-each>
    </xsl:template>
    
    <!-- Verplichte-veldcontrole: zelfde patroon als normalize-date's foutafhandeling hieronder
         (xsl:message terminate="yes") - stopt de transformatie met een duidelijke melding i.p.v.
         een StUF-bericht met een leeg verplicht veld naar CAReL te sturen. -->
    <xsl:template name="require-field">
        <xsl:param name="veldnaam" as="xs:string"/>
        <xsl:param name="waarde" as="xs:string?"/>

        <xsl:if test="normalize-space($waarde) = ''">
            <xsl:message terminate="yes">Verplicht veld ontbreekt of is leeg: <xsl:value-of select="$veldnaam"/></xsl:message>
        </xsl:if>
    </xsl:template>

    <xsl:template name="normalize-date">
        <xsl:param name="input" as="node()?"/>
        
        <xsl:variable name="date" select="normalize-space(string($input))"/>
        <xsl:variable name="elementname" select="local-name($input)"/>
        
        <xsl:choose>
            
            <!-- Case 1: YYYYMMDD -->
            <xsl:when test="matches($date, '^\d{8}$')">
                <xsl:value-of select="$date"/>
            </xsl:when>
            
            <!-- Case 2: D-M-YYYY or DD-MM-YYYY -->
            <xsl:when test="matches($date, '^\d{1,2}-\d{1,2}-\d{4}$')">
                <xsl:variable name="parts" select="tokenize($date, '-')"/>
                
                <xsl:variable name="day" select="format-number(number($parts[1]), '00')"/>
                <xsl:variable name="month" select="format-number(number($parts[2]), '00')"/>
                <xsl:variable name="year" select="$parts[3]"/>
                
                <xsl:value-of select="concat($year, $month, $day)"/>
            </xsl:when>
            
            <!-- Optional: already ISO (YYYY-MM-DD) -->
            <xsl:when test="matches($date, '^\d{4}-\d{2}-\d{2}$')">
                <xsl:value-of select="concat(
                        substring($date, 1, 4),
                        substring($date, 6, 2),
                        substring($date, 9, 2)
                    )"/>
            </xsl:when>
            
            <!-- Fallback -->
            <xsl:otherwise>
                <xsl:message terminate="yes">
                    Unrecognized date format: <xsl:value-of select="concat($elementname, '_',  $date)"/>
                </xsl:message>
            </xsl:otherwise>
            
        </xsl:choose>
    </xsl:template>
    
</xsl:stylesheet>