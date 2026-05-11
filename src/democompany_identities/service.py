import logging
from pathlib import Path

from democompany_identities.client import UsersClient
from democompany_identities.config import Settings
from democompany_identities.csv_exporter import write_contractors_csv
from democompany_identities.models import ExternalUser
from democompany_identities.transform import transform_users


def fetch_external_users(settings: Settings, logger: logging.Logger) -> list[ExternalUser]:
    logger.info("Fetching external users from %s", settings.users_url)
    users = UsersClient(settings.users_url, settings.timeout_seconds).fetch_users()
    logger.info("Total records fetched from endpoint: %s", len(users))
    return users


def generate_contractor_report(settings: Settings, output_path: Path, logger: logging.Logger) -> None:
    logger.info("Process started")
    users = fetch_external_users(settings, logger)
    identities = transform_users(users, settings)
    logger.info("Corporate emails generated successfully: %s", len(identities))
    write_contractors_csv(output_path, identities)
    logger.info("CSV file generated successfully: %s", output_path)
