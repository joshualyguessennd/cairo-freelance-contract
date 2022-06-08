import pytest
from starkware.starkware_utils.error_handling import StarkException
from starkware.starknet.definitions.error_codes import StarknetErrorCode


def uint(a):
    return (a, 0)


@pytest.mark.asyncio
async def test_contract(gene, account):
    owner = await gene.owner().call()
    assert account.contract_address == owner.result.owner
    totalCount = await gene.getTotalContracts().call()
    assert totalCount.result.total == 0


# test deployment new contract
@pytest.mark.asyncio
async def test_factory(gene, account, owner, token, freelancer, account2):
    balanceOwner = await token.balanceOf(owner.public_key).call()
    assert balanceOwner.result.balance == uint(1000000)

    # deploy new contract
    # todo compile and declare the contract
    tx = await owner.send_transaction(
        account,
        gene.contract_address,
        "newContract",
        [
            owner.public_key,
            freelancer.public_key,
            604800,
            token.contract_address,
            *uint(100000),
        ],
    )
