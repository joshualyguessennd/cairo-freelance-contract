%lang starknet

%builtins pedersen range_check ecdsa

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.math import assert_le, assert_nn_le, unsigned_div_rem, assert_not_zero
from starkware.cairo.common.uint256 import (
    Uint256,
    uint256_add,
    uint256_sub,
    uint256_le,
    uint256_lt,
    uint256_mul,
    uint256_eq,
    uint256_unsigned_div_rem,
)
from starkware.starknet.common.syscalls import get_caller_address, get_contract_address
from starkware.starknet.common.syscalls import deploy
# openzeppelin librairy
from openzeppelin.ownable import Ownable

@storage_var
func salt() -> (value : felt):
end

@storage_var
func freelance_contract_hash() -> (value : felt):
end

@storage_var
func totalContracts() -> (total : felt):
end

@view
func owner{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (owner : felt):
    let (owner) = Ownable.owner()
    return (owner)
end

@view
func getTotalContracts{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
    total : felt
):
    let (total) = totalContracts.read()
    return (total)
end

@event
func newContractDeployed(contract_address : felt):
end

@constructor
func constructor{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(owner : felt):
    alloc_locals
    Ownable.initializer(owner)
    return ()
end

@external
func newContract{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    employer : felt, freelancer : felt, timePeriod : felt, token : felt, amount : Uint256
) -> ():
    Ownable.assert_only_owner()
    let (current_salt) = salt.read()
    let (totals) = totalContracts.read()
    let (freelance_hash) = freelance_contract_hash.read()
    let (contract_address) = deploy(
        class_hash=freelance_hash,
        contract_address_salt=current_salt,
        constructor_calldata_size=1,
        constructor_calldata=cast(new (employer, freelancer, timePeriod, token, amount,), felt*),
    )
    salt.write(current_salt + 1)
    totalContracts.write(totals + 1)
    newContractDeployed.emit(contract_address=contract_address)
    return ()
end
