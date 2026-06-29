<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema">
    <xsl:param name="clientId"/>
    <xsl:output method="text"/>
    <xsl:template match="/">
        <xsl:variable name="epoch" select="xs:dateTime('1970-01-01T00:00:00Z')"/>
        <xsl:variable name="iat" select="xs:integer((current-dateTime() - $epoch) div xs:dayTimeDuration('PT1S'))"/>
        <xsl:value-of select="concat('{&quot;iss&quot;:&quot;', $clientId, '&quot;,&quot;iat&quot;:', $iat, ',&quot;client_id&quot;:&quot;', $clientId, '&quot;,&quot;user_id&quot;:&quot;&quot;,&quot;user_representation&quot;:&quot;&quot;}')"/>
    </xsl:template>
</xsl:stylesheet>
