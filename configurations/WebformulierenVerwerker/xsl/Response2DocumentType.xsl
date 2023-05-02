<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:soap="http://www.w3.org/2003/05/soap-envelope" xmlns:bct="http://bct.nl">
    <xsl:template match="/">
        <opslaanBijlageDocumenttypeResponse>
            <opslaanBijlageDocumenttypeResult>
                <xsl:value-of select="soap:Envelope/soap:Body/bct:CreateMetaDocumentResponse/bct:ObjectID" />
            </opslaanBijlageDocumenttypeResult>
        </opslaanBijlageDocumenttypeResponse>
    </xsl:template>
</xsl:stylesheet>