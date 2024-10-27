import boa
import pytest
from eth_account import Account
from eth_utils import to_wei
from moccasin.boa_tools import VyperContract

from src.test import complex_ctf_challenge, simple_ctf_challenge, simple_ctf_registry

BALANCE = to_wei(10, "ether")


@pytest.fixture(scope="session")
def random_account():
    entropy = 13
    account = Account.create(entropy)
    boa.env.set_balance(account.address, BALANCE)
    return account


@pytest.fixture
def registry():
    return simple_ctf_registry.deploy()


@pytest.fixture
def challenge(registry):
    return simple_ctf_challenge.deploy(registry.address)


@pytest.fixture
def complex_challenge(registry) -> VyperContract:
    return complex_ctf_challenge.deploy(registry.address)


@pytest.fixture
def registry_with_challenge(registry, challenge):
    registry.addChallenge(challenge.address)
    return registry
