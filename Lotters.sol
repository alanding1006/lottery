//SPDX-License-Identifier:MIT

pragma solidity ^0.8.7;

contract Lottery {

   address payable public owner; 
   address payable[10] public lotteryusers;
   uint usersCount = 0;
   uint randnonce = 0;
   uint tax = 0.01 ether;
    
    constructor () {
       owner = payable(msg.sender);
    }
    modifier onlyOwner{
        require(msg.sender == owner, "Not Owner");
        _;
    }

    function join() public payable {
        require(msg.value == 1 ether, "Must send 1 ether"); //10000000000000000
        require(usersCount < 10, "User limit reached");
        require(joinedAlready(msg.sender) == false, "User already joined");
        lotteryusers[usersCount] = payable(msg.sender);
        usersCount++;
        if (usersCount == 10){
            selectWinner();
        }
    }

    function joinedAlready(address _lotteryusers)private view returns(bool) {
        bool containLottery = false;
        for(uint i = 0; i < 10; i++) {
            if(lotteryusers[i] == _lotteryusers) {
                containLottery = true;
            }
            return containLottery;
        }
    }

    function selectWinner() public payable returns(address) {
        require(usersCount == 10, "Waiting for more users");
        address payable winner = lotteryusers[randMod()];
        winner.transfer((address(this).balance) - tax);
        delete lotteryusers;
        usersCount = 0;
        return winner;
    }

    function randMod()private returns(uint) {
        uint rand = uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, randnonce))) % 10;
        randnonce++;
        return rand;
    }

    function getBalance() external view returns(uint) {
        return address(this).balance;
    }

    function withdraw() external payable onlyOwner{
        require(usersCount == 0, "You can't withdraw now!");
        owner.transfer(address(this).balance);

    }
}