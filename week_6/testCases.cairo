%lang starknet  

from starkware.starknet.testing.starknet import Starknet  
from starkware.starknet.testing.contract import Contract  
from starkware.starknet.public.abi import get_event_by_name  
from starkware.starknet.testing.utils import assert_event_emitted  
from starkware.starknet.common.syscalls import get_caller_address  

# Testing auction contract  
@external  
func test_start_auction():  
    let starknet = Starknet()  
    let auction = await starknet.deploy('Auction.cairo')  

    # Start the auction  
    await auction.start_auction().invoke()  

    # Verify auction state  
    let auction_state = await auction.get_current_auction().call()  
    assert auction_state[0] == get_caller_address()  # highest_bidder  
    assert auction_state[1] == 0  # highest_bid  
    assert auction_state[2] > 0  # end_time should be set  

@external  
func test_place_bid():  
    let starknet = Starknet()  
    let auction = await starknet.deploy('Auction.cairo')  

    await auction.start_auction().invoke()  
    
    # Place a bid  
    let bid_amount = 100  
    await auction.place_bid(bid_amount).invoke()  
    
    // Verify updated auction state  
    let auction_state = await auction.get_current_auction().call()  
    assert auction_state[0] == get_caller_address()  # highest_bidder  
    assert auction_state[1] == bid_amount  # highest_bid  

@external  
func test_place_lower_bid():  
    let starknet = Starknet()  
    let auction = await starknet.deploy('Auction.cairo')  

    await auction.start_auction().invoke()  

    // Place initial bid  
    let bid_amount_1 = 100  
    await auction.place_bid(bid_amount_1).invoke()  

    // Attempt a lower bid  
    let bid_amount_2 = 50  # This bid should fail since it's lower  
    let result = await auction.place_bid(bid_amount_2).invoke()  
    assert_eq(result.status, 0)  # Check that it raised an exception  

@external  
func test_end_auction():  
    let starknet = Starknet()  
    let auction = await starknet.deploy('Auction.cairo')  

    await auction.start_auction().invoke()  
    
    bid_amount = 100  
    await auction.place_bid(bid_amount).invoke()  

    // Wait for auction to 'end'  
    await auction.end_auction().invoke()  

    // Verify auction has ended  
    let auction_state = await auction.get_current_auction().call()  
    assert auction_state[0] == get_caller_address()  # Check winner  
    assert auction_state[1] == bid_amount  # Check winning bid amount  

@external  
func test_multiple_bidders():  
    let starknet = Starknet()  
    let auction = await starknet.deploy('Auction.cairo')  

    await auction.start_auction().invoke()  

    // Simulate multiple users placing bids  
    let user1 = get_caller_address()  
    await auction.place_bid(150).invoke()  
    
    // Simulate a higher bid from user2  
    let user2 = get_caller_address() + 1  # Hypothetical distinct user  
    await auction.place_bid(200).invoke()  
    
    // Check the auction state  
    let auction_state = await auction.get_current_auction().call()  
    assert auction_state[0] == user2  # user2 should be the highest_bidder  
    assert auction_state[1] == 200  # highest_bid should be 200