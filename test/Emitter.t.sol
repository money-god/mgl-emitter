// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.6.7;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "ds-token/token.sol";

import "../src/Emitter.sol";

contract EmitterTest is Test {
    Emitter emitter;
    DSToken token;
    address receiver = address(1);

    uint constant start = 800000 ether;

    function setUp() public {
        token = new DSToken("RATE", "RATE");
        emitter = new Emitter(
            now, // init
            start,
            20 ether, // c
            uint(1 ether) / 120, // lam
            address(token),
            receiver
        );

        token.mint(address(emitter), start);
    }

    function testConstructor() public {
        assertEq(emitter.init(), now);
        assertEq(emitter.start(), start);
        assertEq(emitter.c(), 20 ether);
        assertEq(address(emitter.token()), address(token));
        assertEq(emitter.receiver(), receiver);
        assertEq(emitter.receiver(), receiver);

        assertEq(token.balanceOf(address(emitter)), start);
    }

    function testFailConstructorNullInit() public {
        emitter = new Emitter(
            0, // init
            start,
            20 ether, // c
            uint(1 ether) / 120, // lam
            address(token),
            receiver
        );
    }

    function testFailConstructorNullStart() public {
        emitter = new Emitter(
            now, // init
            0,
            20 ether, // c
            uint(1 ether) / 120, // lam
            address(token),
            receiver
        );
    }

    function testFailConstructorNullC() public {
        emitter = new Emitter(
            now, // init
            start,
            0, // c
            uint(1 ether) / 120, // lam
            address(token),
            receiver
        );
    }

    function testFailConstructorNullLam() public {
        emitter = new Emitter(
            now, // init
            start,
            20 ether, // c
            0, // lam
            address(token),
            receiver
        );
    }

    function testFailConstructorNullToken() public {
        emitter = new Emitter(
            now, // init
            start,
            20 ether, // c
            uint(1 ether) / 120, // lam
            address(0),
            receiver
        );
    }

    function testFailConstructorNullReceiver() public {
        emitter = new Emitter(
            now, // init
            start,
            20 ether, // c
            uint(1 ether) / 120, // lam
            address(token),
            address(0)
        );
    }

    function testStartingSupplyMonths() public {
        // testing against specced values
        assertEq(emitter.startingSupplyMonths(1),  773800399633161293600000);
        assertEq(emitter.startingSupplyMonths(2),  748458823090550154400000);
        assertEq(emitter.startingSupplyMonths(12), 536484945077947093600000);
        assertEq(emitter.startingSupplyMonths(60), 108499502844419320000000);
        assertEq(emitter.startingSupplyMonths(120), 14715177646857695200000);
        assertEq(emitter.startingSupplyMonths(240),   270670566473224800000);
    }

    function testGetCurrentMonth() public {
        for (uint i = 1; i < 1200; i++) {
            assertEq(emitter.currentMonth(), i);
            vm.warp(now + 30 days);
        }
    }

    function testEmitTokens() public {
        emitter.emitTokens();

        assertEq(token.balanceOf(address(emitter)), 773800399633161293600000);
        assertEq(token.balanceOf(receiver), start - 773800399633161293600000);

        vm.warp(now + 30 days);
        emitter.emitTokens();

        assertEq(token.balanceOf(address(emitter)), 748458823090550154400000);
        assertEq(token.balanceOf(receiver), start - 748458823090550154400000);    

        vm.warp(now + 300 days);
        emitter.emitTokens();

        assertEq(token.balanceOf(address(emitter)), 536484945077947093600000);
        assertEq(token.balanceOf(receiver), start - 536484945077947093600000);  

        vm.warp(now + (48 * 30 days));
        token.mint(address(emitter), 1 ether); // sending one more token to emitter
        emitter.emitTokens();

        assertEq(token.balanceOf(address(emitter)), 108499502844419320000000);
        assertEq(token.balanceOf(receiver), start + 1 ether - 108499502844419320000000); // excess balance is distributed on first dist                    
    }

    function testFailEmitTokensTwiceSameMonth() public {
        emitter.emitTokens();
        emitter.emitTokens();
    }
}
