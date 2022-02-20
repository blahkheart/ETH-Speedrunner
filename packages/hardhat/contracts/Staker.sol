// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "hardhat/console.sol";
import "./ExampleExternalContract.sol";

contract Staker {

  ExampleExternalContract public exampleExternalContract;
  mapping ( address => uint256 ) public balances;
  uint256 public constant threshold = 1 ether;
  uint256 public deadline = block.timestamp + 96 hours;
  bool public openForWithdraw;
  bool public executed;


  // Modifier that check that ExampleExternalContract is not completed yet.
  modifier notCompleted() {
    bool completed = exampleExternalContract.completed();
    require(!completed, "staking process already completed");
    _;
  }

  event Stake(address indexed staker, uint256 amount);

  constructor(address exampleExternalContractAddress) public {
    exampleExternalContract = ExampleExternalContract(exampleExternalContractAddress);
  }

  // Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
  //  ( make sure to add a `Stake(address,uint256)` event and emit it for the frontend <List/> display )
  function stake() public payable {
    require(msg.value > 0, "amount cannot be 0");
    require(block.timestamp < deadline, "staking window closed");
    balances[msg.sender] += msg.value;
    emit Stake(msg.sender, msg.value);
  }

  // After some `deadline` allow anyone to call an `execute()` function
  //  It should either call `exampleExternalContract.complete{value: address(this).balance}()` to send all the value
  function execute () public {
    require(block.timestamp > deadline, "staking window still open");
    require(executed == false, "already executed");
    if (address(this).balance >= 1 ether) {
      exampleExternalContract.complete{value: address(this).balance}();
      executed = true;
    } else {
      openForWithdraw = true;
    }
  }

  // if the `threshold` was not met, allow everyone to call a `withdraw()` function
  // Add a `withdraw(address payable)` function lets users withdraw their balance
  function withdraw() public notCompleted {
    uint256 balance = balances[msg.sender];
    require(block.timestamp > deadline, "staking window still open");
    require(openForWithdraw == true, "withdrawal not allowed, stake successful");
    require(balance > 0, "staking balance cannot be 0");
     // Transfer balance back to the user
    (bool sent,) = msg.sender.call{value: balance}("");
    require(sent, "Failed to send user balance back to the user");
    // reset the balance of the user
    balances[msg.sender] = 0;
  }

  // Add a `timeLeft()` view function that returns the time left before the deadline for the frontend
  function timeLeft() public view returns (uint256) {
    uint256 timeL;
    unchecked {
      timeL = deadline - block.timestamp;
    }
    if (block.timestamp >= deadline) {
      timeL = 0;
    } 
    return timeL;
  }

  // Add the `receive()` special function that receives eth and calls stake()
  receive() external payable {
    stake();
  }
}
