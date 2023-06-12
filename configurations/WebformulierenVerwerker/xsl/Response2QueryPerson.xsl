<soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:xsd="http://www.w3.org/2001/XMLSchema"
    xmlns:wsa="http://schemas.xmlsoap.org/ws/2004/08/addressing"
    xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd"
    xmlns:wsu="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd">
    <env:Header xmlns:env="http://www.w3.org/2003/05/soap-envelope">
        <wsa:Action>http://bct.nl/QueryExecuteResponse</wsa:Action>
        <wsa:MessageID>urn:uuid:9ac3b26f-eeaf-4e9c-bf0c-5ca722165b1c</wsa:MessageID>
        <wsa:RelatesTo>urn:uuid:907cde24-46d5-4ecf-bb79-c7258f6e51be</wsa:RelatesTo>
        <wsa:To>http://schemas.xmlsoap.org/ws/2004/08/addressing/role/anonymous</wsa:To>
        <wsse:Security>
            <wsu:Timestamp wsu:Id="Timestamp-05710965-fe08-4cdf-98b4-2331f0a0c6d8">
                <wsu:Created>2023-02-01T17:00:34Z</wsu:Created>
                <wsu:Expires>2023-02-01T17:05:34Z</wsu:Expires>
            </wsu:Timestamp>
        </wsse:Security>
    </env:Header>
    <soap:Body>
        <QueryExecuteResponse xmlns="http://bct.nl">
            <QueryExecuteResult>
                <xs:schema id="NewDataSet" xmlns="" xmlns:xs="http://www.w3.org/2001/XMLSchema"
                    xmlns:msdata="urn:schemas-microsoft-com:xml-msdata"
                    xmlns:msprop="urn:schemas-microsoft-com:xml-msprop">
                    <xs:element name="NewDataSet" msdata:IsDataSet="true"
                        msdata:MainDataTable="QueryExecResult" msdata:Locale="">
                        <xs:complexType>
                            <xs:choice minOccurs="0" maxOccurs="unbounded">
                                <xs:element name="QueryExecResult" msdata:Locale=""
                                    msprop:PROGRESS.bundo="False" msprop:PROGRESS.brejected="False"
                                    msprop:PROGRESS.bimage_flag="False"
                                    msprop:PROGRESS.bdata_source_mod="False"
                                    msprop:PROGRESS.errorString="">
                                    <xs:complexType>
                                        <xs:sequence>
                                            <xs:element name="_x0024_id_x0024_" msdata:Caption=""
                                                msprop:PROGRESS.progressType="1"
                                                msprop:PROGRESS.init_value=""
                                                msprop:PROGRESS.user_order="3"
                                                msprop:PROGRESS.position="5" type="xs:string"
                                                default="" minOccurs="0" />
                                        </xs:sequence>
                                    </xs:complexType>
                                </xs:element>
                            </xs:choice>
                        </xs:complexType>
                    </xs:element>
                </xs:schema>
                <diffgr:diffgram xmlns:msdata="urn:schemas-microsoft-com:xml-msdata"
                    xmlns:diffgr="urn:schemas-microsoft-com:xml-diffgram-v1">
                    <DocumentElement xmlns="">
                        <QueryExecResult diffgr:id="QueryExecResult1" msdata:rowOrder="0">
                            <_x0024_id_x0024_>SP.00132223</_x0024_id_x0024_>
                        </QueryExecResult>
                        <QueryExecResult diffgr:id="QueryExecResult2" msdata:rowOrder="1">
                            <_x0024_id_x0024_>SP.00132224</_x0024_id_x0024_>
                        </QueryExecResult>
                        <QueryExecResult diffgr:id="QueryExecResult3" msdata:rowOrder="2">
                            <_x0024_id_x0024_>SP.00132225</_x0024_id_x0024_>
                        </QueryExecResult>
                        <QueryExecResult diffgr:id="QueryExecResult4" msdata:rowOrder="3">
                            <_x0024_id_x0024_>SP.00132226</_x0024_id_x0024_>
                        </QueryExecResult>
                        <QueryExecResult diffgr:id="QueryExecResult5" msdata:rowOrder="4">
                            <_x0024_id_x0024_>SP.00132227</_x0024_id_x0024_>
                        </QueryExecResult>
                        <QueryExecResult diffgr:id="QueryExecResult6" msdata:rowOrder="5">
                            <_x0024_id_x0024_>SP.00132228</_x0024_id_x0024_>
                        </QueryExecResult>
                        <QueryExecResult diffgr:id="QueryExecResult7" msdata:rowOrder="6">
                            <_x0024_id_x0024_>SP.00132229</_x0024_id_x0024_>
                        </QueryExecResult>
                        <QueryExecResult diffgr:id="QueryExecResult8" msdata:rowOrder="7">
                            <_x0024_id_x0024_>SP.00132230</_x0024_id_x0024_>
                        </QueryExecResult>
                        <QueryExecResult diffgr:id="QueryExecResult9" msdata:rowOrder="8">
                            <_x0024_id_x0024_>SP.00132231</_x0024_id_x0024_>
                        </QueryExecResult>
                        <QueryExecResult diffgr:id="QueryExecResult10" msdata:rowOrder="9">
                            <_x0024_id_x0024_>SP.00132232</_x0024_id_x0024_>
                        </QueryExecResult>
                    </DocumentElement>
                </diffgr:diffgram>
            </QueryExecuteResult>
            <LastError />
        </QueryExecuteResponse>
    </soap:Body>
</soap:Envelope>