<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:soap="http://www.w3.org/2003/05/soap-envelope">
    <xsl:param name="version" />
    <xsl:param name="versionDate_ddmmyy" />
    <xsl:output method="xml" indent="yes"/>
    <xsl:template match="/">
        <VersionResponse xmlns="http://tempuri.org/">
            <VersionResult>
                Frank! Version <xsl:value-of select="$version" /> - <xsl:value-of select="$versionDate_ddmmyy" />
            </VersionResult>
        </VersionResponse>
    </xsl:template>
</xsl:stylesheet>