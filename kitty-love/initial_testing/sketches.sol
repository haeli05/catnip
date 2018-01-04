/**
 * This smart contract code is Copyright 2017 TokenMarket Ltd. For more information see https://tokenmarket.net
 *
 * Licensed under the Apache License, version 2.0: https://github.com/TokenMarketNet/ico/blob/master/LICENSE.txt
 */

pragma solidity ^0.4.12;

import "zeppelin/contracts/ownership/Ownable.sol";
import "zeppelin/contracts/token/ERC20Basic.sol";

contract Recoverable is Ownable {

	/// @dev Empty constructor (for now)
	function Recoverable() {
	}

	/// @dev This will be invoked by the owner, when owner wants to rescue tokens
	/// @param token Token which will we rescue to the owner from the contract
	function recoverTokens(ERC20Basic token) onlyOwner public {
		token.transfer(owner, tokensToBeReturned(token));
	}

	/// @dev Interface function, can be overwritten by the superclass
	/// @param token Token which balance we will check and return
	/// @return The amount of tokens (in smallest denominator) the contract owns
	function tokensToBeReturned(ERC20Basic token) public returns (uint) {
		return token.balanceOf(this);
	}
}

//Funcation increases supply
function increaseSupply(uint value, address to) public returns (bool) {
	totalSupply = safeAdd(totalSupply, value);
	balances[for] = safeAdd(balances[to], value);
	Transfer(0, to, value);
	return true;
}
function safeAdd(uint a, uint b) internal returns (uint) {
	if (a + b < a) { throw; }
	return a + b;
}
//Function decreases supply
function decreaseSupply(uint value, address from) public returns (bool) {
	balances[from] = safeSub(balances[from], value);
	totalSupply = safeSub(totalSupply, value);  
	Transfer(from, 0, value);
	return true;
}

function safeSub(uint a, uint b) internal returns (uint) {
	if (b > a) { throw; }
	return a - b;
}

/**
 * This smart contract code is Copyright 2017 TokenMarket Ltd. For more information see https://tokenmarket.net
 *
 * Licensed under the Apache License, version 2.0: https://github.com/TokenMarketNet/ico/blob/master/LICENSE.txt
 */

pragma solidity ^0.4.8;

import "zeppelin/contracts/ownership/Ownable.sol";
import "zeppelin/contracts/token/ERC20.sol";


/**
 * Define interface for releasing the token transfer after a successful crowdsale.
 */
contract ReleasableToken is ERC20, Ownable {

	/* The finalizer contract that allows unlift the transfer limits on this token */
	address public releaseAgent;

	/** A crowdsale contract can release us to the wild if ICO success. If false we are are in transfer lock up period.*/
	bool public released = false;

	/** Map of agents that are allowed to transfer tokens regardless of the lock down period. These are crowdsale contracts and possible the team multisig itself. */
	mapping (address => bool) public transferAgents;

	/**
	* Limit token transfer until the crowdsale is over.
	*
		*/
	modifier canTransfer(address _sender) {

		if(!released) {
			if(!transferAgents[_sender]) {
				throw;
			}
		}

		_;
	}

	/**
	 * Set the contract that can call release and make the token transferable.
	 *
	 * Design choice. Allow reset the release agent to fix fat finger mistakes.
	 */
	function setReleaseAgent(address addr) onlyOwner inReleaseState(false) public {

		// We don't do interface check here as we might want to a normal wallet address to act as a release agent
		releaseAgent = addr;
	}

	/**
	* Owner can allow a particular address (a crowdsale contract) to transfer tokens despite the lock up period.
	 */
	function setTransferAgent(address addr, bool state) onlyOwner inReleaseState(false) public {
		transferAgents[addr] = state;
	}

	/**
	* One way function to release the tokens to the wild.
	*
	* Can be called only from the release agent that is the final ICO contract. It is only called if the crowdsale has been success (first milestone reached).
	 */
	function releaseTokenTransfer() public onlyReleaseAgent {
		released = true;
	}

	/** The function can be called only before or after the tokens have been releasesd */
	modifier inReleaseState(bool releaseState) {
		if(releaseState != released) {
			throw;
		}
		_;
	}

	/** The function can be called only by a whitelisted release agent. */
	modifier onlyReleaseAgent() {
		if(msg.sender != releaseAgent) {
			throw;
		}
		_;
	}

	function transfer(address _to, uint _value) canTransfer(msg.sender) returns (bool success) {
		// Call StandardToken.transfer()
		return super.transfer(_to, _value);
	}

	function transferFrom(address _from, address _to, uint _value) canTransfer(_from) returns (bool success) {
		// Call StandardToken.transferForm()
		return super.transferFrom(_from, _to, _value);
	}

}
/**
 * This smart contract code is Copyright 2017 TokenMarket Ltd. For more information see https://tokenmarket.net
 *
 * Licensed under the Apache License, version 2.0: https://github.com/TokenMarketNet/ico/blob/master/LICENSE.txt
 */

pragma solidity ^0.4.8;

import "./Crowdsale.sol";
import "./MintableToken.sol";


/**
 * Uncapped ICO crowdsale contract.
 *
 *
 * Intended usage
 *
 * - A short time window
 * - Flat price
 * - No cap
 *
 */
contract UncappedCrowdsale is Crowdsale {

	function UncappedCrowdsale(address _token, PricingStrategy _pricingStrategy, address _multisigWallet, uint _start, uint _end, uint _minimumFundingGoal) Crowdsale(_token, _pricingStrategy, _multisigWallet, _start, _end, _minimumFundingGoal) {

	}

	/**
	 * Called from invest() to confirm if the curret investment does not break our cap rule.
	 */
	function isBreakingCap(uint weiAmount, uint tokenAmount, uint weiRaisedTotal, uint tokensSoldTotal) constant returns (bool limitBroken) {
		return false;
	}

	function isCrowdsaleFull() public constant returns (bool) {
		// Uncle Scrooge
		return false;
	}

	function assignTokens(address receiver, uint tokenAmount) internal {
		MintableToken mintableToken = MintableToken(token);
		mintableToken.mint(receiver, tokenAmount);
	}
}

/**
* This smart contract code is Copyright 2017 TokenMarket Ltd. For more information see https://tokenmarket.net
*
	* Licensed under the Apache License, version 2.0: https://github.com/TokenMarketNet/ico/blob/master/LICENSE.txt
 */

pragma solidity ^0.4.6;

import "./PricingStrategy.sol";
import "./Crowdsale.sol";
import "./SafeMathLib.sol";
import "zeppelin/contracts/ownership/Ownable.sol";


/// @dev Time milestone based pricing with special support for pre-ico deals.
contract MilestonePricing is PricingStrategy, Ownable {

	using SafeMathLib for uint;

	uint public constant MAX_MILESTONE = 10;

	// This contains all pre-ICO addresses, and their prices (weis per token)
	mapping (address => uint) public preicoAddresses;

	/**
	* Define pricing schedule using milestones.
	*/
	struct Milestone {

		// UNIX timestamp when this milestone kicks in
		uint time;

		// How many tokens per satoshi you will get after this milestone has been passed
		uint price;
	}

	// Store milestones in a fixed array, so that it can be seen in a blockchain explorer
	// Milestone 0 is always (0, 0)
	// (TODO: change this when we confirm dynamic arrays are explorable)
	Milestone[10] public milestones;

	// How many active milestones we have
	uint public milestoneCount;

	/// @dev Contruction, creating a list of milestones
	/// @param _milestones uint[] milestones Pairs of (time, price)
	function MilestonePricing(uint[] _milestones) {
		// Need to have tuples, length check
		if(_milestones.length % 2 == 1 || _milestones.length >= MAX_MILESTONE*2) {
			throw;
		}

		milestoneCount = _milestones.length / 2;

		uint lastTimestamp = 0;

		for(uint i=0; i<_milestones.length/2; i++) {
			milestones[i].time = _milestones[i*2];
			milestones[i].price = _milestones[i*2+1];

			// No invalid steps
			if((lastTimestamp != 0) && (milestones[i].time <= lastTimestamp)) {
				throw;
			}

			lastTimestamp = milestones[i].time;
		}

		// Last milestone price must be zero, terminating the crowdale
		if(milestones[milestoneCount-1].price != 0) {
			throw;
		}
	}

	/// @dev This is invoked once for every pre-ICO address, set pricePerToken
	///      to 0 to disable
	/// @param preicoAddress PresaleFundCollector address
	/// @param pricePerToken How many weis one token cost for pre-ico investors
	function setPreicoAddress(address preicoAddress, uint pricePerToken)
	public
	onlyOwner
	{
		preicoAddresses[preicoAddress] = pricePerToken;
	}

	/// @dev Iterate through milestones. You reach end of milestones when price = 0
	/// @return tuple (time, price)
	function getMilestone(uint n) public constant returns (uint, uint) {
		return (milestones[n].time, milestones[n].price);
	}

	function getFirstMilestone() private constant returns (Milestone) {
		return milestones[0];
	}

	function getLastMilestone() private constant returns (Milestone) {
		return milestones[milestoneCount-1];
	}

	function getPricingStartsAt() public constant returns (uint) {
		return getFirstMilestone().time;
	}

	function getPricingEndsAt() public constant returns (uint) {
		return getLastMilestone().time;
	}

	function isSane(address _crowdsale) public constant returns(bool) {
		Crowdsale crowdsale = Crowdsale(_crowdsale);
		return crowdsale.startsAt() == getPricingStartsAt() && crowdsale.endsAt() == getPricingEndsAt();
	}

	/// @dev Get the current milestone or bail out if we are not in the milestone periods.
	/// @return {[type]} [description]
	function getCurrentMilestone() private constant returns (Milestone) {
		uint i;

		for(i=0; i<milestones.length; i++) {
			if(now < milestones[i].time) {
				return milestones[i-1];
			}
		}
	}

	/// @dev Get the current price.
	/// @return The current price or 0 if we are outside milestone period
	function getCurrentPrice() public constant returns (uint result) {
		return getCurrentMilestone().price;
	}

	/// @dev Calculate the current price for buy in amount.
	function calculatePrice(uint value, uint weiRaised, uint tokensSold, address msgSender, uint decimals) public constant returns (uint) {

		uint multiplier = 10 ** decimals;

		// This investor is coming through pre-ico
		if(preicoAddresses[msgSender] > 0) {
			return value.times(multiplier) / preicoAddresses[msgSender];
		}

		uint price = getCurrentPrice();
		return value.times(multiplier) / price;
	}

	function isPresalePurchase(address purchaser) public constant returns (bool) {
		if(preicoAddresses[purchaser] > 0)
			return true;
		else
			return false;
	}

	function() payable {
		throw; // No money on this contract
	}

}
