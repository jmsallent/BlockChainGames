// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "./RecurringLotteryLib.sol";

contract RecurringLottery {
    uint256 public constant TICKET_PRICE = 1e15;
    mapping(uint256 => RecurringLotteryLib.Round) public rounds;
    uint256 public round;
    uint256 public duration;
    mapping(address => uint256) public balances;

    // duration is in blocks. 1 day = ~5500 blocks
    constructor(uint256 _duration) public {
        duration = _duration;
        round = 1;
        rounds[round].endBlock = block.number + duration;
        rounds[round].drawBlock = block.number + duration + 5;
    }

    function buy() public payable {
        require(msg.value % TICKET_PRICE == 0);
        if (block.number > rounds[round].endBlock) {
            round += 1;
            rounds[round].endBlock = block.number + duration;
            rounds[round].drawBlock = block.number + duration + 5;
        }
        uint256 quantity = msg.value / TICKET_PRICE;
        RecurringLotteryLib.Entry memory entry = RecurringLotteryLib.Entry(
            msg.sender,
            quantity
        );
        rounds[round].entries.push(entry);
        rounds[round].totalQuantity += quantity;
    }

    function drawWinner(uint256 roundNumber) public {
        RecurringLotteryLib.Round storage drawing = rounds[roundNumber];
        require(drawing.winner == address(0));
        require(block.number > drawing.drawBlock);
        require(drawing.entries.length > 0);
        // pick winner
        bytes32 rand = keccak256(abi.encode(blockhash(drawing.drawBlock)));
        uint256 counter = uint256(rand) % drawing.totalQuantity;
        for (uint256 i = 0; i < drawing.entries.length; i++) {
            uint256 quantity = drawing.entries[i].quantity;
            if (quantity > counter) {
                drawing.winner = drawing.entries[i].buyer;
                break;
            } else counter -= quantity;
        }
        balances[drawing.winner] += TICKET_PRICE * drawing.totalQuantity;
    }

    function withdraw() public {
        uint256 amount = balances[msg.sender];
        balances[msg.sender] = 0;
        address payable msgSender = payable(msg.sender);
        msgSender.transfer(amount);
    }

    function deleteRound(uint256 _round) public {
        require(block.number > rounds[_round].drawBlock + 100);
        require(rounds[_round].winner != address(0));
        delete rounds[_round];
    }

    function receive() public payable {
        buy();
    }
}
