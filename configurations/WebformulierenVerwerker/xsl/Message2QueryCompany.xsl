<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="xml" indent="yes" />
    <xsl:param name="afzenderkvk" />
    <xsl:template match="/">
        <bct:QueryExecute xmlns:bct="http://bct.nl">
            <bct:ObjectType>E</bct:ObjectType>
            <bct:QueryItems>
                <bct:QueryItem>
                    <bct:RubricType>qrtReference</bct:RubricType>
                    <bct:RubricID>StufKvk</bct:RubricID>
                    <bct:Condition>qcAnd</bct:Condition>
                    <bct:Operator>qoEqual</bct:Operator>
                    <bct:Value>
                        <xsl:value-of select="$afzenderkvk" />
                    </bct:Value>
                </bct:QueryItem>
            </bct:QueryItems>
            <bct:SkipEmptyConditions>false</bct:SkipEmptyConditions>
            <bct:SearchByQueryOrder>false</bct:SearchByQueryOrder>
            <bct:SearchSubFolders>false</bct:SearchSubFolders>
            <bct:SearchRelated>false</bct:SearchRelated>
            <bct:SearchRecursive>true</bct:SearchRecursive>
            <bct:ReturnIDsOnly>true</bct:ReturnIDsOnly>
            <bct:MaxResult>1</bct:MaxResult>
        </bct:QueryExecute>
    </xsl:template>
</xsl:stylesheet>