import base64
import json
import threading
import unittest
from unittest.mock import patch
from urllib.error import HTTPError
from urllib.request import Request, urlopen

import app
from Crypto.Cipher import AES

T1 = 'a' * 64
T2 = 'b' * 64
URL = 'https://auth.platorelay.com/a?d=' + T1

class Tests(unittest.TestCase):
    def test_validation(self):
        self.assertEqual(app.ticket_from_url(URL), T1)
        for bad in ['http://auth.platorelay.com/a?d=' + T1,
                    'https://auth.platorelay.com.evil.test/a?d=' + T1,
                    'https://evil.test/a?d=' + T1,
                    URL + '&d=' + T2, URL.replace('/a?', '/b?')]:
            with self.assertRaises(app.SolveError): app.ticket_from_url(bad)

    def test_payload_encryption(self):
        payload = app.make_payload(T1)
        raw = AES.new(T1[:16].encode(), AES.MODE_CTR, nonce=b'',
                      initial_value=int.from_bytes(T1[16:32].encode(), 'big')).decrypt(bytes.fromhex(payload['meta']))
        self.assertEqual(json.loads(raw)['browserInfo'][0]['screen'], '390x844')
        self.assertTrue(payload['resolved'])

    def test_chained_solve(self):
        callback = 'https://auth.platorelay.com/a?d=' + T2
        redirect = 'https://advertiser.invalid/?r=' + base64.urlsafe_b64encode(callback.encode()).decode().rstrip('=')
        seen = []
        def fake_api(path, ticket, service=None, payload=None):
            seen.append((path, ticket))
            if path == 'status': return {'data': {'key': 'FREE_test' if ticket == T2 else 'KEY_NOT_FOUND'}}
            if path == 'metadata': return {'data': {'activeRevenueProfile': {'service': 3}}}
            self.assertEqual(service, 3)
            return {'success': True, 'data': {'url': redirect}}
        with patch.object(app, 'api', side_effect=fake_api):
            self.assertEqual(app.solve(URL), 'FREE_test')
        self.assertIn(('status', T2), seen)
        bad = base64.urlsafe_b64encode(b'https://evil.test/a?d=' + T2.encode()).decode()
        self.assertIsNone(app.callback_ticket('https://advertiser.invalid/?r=' + bad))

    def test_http_authorization_and_result(self):
        server = app.ThreadingHTTPServer(('127.0.0.1', 0), app.Handler)
        server.token = 'secret'
        thread = threading.Thread(target=server.serve_forever, daemon=True)
        thread.start()
        root = 'http://127.0.0.1:%d' % server.server_port
        try:
            with urlopen(root + '/') as r:
                self.assertIn(b'Delta Key', r.read())
                self.assertEqual(r.headers['Cache-Control'], 'no-store')
            body = json.dumps({'url': URL}).encode()
            def post(token, origin):
                return urlopen(Request(root + '/solve', body, {'Content-Type': 'application/json', 'Origin': origin, 'X-Local-Token': token}))
            for token, origin in [('wrong', root), ('secret', 'http://evil.test')]:
                with self.assertRaises(HTTPError) as ctx: post(token, origin)
                self.assertEqual(ctx.exception.code, 403)
            with patch.object(app, 'solve', return_value='FREE_test'):
                with post('secret', root) as r:
                    self.assertEqual(json.load(r)['key'], 'FREE_test')
        finally:
            server.shutdown()
            server.server_close()
            thread.join()

if __name__ == '__main__': unittest.main()
