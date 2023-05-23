<!-- <xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="xml" indent="yes" />
    <xsl:template match="*|@*|comment()|processing-instruction()|text()">
        <xsl:copy>
            <xsl:apply-templates />
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet> -->

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:soap="http://www.w3.org/2003/05/soap-envelope">
    <xsl:output method="xml" indent="yes"/>
    <xsl:template match="/">
        <opslaanInkNatuurlijkPersoonResponse>
            <opslaanInkNatuurlijkPersoonResult>
                <xsl:value-of select="//*[name()='ObjectID']" />
            </opslaanInkNatuurlijkPersoonResult>
        </opslaanInkNatuurlijkPersoonResponse>
    </xsl:template>
</xsl:stylesheet>