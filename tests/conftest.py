import os
from _pytest.fixtures import fixture
import pytest
import pytest_asyncio

from starkware.starknet.testing.starknet import Starknet
from sympy import construct_domain
from utils.Signer import Signer


CONTRACT_GENERATOR = os.path.join("contracts", "generator.cairo")
CONTRACT_FREELANCER = os.path.join("contracts", "freelanceContract.cairo")
CONTRACT_ACCOUNT = os.path.join("contracts", "Account.cairo")
CONTRACT_TOKEN = os.path.join("contracts", "TestToken.cairo")


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
def freelancer():
    signer = Signer(123456789987654322)
    yield signer


@pytest_asyncio.fixture(scope="function")
async def account2(starknet, freelancer):
    account2 = await starknet.deploy(
        CONTRACT_ACCOUNT, constructor_calldata=[freelancer.public_key]
    )
    yield account2


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


@pytest.mark.asyncio
@pytest_asyncio.fixture(scope="function")
async def token(starknet, owner):
    token_address = await starknet.deploy(
        CONTRACT_TOKEN,
        constructor_calldata=[
            str_to_felt("freelanceToken"),
            str_to_felt("FT"),
            18,
            *uint(1000000),
            owner.public_key,
        ],
    )
    yield token_address
