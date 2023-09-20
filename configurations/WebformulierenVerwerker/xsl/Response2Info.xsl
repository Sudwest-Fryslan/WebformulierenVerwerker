<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:soap="http://www.w3.org/2003/05/soap-envelope">
    <xsl:output method="xml" indent="yes" />
    <xsl:param name="stage" />
    <xsl:param name="userdomain" />
    <xsl:param name="username" />
    <xsl:param name="serverType" />
    <xsl:param name="osName" />
    <xsl:param name="directory" />
    <xsl:param name="hipVersion" />
    <xsl:param name="wfvVersion" />
    <xsl:param name="versionDate_ddmmyyyy" />
    <xsl:param name="frameworkVersion" />
    <xsl:param name="corsaUrl" />

    <xsl:template match="/">
        <InfoResponse xmlns="http://tempuri.org/">
            <InfoResult>
                <xsl:text>&#xA; Integratie: WebformulierenVerwerker - Version </xsl:text>
                <xsl:value-of select="$wfvVersion" />
                <xsl:text>&#xA; Platform: Het Integratie Platform - Version </xsl:text>
                <xsl:value-of select="$hipVersion" />
                <xsl:text>&#xA; Framework: Frank!Framework - Version </xsl:text>
                <xsl:value-of select="$frameworkVersion" />
                <xsl:text>&#xA; Server: openzksbrugp001</xsl:text>
                <xsl:text>&#xA; Endpoint: /webformulierenverwerker/services/WebformulierenVerwerker</xsl:text>
                <xsl:text>&#xA; Server Type: </xsl:text>
                <xsl:value-of select="$serverType" />
                <xsl:text>&#xA; OS Name: </xsl:text>
                <xsl:value-of select="$osName" />
                <xsl:text>&#xA; Directory: </xsl:text>
                <xsl:value-of select="$directory" />
                <xsl:text>&#xA; Corsa Version: </xsl:text>
                <xsl:value-of select="normalize-space(soap:Envelope/soap:Body)" />
                <xsl:text>&#xA; Stage: </xsl:text>
                <xsl:value-of select="$stage" />
                <xsl:text>&#xA; Connected Webservice: </xsl:text>
                <xsl:value-of select="$corsaUrl" />
            </InfoResult>
        </InfoResponse>
    </xsl:template>
</xsl:stylesheet>