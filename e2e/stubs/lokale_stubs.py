# -*- coding: utf-8 -*-
"""Minimale stubs voor OpenZaakBrug en CAReL, zodat de integratie lokaal de hele
pijplijn kan doorlopen zonder die systemen.

Gebruik (naast `docker compose -f compose.frank.dev.yaml up -d --build`):

    python e2e/stubs/lokale_stubs.py

Poort 7772 speelt OpenZaakBrug en geeft een vaste zaakidentificatie terug; poort
7771 speelt CAReL en bevestigt met een Bv03. Beide schrijven het ontvangen
bericht weg in stub_<poort>.log, zodat je kunt nakijken wat de integratie
werkelijk verstuurd heeft - dat is waar je de mapping op controleert.

De poorten komen uit DeploymentSpecifics.properties (host.docker.internal:7771
en :7772). Dit vervangt trap 1 tot en met 4 uit docs/werkwijze_integraties.md
niet: het toont aan dat de integratie draait en een compleet bericht opbouwt,
niet dat CAReL het accepteert.
"""
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
