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
        uint unitsReq = Units; 
        uint unitsFulfilled = 0;
        bool settled = false;
        
        if (GridData[gridId].sellReqs.length > 0) {
            for (uint numReq = 0; numReq < GridData[gridId].sellReqs.length; numReq++ ) {
                if (GridData[gridId].sellReqs[numReq].sellPrice <= price && GridData[gridId].sellReqs[numReq].unitsAvailable > 0) {
                    if (GridData[gridId].sellReqs[numReq].unitsAvailable >= unitsReq) {
                        
                        IssueSettlement(GridData[gridId].sellReqs[numReq].sellerAccountAddr, AccountAddress, unitsReq);
                        GridData[gridId].sellReqs[numReq].unitsAvailable = GridData[gridId].sellReqs[numReq].unitsAvailable - unitsReq;

                        GridData[gridId].buyReqs.push(BuyReq({
                            buyerAccountAddr: AccountAddress,
                            unitsRequired: Units,
                            unitsFulfilled: unitsReq,
                            buyPrice: GridData[gridId].sellReqs[numReq].sellPrice
                        }));
                        
                        settled = true;
                        break;
                    } else {
                        IssueSettlement(GridData[gridId].sellReqs[numReq].sellerAccountAddr, AccountAddress, GridData[gridId].sellReqs[numReq].unitsAvailable);
                        unitsReq = unitsReq - GridData[gridId].sellReqs[numReq].unitsAvailable;
                        unitsFulfilled += GridData[gridId].sellReqs[numReq].unitsAvailable;
                        GridData[gridId].sellReqs[numReq].unitsAvailable = 0;
                    }
                
                } 
            }
        }

        if (settled == false) {
            GridData[gridId].buyReqs.push(BuyReq ({
                buyerAccountAddr: AccountAddress,
                unitsRequired: Units,
                unitsFulfilled: unitsFulfilled,
                buyPrice: price
            }));
        }
    }

    function Sell(address AccountAddress, uint Units, string memory gridId, uint price) public  {
        uint unitsAvail = Units;
        bool settled = false;

        if (GridData[gridId].buyReqs.length > 0) {
            for (uint numReq = 0; numReq < GridData[gridId].buyReqs.length; numReq++) {
                if (GridData[gridId].buyReqs[numReq].buyPrice >= price && GridData[gridId].buyReqs[numReq].unitsFulfilled < GridData[gridId].buyReqs[numReq].unitsRequired) {
                    if (GridData[gridId].buyReqs[numReq].unitsFulfilled >= unitsAvail) {
                        IssueSettlement(AccountAddress, GridData[gridId].buyReqs[numReq].buyerAccountAddr, unitsAvail);
                        GridData[gridId].buyReqs[numReq].unitsFulfilled = GridData[gridId].buyReqs[numReq].unitsFulfilled - unitsAvail;

                        GridData[gridId].sellReqs.push(SellReq({
                            sellerAccountAddr: AccountAddress,
                            unitsBid: Units,
                            unitsAvailable: 0,
                            sellPrice: GridData[gridId].buyReqs[numReq].buyPrice
                        }));
                        settled = true;
                        break;

                    } else {
                        IssueSettlement(AccountAddress, GridData[gridId].buyReqs[numReq].buyerAccountAddr, GridData[gridId].buyReqs[numReq].unitsRequired - GridData[gridId].buyReqs[numReq].unitsFulfilled);
                        unitsAvail = unitsAvail - GridData[gridId].buyReqs[numReq].unitsRequired;
                        GridData[gridId].buyReqs[numReq].unitsFulfilled = GridData[gridId].buyReqs[numReq].unitsRequired;
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