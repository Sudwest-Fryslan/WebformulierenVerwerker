<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" version="2.0"
    xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/"
    xmlns:tns="http://tempuri.org/">
    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" omit-xml-declaration="yes" />
    <xsl:param name="corsaRequest" select="''" as="xs:string" />
    <xsl:param name="corsaResponse" select="''" as="xs:string" />
    <xsl:param name="soapAction" select="''" as="xs:string" />
    <xsl:param name="corsaErrorMessage" as="xs:string" />

    <xsl:template match="/">
        <tns:Fault>
            <tns:faultcode>SOAP-ENV:Server</tns:faultcode>
            <tns:faultstring>
                <xsl:value-of select="$corsaErrorMessage" />
            </tns:faultstring>
            <tns:detail>
                <tns:Message>
                    <xsl:value-of
                        select="
                    concat(
                        concat(
                            concat(
                                concat(codepoints-to-string(10),' Soap Action: '), 
                            $soapAction),
                            concat(
                                concat(codepoints-to-string(10),' Request: '),
                            $corsaRequest)),
                            concat(
                                concat(codepoints-to-string(10),' Response: '),
                            $corsaResponse))" />
                </tns:Message>
            </tns:detail>
        </tns:Fault>
    </xsl:template>
</xsl:stylesheet>