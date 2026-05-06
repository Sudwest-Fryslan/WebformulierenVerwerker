<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:soap="http://www.w3.org/2003/05/soap-envelope">
    <xsl:param name="ZaakID"/>
    <xsl:output method="xml" indent="yes"/>
    <xsl:template match="/">
        <opslaanAanvraagBijlageResponse xmlns="http://tempuri.org/">
            <!--Optional:-->
            <opslaanAanvraagBijlageResult>
                <xsl:value-of select="$ZaakID" />
            </opslaanAanvraagBijlageResult>
        </opslaanAanvraagBijlageResponse>
    </xsl:template>
</xsl:stylesheet>
