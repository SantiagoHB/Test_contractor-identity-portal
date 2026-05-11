from collections import defaultdict

import pytest

from democompany_identities.emailing import build_email_local_part, generate_unique_email


def test_build_email_local_part_uses_first_initial_and_last_name() -> None:
    assert build_email_local_part("John Ronald Doe") == "jodoe"


def test_build_email_local_part_uses_name_when_last_name_is_too_short() -> None:
    assert build_email_local_part("Nicholas Runolfsdottir V") == "nichv"


def test_build_email_local_part_requires_name_and_last_name() -> None:
    with pytest.raises(ValueError):
        build_email_local_part("Prince")


def test_generate_unique_email_adds_correlative_suffixes() -> None:
    used_counts: defaultdict[str, int] = defaultdict(int)

    assert generate_unique_email("John Doe", "democompany.com", used_counts) == "jodoe@democompany.com"
    assert generate_unique_email("Johana Doe", "democompany.com", used_counts) == "jodoe1@democompany.com"
