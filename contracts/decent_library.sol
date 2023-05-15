// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DecentLibrary {
    address public librarian;

    struct BookShelfDetail {
        string title;
        address holder;
        bool reserved;
        bool available;
        uint holdingTime;
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

    function HoldBook(string memory BookTitle) public Librarian () {
        if (BookShelfDetails[BookTitle].reserved == true) {
            emit bookAvailability(false);
            revert("Book is already reserved");
        }


        if (BookShelfDetails[BookTitle].available == false) {
            emit bookAvailability(false);
            revert("Book is not available");
        }

        BookShelfDetails[BookTitle].holder = msg.sender;
        BookShelfDetails[BookTitle].reserved = true;
        BookShelfDetails[BookTitle].holdingTime = block.timestamp;
    }

    function UnHoldBook(string memory BookTitle) public Librarian () {
            BookShelfDetails[BookTitle].holder = address(0);
            BookShelfDetails[BookTitle].reserved = false;
            BookShelfDetails[BookTitle].holdingTime = 0;
    }

    function AddBookToShelf(string memory BookTitle) public Librarian () {
            BookShelfDetails[BookTitle].available = true;
            BookShelfDetails[BookTitle].reserved = false;
    }

    function CheckBookAvailaility(string memory BookTitle) public view returns (string memory){
        require(BookShelfDetails[BookTitle].available == true, "Book is not available in the library");
        require(BookShelfDetails[BookTitle].reserved == false, "Book is already reserved");
        return "Book is Available to Hold";
    }

    function TransferBook(string memory BookTitle, address _newHolder) public Librarian () {
            require(BookShelfDetails[BookTitle].available == true, "Book is not available in the library");
            BookShelfDetails[BookTitle].holder = _newHolder;
            BookShelfDetails[BookTitle].reserved = true;
            BookShelfDetails[BookTitle].holdingTime = block.timestamp;
    }
}