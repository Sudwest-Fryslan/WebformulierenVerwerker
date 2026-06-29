<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="text"/>
    <xsl:template match="/">
        <!-- normalize-space(.) haalt tekst uit het wrapper-element (Text2XmlPipe output) -->
        <xsl:variable name="stripped" select="translate(normalize-space(.), '=', '')"/>
        <xsl:value-of select="translate($stripped, '+/', '-_')"/>
    </xsl:template>
</xsl:stylesheet>
