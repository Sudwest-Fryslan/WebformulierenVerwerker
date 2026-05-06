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
  <xsl:param name="documentid" as="xs:string"/>
  <xsl:param name="documentnaam" as="xs:string"/>
  <xsl:param name="documentomschrijving" as="xs:string"/>
  <xsl:param name="vertrouwelijkheid" as="xs:string"/>
  <xsl:param name="documentinhoud" as="xs:base64Binary"/>
  
  <xsl:template match="/">
    <ZKN:edcLk01>
      <ZKN:stuurgegevens>
        <StUF:berichtcode>Lk01</StUF:berichtcode>
        <StUF:zender>
          <StUF:organisatie>1900</StUF:organisatie>
          <StUF:applicatie>WebformulierenKoppeling</StUF:applicatie>
          <StUF:gebruiker>Gebruiker</StUF:gebruiker>
        </StUF:zender>
        <StUF:ontvanger>
          <StUF:organisatie>1900</StUF:organisatie>
          <StUF:applicatie>CAREL</StUF:applicatie>
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
        <ZKN:identificatie><xsl:value-of select="$documentid" /></ZKN:identificatie>
        <ZKN:dct.omschrijving><xsl:value-of select="$documentomschrijving" /></ZKN:dct.omschrijving>
        <ZKN:creatiedatum><xsl:value-of select="format-dateTime(current-dateTime(), '[Y0001][M01][D01]')"/></ZKN:creatiedatum>
        <ZKN:ontvangstdatum><xsl:value-of select="format-dateTime(current-dateTime(), '[Y0001][M01][D01]')"/></ZKN:ontvangstdatum>        
        <ZKN:titel><xsl:value-of select="$documentnaam" /></ZKN:titel>
        <ZKN:formaat>pdf</ZKN:formaat>
        <ZKN:taal>nld</ZKN:taal>
        <ZKN:versie xsi:nil="true" StUF:noValue="geenWaarde"/>
        <ZKN:status>concept</ZKN:status>
        <ZKN:verzenddatum xsi:nil="true" StUF:noValue="geenWaarde"/>
        <ZKN:vertrouwelijkAanduiding><xsl:value-of select="$vertrouwelijkheid" /></ZKN:vertrouwelijkAanduiding>
        <ZKN:auteur>WebformulierenKoppeling</ZKN:auteur>
        <ZKN:inhoud xmime:contentType="application/pdf" StUF:bestandsnaam="{$documentnaam}"><xsl:value-of select="$documentinhoud"/></ZKN:inhoud>
        <ZKN:isRelevantVoor StUF:entiteittype="EDCZAK" StUF:verwerkingssoort="T">
          <ZKN:gerelateerde StUF:entiteittype="ZAK" StUF:verwerkingssoort="I">
            <ZKN:identificatie><xsl:value-of select="$zaakid" /></ZKN:identificatie>
            <ZKN:omschrijving>Aanvraag minimaregelingen (Z)</ZKN:omschrijving>
            <ZKN:isVan StUF:entiteittype="ZAKZKT" StUF:verwerkingssoort="I">
              <ZKN:gerelateerde StUF:entiteittype="ZKT" StUF:verwerkingssoort="I">
                <ZKN:omschrijving>Aanvraag minima</ZKN:omschrijving>
                <ZKN:code>B1026</ZKN:code>
                <ZKN:ingangsdatumObject xsi:nil="true" StUF:noValue="geenWaarde"/>
              </ZKN:gerelateerde>
            </ZKN:isVan>
          </ZKN:gerelateerde>
          <ZKN:stt.volgnummer>0003</ZKN:stt.volgnummer>
          <ZKN:stt.omschrijving>In behandeling</ZKN:stt.omschrijving>
          <ZKN:sta.datumStatusGezet><xsl:value-of select="format-dateTime(current-dateTime(), '[Y0001][M01][D01]')"/></ZKN:sta.datumStatusGezet>
        </ZKN:isRelevantVoor>
      </ZKN:object>
    </ZKN:edcLk01>
  </xsl:template>
  
</xsl:stylesheet>