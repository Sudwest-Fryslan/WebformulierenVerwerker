<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:soap="http://www.w3.org/2003/05/soap-envelope">
    <xsl:output method="xml" indent="yes"/>
    
    <xsl:param name="systemdate"/>
    <xsl:param name="DocumentID"/>
    <xsl:template match="/">
        <soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope" xmlns:bct="http://bct.nl">
		   <soap:Header/>
		   <soap:Body>
		      <bct:CreateFileVersion>
		         <!--Optional:-->
		         <bct:ObjectType>S</bct:ObjectType>
		         <!--Optional:-->
		         <bct:ObjectID><xsl:value-of select="$DocumentID"/></bct:ObjectID>
				
		         <bct:FileBytes><xsl:value-of select="//filedata"/></bct:FileBytes>
		         <bct:FileType>ftNative</bct:FileType>
		         <bct:FileVersion>0</bct:FileVersion>
		         <!--Optional:-->
		         <bct:FileExtension>.png</bct:FileExtension>
		         <!--Optional:-->
		         <bct:DocumentName>Het swf logo</bct:DocumentName>
		         <!--Optional:-->
		         <bct:VersionDescription>Eerste versie</bct:VersionDescription>
		         <!--Optional:-->
		         <!--
		         <bct:Action>
		            < ! - - Zero or more repetitions: - - >
		            <bct:DSAction>?</bct:DSAction>
		         </bct:Action>
		         -->
		      </bct:CreateFileVersion>
		   </soap:Body>
		</soap:Envelope>
    </xsl:template>
</xsl:stylesheet>