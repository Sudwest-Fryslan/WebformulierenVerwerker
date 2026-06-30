<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" version="2.0"
    xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/"
    xmlns:tns="http://tempuri.org/">
    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" omit-xml-declaration="yes" />
    <xsl:param name="aanvraagRequest" select="''" as="xs:string" />
    <xsl:param name="aanvraagResponse" select="''" as="xs:string" />
    <xsl:param name="soapAction" select="''" as="xs:string" />
    <xsl:param name="aanvraagErrorMessage" as="xs:string" />
    <xsl:param name="errorInfo" as="xs:string" />

    <xsl:template match="/">
        <tns:Fault>
            <tns:faultcode>SOAP-ENV:Server</tns:faultcode>
            <tns:faultstring>
                <xsl:value-of select="if ($soapAction != '') then concat('[', $soapAction, '] ', $aanvraagErrorMessage) else $aanvraagErrorMessage" />
            </tns:faultstring>
            <tns:detail>
                <tns:ErrorInfo><xsl:value-of select="$errorInfo" /></tns:ErrorInfo>
                <tns:BackendResponse><xsl:value-of select="$aanvraagResponse" /></tns:BackendResponse>
            </tns:detail>
        </tns:Fault>
    </xsl:template>
</xsl:stylesheet>