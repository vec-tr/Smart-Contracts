// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract exPayable {
    string public myName = "Vinayak";
    function updateString(string memory _name) public payable {
        if (msg.value == 1 gwei) {
            myName = _name;
        } else {
            payable(msg.sender).transfer(msg.value);
        }
    }
}