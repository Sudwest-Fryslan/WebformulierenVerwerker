<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:soap="http://www.w3.org/2003/05/soap-envelope" xmlns:bct="http://bct.nl">
    <xsl:output method="xml" indent="yes"/>
    <xsl:template match="/">
        <opslaanInkNatuurlijkPersoonResponse>
            <opslaanInkNatuurlijkPersoonResult>
                <xsl:value-of select="soap:Envelope/soap:Body/bct:CreateMetaPersonResponse/bct:NewObjectID" />
            </opslaanInkNatuurlijkPersoonResult>
        </opslaanInkNatuurlijkPersoonResponse>
    </xsl:template>
</xsl:stylesheet>