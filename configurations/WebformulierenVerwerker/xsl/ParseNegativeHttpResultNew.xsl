<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" version="2.0">
	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" omit-xml-declaration="yes"/>
    <xsl:param name="corsaRequest" select="''" as="xs:string" />
    <xsl:param name="corsaResponse" select="''" as="xs:string" />
    <xsl:param name="soapAction" select="''" as="xs:string" />

    <xsl:template match="/">
        <error>
            <soapAction><xsl:value-of select="$soapAction" /></soapAction>
            <corsaRequest><xsl:value-of select="$corsaRequest" /></corsaRequest>
            <corsaResponse><xsl:value-of select="$corsaResponse" /></corsaResponse>
        </error>
    </xsl:template>
</xsl:stylesheet>
