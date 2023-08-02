<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" version="2.0"
    xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/">
    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" omit-xml-declaration="yes" />
    <xsl:param name="corsaRequest" select="''" as="xs:string" />
    <xsl:param name="corsaResponse" select="''" as="xs:string" />
    <xsl:param name="soapAction" select="''" as="xs:string" />
    <xsl:param name="corsaErrorMessage" as="xs:string" />

    <xsl:template match="/">
        <SOAP-ENV:Fault>
            <faultcode>SOAP-ENV:Server</faultcode>
            <faultstring>
                <xsl:value-of select="$corsaErrorMessage" />
            </faultstring>
            <detail>
                <Message>
                    <xsl:value-of
                        select="
                    concat(
                        concat(
                            concat(
                                concat(codepoints-to-string(10),'Soap Action: '), 
                            $soapAction),
                            concat(
                                concat(codepoints-to-string(10),'Request: '),
                            $corsaRequest)),
                            concat(
                                concat(codepoints-to-string(10),'Response: '),
                            $corsaResponse))" />
                </Message>
            </detail>
        </SOAP-ENV:Fault>
    </xsl:template>
</xsl:stylesheet>