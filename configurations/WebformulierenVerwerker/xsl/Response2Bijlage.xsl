<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:soap="http://www.w3.org/2003/05/soap-envelope">
    <xsl:param name="BijlageID"/>
    <xsl:output method="xml" indent="yes"/>
    <xsl:template match="/">
        <opslaanBijlageResponse xmlns="http://tempuri.org/">
            <opslaanBijlageResult>
                <xsl:value-of select="//*[name()='$BijlageID']" />
            </opslaanBijlageResult>
        </opslaanBijlageResponse>
    </xsl:template>
</xsl:stylesheet>