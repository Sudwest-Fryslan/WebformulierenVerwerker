<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="text"/>
    <!-- Extracts the UUID (last path segment) from the "url" field in a JSON response
         wrapped in an XML element by Text2XmlPipe.
         Input: <response>{"url": "http://.../enkelvoudiginformatieobjecten/<uuid>", ...}</response>
         Output: <uuid>
    -->
    <xsl:template match="/">
        <xsl:variable name="after_colon" select="substring-after(., '&quot;url&quot;:')"/>
        <xsl:variable name="trimmed" select="normalize-space($after_colon)"/>
        <xsl:variable name="rawUrl" select="substring-before(substring($trimmed, 2), '&quot;')"/>
        <xsl:value-of select="tokenize($rawUrl, '/')[last()]"/>
    </xsl:template>
</xsl:stylesheet>
