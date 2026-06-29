<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:param name="part1"/>
    <xsl:param name="part2"/>
    <xsl:output method="text"/>
    <xsl:template match="/">
        <xsl:value-of select="concat($part1, '.', $part2)"/>
    </xsl:template>
</xsl:stylesheet>
