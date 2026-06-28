<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:param name="verzoekIdentificatie"/>

    <xsl:template match="/">
        <indienenVerzoekResponse xmlns="http://tempuri.org/">
            <indienenVerzoekResult><xsl:value-of select="$verzoekIdentificatie"/></indienenVerzoekResult>
        </indienenVerzoekResponse>
    </xsl:template>
</xsl:stylesheet>
