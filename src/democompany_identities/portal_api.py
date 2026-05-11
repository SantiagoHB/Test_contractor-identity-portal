import json
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from typing import Callable

from democompany_identities.web_actions import fetch_users_action, generate_emails_action, logs_action

HOST = "0.0.0.0"
PORT = 8000


def json_response(handler: BaseHTTPRequestHandler, status: int, payload: dict[str, object]) -> None:
    body = json.dumps(payload).encode("utf-8")
    handler.send_response(status)
    handler.send_header("Content-Type", "application/json")
    handler.send_header("Content-Length", str(len(body)))
    handler.send_header("Access-Control-Allow-Origin", "*")
    handler.send_header("Access-Control-Allow-Methods", "GET,POST,OPTIONS")
    handler.send_header("Access-Control-Allow-Headers", "Content-Type")
    handler.end_headers()
    handler.wfile.write(body)


class PortalHandler(BaseHTTPRequestHandler):
    def do_OPTIONS(self) -> None:
        json_response(self, 204, {})

    def do_GET(self) -> None:
        if self.path == "/logs":
            json_response(self, 200, logs_action())
            return
        json_response(self, 404, {"error": "Endpoint not found"})

    def do_POST(self) -> None:
        routes: dict[str, Callable[[], dict[str, object]]] = {
            "/users": fetch_users_action,
            "/emails": generate_emails_action,
        }
        action = routes.get(self.path)
        if action is None:
            json_response(self, 404, {"error": "Endpoint not found"})
            return
        try:
            json_response(self, 200, action())
        except Exception as exc:
            json_response(self, 500, {"error": str(exc)})

    def log_message(self, format: str, *args: object) -> None:
        return


def main() -> int:
    server = ThreadingHTTPServer((HOST, PORT), PortalHandler)
    print(f"Portal API listening on http://{HOST}:{PORT}", flush=True)
    server.serve_forever()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
