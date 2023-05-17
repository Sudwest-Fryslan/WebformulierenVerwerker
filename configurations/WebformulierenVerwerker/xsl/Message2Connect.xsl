<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="xml" indent="yes"/>
	<xsl:param name="pwd"/>
    <xsl:template match="/">
        <soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope"
            xmlns:bct="http://bct.nl">
            <soap:Header />
            <soap:Body>
                <bct:Connect>
                    <!-- <bct:ApplicationID>APPLICATIONID</bct:ApplicationID>
                    <bct:ConnectionID>CONNECTIONID</bct:ConnectionID>
                    <bct:UserName>USERNAME</bct:UserName>
                    <bct:Password>PASSWORD</bct:Password>
                    <bct:EncodedPass>false</bct:EncodedPass> -->
                    <bct:ApplicationID><xsl:value-of select="'KodsionformulierenNaarCorsa'"/></bct:ApplicationID>
                    <bct:ConnectionID>Corsa</bct:ConnectionID>
                    <bct:UserName><xsl:value-of select="opslaanInkNatuurlijkPersoon/behandelaarnaam"/></bct:UserName>
                    <bct:Password><xsl:value-of select="$pwd"/></bct:Password>
                    <bct:EncodedPass>false</bct:EncodedPass>
                </bct:Connect>
            </soap:Body>
        </soap:Envelope>
    </xsl:template>
</xsl:stylesheet>