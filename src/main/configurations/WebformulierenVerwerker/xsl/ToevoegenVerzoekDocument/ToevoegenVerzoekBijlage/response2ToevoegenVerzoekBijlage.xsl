<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:param name="bijlageUuid"/>

    <xsl:template match="/">
        <toevoegenVerzoekBijlageResponse xmlns="http://tempuri.org/">
            <toevoegenVerzoekBijlageResult><xsl:value-of select="$bijlageUuid"/></toevoegenVerzoekBijlageResult>
        </toevoegenVerzoekBijlageResponse>
    </xsl:template>
</xsl:stylesheet>
