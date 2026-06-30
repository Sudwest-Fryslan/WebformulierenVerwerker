<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:err="http://www.w3.org/2005/xqt-errors"
    xmlns:map="http://www.w3.org/2005/xpath-functions/map"
    xmlns:local="urn:local">

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
    <xsl:param name="omschrijving" as="xs:string" select="''"/>
    <xsl:param name="bijlageUuidsXml" as="xs:string" select="''"/>

    <xsl:template match="/">
        <xsl:variable name="bijlagen-doc" select="if ($bijlageUuidsXml != '') then parse-xml($bijlageUuidsXml) else parse-xml('&lt;rowset/&gt;')"/>
        <xsl:variable name="bijlageUuids" select="$bijlagen-doc//field[@name='BIJLAGE_UUID']"/>
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
                <xsl:variable name="effectieve-omschrijving" select="if ($omschrijving != '') then $omschrijving else concat('Aanvraag ', $aanvraagtype)"/>
                <xsl:text>"zaakgegevens": {"omschrijving": "</xsl:text><xsl:value-of select="$effectieve-omschrijving"/><xsl:text>"},</xsl:text>
                <xsl:text>"aanvraaggegevens": </xsl:text>
                <xsl:call-template name="aanvraaggegevens"/>
                <xsl:text>,</xsl:text>
                <xsl:text>"betrokkenen": [</xsl:text>
                    <xsl:text>{</xsl:text>
                        <xsl:text>"inpBsn": "</xsl:text><xsl:value-of select="normalize-space($afzenderbsn)"/><xsl:text>",</xsl:text>
                        <xsl:text>"rolOmschrijvingGeneriek": "initiator"</xsl:text>
                    <xsl:text>}</xsl:text>
                <xsl:text>],</xsl:text>
                <xsl:text>"pdf": "</xsl:text><xsl:value-of select="concat($documentenUrl, '/enkelvoudiginformatieobjecten/', normalize-space($pdfDocumentUuid))"/><xsl:text>",</xsl:text>
                <xsl:text>"csv": "</xsl:text><xsl:value-of select="concat($documentenUrl, '/enkelvoudiginformatieobjecten/', normalize-space($xmlDocumentUuid))"/><xsl:text>",</xsl:text>
                <xsl:text>"bijlagen": [</xsl:text>
                    <xsl:for-each select="$bijlageUuids">
                        <xsl:if test="position() > 1"><xsl:text>,</xsl:text></xsl:if>
                        <xsl:text>"</xsl:text><xsl:value-of select="concat($documentenUrl, '/enkelvoudiginformatieobjecten/', normalize-space(.))"/><xsl:text>"</xsl:text>
                    </xsl:for-each>
                <xsl:text>]</xsl:text>
            <xsl:text>}</xsl:text>
        <xsl:text>}</xsl:text>
        <xsl:text>}</xsl:text>
    </xsl:template>

    <!-- Sectie-filter: sluit systeemblokken uit op naam.
         Veldfilter: sluit bekende Atabix-systeemvelden uit op naampatroon. -->
    <xsl:template name="aanvraaggegevens">
        <xsl:choose>
            <xsl:when test="$aanvraagXml != ''">
                <xsl:try>
                    <xsl:variable name="formulier" select="parse-xml($aanvraagXml)"/>
                    <xsl:variable name="secties" select="$formulier//answers/*[
                        not(matches(local-name(), '^sc')) and
                        not(matches(local-name(), '^digid')) and
                        local-name() != 'globals' and
                        normalize-space(.) != ''
                    ]"/>
                    <xsl:choose>
                        <xsl:when test="exists($secties)">
                            <xsl:variable name="ag" select="map:merge(
                                for $s in $secties
                                return map{local-name($s): local:element-naar-waarde($s)}
                            )"/>
                            <xsl:value-of select="serialize($ag, map{'method': 'json'})"/>
                        </xsl:when>
                        <xsl:otherwise><xsl:text>{}</xsl:text></xsl:otherwise>
                    </xsl:choose>
                    <xsl:catch>
                        <xsl:text>{}</xsl:text>
                    </xsl:catch>
                </xsl:try>
            </xsl:when>
            <xsl:otherwise><xsl:text>{}</xsl:text></xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- Recursief: zet een element om naar een JSON-waarde, met veldniveau-filter op systeemvelden. -->
    <xsl:function name="local:element-naar-waarde" as="item()">
        <xsl:param name="elem" as="element()"/>
        <xsl:choose>
            <xsl:when test="$elem/*">
                <xsl:variable name="relevante-children" select="$elem/*[local:is-relevant-veld(local-name())]"/>
                <xsl:sequence select="map:merge(
                    for $child in $relevante-children
                    return map{local-name($child): local:element-naar-waarde($child)}
                )"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="string($elem)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <!-- Veldfilter: true als het veld relevante gebruikersdata is.
         Sluit Atabix-systeemvelden uit op naampatroon (digid*, stuf, nps*, sss_*, procstuf*, xslt_*, xsp_*, *efautogen*). -->
    <xsl:function name="local:is-relevant-veld" as="xs:boolean">
        <xsl:param name="naam" as="xs:string"/>
        <xsl:sequence select="
            not(matches($naam, '^digid')) and
            not($naam = 'stuf') and
            not(matches($naam, '^nps')) and
            not(matches($naam, '^sss_')) and
            not(matches($naam, '^procstuf')) and
            not(matches($naam, '^xslt_')) and
            not(matches($naam, '^xsp_')) and
            not(contains($naam, 'efautogen'))
        "/>
    </xsl:function>

</xsl:stylesheet>
