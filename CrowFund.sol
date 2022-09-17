pragma solidity ^0.8.17;

// SPDX-License-Identifier: MIT

// Kontrat üzerinde kullanılacak ekstra interface ve fonksiyonları tanımlama / Define extra interfaces and functions to be used on the contract
interface IERC20 {
    // Girilen adrese transfer fonksiyonu / Transfer function to the entered address
    function transfer(address, uint) external returns (bool);
    
    //Girilen adresten istenilen adrese transfer / Transfer from the entered address to the desired address
    function transferFrom(
        address,
        address,
        uint
    ) external returns (bool);
}


contract CrowFund{
// Gerekli eventlerin tanımlanması / Declaring required events
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

    // Kampanya structı için gerekli parametrelerin tanımlanması / Declaring the necessary parameters for the campaign struct
    struct Campain{
        address creator;
        uint goal;
        uint pledged;
        uint32 startAt;
        uint32 endAt;
        bool claimed;
    }
    
    // token değişkeninin tanımı / Declaring  of token variable
    IERC20 public immutable token;
    // Campains array idsi için değişken tanımlama / Declaring variable for campains array id
    uint public count;
    // campains arrayini tanımlama (Tıpkı bir array gibi fakat sırasız)(Girilen id'ye göre campain'i getirir) 
    // Declare campains array (Just like an array but inordered)(Returns campain based on the id entered)
    mapping(uint => Campain) public campains;
    //Girilen adrese göre kişinin ne kadar yatırım yaptığını gösteren mapping
    //According to the entered address, how much the person has invested
    mapping(uint => mapping(address => uint)) pledgedAmount;

     // _token adresine göre token değişkenine atama yapılması (Interface inherit edilebilirdi.)
     // Declaring token variable based on _token address (Interface could be inherited.)
    constructor(address _token){
        token = IERC20(_token);
    }
    
    //campain ekleme fonksiyonu(fonksiyon sonunda Launc eventini harekete geçirir)
    //Add campaign function (activates the Launch event at the end of the function)
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
    
    //Girilen parametreye göre campain'i çağırır(Kontrat sahibi değilsen çalıştırmazsın ve campai'in başlamamış olması gerekir)
    //Calls campain according to the entered parameter (If you do not creator of tihs contract can't run it and campain must not have started)
    function cancel(uint _id) external {
        Campain memory campain = campains[_id];
        require(campain.creator == msg.sender, "Not owner");
        require(campain.startAt < block.timestamp, "started");

        delete campains[_id];

        emit Cancel(_id);
    }
    
    //Girilen parametreye göre bu fonksiyonu çalıştıran kişi bu kontrata transfer yapar
    //According to the entered parameter, the person who runs this function transfers to this contract.
    function pledged(uint _id, uint _amount) external {
        Campain storage campain = campains[_id];
        require(campain.startAt <= block.timestamp, "not started");
        require(campain.endAt >= block.timestamp,"ended" );

        campain.pledged += _amount;
        pledgedAmount[_id][msg.sender] += _amount;

        token.transferFrom(msg.sender,address(this),_amount);

        emit Pledged(_id,msg.sender,_amount);

    }
    
    //Girilen parametreye göre bu fonksiyonu çalıştıran kişi bu kontrata yatırdığı tutarı çeker
    //According to the entered parameter, the person who runs this function withdraws the amount invested in this contract.
    function unpledged(uint _id, uint _amount) external {
        Campain storage campain = campains[_id];
        require(campain.endAt >= block.timestamp,"ended");

        campain.pledged -= _amount;
        pledgedAmount[_id][msg.sender] -= _amount;

        token.transfer(msg.sender,_amount);

        emit Unpledged(_id,msg.sender,_amount);

    }
    
    // Kontrat sahibi kampanya bitimi sonunda hedefine ulaştıysa bütün bakiyeyi çekebilir
    //If the contract owner has reached his goal at the end of the campaign, he can withdraw the entire balance
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
    
    //Kampanya sonunda istenilen hedefe ulaşılmadıysa bütün tutar yatırım yapan kişilere geri aktarılır
    // If the desired goal is not reached at the end of the campaign, the entire amount is transferred back to the investor.
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
