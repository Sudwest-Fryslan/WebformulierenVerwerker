<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" version="2.0">
	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" omit-xml-declaration="yes"/>
    <xsl:param name="senderPipeName" select="''" as="xs:string" />

    <xsl:template match="/">
        <error>
            <xsl:choose>
                <xsl:when test="root/status=400">
                    <code>ClientError</code>
                    <reason>400 Bad Request </reason>
                </xsl:when>
                <xsl:when test="root/status=401">
                    <code>ClientError</code>
                    <reason>401 Unauthorized </reason>
                </xsl:when>
                <xsl:when test="root/status=403">
                    <code>ClientError</code>
                    <reason>403 Forbidden </reason>
                </xsl:when>
                <xsl:when test="root/status=404">
                    <code>ClientError</code>
                    <reason>404 Not Found </reason>
                </xsl:when>
                <xsl:when test="root/status=500">
                    <code>ServerError</code>
                    <reason>500 Internal Server Error </reason>
                </xsl:when>
                <xsl:otherwise>
                    <code>ServerError</code>
                    <reason>Some negative response </reason>
                </xsl:otherwise>
            </xsl:choose>
        </error>
    </xsl:template>
</xsl:stylesheet>
