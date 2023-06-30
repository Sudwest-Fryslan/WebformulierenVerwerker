<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="2.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsi="http://www.w3.org/1999/XMLSchema-instance">
    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" />
    <xsl:param name="errorCode" select="''" as="xs:string" />
    <xsl:param name="errorMessage" select="''" as="xs:string" />

    <xsl:template match="/">
      <Fault>
        <faultcode>soapenv:Server</faultcode>
        <faultstring><xsl:value-of select="$errorMessage" /></faultstring>
      </Fault>
    </xsl:template>
</xsl:stylesheet>