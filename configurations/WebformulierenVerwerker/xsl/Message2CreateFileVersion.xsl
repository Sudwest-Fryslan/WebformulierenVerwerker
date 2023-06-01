<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:soap="http://www.w3.org/2003/05/soap-envelope">
    <xsl:output method="xml" indent="yes"/>
    
    <xsl:param name="systemdate"/>
    <xsl:param name="DocumentID"/>
    <xsl:template match="/">
		   <!-- TODO: Replace with Xpath -->
		      <bct:CreateFileVersion>
		         <!--Optional:-->
		         <bct:ObjectType>S</bct:ObjectType>
		         <!--Optional:-->
		         <bct:ObjectID><xsl:value-of select="$DocumentID"/></bct:ObjectID>
				
		         <bct:FileBytes><xsl:value-of select="//filedata"/></bct:FileBytes>
		         <bct:FileType>ftNative</bct:FileType>
		         <bct:FileVersion>0</bct:FileVersion>
		         <!--Optional:-->
		         <bct:FileExtension><xsl:value-of select="/opslaanBijlage/filename/replace(tokenize(., '/')[last()], '.*\.', '')"/></bct:FileExtension>
		         <!--Optional:-->
		         <bct:DocumentName><xsl:value-of select="tokenize(/opslaanBijlage/filename, '\.|/')[last() - 1]"/></bct:DocumentName>
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
	</xsl:template>
</xsl:stylesheet>