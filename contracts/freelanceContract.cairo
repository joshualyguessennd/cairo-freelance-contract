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
from openzeppelin.IERC20 import IERC20

@storage_var
func employer() -> (res : felt):
end

@storage_var
func freelancer() -> (res : felt):
end

@storage_var
func timePeriod() -> (res : felt):
end

@storage_var
func amount() -> (res : Uint256):
end

@storage_var
func token_address() -> (token : felt):
end

@storage_var
func request() -> (res : felt):
end

@storage_var
func payment_release() -> (res : felt):
end

@view
func token{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (res : felt):
    let (res) = token_address.read()
    return (res)
end

@view
func freelancerAddress{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
    res : felt
):
    let (res) = freelancer.read()
    return (res)
end

@view
func employerAddress{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
    res : felt
):
    let (res) = employer.read()
    return (res)
end

@constructor
func constructor{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    employer : felt, freelancer : felt, timePeriod : felt, amount : Uint256
):
    # set payment state false
    request.write(0)
    return ()
end

# employer should activate the contract by sending the exact funds
@external
func activate{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    alloc_locals
    onlyEmployer()
    let (tokenAddress) = token_address.read()
    let (_amount : Uint256) = amount.read()
    let (contract_address) = get_contract_address()
    let (_sender) = get_caller_address()
    let (balanceOfEmployer : Uint256) = IERC20.balanceOf(tokenAddress, _sender)

    with_attr error_message("Not enough fund"):
        uint256_le(balanceOfEmployer, _amount)
    end

    IERC20.transferFrom(tokenAddress, _sender, contract_address, _amount)

    return ()
end

@external
func requestPayment{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    alloc_locals
    onlyFreelancer()
    let (paymentState) = request.read()
    with_attr error_message("already requested"):
        assert paymentState = 0
    end
    request.write(1)
    return ()
end

@external
func enablePayment{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    alloc_locals
    onlyEmployer()
    let (paymentEnabled) = payment_release.read()
    with_attr error_message("already released"):
        assert paymentEnabled = 0
    end
    payment_release.write(1)
    return ()
end

@external
func claimPayment{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    alloc_locals
    onlyFreelancer()
    let (tokenAddress) = token_address.read()
    let (_amount : Uint256) = amount.read()
    let (freelancerAddress) = freelancer.read()
    let (paymentEnabled) = payment_release.read()
    with_attr error_message("payment not released"):
        assert paymentEnabled = 1
    end
    IERC20.transfer(tokenAddress, freelancerAddress, _amount)

    return ()
end

func onlyFreelancer{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    alloc_locals
    let (_employer) = employer.read()
    let (caller) = get_caller_address()
    with_attr error_message("unauthorized user"):
        assert _employer = caller
    end
    return ()
end

func onlyEmployer{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    alloc_locals
    let (_freelancer) = freelancer.read()
    let (caller) = get_caller_address()
    with_attr error_message("unauthorized user"):
        assert _freelancer = caller
    end
    return ()
end
