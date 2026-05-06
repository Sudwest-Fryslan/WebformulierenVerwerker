<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:StUF="http://www.egem.nl/StUF/StUF0301"
                xmlns:ZKN="http://www.egem.nl/StUF/sector/zkn/0310"
                exclude-result-prefixes="#all">
  
  <xsl:output method="xml" indent="yes"/>
  <xsl:param name="randomuuid" as="xs:string"/>
  
  <xsl:template match="/">
    <ZKN:genereerZaakIdentificatie_Di02>
      <ZKN:stuurgegevens>
        <StUF:berichtcode>Di02</StUF:berichtcode>
        <StUF:zender>
          <StUF:organisatie>1900</StUF:organisatie>
          <StUF:applicatie>WebformulierenKoppeling</StUF:applicatie>
          <StUF:gebruiker>Gebruiker</StUF:gebruiker>
        </StUF:zender>
        <StUF:ontvanger>
          <StUF:organisatie>1900</StUF:organisatie>
          <StUF:applicatie>CDR</StUF:applicatie>
        </StUF:ontvanger>
        <StUF:referentienummer><xsl:value-of select="$randomuuid"/></StUF:referentienummer>
        <StUF:tijdstipBericht><xsl:value-of select="let $dt := current-dateTime() return concat(format-dateTime($dt, '[Y0001][M01][D01][H01][m01][s01]'), substring(format-dateTime($dt, '[f]'), 1, 2))"/></StUF:tijdstipBericht>
        <StUF:functie>genereerZaakidentificatie</StUF:functie>
      </ZKN:stuurgegevens>
    </ZKN:genereerZaakIdentificatie_Di02>
  </xsl:template>

</xsl:stylesheet>