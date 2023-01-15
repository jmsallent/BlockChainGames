// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract SimpleLottery {
    uint256 public constant TICKET_PRICE = 1e16; // 0.01 ether
    address[] public tickets;
    address public winner;
    uint256 public ticketingCloses;

    constructor(uint256 duration) public {
        ticketingCloses = block.timestamp + duration;
    }

    function buy() public payable {
        require(msg.value == TICKET_PRICE);
        require(block.timestamp < ticketingCloses);
        tickets.push(msg.sender);
    }

    function drawWinner() public {
        // require(block.timestamp > ticketingCloses + 5 minutes);
        require(winner == address(0));
        bytes32 rand = keccak256(abi.encode(blockhash(block.number - 1)));
        winner = tickets[uint256(rand) % tickets.length];
    }

    function withdraw() public {
        require(msg.sender == winner);
        address payable msgSender = payable(msg.sender);
        msgSender.transfer(address(this).balance);
    }

    function receive() public payable {
        buy();
    }
}
