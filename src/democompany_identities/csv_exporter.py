import csv
from dataclasses import asdict
from pathlib import Path

from democompany_identities.models import ContractorIdentity

FIELDNAMES = [
    "full_name",
    "phone",
    "original_email",
    "company",
    "city",
    "corporate_email",
]


def write_contractors_csv(path: Path, identities: list[ContractorIdentity]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", newline="", encoding="utf-8") as file:
        writer = csv.DictWriter(file, fieldnames=FIELDNAMES)
        writer.writeheader()
        for identity in identities:
            writer.writerow(asdict(identity))
