<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:param name="bijlageUuid"/>

    <xsl:template match="/">
        <toevoegenVerzoekDocumentResponse xmlns="http://tempuri.org/">
            <toevoegenVerzoekDocumentResult><xsl:value-of select="$bijlageUuid"/></toevoegenVerzoekDocumentResult>
        </toevoegenVerzoekDocumentResponse>
    </xsl:template>
</xsl:stylesheet>
