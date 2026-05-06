<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" version="2.0"
    xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/"
    xmlns:tns="http://tempuri.org/">
    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" omit-xml-declaration="yes" />
    <xsl:param name="aanvraagRequest" select="''" as="xs:string" />
    <xsl:param name="aanvraagResponse" select="''" as="xs:string" />
    <xsl:param name="soapAction" select="''" as="xs:string" />
    <xsl:param name="aanvraagErrorMessage" as="xs:string" />

    <xsl:template match="/">
        <tns:Fault>
            <tns:faultcode>SOAP-ENV:Server</tns:faultcode>
            <tns:faultstring>
                <xsl:value-of select="$aanvraagErrorMessage" />
            </tns:faultstring>
            <tns:detail>
                Something wrent wrong. See faultstring for information or try again later.
                <!-- Left out to prevent data exposure. -->
                <!-- <tns:Message>
                    <xsl:value-of
                        select="
                    concat(
                        concat(
                            concat(
                                concat(codepoints-to-string(10),' Soap Action: '), 
                            $soapAction),
                            concat(
                                concat(codepoints-to-string(10),' Request: '),
                            $aanvraagRequest)),
                            concat(
                                concat(codepoints-to-string(10),' Response: '),
                            $aanvraagResponse))" />
                </tns:Message> -->
            </tns:detail>
        </tns:Fault>
    </xsl:template>
</xsl:stylesheet>