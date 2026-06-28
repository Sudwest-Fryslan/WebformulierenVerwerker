<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:param name="verzoekIdentificatie"/>
    <xsl:param name="pdfDocumentUrl"/>
    <xsl:param name="xmlDocumentUrl"/>

    <xsl:template match="/">
        <aanmakenVerzoekNatuurlijkPersoonResponse xmlns="http://tempuri.org/">
            <verzoekIdentificatie><xsl:value-of select="$verzoekIdentificatie"/></verzoekIdentificatie>
            <pdfDocumentUrl><xsl:value-of select="$pdfDocumentUrl"/></pdfDocumentUrl>
            <xmlDocumentUrl><xsl:value-of select="$xmlDocumentUrl"/></xmlDocumentUrl>
        </aanmakenVerzoekNatuurlijkPersoonResponse>
    </xsl:template>
</xsl:stylesheet>
