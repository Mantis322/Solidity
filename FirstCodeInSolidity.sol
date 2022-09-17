pragma solidity ^0.8.17;

// SPDX-License-Identifier: MIT

contract FirstCode{
    // Kontrat için sahip ve bakiye değişkenleri tanımlama,  Define owner and balance variables for the contract
    address public owner;
    uint public balance;
    
    // Kontrat sahibini tanımlamak için constructor, Constructor to define the contract owner
    constructor(){
        owner = msg.sender;

    }
    
    // Fonksiyonun çalışması için payable olması gerekli, The function must be payable for it to work.
    receive() payable external {
        // gelen tutarı bakiyeye aktarma
        balance += msg.value;
    }

    // Fonksiyonun tanımlanması ve gerekli parametrelerin yazılması, Defining the function and writing the necessary parameters
    function withdraw(uint amount, address payable destAddr) public {
       // require sağlanmaz ise fonksiyon devam etmez ,If require is not supplied, the function does not continue.
       require(msg.sender == owner,"Only owner can withdraw");
        require(amount <= balance, "Insufficient funds");
        
        // parametre olarak girilen adrese aktarımın yapılması, Transferring to the address entered as a parameter
        destAddr.transfer(amount);
        // transfere göre bakiyenin güncellenmesi, Updating the balance according to the transfer
        balance-=amount;

    }

}
