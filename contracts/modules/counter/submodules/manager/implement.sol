pragma solidity >=0.5.1 <0.7.0;

import "./state.sol";

contract CounterManagerImpl is CounterManagerState {

    modifier AuthorizedOnly() {
        require(msg.sender == authorizedAddress); _;
    }

    // ，
    function WhenOrderCreatedDelegate(OrderInterface order)
    external AuthorizedOnly returns (uint, address[] memory, uint[] memory, AwardType[] memory) {

        address owner = order.contractOwner();
        uint orderAmount = order.totalAmount();

        // 
        if ( !vaildAddressMapping[owner] ) {
            // 
            vaildAddressMapping[owner] = true;
            // 
            vaildAddressCountMapping[RLTInterface.GetIntroducer(owner)]++;
        }

        // 
        selfAchievementMapping[owner] += orderAmount;

        // dlv1DepositedNeed，D1
        if ( dlevelMapping[owner] == 0 ) {
            if (orderAmount >= dlv1DepositedNeed ) {
                depositedGreatThanD1[owner] = true;
            } else if ( orderAmount >= 5000 * 10 ** 6 ) {
                depositedGreatThan5000USD[owner] = true;
            }
        }
    }

    // ，,len，,
    function WhenOrderFrozenDelegate(OrderInterface order)
    external AuthorizedOnly returns (uint len, address[] memory addresses, uint[] memory awards, AwardType[] memory types) {

        ////////////////////////////////////////
        //                               //
        ////////////////////////////////////////

        // , * 4 ，3
        // ，
        len = dlevelAwarProp.length * 4;
        addresses = new address[](len);
        awards = new uint[](len);
        types = new AwardType[](len);

        // 
        uint[] memory awarProps = dlevelAwarProp;

        // 100%D
        // 
        address owner = order.contractOwner();

        // 
        address root = RLTInterface.rootAddress();

        // 
        for (
            (uint i, address parent) = (0, RLTInterface.GetIntroducer(owner) );
            i < dlvDepthMaxLimit && parent != address(0x0) && parent != root;
            (parent = RLTInterface.GetIntroducer(parent), i++)
        ) {
            uint8 dlv = dlevelMapping[parent];

            // 
            if ( addresses[dlv] != address(0x0) ) {
                continue;
            }

            uint psum = 0;

            // 
            for ( uint8 x = dlv; x > 0; x-- ) {
                psum += awarProps[x];
                awarProps[x] = 0;
            }

            if ( psum > 0 ) {

                addresses[dlv] = parent;
                awards[dlv] = order.totalAmount() * psum / 1 szabo;
                types[dlv] = AwardType.Manager;

                // ，,3，
                for (
                    (uint j, address grower) = (0, RLTInterface.GetIntroducer(parent));
                    j < 3 && grower != address(0x0) && grower != root;
                    (grower = RLTInterface.GetIntroducer(grower), j++)
                ) {
                    // 
                    // “6 + dlv * 3 + j”
                    // 6，3，j
                    // ，
                    // 0      : ,
                    // 1 - 5  : D
                    // 6 - 8  : dlv0（,dlv0)
                    // 9 - 11 : dlv1
                    // ....   : dlv5
                    if ( dlevelMapping[grower] <= dlv && dlevelMapping[grower] >= 2 ) {

                        uint offset = 6 + dlv * 3 + j;

                        addresses[offset] = grower;

                        // 10%
                        awards[offset] = awards[dlv] * 0.1 szabo / 1 szabo;

                        types[offset] = AwardType.Grow;
                    }
                }
            }

            // ，
            if ( dlv >= dlevelAwarProp.length - 1 ) {
                break;
            }
        }
    }

    // 
    function WhenOrderDoneDelegate(OrderInterface order)
    external AuthorizedOnly returns (uint len, address[] memory addresses, uint[] memory awards, AwardType[] memory types) {

        ////////////////////////////////////////
        //                               //
        ////////////////////////////////////////

        // 
        uint profit = (order.getHelpedAmountTotal() - order.totalAmount());

        // 
        address owner = order.contractOwner();

        // 
        address root = RLTInterface.rootAddress();

        // 
        len = RLTInterface.Depth(owner);
        // 
        if ( len > awardProp.length ) {
            len = awardProp.length;
        }

        // 
        addresses = new address[](len);
        awards = new uint[](len);
        types = new AwardType[](len);

        // 
        for (
            (uint i, address parent) = (0, RLTInterface.GetIntroducer(owner) );
            i < len && parent != address(0x0) && parent != root;
            (parent = RLTInterface.GetIntroducer(parent), i++)
        ) {
            // ，,，i+1，i0
            // !!，，
            if (
                dlevelMapping[parent] > 0 || // Dlevel
                vaildAddressCountMapping[parent] >= i + 1 || // 
                vaildAddressCountMapping[parent] >= 9 // 10
            ) {
                addresses[i] = parent;
                awards[i] = profit * awardProp[i] / 1 szabo;
                types[i] = AwardType.Admin;
            }
        }
    }

    // 
    function InfomationOf(address owner) external returns (
        // 
        bool isvaild,
        // 
        uint vaildMemberTotal,
        // 
        uint selfAchievements,
        // D
        uint dlevel
    ) {
        return (
            vaildAddressMapping[owner],
            vaildAddressCountMapping[owner],
            selfAchievementMapping[owner],
            uint(dlevelMapping[owner])
        );
    }

    function LevelListOf(uint lv) external returns (address[] memory) {
        return _levelListMapping[lv];
    }

    // D
    function UpgradeDLevel() external returns (uint origin, uint current) {

        origin = dlevelMapping[msg.sender];
        current = origin;

        // 
        if ( origin == dlevelAwarProp.length - 1 ) {
            return (origin, current);
        }

        // 
        (address[] memory directAddresses, uint len) = RLTInterface.RecommendList(msg.sender);

        if ( current == 0 ) {

            if ( vaildAddressMapping[msg.sender] && vaildAddressCountMapping[msg.sender] >= 10 ) {

                uint effCount = 0;
                /// ，，1000u
                for (uint i = 0; i < len; i++) {
                    (
                        uint rewardAmount,
                        /* uint totalDeposit, */,
                        uint totalRewardedAmount
                    ) = rewardInterface.RewardInfo(directAddresses[i]);

                    if ( rewardAmount + totalRewardedAmount >= 1000e6 ) {
                        if ( ++effCount >= 3 ) {
                            break;
                        }
                    }
                }

                if (effCount >= 3) {
                    current = 1;
                }
            }
        }

        // 
        uint[] memory childrenDLVSCount = new uint[](dlevelAwarProp.length);

        // 
        // ，
        for ( uint i = 0; i < len; i++) {
            childrenDLVSCount[dlevelMemberMaxMapping[directAddresses[i]]]++;
        }

        // 
        // D1->D2
        if ( current == 1 ) {
            uint effCount = 0;
            for (uint i = current; i < dlevelAwarProp.length; i++ ) {
                effCount += childrenDLVSCount[i];
            }
            if ( effCount >= 2 ) {
                current = 2;
            }
        }

        // D2->D3
        if ( current == 2 ) {
            uint effCount = 0;
            for (uint i = current; i < dlevelAwarProp.length; i++ ) {
                effCount += childrenDLVSCount[i];
            }
            if ( effCount >= 2 ) {
                current = 3;
            }
        }

        // D3->D4
        if ( current == 3 ) {
            uint effCount = 0;
            for (uint i = current; i < dlevelAwarProp.length; i++ ) {
                effCount += childrenDLVSCount[i];
            }
            if ( effCount >= 3 ) {
                current = 4;
            }
        }

        // D4->D5
        if ( current == 4 ) {
            uint effCount = 0;
            for (uint i = current; i < dlevelAwarProp.length; i++ ) {
                effCount += childrenDLVSCount[i];
            }
            if ( effCount >= 3 ) {
                current = 5;
            }
        }

        // 
        if ( current > origin ) {

            /// 
            for (uint i = origin + 1; i <= current; i++) {
                _levelListMapping[i].push(msg.sender);
            }

            // 
            dlevelMapping[msg.sender] = uint8(current);

            // 
            address root = RLTInterface.rootAddress();
            for (
                (uint i, address parent) = (0, msg.sender);
                // 10
                i < 10 && parent != address(0x0) && parent != root;
                (parent = RLTInterface.GetIntroducer(parent), i++)
            ) {
                if ( dlevelMemberMaxMapping[parent] < current ) {
                    dlevelMemberMaxMapping[parent] = uint8(current);
                }
            }
        }

        return (origin, current);
    }

    // D1
    function PaymentDLevel(uint lv) external returns (bool) {

        // ，
        require( RLTInterface.GetIntroducer(msg.sender) != address(0x0) );

        require( lv == 1 || lv == 2 );

        // 0
        if ( dlevelMapping[msg.sender] >= lv ) {
            return false;
        }

        // 
        if ( usdtInterface.balanceOf(msg.sender) < dlvPrices[lv] ) {
            return false;
        }

        dlevelMapping[msg.sender] = uint8(lv);

        // 
        address root = RLTInterface.rootAddress();
        for (
            (uint i, address parent) = (0, msg.sender);
            i < 10 && parent != address(0x0) && parent != root;
            (parent = RLTInterface.GetIntroducer(parent), i++)
        ) {
            if ( dlevelMemberMaxMapping[parent] < uint8(lv) ) {
                dlevelMemberMaxMapping[parent] = uint8(lv);
            }
        }

        // USDT
        usdtInterface.operatorSend(msg.sender, _KContractOwners[0], dlvPrices[lv], "", "PaymentDLevel");

        return true;
    }

    // 
    function SetRecommendAwardProp(uint l, uint p) external KOwnerOnly {
        require( l >= 0 && l < awardProp.length );
        awardProp[l] = p;
    }

    // D
    function SetDLevelAwardProp(uint dl, uint p) external KOwnerOnly {
        require( dl >= 1 && dl < dlevelAwarProp.length );
        dlevelAwarProp[dl] = p;
    }

    // D
    function SetDLevelSearchDepth(uint depth) external KOwnerOnly {
        dlvDepthMaxLimit = depth;
    }

    // D1，
    function SetDlevel1DepositedNeed(uint need) external KOwnerOnly {
        dlv1DepositedNeed = need;
    }

    // D1DT
    function SetDLevelPrices(uint lv, uint prices) external KOwnerOnly {
        dlvPrices[lv] = prices;
    }

}
