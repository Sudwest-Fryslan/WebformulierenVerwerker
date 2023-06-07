<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:soap="http://www.w3.org/2003/05/soap-envelope">
    <xsl:output method="xml" indent="yes"/>
    <xsl:param name="stage"/>
    <xsl:param name="userdomain"/>
    <xsl:param name="username"/>
    <xsl:param name="serverType"/>
    <xsl:param name="osName"/>
    <xsl:param name="directory"/>
    <xsl:template match="/">
        <InfoResponse xmlns="http://tempuri.org/">
            <InfoResult>
                <xsl:text>Corsa Version: </xsl:text> 
                <xsl:value-of select="soap:Envelope/soap:Body" />
                <xsl:text>Stage: </xsl:text>
                <xsl:value-of select="$stage" />
                <xsl:text>&#xA;User Domain: </xsl:text>
                <xsl:value-of select="$userdomain" />
                <xsl:text>&#xA;Username: </xsl:text>
                <xsl:value-of select="$username" />
                <xsl:text>&#xA;Server Type: </xsl:text>
                <xsl:value-of select="$serverType" />
                <xsl:text>&#xA;OS Name: </xsl:text>
                <xsl:value-of select="$osName" />
                <xsl:text>&#xA;Directory: </xsl:text>
                <xsl:value-of select="$directory" />
                <xsl:text>&#xA;</xsl:text> <!-- New line -->
            </InfoResult>
        </InfoResponse>
    </xsl:template>
</xsl:stylesheet>