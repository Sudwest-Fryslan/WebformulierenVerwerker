<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:soap="http://www.w3.org/2003/05/soap-envelope">
    <xsl:output method="xml" indent="yes"/>
    <xsl:template match="/">
        <VersionResponse xmlns="http://tempuri.org/">
            <VersionResult>
                Frank! Version 1 - 07/06/2023
            </VersionResult>
        </VersionResponse>
    </xsl:template>
</xsl:stylesheet>