<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/"
    xmlns:StUF="http://www.egem.nl/StUF/StUF0301"
    xmlns:ZKN="http://www.egem.nl/StUF/sector/zkn/0310" version="2.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsi="http://www.w3.org/1999/XMLSchema-instance">
    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" />
    <xsl:param name="errorCode" select="''" as="xs:string" />
    <xsl:param name="errorMessage" select="''" as="xs:string" />

    <xsl:template match="/">
      <SOAP-ENV:Fault>
        <faultcode><xsl:value-of select="$errorCode" /></faultcode>
        <faultstring><xsl:value-of select="$errorMessage" /></faultstring>
      </SOAP-ENV:Fault>
    </xsl:template>
</xsl:stylesheet>