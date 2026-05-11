import csv

from democompany_identities.csv_exporter import FIELDNAMES, write_contractors_csv
from democompany_identities.models import ContractorIdentity


def test_write_contractors_csv_includes_identity_columns(tmp_path) -> None:
    identity = ContractorIdentity(
        full_name="Leanne Graham",
        phone="1-770-736-8031",
        original_email="user1@example.com",
        company="Romaguera-Crona",
        city="Gwenborough",
        corporate_email="lgraham@democompany.com",
    )

    output_path = tmp_path / "contractors.csv"
    write_contractors_csv(output_path, [identity])

    with output_path.open(encoding="utf-8", newline="") as file:
        rows = list(csv.DictReader(file))

    assert list(rows[0]) == FIELDNAMES
    assert rows[0]["corporate_email"] == "lgraham@democompany.com"
