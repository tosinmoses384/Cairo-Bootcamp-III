%lang starknet  

from starkware.starknet.common.syscalls import get_caller_address, emit_event  

# Events  
@event  
func PointsAdded(user: felt, amount: felt):  
    pass  

@event  
func PointsRedeemed(user: felt, amount: felt):  
    pass  

# Storage for user balances  
@storage  
func user_balance(user: felt) -> (balance: felt):  
    pass  

@external  
func add_points(user: felt, amount: felt):  
    # Get the current balance  
    let (current_balance) = user_balance.read(user)  

    # Update the balance  
    let new_balance = current_balance + amount  
    user_balance.write(user, new_balance)  

    # Emit event  
    emit_event(PointsAdded(user, amount))  

@external  
func redeem_points(user: felt, amount: felt):  
    # Get the current balance  
    let (current_balance) = user_balance.read(user)  

    assert current_balance >= amount, 'Insufficient balance'  

    # Update the balance  
    let new_balance = current_balance - amount  
    user_balance.write(user, new_balance)  

    # Emit event  
    emit_event(PointsRedeemed(user, amount))  

@view  
func get_balance(user: felt) -> (balance: felt):  
    let (balance) = user_balance.read(user)  
    return (balance)