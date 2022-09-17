pragma solidity ^0.8.17;

// SPDX-License-Identifier: MIT

interface IERC20 {
    function transfer(address, uint) external returns (bool);

    function transferFrom(
        address,
        address,
        uint
    ) external returns (bool);
}


contract CrowFund{
    event Launch(
        uint id,
        address indexed creator,
        uint goal,
        uint32 startAt,
        uint32 endAt
    );

    event Cancel(uint id);
    event Pledged(uint indexed id,address indexed caller,uint amount);
    event Unpledged(uint indexed id, address indexed caller,uint amount);
    event Claim(uint id);
    event Refund(uint id,address indexed caller, uint amount);

    struct Campain{
        address creator;
        uint goal;
        uint pledged;
        uint32 startAt;
        uint32 endAt;
        bool claimed;
    }

    IERC20 public immutable token;
    uint public count;
    mapping(uint => Campain) public campains;
    mapping(uint => mapping(address => uint)) pledgedAmount;


    constructor(address _token){
        token = IERC20(_token);
    }

    function launch(uint _goal,uint32 _startAt, uint32 _endAt) external{
            require(_startAt >= block.timestamp, "start at < now" );
            require(_endAt >= _startAt , "end at < start at");
            require(_endAt <= block.timestamp + 90 days,"end at > max duration" );

            count+=1;

            campains[count] = Campain({
                creator: msg.sender,
                goal: _goal,
                pledged:0,
                startAt: _startAt,
                endAt: _endAt,
                claimed: false
            });

            emit Launch(count, msg.sender, _goal, _startAt, _endAt);
        
    }

    function cancel(uint _id) external {
        Campain memory campain = campains[_id];
        require(campain.creator == msg.sender, "Not owner");
        require(campain.startAt < block.timestamp, "started");

        delete campains[_id];

        emit Cancel(_id);
    }

    function pledged(uint _id, uint _amount) external {
        Campain storage campain = campains[_id];
        require(campain.startAt <= block.timestamp, "not started");
        require(campain.endAt >= block.timestamp,"ended" );

        campain.pledged += _amount;
        pledgedAmount[_id][msg.sender] += _amount;

        token.transferFrom(msg.sender,address(this),_amount);

        emit Pledged(_id,msg.sender,_amount);

    }

    function unpledged(uint _id, uint _amount) external {
        Campain storage campain = campains[_id];
        require(campain.endAt >= block.timestamp,"ended");

        campain.pledged -= _amount;
        pledgedAmount[_id][msg.sender] -= _amount;

        token.transfer(msg.sender,_amount);

        emit Unpledged(_id,msg.sender,_amount);

    }

    function claim(uint _id) external {
        Campain storage campain = campains[_id];
        require(msg.sender == campain.creator, "not creator");
        require(campain.endAt < block.timestamp, "not ended");
        require(campain.goal >= campain.pledged, "pledged < goal");
        require(!campain.claimed , "claimed");

        campain.claimed = true;
        token.transfer(campain.creator,campain.pledged);

        emit Claim(_id);

    }

    function refund(uint _id) external {
        Campain storage campain = campains[_id];
        require(campain.endAt <= block.timestamp , "not ended");
        require(campain.pledged < campain.goal, "pledged < goal");

        uint bal = pledgedAmount[_id][msg.sender];
        pledgedAmount[_id][msg.sender] = 0;

        token.transfer(msg.sender,bal);

        emit Refund(_id,msg.sender,bal);
    }
}