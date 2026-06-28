<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="text"/>
    <xsl:param name="bronorganisatie"/>
    <xsl:param name="objecttype"/>
    <xsl:param name="bron.naam"/>
    <xsl:param name="verzoekIdentificatie"/>
    <xsl:param name="afzenderbsn"/>
    <xsl:param name="aanvraagtype"/>
    <xsl:param name="pdfDocumentUrl"/>
    <xsl:param name="xmlDocumentUrl"/>

    <xsl:template match="/">
        <xsl:variable name="bijlageUrls" select="//bijlageUrl"/>
        <xsl:text>{</xsl:text>
        <xsl:text>"type": "</xsl:text><xsl:value-of select="$objecttype"/><xsl:text>",</xsl:text>
        <xsl:text>"record": {</xsl:text>
            <xsl:text>"typeVersion": 1,</xsl:text>
            <xsl:text>"startAt": "</xsl:text><xsl:value-of select="format-date(current-date(), '[Y0001]-[M01]-[D01]')"/><xsl:text>",</xsl:text>
            <xsl:text>"data": {</xsl:text>
                <xsl:text>"bron": {</xsl:text>
                    <xsl:text>"naam": "</xsl:text><xsl:value-of select="$bron.naam"/><xsl:text>",</xsl:text>
                    <xsl:text>"kenmerk": "</xsl:text><xsl:value-of select="$verzoekIdentificatie"/><xsl:text>"</xsl:text>
                <xsl:text>},</xsl:text>
                <xsl:text>"type": "</xsl:text><xsl:value-of select="$aanvraagtype"/><xsl:text>",</xsl:text>
                <xsl:text>"aanvraaggegevens": {},</xsl:text>
                <xsl:text>"betrokkenen": [</xsl:text>
                    <xsl:text>{</xsl:text>
                        <xsl:text>"inpBsn": "</xsl:text><xsl:value-of select="$afzenderbsn"/><xsl:text>",</xsl:text>
                        <xsl:text>"rolOmschrijvingGeneriek": "initiator"</xsl:text>
                    <xsl:text>}</xsl:text>
                <xsl:text>],</xsl:text>
                <xsl:text>"pdf": "</xsl:text><xsl:value-of select="$pdfDocumentUrl"/><xsl:text>",</xsl:text>
                <xsl:text>"csv": "</xsl:text><xsl:value-of select="$xmlDocumentUrl"/><xsl:text>",</xsl:text>
                <xsl:text>"bijlagen": [</xsl:text>
                    <xsl:for-each select="$bijlageUrls">
                        <xsl:if test="position() > 1"><xsl:text>,</xsl:text></xsl:if>
                        <xsl:text>"</xsl:text><xsl:value-of select="."/><xsl:text>"</xsl:text>
                    </xsl:for-each>
                <xsl:text>]</xsl:text>
            <xsl:text>}</xsl:text>
        <xsl:text>}</xsl:text>
        <xsl:text>}</xsl:text>
    </xsl:template>
</xsl:stylesheet>
