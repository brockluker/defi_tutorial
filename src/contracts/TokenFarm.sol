pragma solidity ^0.5.0;

import "./DappToken.sol";
import "./DaiToken.sol";


contract TokenFarm {
    // All the code goes in here...
    string public name = "Dapp Token Farm"; // This is called a state variable that will be shared on the blockchain
    address public owner; // Declare but not assigned yet
    DappToken public dappToken;
    DaiToken public daiToken;

    address[] public stakers; // We do not want these investors to be double counted
    mapping(address => uint) public stakingBalance;
    mapping(address => bool) public hasStaked;
    mapping(address => bool) public isStaking;

    constructor(DappToken _dapptoken, DaiToken _daitoken) public {
        dappToken = _dapptoken;
        daiToken = _daitoken;
        owner = msg.sender; // Person who depolyed the contract it give title of owner
    }

    // Stake Tokens (deposits) investor deposits the DAI into a smart contract to begin earning rewards
    function stakeTokens(uint _amount) public {
        // Require amount is greater than 0
        require(_amount > 0, "amount cannot be 0");
    
        // Transfer Mock DAI tokens to this contract for staking
        daiToken.transferFrom(msg.sender, address(this), _amount); // transferFrom allows the contract to move the funds on behalf of the investor

        // Update staking balance
        stakingBalance[msg.sender] = stakingBalance[msg.sender] + _amount;

        // Add user to stakers array *only* if they haven't staked already
        if(!hasStaked[msg.sender]) {
            stakers.push(msg.sender);
        }

        // Update staking status
        isStaking[msg.sender] = true;
        hasStaked[msg.sender] = true;
    }

    // Unstaking Tokens (witdraws)
    function unstakeTokens() public {
        // Fetch staking balance
        uint balance = stakingBalance[msg.sender];

        // require an amount greater than 0
        require(balance > 0, "staking balance cannot be 0");

        // Transfer Mock DAI tokens to this contract for staking
        daiToken.transfer(msg.sender, balance);

        // Reset the staking balance back to 0 
        stakingBalance[msg.sender] = 0;

        // Update staking status
        isStaking[msg.sender] = false;
    }


    // Issuing Tokens (earning interest) function is called by the owner of the contract
    function issueTokens() public {
        // ***ONLY*** the Owner of the contract may issue tokens
        require(msg.sender == owner, "caller must be owner");
        
        // Issue tokens to all stakers
        for (uint i=0; i<stakers.length; i++) {
            address recipient = stakers[i];
            uint balance = stakingBalance[recipient];
            if(balance > 0) {
                dappToken.transfer(recipient, balance);
            }
        }
    }




}
