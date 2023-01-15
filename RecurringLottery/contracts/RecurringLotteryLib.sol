// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

library RecurringLotteryLib {
    struct Round {
        uint256 endBlock;
        uint256 drawBlock;
        Entry[] entries;
        uint256 totalQuantity;
        address winner;
    }
    struct Entry {
        address buyer;
        uint256 quantity;
    }
}
