from dataclasses import dataclass
from os import getenv

from dotenv import load_dotenv

DEFAULT_USERS_URL = "https://jsonplaceholder.typicode.com/users"
DEFAULT_DOMAIN = "democompany.com"


@dataclass(frozen=True)
class Settings:
    users_url: str = DEFAULT_USERS_URL
    corporate_domain: str = DEFAULT_DOMAIN
    timeout_seconds: float = 10.0

    @classmethod
    def from_env(cls) -> "Settings":
        load_dotenv()
        return cls(
            users_url=getenv("DEMOCOMPANY_USERS_URL", DEFAULT_USERS_URL),
            corporate_domain=getenv("DEMOCOMPANY_DOMAIN", DEFAULT_DOMAIN),
            timeout_seconds=float(getenv("DEMOCOMPANY_TIMEOUT_SECONDS", "10")),
        )
