<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:soap="http://www.w3.org/2003/05/soap-envelope">
    <xsl:output method="xml" indent="yes" />

    <!-- Are you adding this file as an external XSLT / Docker mounted file?
     Make sure to copy the code already in this document! -->

    <!-- Parameters get their values from transformations performed in
    Configuration_WebformulierenVerwerker.xml -->
    <xsl:param name="systemdate" />
    <xsl:param name="ONum" />

    <!-- This template determines what the output will look like. -->
    <xsl:template match="/">
        <bct:CreateMetaDocument xmlns:bct="http://bct.nl">
            <bct:ObjectID></bct:ObjectID>
            <bct:ObjectKind>INK</bct:ObjectKind>
            <bct:FieldValues>
                <!-- New elements can be set by adding them in a similar manner as the elements
                below. -->
                <bct:NameValue>
                    <bct:Name>poststuk.dat_afh_str</bct:Name>
                    <bct:Value>
                        <xsl:value-of select="$systemdate" />
                    </bct:Value>
                </bct:NameValue>
                <bct:NameValue>
                    <bct:Name>poststuk.onderwerp</bct:Name>
                    <bct:Value>
                        <xsl:value-of select="//onderwerp" />
                    </bct:Value>
                </bct:NameValue>
                <bct:NameValue>
                    <bct:Name>poststuk.inhoud1</bct:Name>
                    <bct:Value>
                        <xsl:value-of select="//inhoud" />
                    </bct:Value>
                </bct:NameValue>
                <bct:NameValue>
                    <bct:Name>poststuk.v_plaats_id</bct:Name>
                    <bct:Value>
                        <xsl:value-of select="//behandelaarnaam" />
                    </bct:Value>
                </bct:NameValue>
                <bct:NameValue>
                    <bct:Name>poststuk.reg_datum</bct:Name>
                    <bct:Value>
                        <xsl:value-of select="$systemdate" />
                    </bct:Value>
                </bct:NameValue>
                <bct:NameValue>
                    <bct:Name>poststuk.dat_poststuk</bct:Name>
                    <bct:Value>
                        <xsl:value-of select="$systemdate" />
                    </bct:Value>
                </bct:NameValue>
                <bct:NameValue>
                    <bct:Name>poststuk.kenmerk</bct:Name>
                    <bct:Value>
                        <xsl:value-of select="//onderwerp" />
                    </bct:Value>
                </bct:NameValue>
                <bct:NameValue>
                    <bct:Name>obj_vert.vertrouw_id</bct:Name>
                    <bct:Value>
                        <xsl:value-of select="//vertrouwelijkheid" />
                    </bct:Value>
                </bct:NameValue>
                <bct:NameValue>
                    <bct:Name>poststuk.soort_ext</bct:Name>
                    <bct:Value>I</bct:Value>
                </bct:NameValue>
                <bct:NameValue>
                    <bct:Name>poststuk.relatie_id</bct:Name>
                    <bct:Value>
                        <xsl:value-of select="$ONum" />
                    </bct:Value>
                </bct:NameValue>
                <xsl:choose>
                    <xsl:when test="//dossiercode">
                        <bct:NameValue>
                            <bct:Name>stuk_doss.dossier_id</bct:Name>
                            <bct:Value>
                                <xsl:value-of select="//dossiercode" />
                            </bct:Value>
                        </bct:NameValue>
                    </xsl:when>
                    <xsl:otherwise>
                        <bct:NameValue>
                            <bct:Name>stuk_doss.dossier_id</bct:Name>
                            <bct:Value></bct:Value>
                        </bct:NameValue>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:choose>
                    <xsl:when test="//afgehandeld">
                        <bct:NameValue>
                            <bct:Name>poststuk.afgehandeld</bct:Name>
                            <bct:Value>
                                <xsl:value-of select="//afgehandeld" />
                            </bct:Value>
                        </bct:NameValue>
                    </xsl:when>
                    <xsl:otherwise>
                        <bct:NameValue>
                            <bct:Name>poststuk.afgehandeld</bct:Name>
                            <bct:Value>0</bct:Value>
                        </bct:NameValue>
                    </xsl:otherwise>
                </xsl:choose>
            </bct:FieldValues>
            <bct:ReferenceValues>
                <bct:NameValue>
                    <bct:Name>ontvdat</bct:Name>
                    <bct:Value>
                        <xsl:value-of select="translate($systemdate,'/','-')" />
                    </bct:Value>
                </bct:NameValue>
                <bct:NameValue>
                    <bct:Name>kanaal</bct:Name>
                    <bct:Value>Internet</bct:Value>
                </bct:NameValue>
            </bct:ReferenceValues>
            <bct:DuplicateID></bct:DuplicateID>
            <bct:DSPTemplateID></bct:DSPTemplateID>
        </bct:CreateMetaDocument>
    </xsl:template>
</xsl:stylesheet>