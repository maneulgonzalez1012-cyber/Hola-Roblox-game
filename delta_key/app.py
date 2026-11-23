#!/usr/bin/env python3
"""Experimental Platorelay solver. Protocol adapted from the MIT-licensed
xiaobai1023/Delta-solve-keysystem-tool; see UPSTREAM-LICENSE.txt.
"""
import argparse
import base64
import hmac
import json
import ipaddress
import re
import secrets
import socket
import time
import urllib.error
import urllib.parse
import urllib.request
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path

try:
    from Crypto.Cipher import AES
except ImportError:
    raise SystemExit('Falta pycryptodome. Instala: python3 -m pip install pycryptodome')

AUTH = 'https://auth.platorelay.com'
UA = ('Mozilla/5.0 (iPhone; CPU iPhone OS 18_3_2 like Mac OS X) '
      'AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.3.1 Mobile/15E148 Safari/604.1')
VERSION = '8.2.0'
TICKET_RE = re.compile(r'^[A-Za-z0-9_-]{33,4096}$')

class SolveError(Exception):
    pass


def ticket_from_url(url):
    if not isinstance(url, str) or len(url) > 8192:
        raise SolveError('URL inválida o demasiado larga.')
    try:
        p = urllib.parse.urlsplit(url.strip())
        if (p.scheme != 'https' or p.hostname != 'auth.platorelay.com' or p.port not in (None, 443)
                or p.username or p.password or p.path != '/a'):
            raise ValueError()
        values = urllib.parse.parse_qs(p.query, keep_blank_values=True).get('d', [])
    except ValueError:
        raise SolveError('La URL debe ser https://auth.platorelay.com/a?d=...')
    if len(values) != 1 or not TICKET_RE.fullmatch(values[0]):
        raise SolveError('El parámetro d no es un ticket válido.')
    return values[0]


def callback_ticket(url):
    try:
        query = urllib.parse.parse_qs(urllib.parse.urlsplit(url).query)
        encoded = query.get('r', [None])[0]
        if not encoded or len(encoded) > 12000:
            return None
        decoded = base64.urlsafe_b64decode(encoded + '=' * (-len(encoded) % 4)).decode('utf-8')
        return ticket_from_url(decoded)
    except (ValueError, UnicodeError, SolveError):
        return None

class NoRedirect(urllib.request.HTTPRedirectHandler):
    def redirect_request(self, req, fp, code, msg, headers, newurl):
        return None

OPENER = urllib.request.build_opener(NoRedirect())

def api(path, ticket, service=None, payload=None):
    params = {'ticket': ticket}
    if service is not None:
        params['service'] = str(service)
    url = AUTH + '/api/session/' + path + '?' + urllib.parse.urlencode(params)
    headers = {'User-Agent': UA, 'Accept': 'application/json', 'x-client-name': 'platoboost webclient',
               'x-client-version': VERSION}
    body = None
    if payload is not None:
        headers['Content-Type'] = 'application/json'
        body = json.dumps(payload, separators=(',', ':')).encode()
    request = urllib.request.Request(url, data=body, headers=headers, method='PUT' if body else 'GET')
    try:
        with OPENER.open(request, timeout=15) as response:
            raw = response.read(65537)
            if len(raw) > 65536:
                raise SolveError('Respuesta del proveedor demasiado grande.')
            result = json.loads(raw)
            if not isinstance(result, dict):
                raise ValueError()
            return result
    except urllib.error.HTTPError as exc:
        raise SolveError('El proveedor respondió HTTP %d.' % exc.code) from None
    except (urllib.error.URLError, TimeoutError, OSError):
        raise SolveError('No se pudo conectar con Platorelay desde el servidor Python.') from None
    except (ValueError, UnicodeError):
        raise SolveError('El proveedor no devolvió JSON válido.') from None


def encrypt(text, key, iv):
    return AES.new(key.encode('ascii'), AES.MODE_CTR, nonce=b'',
                   initial_value=int.from_bytes(iv.encode('ascii'), 'big')).encrypt(text.encode()).hex()


def make_payload(ticket):
    now = int(time.time() * 1000)
    meta = json.dumps({'browserInfo': [{'screen': '390x844', 'ua': UA, 'time': now}]}, separators=(',', ':'))
    stream = json.dumps({'events': [{'event': 1, 'data': {'time': now}}]}, separators=(',', ':'))
    return {'captcha': None, 'meta': encrypt(meta, ticket[:16], ticket[16:32]),
            'stream': encrypt(stream, ticket[1:17], ticket[17:33]), 'resolved': True}


def get_key(ticket):
    result = api('status', ticket)
    data = result.get('data')
    if not isinstance(data, dict):
        data = result
    key = data.get('key')
    return key if isinstance(key, str) and key and key != 'KEY_NOT_FOUND' else None


def solve(url):
    ticket = ticket_from_url(url)
    for _ in range(12):
        key = get_key(ticket)
        if key:
            return key
        metadata = api('metadata', ticket)
        data = metadata.get('data')
        if not isinstance(data, dict):
            data = metadata
        profile = data.get('activeRevenueProfile')
        if not isinstance(profile, dict) or not isinstance(profile.get('service'), int):
            raise SolveError('No se encontró el servicio en metadata; enlace caducado o protocolo cambiado.')
        result = api('step', ticket, profile['service'], make_payload(ticket))
        if not result.get('success'):
            message = str(result.get('message') or result.get('error') or 'sin detalles')[:160]
            raise SolveError('El proveedor rechazó el paso: ' + message)
        data = result.get('data')
        next_url = data.get('url') if isinstance(data, dict) else None
        if next_url == 'about:blank':
            for _ in range(10):
                key = get_key(ticket)
                if key:
                    return key
                time.sleep(0.5)
            raise SolveError('No apareció la key. Puede requerir espera o un checkpoint real.')
        next_ticket = callback_ticket(next_url) if isinstance(next_url, str) else None
        if not next_ticket:
            key = get_key(ticket)
            if key:
                return key
            raise SolveError('No se pudo encontrar el siguiente ticket ni una key.')
        ticket = next_ticket
    raise SolveError('Demasiados checkpoints; detenido por seguridad.')


class Handler(BaseHTTPRequestHandler):
    def log_message(self, *_):
        pass  # no URLs, tickets or keys in access logs

    def send(self, status, data, content_type):
        self.send_response(status)
        self.send_header('Content-Type', content_type)
        self.send_header('Content-Length', str(len(data)))
        self.send_header('Cache-Control', 'no-store')
        self.send_header('X-Content-Type-Options', 'nosniff')
        self.send_header('Referrer-Policy', 'no-referrer')
        self.send_header('Content-Security-Policy', "default-src 'self'; script-src 'self'; style-src 'self'; connect-src 'self'; base-uri 'none'; frame-ancestors 'none'")
        self.end_headers()
        self.wfile.write(data)

    def do_GET(self):
        files = {'/': ('index.html', 'text/html; charset=utf-8'),
                 '/app.js': ('app.js', 'application/javascript; charset=utf-8'),
                 '/style.css': ('style.css', 'text/css; charset=utf-8')}
        entry = files.get(self.path)
        if not entry:
            return self.send(404, b'Not found', 'text/plain')
        return self.send(200, (Path(__file__).parent / entry[0]).read_bytes(), entry[1])

    def do_POST(self):
        origin = self.headers.get('Origin', '')
        host = self.headers.get('Host', '')
        supplied_token = self.headers.get('X-Local-Token', '').encode('utf-8')
        if (self.path not in ('/solve', '/connected')
                or not hmac.compare_digest(supplied_token, self.server.token.encode('ascii'))
                or origin != 'http://' + host or self.headers.get_content_type() != 'application/json'):
            return self.send(403, b'{"error":"Acceso denegado"}', 'application/json')
        if self.path == '/connected':
            address = self.client_address[0]
            remote = not ipaddress.ip_address(address).is_loopback
            if remote:
                print('\n[OK] Un dispositivo remoto abrio la pagina y se conecto al servidor.', flush=True)
                print('Esto confirma conectividad, no que ambos usen el mismo Wi-Fi.', flush=True)
            return self.send(200, json.dumps({'connected': True, 'remote': remote}).encode(), 'application/json')
        try:
            length = int(self.headers.get('Content-Length', '0'))
            if length < 1 or length > 10000:
                raise ValueError()
            obj = json.loads(self.rfile.read(length))
            if not isinstance(obj, dict):
                raise ValueError()
            result = {'key': solve(obj.get('url'))}
            status = 200
        except (ValueError, json.JSONDecodeError):
            result, status = {'error': 'Solicitud inválida.'}, 400
        except SolveError as exc:
            result, status = {'error': str(exc)}, 400
        self.send(status, json.dumps(result, ensure_ascii=False).encode(), 'application/json; charset=utf-8')


def local_ipv4_addresses():
    """Possible local interfaces, not proof of iPhone connectivity or shared Wi-Fi."""
    addresses = set()
    try:
        for entry in socket.getaddrinfo(socket.gethostname(), None, socket.AF_INET):
            ip = ipaddress.ip_address(entry[4][0])
            if ip.is_private and not ip.is_loopback and not ip.is_link_local:
                addresses.add(str(ip))
    except OSError:
        pass
    return sorted(addresses)


def main():
    parser = argparse.ArgumentParser(description='Servidor local experimental de Delta Key')
    parser.add_argument('--lan', action='store_true', help='Permitir acceso desde la red local; usar solo en Wi-Fi privada')
    parser.add_argument('--port', type=int, default=8765)
    args = parser.parse_args()
    server = ThreadingHTTPServer(('0.0.0.0' if args.lan else '127.0.0.1', args.port), Handler)
    server.token = secrets.token_urlsafe(32)
    print('En este dispositivo: http://127.0.0.1:%d/#%s' % (server.server_port, server.token), flush=True)
    if args.lan:
        print('\nAbre uno de estos enlaces COMPLETOS en Safari del iPhone:', flush=True)
        addresses = local_ipv4_addresses()
        for address in addresses:
            print('  http://%s:%d/#%s' % (address, server.server_port, server.token), flush=True)
        if not addresses:
            print('No se detecto una IP local automaticamente. Usa ipconfig y reemplaza 127.0.0.1 por la IPv4 de Wi-Fi.', flush=True)
        print('Si hay varias IP, prueba la de Wi-Fi. Esperando conexion del iPhone...', flush=True)
        print('Solo Wi-Fi privada: HTTP no cifra el trafico. No compartas el enlace.', flush=True)
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        pass
    finally:
        server.server_close()

if __name__ == '__main__':
    main()
