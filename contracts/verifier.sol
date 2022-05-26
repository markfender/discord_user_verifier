// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import '@chainlink/contracts/src/v0.8/ChainlinkClient.sol';
import '@chainlink/contracts/src/v0.8/ConfirmedOwner.sol';

contract Verifier is Ownable, ChainlinkClient, ConfirmedOwner {
    using Chainlink for Chainlink.Request;

    /* Variables & Constants */
    struct DiscordData {
        uint256 userId;
        uint256[] timestamps;
    }
    uint256 private constant arrayLimit = 5;
    uint256 private constant lowerBound = 1 seconds;
    uint256 private constant upperBound = 1 hours;
    mapping(address => DiscordData) public discordDataOfWallet;
    mapping(address => bool) public isUserVerified;
    uint256 public volume;
    bytes32 private jobId;
    uint256 private fee; 

    /* Modifiers */  
    modifier userExists(address _userAddr){
        require(discordDataOfWallet[_userAddr].userId == 0, "User Exists...");
        _;
    }
    modifier UserNotVerified(address _userAddr){
        require(!isUserVerified[_userAddr], "User Already Verified...");
        _;
    }
    modifier UserVerified(address _userAddr){
        require(isUserVerified[_userAddr], "User Not Verified...");
        _;
    }
    modifier userAddrisValid(address _userAddr){
        require(_userAddr != address(0), "Invalid User Addr..." );
        _;
    }
    /* Constuctor */
    constructor() ConfirmedOwner(msg.sender){
        // TODO
    }

    /* Functions */
    /// @dev gets off chain discord API data 
    function getDiscordData() external returns(){ 
        //TODO
    }

    /// @dev try to verify the user 
    function verifyUser(address _userAddr, DiscordData memory dd) internal UserNotVerified(_userAddr) returns(bool){
        // Check if user has 5 messages
        uint userMsgCount = dd.timestamps.length;
        if(userMsgCount < arrayLimit ){
            return false;
        }
        else{
            // Check the time between the messages
            if(dd.timestamps[userMsgCount - 1] - dd.timestamps[0] < upperBound){
                for(uint256 i = 0; i <= userMsgCount-1; i++){
                    if(dd.timestamps[i+1] - dd.timestamps[1] < lowerBound){
                        return false;
                    }
                }
                return true;
            }
            return false;
        }
    }

    /// @dev add user record to the contract
    function registerUser(address _userAddr, uint256 _userId, uint256[] _timestamps) external userExists(_userAddr){
        DiscordData userData = DiscordData({userId:_userId, timestamps: _timestamps});
        // Add user record to the system
        discordDataOfWallet[_userAddr] = userData;
        // Try to Verify 
        bool userVerifStatus = verifyUser(_userAddr, userData);
        isUserVerified[_userAddr] = userVerifStatus;
    }

    /// @dev notify server that about this verified user
    function acceptUserToTheServer(address _userAddr) external UserVerified(_userAddr){
        // TODO
    }


}