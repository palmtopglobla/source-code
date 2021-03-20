pragma solidity >=0.5.1 <0.7.0;

import "../../core/KContract.sol";
import "../../core/interface/ERC20Interface.sol";

import {ControllerDelegate} from "../controller/interface.sol";
import {ConfigInterface} from "../config/interface.sol";
import {CounterModulesInterface} from "../counter/interface.sol";

import "./interface.sol";

contract OrderState is OrderInterface, KState(0xcb150bf5) {

    // 
    mapping(uint8 => uint) public times;

    // 
    OrderInterface.OrderType public orderType;

    // 
    uint public totalAmount;

    // 
    uint public toHelpedAmount;

    // 
    uint public getHelpedAmount;

    // 
    uint public getHelpedAmountTotal;

    // 
    uint public paymentPartMinLimit;

    // 
    uint public createdPaymentAmount;

    // 
    OrderInterface.OrderStates public orderState;

    // ,
    bool public nextOrderVaild;

    // 
    address public contractOwner;

    // 
    uint public orderIndex;

    // 
    // [0] 
    // [1] 
    mapping(uint => uint) public blockRange;

    // 
    ERC20Interface internal _usdtInterface;
    ConfigInterface internal _configInterface;
    ControllerDelegate internal _CTL;
    CounterModulesInterface internal _counterInteface;
}
