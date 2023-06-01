<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="xml" indent="yes"/>
	<xsl:param name="username"/>
	<xsl:param name="password"/>
    <xsl:param name="ConnectionID"/>
    <xsl:template match="/">
                <bct:Connect xmlns:bct="http://bct.nl">
                    <bct:ApplicationID><xsl:value-of select="'KodsionformulierenNaarCorsa'"/></bct:ApplicationID>
                    <bct:ConnectionID><xsl:value-of select="$ConnectionID"/></bct:ConnectionID>
                    <bct:UserName><xsl:value-of select="$username"/></bct:UserName>
                    <bct:Password><xsl:value-of select="$password"/></bct:Password>
                    <bct:EncodedPass>false</bct:EncodedPass>
                </bct:Connect>
    </xsl:template>
</xsl:stylesheet>