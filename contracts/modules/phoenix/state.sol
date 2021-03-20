pragma solidity >=0.5.1 <0.7.0;

import "../../core/KContract.sol";
import "../../core/interface/ERC777Interface.sol";

import "../swap/state.sol";
import "../controller/interface.sol";
import "../assertpool/awards/interface.sol";
import "./interface.sol";

contract PhoenixState is PhoenixInterface, KState(0x4eb1d593) {

    // 
    mapping(uint => mapping(address => InoutTotal)) public inoutMapping;

    // 
    mapping(address => Compensate) public compensateMapping;

    // ,，，，
    // 
    uint public dataStateVersion = 0;

    // 
    uint public compensateRelaseProp = 0.01 szabo;

    // 
    uint public compensateProp = 0;

    // CTL
    ControllerDelegate internal _CTL;

    // _ASTPoolAwards
    AssertPoolAwardsInterface internal _ASTPoolAwards;

    ERC777Interface internal pttInterface;

    SwapState internal swapState;
}
