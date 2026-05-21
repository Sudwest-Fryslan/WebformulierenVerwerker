<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:StUF="http://www.egem.nl/StUF/StUF0301"
                xmlns:ZKN="http://www.egem.nl/StUF/sector/zkn/0310"
                exclude-result-prefixes="#all">
  
  <xsl:output method="xml" indent="yes"/>
  <xsl:param name="randomuuid" as="xs:string"/>
  <xsl:param name="stuf_zender_organisatie" as="xs:string"/>
  <xsl:param name="stuf_zender_applicatie" as="xs:string"/>
  <xsl:param name="stuf_zender_gebruiker" as="xs:string"/>
  <xsl:param name="stuf_ontvanger_organisatie" as="xs:string"/>
  <xsl:param name="stuf_ontvanger_applicatie" as="xs:string"/>
  
  <xsl:template match="/">
    <ZKN:genereerDocumentIdentificatie_Di02>
      <ZKN:stuurgegevens>
        <StUF:berichtcode>Di02</StUF:berichtcode>
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
        <StUF:functie>genereerDocumentidentificatie</StUF:functie>
      </ZKN:stuurgegevens>
    </ZKN:genereerDocumentIdentificatie_Di02>
  </xsl:template>
  
</xsl:stylesheet>