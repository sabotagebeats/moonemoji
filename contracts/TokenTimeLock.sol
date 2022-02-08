pragma solidity ^0.8.0;

import "openzeppelin-contracts/contracts/token/ERC20/SafeERC20.sol";

// from openzeppelin TokenTimeLock and modified for use for foodpyramid 

contract TokenTimelock {
    using SafeERC20 for IERC20;

    // ERC20 basic token contract being held
    IERC20 private _token;

    // beneficiary of tokens after they are released
    address payable private _beneficiary;

    // timestamp when token release is enabled
    uint256 private _releaseTime;

    constructor (IERC20 token, address payable beneficiary, uint256 releaseTime) public {
        // solhint-disable-next-line not-rely-on-time
        require(releaseTime > block.timestamp, "TokenTimelock: release time is before current time");
        _token = token;
        _beneficiary = beneficiary;
        _releaseTime = releaseTime;
    }

    /**
     * @return the token being held.
     */
    function token() public view returns (IERC20) {
        return _token;
    }

    /**
     * @return the beneficiary of the tokens.
     */
    function beneficiary() public view returns (address) {
        return _beneficiary;
    }

    /**
     * @return the time when the tokens are released.
     */
    function releaseTime() public view returns (uint256) {
        return _releaseTime;
    }

    /**
     * @notice Transfers tokens held by timelock to beneficiary.
     */
    function release() public {
        // solhint-disable-next-line not-rely-on-time
        require(block.timestamp >= _releaseTime, "TokenTimelock: current time is before release time");

        uint256 amount = _token.balanceOf(address(this));
        require(amount > 0, "TokenTimelock: no tokens to release");

        _token.safeTransfer(_beneficiary, amount);
    }

    function withdraw(IERC20 otherToken) public{
        require(otherToken != _token, "TokenTimelock: locked token cannot be withdrawn, try release()");
        uint256 amount = otherToken.balanceOf(address(this));
        require(amount > 0, "no tokens to withdraw");
        otherToken.safeTransfer(_beneficiary, amount);
    }

    function() external fallback {
        _beneficiary.transfer(address(this).balance);
    }
}
