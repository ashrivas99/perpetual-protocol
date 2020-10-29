// SPDX-License-Identifier: BSD-3-CLAUSE
pragma solidity 0.6.9;
pragma experimental ABIEncoderV2;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { IPriceFeed } from "../../interface/IPriceFeed.sol";
import { BaseBridge } from "../BaseBridge.sol";
import { Decimal } from "../../utils/Decimal.sol";

contract RootBridge is BaseBridge {
    using Decimal for Decimal.decimal;

    uint256 public constant DEFAULT_GAS_LIMIT = 2e6;

    //**********************************************************//
    //   The order of below state variables can not be changed  //
    //**********************************************************//

    IPriceFeed public priceFeed;

    //**********************************************************//
    //  The order of above state variables can not be changed   //
    //**********************************************************//

    //
    // PUBLIC
    //
    function initialize(address _ambBridge, address _multiTokenMediator) public initializer {
        __BaseBridge_init(_ambBridge, _multiTokenMediator);
    }

    function updatePriceFeed(
        address _priceFeedAddrOnL2,
        bytes32 _priceFeedKey,
        Decimal.decimal calldata _price,
        uint256 _timestamp,
        uint256 _roundId
    ) external returns (bytes32 messageId) {
        require(address(priceFeed) == _msgSender(), "!priceFeed");

        bytes4 methodSelector = IPriceFeed.setLatestData.selector;
        bytes memory data = abi.encodeWithSelector(
            methodSelector,
            _priceFeedKey,
            _price.toUint(),
            _timestamp,
            _roundId
        );
        return callBridge(_priceFeedAddrOnL2, data, DEFAULT_GAS_LIMIT);
    }

    function setPriceFeed(address _priceFeed) external onlyOwner {
        priceFeed = IPriceFeed(_priceFeed);
    }

    //
    // INTERNALS
    //
}