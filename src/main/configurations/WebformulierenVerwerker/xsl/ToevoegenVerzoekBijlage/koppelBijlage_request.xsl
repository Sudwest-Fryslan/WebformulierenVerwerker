<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:param name="verzoekUrl"/>
    <xsl:param name="verzoekIdentificatie"/>
    <xsl:param name="bijlageDocumentUrl"/>

    <!-- TODO: implementeer JSON body voor POST /verzoekinformatieobjecten (Verzoeken API) -->
    <!-- Body: { "verzoek": "<verzoekUrl><verzoekIdentificatie>", "informatieobject": "<bijlageDocumentUrl>" } -->
    <xsl:template match="/">
        <xsl:text>TODO</xsl:text>
    </xsl:template>
</xsl:stylesheet>
