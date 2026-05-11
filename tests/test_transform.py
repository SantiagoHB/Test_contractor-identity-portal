from democompany_identities.config import Settings
from democompany_identities.models import ExternalUser
from democompany_identities.transform import transform_users


def make_settings() -> Settings:
    return Settings()


def make_user(user_id: int, name: str) -> ExternalUser:
    return ExternalUser(
        id=user_id,
        name=name,
        username=f"user{user_id}",
        email=f"user{user_id}@example.com",
        phone="1-770-736-8031",
        company="Romaguera-Crona",
        city="Gwenborough",
    )


def test_transform_users_maps_fields_and_generates_email() -> None:
    settings = make_settings()
    identities = transform_users([make_user(1, "Leanne Graham")], settings)
    identity = identities[0]

    assert identity.corporate_email == "lgraham@democompany.com"
    assert identity.original_email == "user1@example.com"


def test_transform_users_deduplicates_generated_emails() -> None:
    identities = transform_users([make_user(1, "John Doe"), make_user(2, "Johana Doe")], make_settings())

    assert [identity.corporate_email for identity in identities] == [
        "jodoe@democompany.com",
        "jodoe1@democompany.com",
    ]
