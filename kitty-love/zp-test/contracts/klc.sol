pragma solidity ^0.4.16;

import "./kl.sol";
import '../node_modules/zeppelin-solidity/contracts/math/SafeMath.sol';
import "../node_modules/zeppelin-solidity/contracts/crowdsale/RefundVault.sol";
import "../node_modules/zeppelin-solidity/contracts/ownership/Ownable.sol";
contract Crowdsale is Ownable{
	using SafeMath for uint256;

	// The token being sold
	klrinkeby public token;

	// start and end timestamps where investments are allowed (both inclusive)
	uint256 public startTime;
	uint256 public endTime;

	// address where funds are collected
	address public wallet;

	// how many token units a buyer gets per wei
	uint256 public rate;

	// amount of raised money in wei
	uint256 public weiRaised;
	uint256 public goal=8;
	RefundVault public vault;
	bool public isFinalized = false;



	/**
	 * event for token purchase logging
	 * @param purchaser who paid for the tokens
	 * @param beneficiary who got the tokens
	 * @param value weis paid for purchase
	 * @param amount amount of tokens purchased
	 */
	event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);
	event UpdatedEndTime(uint256 indexed newTime);
	event ClaimRefund();

	function Crowdsale(uint256 _goal,uint256 _startTime, uint256 _endTime, uint256 _rate, address _wallet) public {
		require(_startTime >= now);
		require(_endTime >= _startTime);
		require(_rate > 0);
		require(_wallet != address(0));

		token = createTokenContract();
		startTime = _startTime;
		endTime = _endTime;
		rate = _rate;
		wallet = _wallet;

		require(_goal > 0);
		vault = new RefundVault(wallet);
		goal = _goal;
	}

	function createTokenContract() internal returns (klrinkeby) {
		return new klrinkeby();
	}
	function () external payable {
		
		buyTokens(msg.sender);
	}
	function buyTokens(address beneficiary) public payable {
		require(beneficiary != address(0));
		require(validPurchase());

		uint256 weiAmount = msg.value;

		uint256 tokens = weiAmount.mul(rate);

		weiRaised = weiRaised.add(weiAmount);
		token.mint(beneficiary, tokens);
		TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);

		ForwardFunds();
	}

	function ForwardFunds() internal {
		wallet.transfer(msg.value);
	}

	function validPurchase() internal view returns (bool) {
		bool withinPeriod = now >= startTime && now <= endTime;
		bool nonZeroPurchase = msg.value != 0;
		return withinPeriod && nonZeroPurchase;
	}

	function hasEnded() public view returns (bool) {
		return now > endTime;
	}

	function forwardFunds() internal {
		vault.deposit.value(msg.value)(msg.sender);
	}

	function good() public view returns(bool){
		return now >= startTime && now<= endTime;
	}	
	
	function goalReached() public view returns (bool) {
		return weiRaised >= goal;
 	} 
		// if crowdsale is unsuccessful, investors can claim refunds here
	function claimRefund() public {
		require(isFinalized);
		require(!goalReached());

		vault.refund(msg.sender);
		ClaimRefund();
	}

	function finalize() onlyOwner public {
		require(!isFinalized);
		require(hasEnded());

		finalization();

		isFinalized = true;
	}

	function updateEndTime(uint256 newTime) onlyOwner public{
		endTime = newTime;
		UpdatedEndTime(newTime);
	}

	// vault finalization task, called when owner calls finalize()
	function finalization() internal {
		if (goalReached()) {
			vault.close();
		} else {
			vault.enableRefunds();
		}
	}

}




