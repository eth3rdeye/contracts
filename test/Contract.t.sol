// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Eth3rdEye.sol";
import "../src/structs.sol";

abstract contract TestHelper {
    Eth3rdEye eth3rdEye;
}

contract ContractTest is Test, TestHelper {

    string target;
    string salt;
    uint16 sessionIndex;

    address tasker;
    address psychic;

    function setUp() public {
        eth3rdEye = new Eth3rdEye();
        target = "land";
        salt = "1230430249";
        sessionIndex = 1;

        tasker = 0x1234123412341234123412341234123412341234;
        psychic = 0x5678567856785678567856785678567856785678;

    }

    function testStartSession() public {

        hoax(tasker);

        eth3rdEye.startSession( sessionIndex, keccak256( abi.encode(salt, target)) );
        assertEq(1, eth3rdEye.lastSessionIndex());

        Session memory s = eth3rdEye.getSession(sessionIndex);
        
        assertEq(s.tasker, tasker);

    }

    function testSubmitPrediction() public {

        hoax(psychic);

        string memory prediction = "land";
        eth3rdEye.submitPrediction(sessionIndex, prediction);

        bytes32 key = keccak256(abi.encode(sessionIndex, psychic));

        assertEq(eth3rdEye.predictions(key), prediction);

        assertEq(eth3rdEye.attempts(psychic), 1);
    }

    function testRevealTarget() public {

        startHoax(tasker);

        eth3rdEye.startSession( sessionIndex, keccak256( abi.encode(salt, target)) );
        eth3rdEye.revealTarget(sessionIndex, salt, target);

        Session memory s2 = eth3rdEye.getSession(sessionIndex);
        assertEq(s2.target, target);

    }

    function testClaimAccuracy() public {

        hoax(tasker);
        eth3rdEye.startSession( sessionIndex, keccak256( abi.encode(salt, target)) );
        hoax(tasker);
        eth3rdEye.revealTarget(sessionIndex, salt, target);

        hoax(psychic); // lulz
        eth3rdEye.submitPrediction(sessionIndex, "land");
        
        hoax(psychic);
        eth3rdEye.claimAccuracy(sessionIndex, "land");
        
        hoax(psychic);
        assertEq(1, eth3rdEye.accuracy(psychic));

    } 

    // Test start round
    // - store blockstamp epoch timer
    // - assert event emitted

    // Test Viewer submission
    // - assert viewer has not yet submitted
    // - emit event

    // Test reveal
    // - assert epoch has ended
    // - assert provided secret + salt matches commitment
    // - assert event emitted

    // Test scoring
    // - 

}
