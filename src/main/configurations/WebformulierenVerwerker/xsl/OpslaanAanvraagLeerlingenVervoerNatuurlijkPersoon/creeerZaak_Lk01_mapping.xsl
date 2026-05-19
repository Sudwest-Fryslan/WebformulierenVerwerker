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
                <!-- Rol volgens standaard: aanvrager (ouder/verzorger) -->
                <ZKN:heeftAlsInitiator StUF:entiteittype="ZAKBTRINI" StUF:verwerkingssoort="T">
                    <ZKN:gerelateerde>
                        <ZKN:natuurlijkPersoon StUF:entiteittype="NPS" StUF:verwerkingssoort="T">
                            <BG:inp.bsn><xsl:value-of select="globals/bsn"/></BG:inp.bsn><!-- {afzenderbsn} -->
                            <BG:authentiek StUF:metagegeven="true">J</BG:authentiek>
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
                    <!-- Gegevens aanvrager -->
                    <StUF:extraElement naam="aanvrager_bsn"><xsl:value-of select="globals/stuf/inp/bsn"/></StUF:extraElement>
                    <StUF:extraElement naam="aanvrager_voornamen"><xsl:value-of select="globals/stuf/voorletters"/></StUF:extraElement>
                    <StUF:extraElement naam="aanvrager_tussenvoegsel"/>
                    <StUF:extraElement naam="aanvrager_achternaam"><xsl:value-of select="globals/stuf/geslachtsnaam"/></StUF:extraElement>
                    <StUF:extraElement naam="aanvrager_geboortedatum"><xsl:call-template name="normalize-date"><xsl:with-param name="input" select="globals/stuf/geboortedatum"/></xsl:call-template></StUF:extraElement>
                    <StUF:extraElement naam="aanvrager_adres"><xsl:value-of select="globals/stuf/verblijfsadres/straat"/></StUF:extraElement>
                    <StUF:extraElement naam="aanvrager_postcode"><xsl:value-of select="globals/stuf/verblijfsadres/postcode"/></StUF:extraElement>
                    <StUF:extraElement naam="aanvrager_plaats"><xsl:value-of select="globals/stuf/verblijfsadres/woonplaats"/></StUF:extraElement>
                    <StUF:extraElement naam="aanvrager_telefoonnummer"><xsl:value-of select="fleerlingenvervoerv3gegevensburger/telefoonnummer"/></StUF:extraElement>
                    <StUF:extraElement naam="aanvrager_emailadres"><xsl:value-of select="fleerlingenvervoerv3gegevensburger/emailadres"/></StUF:extraElement>
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
                    <!-- Eigen bijdrage -->
                    <StUF:extraElement naam="eigenbijdrage_verzamelinkomen_2023"><xsl:value-of select="fleerlingenvervoerv3eigenbijdrage/newyear/hetverzamelinkomen"/></StUF:extraElement>
                    <StUF:extraElement naam="eigenbijdrage_upload_belastingaangifte"><xsl:value-of select="fleerlingenvervoerv3eigenbijdrage/belastingaangifte"/></StUF:extraElement>
                    <!-- Soort vervoer -->
                    <StUF:extraElement naam="vervoer_type"><xsl:value-of select="fleerlingenvervoerv3vervoer/typevergoedingvervoer"/></StUF:extraElement>
                    <StUF:extraElement naam="vervoer_upload_routeplanner"><xsl:value-of select="fleerlingenvervoerv3vervoer/uploadfiets"/></StUF:extraElement>
                    <StUF:extraElement naam="vervoer_upload_vervoersverklaring"><xsl:value-of select="fleerlingenvervoerv3vervoer/bijlagen"/></StUF:extraElement>
                    <StUF:extraElement naam="vervoer_vanaf_datum_nodig"><xsl:call-template name="normalize-date"><xsl:with-param name="input" select="fleerlingenvervoerv3aanvraag/ingangsdatum"/></xsl:call-template></StUF:extraElement>
                    
                    <xsl:apply-templates select="fleerlingenvervoerv3vervoer"/>
                    
                    <!-- Toelichting -->
                    <StUF:extraElement naam="toelichting"><xsl:value-of select="fleerlingenvervoerv3toelichting/extratoelichting"/></StUF:extraElement>
                </StUF:extraElementen>
            </ZKN:object>
        </ZKN:zakLk01>
    </xsl:template>
    
    <!-- Special case: dagen vervoer -->
    <xsl:template match="fleerlingenvervoerv3vervoer">
        <xsl:variable name="type" select="replace(normalize-space(lower-case(typevergoedingvervoer)), '\s+', '')"/>
        
        <xsl:variable name="maandagvervoer" select="*[local-name() = concat('maandagvervoer', $type)]"/>
        <xsl:variable name="dinsdagvervoer" select="*[local-name() = concat('dinsdagvervoer', $type)]"/>
        <xsl:variable name="woensdagvervoer" select="*[local-name() = concat('woensdagvervoer', $type)]"/>
        <xsl:variable name="donderdagvervoer" select="*[local-name() = concat('donderdagvervoer', $type)]"/>
        <xsl:variable name="vrijdagvervoer" select="*[local-name() = concat('vrijdagvervoer', $type)]"/>
        
        <StUF:extraElement naam="vervoer_maandag"><xsl:value-of select="string-join($maandagvervoer ! normalize-space(.), ', ')"/></StUF:extraElement>
        <StUF:extraElement naam="vervoer_dinsdag"><xsl:value-of select="string-join($dinsdagvervoer ! normalize-space(.), ', ')"/></StUF:extraElement>
        <StUF:extraElement naam="vervoer_woensdag"><xsl:value-of select="string-join($woensdagvervoer ! normalize-space(.), ', ')"/></StUF:extraElement>
        <StUF:extraElement naam="vervoer_donderdag"><xsl:value-of select="string-join($donderdagvervoer ! normalize-space(.), ', ')"/></StUF:extraElement>
        <StUF:extraElement naam="vervoer_vrijdag"><xsl:value-of select="string-join($vrijdagvervoer ! normalize-space(.), ', ')"/></StUF:extraElement>
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