%lang starknet  

from starkware.starknet.common.syscalls import get_caller_address, emit_event  
from starkware.starknet.common.alloc import alloc  
from starkware.starknet.common.math import assert_gt  

# Constants  
@constant  
func AUCTION_DURATION() -> (duration: felt):  
    return (600)  # Auction duration in seconds (example: 10 minutes)  

# Auction state  
struct Auction:  
    highest_bidder: felt  
    highest_bid: felt  
    end_time: felt  

# Storing the auction state  
@storage  
func auction_state() -> (state: Auction):  
    pass  

@event  
func BidPlaced(bidder: felt, amount: felt):  
    pass  

@event  
func AuctionEnded(winner: felt, amount: felt):  
    pass  

# External function to start an auction  
@external  
func start_auction():  
    let caller = get_caller_address()  
    let current_time = starknet.get_block_timestamp()  # Gets the current block timestamp  

    # Initialize auction state  
    auction_state.write(Auction(caller, 0, current_time + AUCTION_DURATION()))  

# External function for placing bids  
@external  
func place_bid():  
    let caller = get_caller_address()  
    let (state) = auction_state.read()  
    
    let current_time = starknet.get_block_timestamp()  
    assert current_time < state.end_time, "Auction has ended"  

    let bid_amount: felt = /* Place the logic to accept bid amount from the user */  
    assert_gt(bid_amount, state.highest_bid, "Bid must be higher than the current highest bid")  

    // Update auction state  
    auction_state.write(Auction(caller, bid_amount, state.end_time))  

    // Emit event for the new bid  
    emit_event(BidPlaced(caller, bid_amount))  

# External function to end the auction  
@external  
func end_auction():  
    let (state) = auction_state.read()  
    let current_time = starknet.get_block_timestamp()  

    assert current_time >= state.end_time, "Auction still ongoing"  

    // Emit auction ended event  
    emit_event(AuctionEnded(state.highest_bidder, state.highest_bid))  

    // Reset auction state  
    auction_state.write(Auction(0, 0, 0))  

@view  
func get_current_auction() -> (highest_bidder: felt, highest_bid: felt, end_time: felt):  
    let (state) = auction_state.read()  
    return (state.highest_bidder, state.highest_bid, state.end_time)