import os
from _pytest.fixtures import fixture
import pytest
import pytest_asyncio

from starkware.starknet.testing.starknet import Starknet
from utils.Signer import Signer


CONTRACT_GENERATOR = os.path.join("contracts", "generator.cairo")
CONTRACT_FREELANCER = os.path.join("contracts", "freelanceContract.cairo")
CONTRACT_ACCOUNT = os.path.join("contracts", "Account.cairo")


def uint(a):
    return (a, 0)


def str_to_felt(text):
    b_text = bytes(text, "UTF-8")
    return int.from_bytes(b_text, "big")


@pytest_asyncio.fixture(scope="function")
@pytest.mark.asyncio
async def starknet():
    starkNet = await Starknet.empty()
    yield starkNet


@pytest_asyncio.fixture(scope="function")
def owner():
    signer = Signer(123456789987654321)
    yield signer


@pytest_asyncio.fixture(scope="function")
async def account(starknet, owner):
    account = await starknet.deploy(
        CONTRACT_ACCOUNT, constructor_calldata=[owner.public_key]
    )
    yield account


@pytest.mark.asyncio
@pytest_asyncio.fixture(scope="function")
async def gene(starknet, account):
    gene_contract = await starknet.deploy(
        CONTRACT_GENERATOR, constructor_calldata=[account.contract_address]
    )
    yield gene_contract
