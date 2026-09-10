# -*- coding: utf-8 -*-
import re, io, base64
s = io.open('e2e/webformulierenverwerker-soapui-project.xml', encoding='utf-8').read()
parts = re.split(r'(<con:testStep [^>]*name="([^"]+)"[^>]*>)', s)
i = 1
while i < len(parts):
    name, body = parts[i+1], parts[i+2]
    if name == '01a-opslaanAanvraagNatuurlijkPersoon':
        m = re.search(r'<con:request><!\[CDATA\[(.*?)\]\]></con:request>', body, re.S)
        if m:
            io.open('req_geldig.xml','w',encoding='utf-8').write(m.group(1))
            print('geldig request opgeslagen, %d tekens' % len(m.group(1)))
            break
    i += 3
