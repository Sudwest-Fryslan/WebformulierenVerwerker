<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                exclude-result-prefixes="#all">

    <xsl:output method="xml" indent="no"/>
    <xsl:param name="minVersion" as="xs:string" select="'1.2'"/>

    <!--
      Live controle: logt of Atabix de verwachte (of hogere) versie van
      WebformulierenVerwerker_Passthrough.xml heeft gebruikt om deze aanvraag-XML te genereren.
      Puur diagnostisch - verandert de doorgaande data niet en blokkeert niets, ook niet als de
      versie ontbreekt of te oud is (dat kan legitiem zijn: het oude formulierformaat heeft nooit
      een passthroughVersion-attribuut gehad).

      Let op: dit controleert het passthroughVersion-attribuut op /FORMULIER, NIET het xsl:comment
      in WebformulierenVerwerker_Passthrough.xml - Frank!Framework's eigen XSLT-verwerking geeft
      XML-commentaar niet door aan de XSLT (bevestigd 22 juli 2026), dus daarop controleren werkt
      hier niet, ook al werkt het prima wanneer je dezelfde stylesheet los met Saxon uitvoert.
    -->
    <xsl:template match="/">
        <xsl:variable name="versionAttr" select="/FORMULIER/@passthroughVersion"/>
        <xsl:choose>
            <xsl:when test="not($versionAttr)">
                <xsl:message>WebformulierenVerwerker: geen passthroughVersion-attribuut gevonden op FORMULIER in de aangeleverde aanvraagxmldata (oud formulierformaat, of een Atabix-stylesheet zonder versiemarkering).</xsl:message>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="versionText" select="string($versionAttr)"/>
                <xsl:variable name="major" select="number(tokenize($versionText, '\.')[1])"/>
                <xsl:variable name="minor" select="number(tokenize($versionText, '\.')[2])"/>
                <xsl:variable name="minMajor" select="number(tokenize($minVersion, '\.')[1])"/>
                <xsl:variable name="minMinor" select="number(tokenize($minVersion, '\.')[2])"/>
                <xsl:choose>
                    <xsl:when test="$major &gt; $minMajor or ($major = $minMajor and $minor &gt;= $minMinor)">
                        <xsl:message>WebformulierenVerwerker: Atabix-stylesheetversie OK (<xsl:value-of select="$versionText"/>, minimaal vereist <xsl:value-of select="$minVersion"/>).</xsl:message>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:message>WebformulierenVerwerker WAARSCHUWING: Atabix gebruikt WebformulierenVerwerker_Passthrough.xml versie <xsl:value-of select="$versionText"/>, verwacht minimaal <xsl:value-of select="$minVersion"/> - vraag om de stylesheet in het Atabix-scenario bij te werken.</xsl:message>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:copy-of select="."/>
    </xsl:template>

</xsl:stylesheet>
