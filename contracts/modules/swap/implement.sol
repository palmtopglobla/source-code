pragma solidity >=0.5.1 <0.7.0;

import "./state.sol";

contract SwapImpl is SwapState {

    function Doswaping(uint amount) external returns (DoswapingError code, uint tokenAmount) {

        require( exchangeLimit(msg.sender) >= amount );

        // 
        tokenAmount = amount * swapInfo.prop;

        // 
        if ( swapInfo.current + tokenAmount > swapInfo.total  ) {
            return (DoswapingError.SwapBalanceInsufficient, 0);
        }

        // 
        if ( usdtInterface.balanceOf(msg.sender) < amount ) {
            return (DoswapingError.BalanceInsufficient, 0);
        }

        // 
        swapInfo.current += tokenAmount;
        swapedTotalSum += tokenAmount;

        // (USDT)
        usdtInterface.operatorSend(msg.sender, address(astPool), amount, "Doswaping", "");
        astPool.Auth_RecipientDelegate(amount);

        pttInterface.operatorSend(address(_KContractOwners[0]), msg.sender, tokenAmount, "Doswaping", "");

        quotaMapping[msg.sender][now / 1 days * 1 days] += tokenAmount;
        emit Log_Swaped(msg.sender, now, amount, tokenAmount);

        return (DoswapingError.NoError, tokenAmount);
    }

    function OwnerUpdateSwapInfo(uint total, uint prop) external KOwnerOnly {

        swapInfo.roundID ++;
        swapInfo.total = total;
        swapInfo.current = 0;
        swapInfo.prop = prop;

        emit Log_UpdateSwapInfo(now, msg.sender, total, prop);
    }

    // 
    function exchangeLimit(address owner) public returns(uint) {

        // 
        (uint tin, ) = phoenixInc.GetInoutTotalInfo(owner);

        uint dayz = now / 1 days * 1 days;

        uint quota = tin > 0 ? vaildAddressQuota : nomalAddressQuota;

        if ( quota > quotaMapping[owner][dayz] ) {
            return quota - quotaMapping[owner][dayz];
        } else {
            return 0;
        }
    }

    function shouldChange(address owner, uint amountOfUSD) external returns(bool) {
        uint limit = exchangeLimit(owner);
        return limit <= amountOfUSD;
    }

    function Owner_SetChangeQuota(uint nomal, uint vaild) external KOwnerOnly {
        nomalAddressQuota = nomal;
        vaildAddressQuota = vaild;
    }

}
