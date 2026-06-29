<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="text"/>
    <xsl:param name="bronorganisatie"/>
    <xsl:param name="informatieobjecttype"/>
    <xsl:param name="aanvraagtype"/>
    <xsl:param name="inhoud"/>
    <xsl:param name="vertrouwelijkheidaanduiding"/>

    <xsl:template match="/">
        <xsl:text>{"bronorganisatie": "</xsl:text><xsl:value-of select="$bronorganisatie"/><xsl:text>",</xsl:text>
        <xsl:text>"creatiedatum": "</xsl:text><xsl:value-of select="format-date(current-date(), '[Y0001]-[M01]-[D01]')"/><xsl:text>",</xsl:text>
        <xsl:text>"titel": "</xsl:text><xsl:value-of select="$aanvraagtype"/><xsl:text>-aanvraagdata.xml",</xsl:text>
        <xsl:text>"auteur": "WebformulierenVerwerker",</xsl:text>
        <xsl:text>"taal": "nld",</xsl:text>
        <xsl:text>"informatieobjecttype": "</xsl:text><xsl:value-of select="$informatieobjecttype"/><xsl:text>",</xsl:text>
        <xsl:text>"inhoud": "</xsl:text><xsl:value-of select="$inhoud"/><xsl:text>",</xsl:text>
        <xsl:text>"bestandsnaam": "</xsl:text><xsl:value-of select="$aanvraagtype"/><xsl:text>-aanvraagdata.xml",</xsl:text>
        <xsl:text>"formaat": "application/xml",</xsl:text>
        <xsl:text>"status": "definitief",</xsl:text>
        <xsl:text>"vertrouwelijkheidaanduiding": "</xsl:text><xsl:value-of select="$vertrouwelijkheidaanduiding"/><xsl:text>"}</xsl:text>
    </xsl:template>
</xsl:stylesheet>
