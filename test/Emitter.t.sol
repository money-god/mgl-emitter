// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.6.7;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "ds-token/token.sol";

import "../src/Emitter.sol";

contract EmitterTest is Test {
    Emitter emitter;
    DSToken token;

    uint constant start = 800000 ether;

    function setUp() public {
        token = new DSToken("RATE", "RATE");
        emitter = new Emitter(
            now, // init
            start,
            20 ether, // c
            uint(1 ether) / 120, // lam
            address(token),
            address(0x0dd)
        );

        token.mint(address(emitter), start);
    }

    function test_math() public {
        emit log_named_int("0    ", emitter.startingSupplyMonths(0));
        emit log_named_int("1    ", emitter.startingSupplyMonths(1));
        emit log_named_int("2    ", emitter.startingSupplyMonths(2));
        emit log_named_int("10   ", emitter.startingSupplyMonths(10));
        emit log_named_int("100  ", emitter.startingSupplyMonths(100));
        emit log_named_int("1000 ", emitter.startingSupplyMonths(1000));

    }


}
