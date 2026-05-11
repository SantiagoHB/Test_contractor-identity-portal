from typing import Any

import httpx

from democompany_identities.models import ExternalUser


class UsersClientError(RuntimeError):
    """Raised when the users service cannot be consumed safely."""


class UsersClient:
    def __init__(self, url: str, timeout_seconds: float) -> None:
        self._url = url
        self._timeout_seconds = timeout_seconds

    def fetch_users(self) -> list[ExternalUser]:
        try:
            response = httpx.get(self._url, timeout=self._timeout_seconds)
            response.raise_for_status()
            payload = response.json()
        except httpx.HTTPError as exc:
            raise UsersClientError(f"Failed to fetch users from {self._url}") from exc
        except ValueError as exc:
            raise UsersClientError("Users service returned invalid JSON") from exc

        if not isinstance(payload, list):
            raise UsersClientError("Users service response must be a JSON array")

        return [parse_user(item) for item in payload]


def parse_user(item: Any) -> ExternalUser:
    if not isinstance(item, dict):
        raise UsersClientError("Each user record must be an object")
    address = item.get("address")
    company = item.get("company")
    if not isinstance(address, dict) or not isinstance(company, dict):
        raise UsersClientError("User record must include address and company objects")
    return ExternalUser(
        id=int(item["id"]),
        name=str(item["name"]).strip(),
        username=str(item["username"]).strip(),
        email=str(item["email"]).strip(),
        phone=str(item["phone"]).strip(),
        company=str(company["name"]).strip(),
        city=str(address["city"]).strip(),
    )
