<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:param name="verzoekIdentificatie"/>
    <xsl:param name="pdfDocumentUuid"/>
    <xsl:param name="xmlDocumentUuid"/>

    <xsl:template match="/">
        <aanmakenVerzoekNatuurlijkPersoonResponse xmlns="http://tempuri.org/">
            <verzoekIdentificatie><xsl:value-of select="$verzoekIdentificatie"/></verzoekIdentificatie>
            <pdfDocumentUuid><xsl:value-of select="$pdfDocumentUuid"/></pdfDocumentUuid>
            <xmlDocumentUuid><xsl:value-of select="$xmlDocumentUuid"/></xmlDocumentUuid>
        </aanmakenVerzoekNatuurlijkPersoonResponse>
    </xsl:template>
</xsl:stylesheet>
