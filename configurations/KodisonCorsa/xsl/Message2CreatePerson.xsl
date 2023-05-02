<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:soap="http://www.w3.org/2003/05/soap-envelope">
    <xsl:output method="xml" indent="yes"/>
    <xsl:template match="/">
        <soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope"
            xmlns:bct="http://bct.nl" xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">
            <soap:Header />
            <soap:Body>
                <bct:CreateMetaPerson>
                    <!-- This field can remain empty. -->
                    <bct:ObjectID>
                    </bct:ObjectID>
                    <bct:ObjectKind>STUF</bct:ObjectKind>
                    <bct:ReferenceValues>
                        <bct:NameValue>
                            <!-- BSN -->
                            <bct:Name>BRSpSofi</bct:Name>
                            <bct:Value>
                                <xsl:value-of
                                    select="//opslaanInkNatuurlijkPersoon/afzenderbsn" />
                            </bct:Value>
                        </bct:NameValue>
                    </bct:ReferenceValues>
                </bct:CreateMetaPerson>
            </soap:Body>
        </soap:Envelope>
    </xsl:template>
</xsl:stylesheet>