// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DecentLibrary {
    address public librarian;
    struct BookShelfDetail {
        string title;
        address holderName;
        bool reserved;
    }

    mapping (string => BookShelfDetail) BookShelfDetails;
    event bookAvailability (bool _available);

    constructor(address _librarian) {
        librarian = _librarian;
    }

    modifier Librarian () {
        require(librarian == msg.sender, "Only Librarian Can Update The Book Shelf details");
        _;
    }

    function ReserveBook(string memory BookTitle) public Librarian () {
        if (BookShelfDetails[BookTitle].reserved == true) {
            emit bookAvailability(false);
            revert("Book Not Available");
        }
        BookShelfDetails[BookTitle].holderName = msg.sender;
        BookShelfDetails[BookTitle].reserved = true;
    }

    function CheckBookAvailaility(string memory BookTitle) public view returns (string memory){
        require(BookShelfDetails[BookTitle].reserved == true, "Book Not Available");
        return "Book Available";
    }
}