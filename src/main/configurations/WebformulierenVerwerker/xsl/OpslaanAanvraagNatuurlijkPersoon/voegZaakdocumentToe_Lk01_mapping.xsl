<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                xmlns:xmime="http://www.w3.org/2005/05/xmlmime"
                xmlns:StUF="http://www.egem.nl/StUF/StUF0301"
                xmlns:ZKN="http://www.egem.nl/StUF/sector/zkn/0310"
                exclude-result-prefixes="#all">
  
  <xsl:output method="xml" indent="yes"/>
  <xsl:param name="randomuuid" as="xs:string"/>
  <xsl:param name="zaakid" as="xs:string"/>
  <xsl:param name="documentid" as="xs:string" select="''"/>
  <xsl:param name="documentnaam" as="xs:string" select="''"/>
  <xsl:param name="documentomschrijving" as="xs:string" select="''"/>
  <xsl:param name="vertrouwelijkheid" as="xs:string" select="''"/>
  <xsl:param name="documentinhoud" as="xs:base64Binary"/>
  <xsl:param name="formaat" as="xs:string"/>
  <xsl:param name="content-type" as="xs:string"/>
  <xsl:param name="datumverzending" as="xs:dateTime"/>
  <xsl:param name="stuf_zender_organisatie" as="xs:string"/>
  <xsl:param name="stuf_zender_applicatie" as="xs:string"/>
  <xsl:param name="stuf_zender_gebruiker" as="xs:string"/>
  <xsl:param name="stuf_ontvanger_organisatie" as="xs:string"/>
  <xsl:param name="stuf_ontvanger_applicatie" as="xs:string"/>
  
  <xsl:template match="/">
    <ZKN:edcLk01>
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
        <StUF:referentienummer><xsl:value-of select="$randomuuid"/></StUF:referentienummer>
        <StUF:tijdstipBericht><xsl:value-of select="let $dt := current-dateTime() return concat(format-dateTime($dt, '[Y0001][M01][D01][H01][m01][s01]'), substring(format-dateTime($dt, '[f]'), 1, 2))"/></StUF:tijdstipBericht>
        <StUF:entiteittype>EDC</StUF:entiteittype>
      </ZKN:stuurgegevens>
      <ZKN:parameters>
        <StUF:mutatiesoort>T</StUF:mutatiesoort>
        <StUF:indicatorOvername>V</StUF:indicatorOvername>
      </ZKN:parameters>
      <ZKN:object StUF:entiteittype="EDC" StUF:verwerkingssoort="T">
        <ZKN:identificatie><xsl:value-of select="$documentid"/></ZKN:identificatie>
        <ZKN:dct.omschrijving><xsl:value-of select="$documentomschrijving"/></ZKN:dct.omschrijving>
        <ZKN:creatiedatum><xsl:value-of select="format-dateTime(current-dateTime(), '[Y0001][M01][D01]')"/></ZKN:creatiedatum>
        <ZKN:ontvangstdatum><xsl:value-of select="format-dateTime($datumverzending, '[Y0001][M01][D01]')"/></ZKN:ontvangstdatum>
        <ZKN:titel><xsl:value-of select="$documentnaam"/></ZKN:titel>
        <ZKN:formaat><xsl:value-of select="$formaat"/></ZKN:formaat>
        <ZKN:taal>nld</ZKN:taal>
        <ZKN:versie xsi:nil="true" StUF:noValue="geenWaarde"/>
        <ZKN:status>concept</ZKN:status>
        <ZKN:verzenddatum xsi:nil="true" StUF:noValue="geenWaarde"/>
        <ZKN:vertrouwelijkAanduiding><xsl:value-of select="$vertrouwelijkheid"/></ZKN:vertrouwelijkAanduiding>
        <ZKN:auteur>WebformulierenKoppeling</ZKN:auteur>
        <ZKN:inhoud xmime:contentType="{$content-type}" StUF:bestandsnaam="{$documentnaam}"><xsl:value-of select="$documentinhoud"/></ZKN:inhoud>
        <ZKN:isRelevantVoor StUF:entiteittype="EDCZAK" StUF:verwerkingssoort="T">
          <ZKN:gerelateerde StUF:entiteittype="ZAK" StUF:verwerkingssoort="I">
            <ZKN:identificatie><xsl:value-of select="$zaakid"/></ZKN:identificatie>
            <ZKN:omschrijving>Aanvraag leerlingenvervoer</ZKN:omschrijving>
            <ZKN:isVan StUF:entiteittype="ZAKZKT" StUF:verwerkingssoort="I">
              <ZKN:gerelateerde StUF:entiteittype="ZKT" StUF:verwerkingssoort="I">
                <ZKN:omschrijving>Leerlingenvervoer aanvraag</ZKN:omschrijving>
                <ZKN:code>LV001</ZKN:code>
                <ZKN:ingangsdatumObject xsi:nil="true" StUF:noValue="geenWaarde"/>
              </ZKN:gerelateerde>
            </ZKN:isVan>
          </ZKN:gerelateerde>
        </ZKN:isRelevantVoor>
      </ZKN:object>
    </ZKN:edcLk01>
  </xsl:template>
  
</xsl:stylesheet>