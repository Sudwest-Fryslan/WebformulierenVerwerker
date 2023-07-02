<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    version="2.0">
    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" />

    <xsl:template match="/">
        <SOAP-ENV:Fault>
            <faultcode>SOAP-ENV:Server</faultcode>
            <faultstring>
                <xsl:value-of select="concat(concat(error/senderPipeName, 'Response: ' ), error/corsaResponse)" />
            </faultstring>
        </SOAP-ENV:Fault>
    </xsl:template>
</xsl:stylesheet>