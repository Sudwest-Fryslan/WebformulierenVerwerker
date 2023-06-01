<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:soap="http://www.w3.org/2003/05/soap-envelope">
	<xsl:output method="xml" indent="yes" />

	<xsl:param name="systemdate" />
	<xsl:param name="PersoonID" />
	<xsl:template match="/">
		<bct:CreateMetaDocument xmlns:bct="http://bct.nl">
			<!--Optional:-->
			<bct:ObjectID></bct:ObjectID>
			<!--Optional:-->
			<bct:ObjectKind>BIJL</bct:ObjectKind>
			<bct:FieldValues>
				<!--Zero
				or more repetitions:-->
				<!-- 
		          	var now = DateTime.Now.ToString("dd/MM/yyyy");
				  	Add("poststuk.dat_afh_str", now);
		            	Add("poststuk.onderwerp", onderwerp);
		            	Add("poststuk.inhoud1", bericht);
		            	Add("poststuk.v_plaats_id", behandelaarnaam);
		            	Add("poststuk.reg_datum", now);         // DOET HET NIET!
		            	Add("poststuk.dat_poststuk", now);      // DOET HET NIET!
		            	Add("poststuk.kenmerk", onderwerp); // DOET HET NIET!
		            	Add("obj_vert.vertrouw_id", vertrouwelijkheid);
					-->
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
						<xsl:value-of select="//bericht" />
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
			</bct:FieldValues>
			<!--Optional:-->
			<bct:ReferenceValues>
				<!--Zero
				or more repetitions:-->
				<!--
		            var now = DateTime.Now.ToString("dd-MM-yyyy");
		            Add("ontvdat", now);
		            Add("kanaal", "Internet");
		            -->
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
			<!--Optional:-->
			<bct:DuplicateID></bct:DuplicateID>
			<!--Optional:-->
			<bct:DSPTemplateID></bct:DSPTemplateID>
		</bct:CreateMetaDocument>
	</xsl:template>
</xsl:stylesheet>