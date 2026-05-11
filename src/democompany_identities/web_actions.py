import argparse
import json
import logging
from io import StringIO
from dataclasses import asdict
from pathlib import Path

from democompany_identities.config import Settings
from democompany_identities.csv_exporter import write_contractors_csv
from democompany_identities.models import ExternalUser
from democompany_identities.service import fetch_external_users
from democompany_identities.transform import transform_users

OUTPUT_DIR = Path("output")
LOG_FILE = Path("logs/app.log")
USERS_JSON = OUTPUT_DIR / "users.json"
IDENTITIES_JSON = OUTPUT_DIR / "contractors.json"
CSV_FILE = OUTPUT_DIR / "contractors.csv"


def configure_session_logger() -> tuple[logging.Logger, StringIO]:
    stream = StringIO()
    logger = logging.getLogger("democompany_identities.portal_session")
    logger.setLevel(logging.INFO)
    logger.handlers.clear()
    logger.propagate = False
    handler = logging.StreamHandler(stream)
    handler.setFormatter(logging.Formatter("%(asctime)s %(levelname)s %(message)s"))
    logger.addHandler(handler)
    return logger, stream


def write_json(path: Path, payload: object) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(payload, indent=2), encoding="utf-8")


def read_users() -> list[ExternalUser]:
    payload = json.loads(USERS_JSON.read_text(encoding="utf-8"))
    return [ExternalUser(**item) for item in payload]


def fetch_users_action() -> dict[str, object]:
    settings = Settings.from_env()
    logger, log_stream = configure_session_logger()
    logger.info("Portal action started: fetch users")
    users = fetch_external_users(settings, logger)
    payload = [asdict(user) for user in users]
    write_json(USERS_JSON, payload)
    logger.info("Portal action finished: users saved to %s", USERS_JSON)
    return {"users": payload, "logs": log_stream.getvalue()}


def generate_emails_action() -> dict[str, object]:
    settings = Settings.from_env()
    logger, log_stream = configure_session_logger()
    logger.info("Portal action started: generate corporate emails")
    if USERS_JSON.exists():
        users = read_users()
        logger.info("Loaded users from %s", USERS_JSON)
    else:
        users = fetch_external_users(settings, logger)
        write_json(USERS_JSON, [asdict(user) for user in users])
    identities = transform_users(users, settings)
    payload = [asdict(identity) for identity in identities]
    write_json(IDENTITIES_JSON, payload)
    write_contractors_csv(CSV_FILE, identities)
    logger.info("Corporate emails generated successfully: %s", len(identities))
    logger.info("CSV file generated successfully: %s", CSV_FILE)
    return {"identities": payload, "logs": log_stream.getvalue()}


def logs_action() -> dict[str, object]:
    return {"logs": ""}


def main() -> int:
    parser = argparse.ArgumentParser(description="Actions used by the Next.js portal.")
    parser.add_argument("action", choices=["fetch-users", "generate-emails"])
    args = parser.parse_args()

    if args.action == "fetch-users":
        result = fetch_users_action()
    else:
        result = generate_emails_action()

    print(json.dumps(result))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
