// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract VotePlace {

    struct Place {
        string name;
        uint256 voteNumber;
    }

    struct User {
        address addr;
        bool hasVoted;
    }

    event Voted(address _addr, string _place);

    Place[]  public places;
    User[]   public users;
    string[] public placeList;
    address  payable public owner;
    bool     public isVotingActive;
    mapping(address => bool) public hasVotedList;

    modifier onlyOwner() {
        require(msg.sender == owner, "You're not contract owner.");
        _;
    }

    modifier isActive() {
        require(isVotingActive == true, "Voting is not active.");
        _;
    }

    modifier hasVoted() {
        require(hasVotedList[msg.sender] == false, "You can only vote once");
        _;
    }

    constructor() {
        owner = payable(msg.sender);
        isVotingActive = true;
        string[3] memory _placeList = ["options1","options2","options3"];

        for (uint256 i=0; i<_placeList.length; i++) {
            places.push(Place({name: _placeList[i], voteNumber: 0}));
        }
    }

    fallback() external payable {}
    receive() external payable {}  


    function getAllUsers() public view returns (User[] memory) {
        return users;
    }

    function gelAllPlaces() public view returns (Place[] memory){
        return places;
    }

    function getVoterByAddress(address _addr) public view returns(bool) {
        return hasVotedList[_addr];
    }

    function vote(string calldata place) public isActive hasVoted payable {
        bool success = owner.send(msg.value);
        require(success == true, "No payment received.");
        
        hasVotedList[msg.sender] = true;
        users.push(User({addr: msg.sender, hasVoted:false}));

        for (uint256 i=0; i<places.length; i++) {
             if (keccak256(bytes(places[i].name)) == keccak256(bytes(place))) {
                places[i].voteNumber += 1;
            }
        }

        emit Voted(msg.sender, place);
    }

    function getWinPlace() view public returns (Place memory) {
        uint256  max = places[0].voteNumber;
        Place memory winPlace = places[0];

        for (uint256 i=1; i<places.length; i++) {
            if(places[i].voteNumber > max) {
                max = places[i].voteNumber;
                winPlace = places[i];
            }
        }

        return winPlace;
    }

    function finishVoting() public onlyOwner {
        isVotingActive = false;
    }

}
