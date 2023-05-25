<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:soap="http://www.w3.org/2003/05/soap-envelope">
    <xsl:output method="xml" indent="yes"/>
    
    <xsl:param name="systemdate"/>
    <!-- <xsl:param name="DocumentID"/> -->
    <xsl:param name="BijlageID"/>
    <xsl:template match="/">
        <soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope" xmlns:bct="http://bct.nl">
   <soap:Header/>
   <soap:Body>
      <bct:ModObjectRelation>
         <bct:Action>MORA_Create</bct:Action>
         <!--Optional:-->
         <bct:ObjectType_1>S</bct:ObjectType_1>
         <!--Optional:-->
         <bct:ObjectID_1><xsl:value-of select="//*[name()='registratienummer']"/></bct:ObjectID_1>
         <!--Optional:-->
         <bct:ObjectType_2>S</bct:ObjectType_2>
         <!--Optional:-->
         <bct:ObjectID_2><xsl:value-of select="$BijlageID"/></bct:ObjectID_2>
         <!--Optional:-->
         <bct:RelationTypeID>BIJ</bct:RelationTypeID>
      </bct:ModObjectRelation>
   </soap:Body>
</soap:Envelope>
    </xsl:template>
</xsl:stylesheet>