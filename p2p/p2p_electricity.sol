// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract P2PElectricity {
    struct RecordSettlement {
        address sellerAccountAddr;
        address buyerAccountAddr;
        uint unitsSettled;
    }

    struct BuyReq {
        address buyerAccountAddr;
        uint unitsRequired;
        uint buyPrice;
        uint unitsFulfilled;
    }

    struct SellReq {
        address sellerAccountAddr;
        uint unitsBid;
        uint sellPrice;
        uint unitsAvailable;
    }

    struct GridRecord {
        BuyReq[] buyReqs;
        SellReq[] sellReqs;
    }

    mapping (string => GridRecord) GridData;

    RecordSettlement[] settlements;

    function IssueSettlement(address FromAddress, address Toaddress, uint units) internal {
        settlements.push(RecordSettlement({
            sellerAccountAddr: FromAddress,
            buyerAccountAddr: Toaddress,
            unitsSettled: units
        }));
    }

    function Buy(address AccountAddress, uint Units, string memory gridId, uint price) public {
        GridRecord memory gridRecord = GridData[gridId];
        uint unitsReq = Units;
        bool settled = false;
        
        if (gridRecord.sellReqs.length > 0) {
            for (uint numReq = 0; numReq < gridRecord.sellReqs.length; numReq++ ) {
                if (gridRecord.sellReqs[numReq].sellPrice <= price && gridRecord.sellReqs[numReq].unitsAvailable > 0) {
                    if (gridRecord.sellReqs[numReq].unitsAvailable >= unitsReq) {
                        
                        IssueSettlement(gridRecord.sellReqs[numReq].sellerAccountAddr, AccountAddress, unitsReq);
                        gridRecord.sellReqs[numReq].unitsAvailable = gridRecord.sellReqs[numReq].unitsAvailable - unitsReq;

                        GridData[gridId].buyReqs.push(BuyReq({
                            buyerAccountAddr: AccountAddress,
                            unitsRequired: Units,
                            unitsFulfilled: unitsReq,
                            buyPrice: gridRecord.sellReqs[numReq].sellPrice
                        }));
                        settled = true;
                        break;
                    } else {
                        IssueSettlement(gridRecord.sellReqs[numReq].sellerAccountAddr, AccountAddress, gridRecord.sellReqs[numReq].unitsAvailable);
                        unitsReq = unitsReq - gridRecord.sellReqs[numReq].unitsAvailable;
                        gridRecord.sellReqs[numReq].unitsAvailable = 0;
                    }
                
                } 
            }
        }

        if (settled == false) {
            GridData[gridId].buyReqs.push(BuyReq ({
                buyerAccountAddr: AccountAddress,
                unitsRequired: Units,
                unitsFulfilled: unitsReq,
                buyPrice: price
            }));
        }
    }

    function Sell(address AccountAddress, uint Units, string memory gridId, uint price) public  {
        GridRecord memory gridRecord = GridData[gridId];
        uint unitsAvail = Units;
        bool settled = false;

        if (gridRecord.buyReqs.length > 0) {
            for (uint numReq = 0; numReq < gridRecord.buyReqs.length; numReq++) {
                if (gridRecord.buyReqs[numReq].buyPrice >= price && gridRecord.buyReqs[numReq].unitsFulfilled < gridRecord.buyReqs[numReq].unitsRequired) {
                    if (gridRecord.buyReqs[numReq].unitsFulfilled >= unitsAvail) {
                        IssueSettlement(AccountAddress, gridRecord.buyReqs[numReq].buyerAccountAddr, unitsAvail);
                        gridRecord.buyReqs[numReq].unitsFulfilled = gridRecord.buyReqs[numReq].unitsFulfilled - unitsAvail;

                        GridData[gridId].sellReqs.push(SellReq({
                            sellerAccountAddr: AccountAddress,
                            unitsBid: Units,
                            unitsAvailable: 0,
                            sellPrice: gridRecord.buyReqs[numReq].buyPrice
                        }));
                        settled = true;
                        break;

                    } else {
                        IssueSettlement(AccountAddress, gridRecord.buyReqs[numReq].buyerAccountAddr, gridRecord.buyReqs[numReq].unitsFulfilled);
                        unitsAvail = unitsAvail - gridRecord.buyReqs[numReq].unitsRequired;
                        gridRecord.buyReqs[numReq].unitsFulfilled = gridRecord.buyReqs[numReq].unitsRequired;
                    }
                }
            }
            
        }
        
        if (settled == false) {
            GridData[gridId].sellReqs.push(SellReq({
                sellerAccountAddr: AccountAddress,
                unitsBid: Units,
                unitsAvailable: unitsAvail,
                sellPrice: price
            }));
        }
    }

    function Buyers(string memory gridId) public view returns(BuyReq[] memory) {
        return GridData[gridId].buyReqs;
    }

    function Sellers(string memory gridId) public view returns(SellReq[] memory) {
        return GridData[gridId].sellReqs;
    }

    function SettledTx() public view returns(RecordSettlement[] memory) {
        return settlements;
    }
}