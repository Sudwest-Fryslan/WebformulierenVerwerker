<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="xml" indent="yes"/>
    <xsl:template match="/">
        <soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope"
            xmlns:bct="http://bct.nl">
            <soap:Header />
            <soap:Body>
                <bct:QueryExecute>
                    <!--Persoon-->
                    <bct:ObjectType>P</bct:ObjectType>
                    <!--Query-->
                    <bct:QueryItems>
                        <bct:QueryItem>
                            <!--
              possible value: qrtDbField, 
           possible value: qrtRelatedDbField, 
           possible value: qrtReference, 
           possible value: qrtProcedureField, 
           possible value: qrtConstantValueField, 
           possible value: qrtSearchWord, 
           possible value: qrtFullText
               
               Waarde was: "K"-->
                            <bct:RubricType>K</bct:RubricType>
                            <!-- BRSpSOFI / BRSpSofi / BSN -->
                            <bct:RubricID>BRSpSofi</bct:RubricID>
                            <!--
              possible value: qcAnd, 
           possible value: qcOr, 
           possible value: qcNot			
               
               Waarde was: "AND"-->
                            <bct:Condition>qcOr</bct:Condition>
                            <!--
              possible value: qoSmaller, 
           possible value: qoSmallerOrEqual, 
           possible value: qoEqual, 
           possible value: qoUnEqual, 
           possible value: qoLarger, 
           possible value: qoLargerOrEqual, 
           possible value: qoStartsWith, 
           possible value: qoContains
               
               Waarde was: "="-->
                            <bct:Operator>qoEqual</bct:Operator>
                            <!-- logius test bsn: 900246315 -->
                            <bct:Value>${Properties#BSN}</bct:Value>
                            <!-- <bct:Value>109098766</bct:Value> -->
                        </bct:QueryItem>
                    </bct:QueryItems>
                    <!--True
                    to skip empty query conditions, otherwise false. Default true-->
                    <bct:SkipEmptyConditions>false</bct:SkipEmptyConditions>
                    <!--True
                    to execute the query according to the query order, otherwise false. Default
                    false-->
                    <bct:SearchByQueryOrder>false</bct:SearchByQueryOrder>
                    <!--Default
                    false, only used when ObjectType is D (= folder).
       True to additionally return subfolders of the folders found (1st level down only).
       Set parameter SearchRecursive to True to return all sub folder levels (including subfolders of
                    subfolders) .-->
                    <bct:SearchSubFolders>false</bct:SearchSubFolders>
                    <!--Default
                    false. True to additionally return related objects (not recursively). To
                    recursively return all related objects
       (related objects of related objects), set parameter SearchRecursive to True.-->
                    <bct:SearchRelated>false</bct:SearchRelated>
                    <!--Default
                    false. True to search through related objects recursively.-->
                    <bct:SearchRecursive>true</bct:SearchRecursive>
                    <!--True
                    to retrieve only ObjectID’s as result, false to use the ResultItems parameter to
                    determine the returned values-->
                    <bct:ReturnIDsOnly>true</bct:ReturnIDsOnly>
                    <!--Maximum
                    number of items to retrieve. Use 0 to not limit the result-->
                    <bct:MaxResult>1</bct:MaxResult>
                    <!--Optional:
    <bct:ResultItems>
       <bct:TypeValue>
          <bct:Type>?</bct:Type>
          <bct:Value>?</bct:Value>
       </bct:TypeValue>
    </bct:ResultItems>-->
                    <!--Optional:
    <bct:QueryLayoutId>?</bct:QueryLayoutId>-->
                </bct:QueryExecute>

            </soap:Body>
        </soap:Envelope>
    </xsl:template>
</xsl:stylesheet>