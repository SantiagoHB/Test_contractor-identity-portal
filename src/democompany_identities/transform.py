from collections import defaultdict

from democompany_identities.config import Settings
from democompany_identities.emailing import generate_unique_email
from democompany_identities.models import ContractorIdentity, ExternalUser


def transform_users(users: list[ExternalUser], settings: Settings) -> list[ContractorIdentity]:
    used_counts: defaultdict[str, int] = defaultdict(int)
    identities: list[ContractorIdentity] = []

    for user in users:
        corporate_email = generate_unique_email(user.name, settings.corporate_domain, used_counts)
        identities.append(
            ContractorIdentity(
                full_name=user.name,
                phone=user.phone,
                original_email=user.email,
                company=user.company,
                city=user.city,
                corporate_email=corporate_email,
            )
        )

    return identities
