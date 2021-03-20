pragma solidity >=0.5.1 <0.7.0;

import "./state.sol";

contract Swap is SwapState, KContract {

    constructor(
        ERC777Interface usdInc,
        AssertPoolInterface astPoolInc,
        PhoenixInterface _phoenixInc,
        ERC777Interface _pttInc,
        Hosts host
    ) public {
        _KHost = host;
        usdtInterface = usdInc;
        phoenixInc = _phoenixInc;
        astPool = astPoolInc;
        pttInterface = _pttInc;

        
        swapInfo = Info(
            1, //roundID
            100000 ether, //total
            0, //current
            13 * 10 ** 12 //prop
        );
    }

    // usdt
    function Doswaping(uint) external readwrite returns (DoswapingError, uint) {
        super.implementcall();
    }

    //
    function OwnerUpdateSwapInfo(uint, uint) external readwrite {
        super.implementcall();
    }

    //
    function exchangeLimit(address) public returns(uint) {
        super.implementcall();
    }

    function shouldChange(address, uint) external returns(bool) {
        super.implementcall();
    }

    function Owner_SetChangeQuota(uint, uint) external {
        super.implementcall();
    }
}
