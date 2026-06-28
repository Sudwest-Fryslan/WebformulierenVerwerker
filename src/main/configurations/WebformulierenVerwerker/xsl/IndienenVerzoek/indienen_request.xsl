<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <!-- TODO: implementeer JSON body voor PATCH /verzoeken/{uuid} (Verzoeken API) -->
    <!-- Body: { "status": "ingediend" } -->
    <xsl:template match="/">
        <xsl:text>{"status": "ingediend"}</xsl:text>
    </xsl:template>
</xsl:stylesheet>
