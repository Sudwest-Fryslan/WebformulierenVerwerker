<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:soap="http://www.w3.org/2003/05/soap-envelope">
    <xsl:output method="xml" indent="yes"/>
    <xsl:template match="/">
        <opslaanInkNietNatuurlijkPersoonResponse xmlns="http://tempuri.org/">
            <opslaanInkNietNatuurlijkPersoonResult>
                <xsl:value-of select="//*[name()='ObjectID']" />
            </opslaanInkNietNatuurlijkPersoonResult>
        </opslaanInkNietNatuurlijkPersoonResponse>
    </xsl:template>
</xsl:stylesheet>