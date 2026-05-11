import argparse
from pathlib import Path

from democompany_identities.config import Settings
from democompany_identities.logging_config import configure_logging
from democompany_identities.service import generate_contractor_report


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Generate DemoCompany contractor identities from a JSON users endpoint."
    )
    parser.add_argument("--output", type=Path, default=Path("output/contractors.csv"))
    parser.add_argument("--log-file", type=Path, default=Path("logs/app.log"))
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    settings = Settings.from_env()
    logger = configure_logging(args.log_file)
    generate_contractor_report(settings, args.output, logger)
    return 0
