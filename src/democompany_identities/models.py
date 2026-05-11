from dataclasses import dataclass


@dataclass(frozen=True)
class ExternalUser:
    id: int
    name: str
    username: str
    email: str
    phone: str
    company: str
    city: str


@dataclass(frozen=True)
class ContractorIdentity:
    full_name: str
    phone: str
    original_email: str
    company: str
    city: str
    corporate_email: str
