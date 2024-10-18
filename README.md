# WebformulierenVerwerker

Communicate between Kodison and Corsa. This configuration transforms incoming Kodison messages and makes them into Corsa requests. The responses are then transformed into messages accepted by Kodison.

This application processes SOAP requests that satisfy a WSDL that has been copied from the predecessor of this bridge. The WSDL is included in this project.

## Testing
This project can be tested using the SoapUI project in the Tests folder. For local testing you must run the Mockservice contained within the SoapUI project and then run the General Tests testcase. For testing on a configured test environment you will not need the mockservice. However, you will have to change the project's custom property "WebformulierenVerwerkerEndpoint" to the Corsa endpoint. 

The mockservice runs on port 8081. Communication with the Frank! is presumed to be on port 8080.

## Advanced Information

The WebformulierenVerwerker is a Frank! which runs on Frank!Framework version 7.9-20231002.120318. This version may differ in production as it is currently deployed on Het Integratie Platform which runs its own version of the Framework.

Every incoming message arrives at Configuration_WebformulierenVerwerkerDispatcher.xml under the adapter WebformulierenVerwerker. It is in that adapter that a WebserviceListener receives the incoming SOAP messages. After validating the input using the file GeneriekeFormulierAfhandeling.wsdl the configuration unwraps the message. 
A XMLSwitchPipe determines the flow based on the action noted in the input. (i.e. action "Version" will follow the VersionAction flow.)
It then stores the SoapAction in a sessionkey so it can be used for logging and errorHandling later on.
The last action the WebformulierenVerwerker adapter takes is to call the adapter corresponding to the action. 

The next steps are taken by the adapter corresponding to the action. In this description we will discuss the most complex adapter in the hope that other adapters will become easier to figure out on your own.
Presuming that the action was "opslaanInkNatuurlijkPersoon", we follow the flow to it's respective adapter in Configuration_WebformulierenVerwerker.xml.

The first step the adapter opslaanInkNatuurlijkPersoon takes is to apply a locker. The locker is used to prevent issues with multiple messages coming in at the same time.
The adapter then prepares and sends a connect request to Corsa. Once a confirmation of a successful connection attempt is returned, the configuration checks if a BSN element is present in the input message. If one is present then the configuration sends a query to Corsa to retrieve the corresponding person registration. If there is no BSN included then the configuration does not aim to connect the input message to a person registration and moves on to storing the input document.

The person registration query aims to return one result or none at all. In the event that a person registration is found, we get exactly one result back. This result is then used to extract the person registration number so that it may be used to connect the incoming documents to that person (Pipe "GetSPNum").
If no result is found, we make the presumption that no person registration is present and that the Frank! is responsible for creating one. In this case we send a request to create a person registration (Pipe "ConvertToCreatePerson").

After the work with person registration documents has finished, the Frank! gets to processing the input document. It proceeds to first register the document in Corsa. If successful, it sends another request to Corsa but this time it is a request to assign a version to the file that the Frank! just registered in Corsa. The request is created in pipe "ConvertToCreateFileVersion".
If every step so far has been succesful, we send a disconnect request and store the authentication value in our database (Pipe "StoreVertrouwelijkheid"). This authentication value is necessary for the OpslaanBijlage adapter as it requires this value but is not given the value in the input.

Under any circumstance, the Frank! will attempt to do proper error handling. In the event that an error message is returned at any of the sender pipes, the Frank! will immediately transfer the returned message to the pipe storeErrorResponse. Shortly after a properly readable error message is created which contains additional information that may be useful to the user. Java errors in other pipes are not always handled this way as they do not tend to contain information that is useful to the user.

The description above does not describe every pipe in the pipeline, but it is safe to assume that every part takes the same steps:
1. Create the request
2. Wrap the request
3. Validate the request
4. Send the request
5. Unwrap the response
6. Check if response is succesful