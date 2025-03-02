// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

import "./auction/Auction.sol";
import "hardhat/console.sol";

contract Main {
    receive() external payable {}

    event Winner(address indexed winner, string _auctionid);
    event BaseAmountPayEvent(address indexed bidder, string indexed auctionId);
    event commitAmountPayEvent(
        address indexed bidder,
        string indexed auctionId
    );
    event revealPhaseCompleted(
        address indexed bidder,
        string indexed auctionId
    );
    event TransferStatus(bool status, string indexed auctionId);
    struct AuctionHistory {
        address payable contract_address;
        address payable owner;
        Auction auction;
    }
    mapping(string => AuctionHistory) public _auctiondetails;
    mapping(address => int256) public userCrediblity;
    mapping(address =>int256) public userAuctionBid;
    mapping(address=>int256) public userAuctionWin;

    address payable public Owner;

    constructor() {
        Owner = payable(msg.sender);
    }

    function createAuction(
        uint256 _minamount,
        string memory auctionId
    ) public payable {
        require(msg.value >= 0, "Payment must be greater than zero");

        (bool sent, ) = address(this).call{value: msg.value}("");
        require(sent, "Failed to send Ether to Owner");

        Auction _auction = new Auction(_minamount, auctionId, msg.sender);
        _auctiondetails[auctionId].owner = payable(msg.sender);
        _auctiondetails[auctionId].contract_address = payable(
            address(_auction)
        );
        _auctiondetails[auctionId].auction = _auction;
    }

    modifier onlyBidder(address bidderAddress, string memory auctionId) {
        address auctioncreator = _auctiondetails[auctionId]
            .auction
            ._auctionowner();

        require(auctioncreator != bidderAddress, "Only bidders are allowed!");
        _;
    }

    function payminamount(
        string memory auctionId
    ) public payable onlyBidder(msg.sender, auctionId) {
        uint256 _minamount = _auctiondetails[auctionId].auction._minamount();
        require(msg.value == _minamount, "pay min amount!!");
        (bool sent, ) = _auctiondetails[auctionId].contract_address.call{
            value: msg.value
        }("");
        require(sent, "Failed to pay the minimum amount");
        emit BaseAmountPayEvent(msg.sender, auctionId);
    }

    function signCommit(
        string memory auctionId,
        bytes32 hash
    ) public payable onlyBidder(msg.sender, auctionId) {
        _auctiondetails[auctionId].auction.commit(msg.sender, hash);
        emit commitAmountPayEvent(msg.sender, auctionId);
    }

    function signReveal(
        string memory auctionId,
        uint256 bidAmt,
        string memory secretSalt
    ) public payable onlyBidder(msg.sender, auctionId) {
        _auctiondetails[auctionId].auction.revealBid(
            msg.sender,
            bidAmt,
            secretSalt
        );
        emit revealPhaseCompleted(msg.sender, auctionId);
    }

    function getHash(
        uint decimalValue,
        string memory secretSalt
    ) public pure returns (bytes32) {
        uint256 weiValue = decimalValue * 1e18;
        bytes32 _hashBidAmt = keccak256(abi.encode(weiValue));
        return keccak256(abi.encode(_hashBidAmt, secretSalt));
    }

    function payCommitBidAmount(
        string memory auctionId,
        bytes32 hash
    ) public payable onlyBidder(msg.sender, auctionId) {
        require(msg.value > 0, "Zero cannot be given as bid");
        (bool sent, ) = _auctiondetails[auctionId].contract_address.call{
            value: msg.value
        }("");
        require(sent, "Failed to pay commitBid");
        signCommit(auctionId, hash);
    }

    function getWinner(string memory _auctionId) public {
        require(
            msg.sender == _auctiondetails[_auctionId].owner,
            "Only the owner can trigger this function"
        );
        Auction auction = _auctiondetails[_auctionId].auction;

        address payable _auctionwinner = auction.getAuctionWinner();
        emit Winner(_auctionwinner, _auctionId);
    }

    function returnMainbalance() public view returns (uint) {
        return address((this)).balance;
    }

    function returncontractbalance(
        string memory _auctionId
    ) public view returns (uint) {
        address _address = _auctiondetails[_auctionId].contract_address;
        return _address.balance;
    }

    function returnUserCredibilty(address _address) public view returns (int) {
        return userCrediblity[_address];
    }

    function returnUserAuctionBids(address _address) public view returns (int){
        return userAuctionBid[_address];
    }
    function returnUserAuctionWins(address _address) public view returns (int){
        return userAuctionWin[_address];
    }


    function transferAmount(string memory _auctionId) external {
        require(
            msg.sender == _auctiondetails[_auctionId].owner,
            "Only the owner can trigger this function"
        );
        Auction auction = _auctiondetails[_auctionId].auction;
        bool status = auction.transferAmount();
        emit TransferStatus(status, _auctionId);
    }

    function increaseCred(
        address bidderAddress,
        int256 points,
        bool status
    ) public {
        if (status) {
            userCrediblity[bidderAddress] += points;
        } else {
            userCrediblity[bidderAddress] -= points;
        }
    }

    function increaseUserAuctionBid(address bidderAddress)public{
        userAuctionBid[bidderAddress]+=1;
    }
    function increaseUserAuctionWin(address bidderAddress)public{
        userAuctionWin[bidderAddress]+=1;
    }

    
}
