<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="xml" indent="yes" omit-xml-declaration="yes"/>
    <xsl:param name="datetime" />

    <xsl:template match="/">
        <xsl:value-of select="substring($datetime, 1, 10)" />
    </xsl:template>
</xsl:stylesheet>