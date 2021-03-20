pragma solidity >=0.5.1 <0.7.0;

import "./interface.sol";

import "../../core/KContract.sol";
import "../../core/interface/ERC777Interface.sol";

import "../assertpool/interface.sol";
import "../phoenix/interface.sol";

contract SwapState is SwapInterface, KState(0x6b0331b4) {

    // 
    uint public swapedTotalSum;

    Info public swapInfo;

    ERC777Interface public usdtInterface;

    ERC777Interface public pttInterface;

    AssertPoolInterface public astPool;

    /// USDT
    uint public nomalAddressQuota = 5 * 10 ** 6;

    /// USDT
    uint public vaildAddressQuota = 100 * 10 ** 6;

    ///  ->  -> 
    mapping( address => mapping(uint => uint) ) public quotaMapping;

    PhoenixInterface internal phoenixInc;
}
