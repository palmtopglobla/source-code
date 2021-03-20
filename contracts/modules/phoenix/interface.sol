pragma solidity >=0.5.1 <0.7.0;

interface PhoenixInterface {

    struct InoutTotal {
        uint totalIn;
        uint totalOut;
    }

    struct Compensate {
        // 
        uint total;
        // 
        uint currentWithdraw;
        // 
        uint latestWithdrawTime;
    }

    // ,
    event Log_CompensateCreated(address indexed owner, uint when, uint compensateAmount);

    // 
    event Log_CompensateRelase(address indexed owner, uint when, uint relaseAmount);

    // 
    function GetInoutTotalInfo(address owner) external returns (uint totalIn, uint totalOut);

    // 
    function WithdrawCurrentRelaseCompensate() external returns (uint amount);

    // 
    function CTL_AppendAmountInfo(address owner, uint inAmount, uint outAmount) external;

    // ，（）
    function CTL_ClearHistoryDelegate(address breaker) external;

    function CTL_SettlementCompensate(address owner) external returns (uint total);

    // ,ASTPoolAward
    function ASTPoolAward_PushNewStateVersion() external;

    // 
    function SetCompensateRelaseProp(uint p) external;

    // 
    function SetCompensateProp(uint p) external;

}
