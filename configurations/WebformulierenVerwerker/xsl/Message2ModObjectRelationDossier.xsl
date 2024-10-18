<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   xmlns:soap="http://www.w3.org/2003/05/soap-envelope">
   <xsl:output method="xml" indent="yes" />

   <xsl:param name="systemdate" />
   <xsl:param name="DossierID" />
   <xsl:param name="Registratienummer" />

   <xsl:template match="/">
      <bct:ModObjectRelation xmlns:bct="http://bct.nl">
         <bct:Action>MORA_Create</bct:Action>
         <!--Optional:-->
         <bct:ObjectType_1>S</bct:ObjectType_1>
         <!--Optional:-->
         <bct:ObjectID_1>
            <xsl:value-of select="$Registratienummer" />
         </bct:ObjectID_1>
         <!--Optional:-->
         <bct:ObjectType_2>D</bct:ObjectType_2>
         <!--Optional:-->
         <bct:ObjectID_2>
            <xsl:value-of select="$DossierID" />
         </bct:ObjectID_2>
         <!--Optional:-->
         <bct:RelationTypeID>BIJ</bct:RelationTypeID>
      </bct:ModObjectRelation>
   </xsl:template>
</xsl:stylesheet>