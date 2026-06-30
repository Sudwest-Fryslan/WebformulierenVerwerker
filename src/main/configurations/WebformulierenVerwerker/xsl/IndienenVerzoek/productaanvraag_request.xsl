<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema">
    <xsl:output method="text"/>
    <xsl:param name="bronorganisatie"/>
    <xsl:param name="objecttype"/>
    <xsl:param name="bron.naam"/>
    <xsl:param name="verzoekIdentificatie"/>
    <xsl:param name="afzenderbsn"/>
    <xsl:param name="aanvraagtype"/>
    <xsl:param name="documentenUrl"/>
    <xsl:param name="pdfDocumentUuid"/>
    <xsl:param name="xmlDocumentUuid"/>
    <xsl:param name="aanvraagXml" as="xs:string" select="''"/>

    <xsl:template match="/">
        <xsl:variable name="bijlageUuids" select="//bijlageUuid"/>
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
                <xsl:text>"aanvraaggegevens": </xsl:text>
                <xsl:call-template name="aanvraaggegevens"/>
                <xsl:text>,</xsl:text>
                <xsl:text>"betrokkenen": [</xsl:text>
                    <xsl:text>{</xsl:text>
                        <xsl:text>"inpBsn": "</xsl:text><xsl:value-of select="$afzenderbsn"/><xsl:text>",</xsl:text>
                        <xsl:text>"rolOmschrijvingGeneriek": "initiator"</xsl:text>
                    <xsl:text>}</xsl:text>
                <xsl:text>],</xsl:text>
                <xsl:text>"pdf": "</xsl:text><xsl:value-of select="concat($documentenUrl, '/enkelvoudiginformatieobjecten/', $pdfDocumentUuid)"/><xsl:text>",</xsl:text>
                <xsl:text>"csv": "</xsl:text><xsl:value-of select="concat($documentenUrl, '/enkelvoudiginformatieobjecten/', $xmlDocumentUuid)"/><xsl:text>",</xsl:text>
                <xsl:text>"bijlagen": [</xsl:text>
                    <xsl:for-each select="$bijlageUuids">
                        <xsl:if test="position() > 1"><xsl:text>,</xsl:text></xsl:if>
                        <xsl:text>"</xsl:text><xsl:value-of select="concat($documentenUrl, '/enkelvoudiginformatieobjecten/', .)"/><xsl:text>"</xsl:text>
                    </xsl:for-each>
                <xsl:text>]</xsl:text>
            <xsl:text>}</xsl:text>
        <xsl:text>}</xsl:text>
        <xsl:text>}</xsl:text>
    </xsl:template>

    <!-- Genereer aanvraaggegevens JSON vanuit de aanvraag-XML.
         Structuur: elke child van <answers> is een sectie (kopje),
         de children van die sectie zijn key-value pairs.
         Geneste sub-elementen worden recursief als object weergegeven. -->
    <xsl:template name="aanvraaggegevens">
        <xsl:choose>
            <xsl:when test="$aanvraagXml != ''">
                <xsl:variable name="xmlLengte" select="string-length($aanvraagXml)"/>
                <xsl:variable name="formulier" select="parse-xml($aanvraagXml)"/>
                <xsl:variable name="secties" select="$formulier//answers/*"/>
                <xsl:choose>
                    <xsl:when test="exists($secties)">
                        <xsl:text>{</xsl:text>
                        <xsl:for-each select="$secties">
                            <xsl:if test="position() > 1"><xsl:text>,</xsl:text></xsl:if>
                            <xsl:text>"</xsl:text><xsl:value-of select="local-name()"/><xsl:text>": {</xsl:text>
                            <xsl:call-template name="xml-naar-json-object">
                                <xsl:with-param name="elementen" select="*"/>
                            </xsl:call-template>
                            <xsl:text>}</xsl:text>
                        </xsl:for-each>
                        <xsl:text>}</xsl:text>
                    </xsl:when>
                    <xsl:otherwise><xsl:text>{"__debug": "geen answers gevonden, xml-lengte: </xsl:text><xsl:value-of select="$xmlLengte"/><xsl:text>"}</xsl:text></xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise><xsl:text>{"__debug": "aanvraagXml is leeg"}</xsl:text></xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- Recursief: zet XML-elementen om naar JSON key-value of key-object pairs -->
    <xsl:template name="xml-naar-json-object">
        <xsl:param name="elementen" as="element()*"/>
        <xsl:for-each select="$elementen">
            <xsl:if test="position() > 1"><xsl:text>,</xsl:text></xsl:if>
            <xsl:text>"</xsl:text><xsl:value-of select="local-name()"/><xsl:text>": </xsl:text>
            <xsl:choose>
                <xsl:when test="*">
                    <xsl:text>{</xsl:text>
                    <xsl:call-template name="xml-naar-json-object">
                        <xsl:with-param name="elementen" select="*"/>
                    </xsl:call-template>
                    <xsl:text>}</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>"</xsl:text>
                    <xsl:value-of select="replace(replace(replace(string(.), '\\', '\\\\'), '&quot;', '\\&quot;'), '&#10;', '\n')"/>
                    <xsl:text>"</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>

</xsl:stylesheet>
