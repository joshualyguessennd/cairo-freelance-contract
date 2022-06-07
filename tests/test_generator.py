import pytest
from starkware.starkware_utils.error_handling import StarkException
from starkware.starknet.definitions.error_codes import StarknetErrorCode


@pytest.mark.asyncio
async def test_contract(gene, account, signer):
    owner = await gene.owner().call()
    assert account.contract_address == owner.result.owner
    totalCount = await gene.getTotalContracts().call()
    assert totalCount.result.total == 0


# test deployment new contract
