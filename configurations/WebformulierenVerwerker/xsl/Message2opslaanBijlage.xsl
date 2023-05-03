<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="xml" indent="yes"/>
	
    <xsl:template match="/">
        <soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope" xmlns:bct="http://bct.nl">
            <soap:Header />
            <soap:Body>
                <bct:OpslaanBijlage>
                   	<bct:RegistrationNummer><xsl:value-of select="opslaanBijlage/registratienummer"/></bct:RegistrationNummer>
                    <bct:FileName><xsl:value-of select="opslaanBijlage/filename"/></bct:FileName>
                    <bct:FileData><xsl:value-of select="opslaanBijlage/filedata"/></bct:FileData>
                </bct:OpslaanBijlage>
            </soap:Body>
        </soap:Envelope>
    </xsl:template>
</xsl:stylesheet>