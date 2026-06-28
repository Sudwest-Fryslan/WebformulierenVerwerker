<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="text"/>
    <!-- Extracts the "url" field value from a JSON response wrapped in an XML text node.
         Input: <response>{"url": "http://...", ...}</response>
         Output: http://...
    -->
    <xsl:template match="/">
        <xsl:variable name="after_colon" select="substring-after(., '&quot;url&quot;:')"/>
        <xsl:variable name="trimmed" select="normalize-space($after_colon)"/>
        <xsl:value-of select="substring-before(substring($trimmed, 2), '&quot;')"/>
    </xsl:template>
</xsl:stylesheet>
