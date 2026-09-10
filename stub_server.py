# -*- coding: utf-8 -*-
"""Minimale stubs voor OpenZaakBrug (7772) en CAReL (7771), zodat de hele
pijplijn lokaal doorlopen kan worden zonder die systemen."""
import threading, sys
from http.server import BaseHTTPRequestHandler, HTTPServer

ID_RESP = b"""<?xml version="1.0" encoding="UTF-8"?>
<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/">
 <SOAP-ENV:Body>
  <ZKN:genereerZaakIdentificatie_Du02 xmlns:ZKN="http://www.egem.nl/StUF/sector/zkn/0310">
   <ZKN:zaak><ZKN:identificatie>1900999999</ZKN:identificatie></ZKN:zaak>
  </ZKN:genereerZaakIdentificatie_Du02>
 </SOAP-ENV:Body>
</SOAP-ENV:Envelope>"""

BV03 = b"""<?xml version="1.0" encoding="UTF-8"?>
<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/">
 <SOAP-ENV:Body>
  <StUF:Bv03Bericht xmlns:StUF="http://www.egem.nl/StUF/StUF0301">
   <StUF:stuurgegevens><StUF:berichtcode>Bv03</StUF:berichtcode></StUF:stuurgegevens>
  </StUF:Bv03Bericht>
 </SOAP-ENV:Body>
</SOAP-ENV:Envelope>"""

class H(BaseHTTPRequestHandler):
    resp = ID_RESP
    def do_POST(self):
        n = int(self.headers.get('Content-Length', 0))
        body = self.rfile.read(n)
        with open('stub_%d.log' % self.server.server_address[1], 'ab') as f:
            f.write(body + b'\n=====\n')
        self.send_response(200)
        self.send_header('Content-Type', 'text/xml; charset=utf-8')
        self.send_header('Content-Length', str(len(self.resp)))
        self.end_headers()
        self.wfile.write(self.resp)
    def log_message(self, *a): pass

def serve(port, resp):
    cls = type('H%d' % port, (H,), {'resp': resp})
    HTTPServer(('0.0.0.0', port), cls).serve_forever()

threading.Thread(target=serve, args=(7772, ID_RESP), daemon=True).start()
serve(7771, BV03)
