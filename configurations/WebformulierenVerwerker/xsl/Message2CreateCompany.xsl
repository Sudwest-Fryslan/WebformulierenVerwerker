<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:soap="http://www.w3.org/2003/05/soap-envelope">
    <xsl:output method="xml" indent="yes" />
    <xsl:template match="/">
        <bct:CreateMetaOrganisation xmlns:bct="http://bct.nl">
            <bct:ObjectID />
            <bct:ObjectKind>STUF</bct:ObjectKind>
            <bct:ReferenceValues>
                <bct:NameValue>
                    <bct:Name>StufKvk</bct:Name>
                    <bct:Value>
                        <xsl:value-of
                            select="//opslaanInkNietNatuurlijkPersoon/afzenderkvk" />
                    </bct:Value>
                </bct:NameValue>
            </bct:ReferenceValues>
        </bct:CreateMetaOrganisation>
    </xsl:template>
</xsl:stylesheet>