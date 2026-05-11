import httpx
import pytest
import respx

from democompany_identities.client import UsersClient, UsersClientError

VALID_USER = {
    "id": 1,
    "name": "Leanne Graham",
    "username": "Bret",
    "email": "Sincere@april.biz",
    "phone": "1-770-736-8031 x56442",
    "address": {"city": "Gwenborough"},
    "company": {"name": "Romaguera-Crona"},
}


@respx.mock
def test_fetch_users_returns_validated_users() -> None:
    respx.get("https://example.test/users").mock(return_value=httpx.Response(200, json=[VALID_USER]))

    users = UsersClient("https://example.test/users", timeout_seconds=1).fetch_users()

    assert len(users) == 1
    assert users[0].name == "Leanne Graham"


@respx.mock
def test_fetch_users_rejects_non_array_payload() -> None:
    respx.get("https://example.test/users").mock(return_value=httpx.Response(200, json={"id": 1}))

    with pytest.raises(UsersClientError, match="JSON array"):
        UsersClient("https://example.test/users", timeout_seconds=1).fetch_users()
