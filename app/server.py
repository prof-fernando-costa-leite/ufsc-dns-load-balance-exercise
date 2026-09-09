import json
import os
import time
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from urllib.parse import parse_qs, urlparse


INSTANCE = os.environ.get("INSTANCE", "app-unknown")
PORT = int(os.environ.get("PORT", "8000"))


class Handler(BaseHTTPRequestHandler):
    server_version = "DNSLBClassDemo/1.0"

    def log_message(self, fmt, *args):
        print(f"[{INSTANCE}] {self.client_address[0]} {fmt % args}", flush=True)

    def send_json(self, status, payload):
        data = json.dumps(payload, ensure_ascii=False).encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(data)))
        self.send_header("X-Backend-Instance", INSTANCE)
        self.end_headers()
        self.wfile.write(data)

    def do_GET(self):
        parsed = urlparse(self.path)
        if parsed.path == "/health":
            self.send_json(200, {"status": "ok", "instance": INSTANCE})
            return

        delay_ms = 0
        if parsed.path == "/slow":
            raw_delay = parse_qs(parsed.query).get("ms", ["2000"])[0]
            try:
                delay_ms = max(0, min(int(raw_delay), 5000))
            except ValueError:
                delay_ms = 2000
            time.sleep(delay_ms / 1000)

        self.send_json(
            200,
            {
                "instance": INSTANCE,
                "path": parsed.path,
                "delay_ms": delay_ms,
                "host": self.headers.get("Host"),
                "forwarded_for": self.headers.get("X-Forwarded-For"),
                "unix_time": round(time.time(), 3),
            },
        )


if __name__ == "__main__":
    print(f"[{INSTANCE}] escutando em 0.0.0.0:{PORT}", flush=True)
    ThreadingHTTPServer(("0.0.0.0", PORT), Handler).serve_forever()
