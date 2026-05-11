import re
import unicodedata
from collections import defaultdict

NON_ALNUM = re.compile(r"[^a-z0-9]+")
MIN_LOCAL_PART_LENGTH = 5


def normalize_token(value: str) -> str:
    ascii_value = unicodedata.normalize("NFKD", value).encode("ascii", "ignore").decode("ascii")
    return NON_ALNUM.sub("", ascii_value.lower())


def build_email_local_part(full_name: str) -> str:
    tokens = [normalize_token(part) for part in full_name.split()]
    tokens = [token for token in tokens if token]
    if len(tokens) < 2:
        raise ValueError(f"Cannot generate corporate email from incomplete name: {full_name!r}")
    local_part = f"{tokens[0][0]}{tokens[-1]}"
    if len(local_part) >= MIN_LOCAL_PART_LENGTH:
        return local_part
    first_name_prefix_length = max(MIN_LOCAL_PART_LENGTH - len(tokens[-1]), 1)
    return f"{tokens[0][:first_name_prefix_length]}{tokens[-1]}"


def generate_unique_email(full_name: str, domain: str, used_counts: defaultdict[str, int]) -> str:
    base = build_email_local_part(full_name)
    index = used_counts[base]
    used_counts[base] += 1
    suffix = "" if index == 0 else str(index)
    return f"{base}{suffix}@{domain}"
