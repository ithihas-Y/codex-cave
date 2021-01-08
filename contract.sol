// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.8.0;
pragma experimental ABIEncoderV2;

contract VaccineTracker{
    struct Vaccine{
        string Name;
        string Manufacturer;
        uint256 ID;
        uint256 ExpDate;
        bool initialised;
        bool Assigned;
        address CurrentDistributor;
        int8 locationLatitude;
        int8 locationLongitude;
        uint256 Temp;
        uint256 EndUserID;
    }
    
    struct Distributor{
        string Name; 
        bool authorised;
        address ID;
    }
    
    struct Location{
        int8 Latitude;
        int8 Longitude;
    }
    
    event locationUpdated(Location[]);
    
    address payable owner;
    Vaccine[] public vaccine;
    uint256 public Vcount; 
    uint256[] public Temp;
    
    mapping(uint256 => Vaccine) public details;
    mapping(address =>Distributor) public Authdistributors;
    mapping(uint256 => Location[]) public history;
    mapping(address => uint256[]) public inventory;
    
    constructor(){
        owner = msg.sender;
        Vcount =0;
    }
    
    modifier OnlyOwner{
        require(msg.sender == owner);
        _;
    }
    
    modifier OnlyDistributor{
        require(Authdistributors[msg.sender].authorised == true);
        _;
    }
    
    function setDistributor(address did,string memory name) public OnlyOwner{
        Authdistributors[did].Name = name;
        Authdistributors[did].ID = did;
        Authdistributors[did].authorised = true;
    }
    
    function fireDistributor(address Did) public OnlyOwner{
        Authdistributors[Did].authorised = false;
    }
    
    function setVaccine(string memory name,string memory manufacturer,uint256 id,uint256 expDate,
    int8 lat,int8 long,uint256 temp)
    public {
        if(!details[id].initialised){
            Vcount++;
            details[id] = Vaccine(name,manufacturer,id,expDate,true,false,msg.sender,lat,long,temp,0);
            vaccine.push(details[id]);
            history[id].push(Location(lat,long));
        }else{revert();}
    }
    
    function travelHistory(uint256 idd)  public{
        emit locationUpdated(history[idd]);
    }
    
    function updateLocation(uint256 VID,int8 newlat,int8 newlong) public{
        history[VID].push(Location(newlat,newlong));
    }
    
    function RequestVaccine(uint256 quantity) public OnlyDistributor returns(uint[] memory){
        if(quantity <= Vcount){
            uint256 count =0;
            for(uint256 i=0;i < vaccine.length-1;i++){
                while(count < quantity){
                    if(!vaccine[i].Assigned){
                        vaccine[i].Assigned = true;
                        vaccine[i].CurrentDistributor = msg.sender;
                        inventory[msg.sender].push(vaccine[i].ID);
                        count++;
                        Vcount--;
                    }
                    else{
                        i++;
                    }
                }
                }
        }else revert();
        return inventory[msg.sender];
    }
    
    function returnInventory(address Aid) public view returns (uint256[] memory){
        return inventory[Aid];
    }
    
    
    function withdraw() public payable OnlyOwner{
        owner.transfer(address(this).balance);
    }
    
}
