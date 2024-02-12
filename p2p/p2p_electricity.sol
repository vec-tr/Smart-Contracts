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
        uint qtyUnitsReq;
        uint buyPrice;
        bool settled;
    }

    struct SellReq {
        address sellerAccountAddr;
        uint qtyUnitsAvail;
        uint sellPrice;
        bool settled;
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

    function Buy(address AccountAddress, uint units, string memory gridId, uint price) public {
        GridRecord memory gridRecord = GridData[gridId];
        if (gridRecord.sellReqs.length > 0){
            for (int count = int (gridRecord.sellReqs.length - 1); count >= 0; count-- ) {
                uint numReq = uint(count);
                if (gridRecord.sellReqs[numReq].qtyUnitsAvail >= units && gridRecord.sellReqs[numReq].sellPrice <= price) {
                    IssueSettlement(gridRecord.sellReqs[numReq].sellerAccountAddr, AccountAddress, units);
                    if (gridRecord.sellReqs[numReq].qtyUnitsAvail > units) {
                        GridData[gridId].sellReqs.push(SellReq({
                            sellerAccountAddr: gridRecord.sellReqs[numReq].sellerAccountAddr,
                            qtyUnitsAvail: gridRecord.sellReqs[numReq].qtyUnitsAvail - units,
                            sellPrice: gridRecord.sellReqs[numReq].sellPrice,
                            settled: false
                        }));

                         GridData[gridId].buyReqs.push(BuyReq({
                            buyerAccountAddr: AccountAddress,
                            qtyUnitsReq: 0,
                            buyPrice: price,
                            settled: true
                        }));

                    } else {
                        GridData[gridId].buyReqs.push(BuyReq({
                            buyerAccountAddr: AccountAddress,
                            qtyUnitsReq: 0,
                            buyPrice: price,
                            settled: true
                        }));

                        GridData[gridId].sellReqs.push(SellReq({
                            sellerAccountAddr: gridRecord.sellReqs[numReq].sellerAccountAddr,
                            qtyUnitsAvail: 0,
                            sellPrice: gridRecord.sellReqs[numReq].sellPrice,
                            settled: true
                        }));
                    }
                } else if(gridRecord.sellReqs[numReq].qtyUnitsAvail < units && gridRecord.sellReqs[numReq].sellPrice <= price) {
                    IssueSettlement(gridRecord.sellReqs[numReq].sellerAccountAddr, AccountAddress, units);
                    GridData[gridId].buyReqs.push(BuyReq({
                        buyerAccountAddr: AccountAddress,
                        qtyUnitsReq: units - gridRecord.sellReqs[numReq].qtyUnitsAvail,
                        buyPrice: price,
                        settled: false    
                    }));

                     GridData[gridId].sellReqs.push(SellReq({
                        sellerAccountAddr: gridRecord.sellReqs[numReq].sellerAccountAddr,
                        qtyUnitsAvail: 0,
                        sellPrice: gridRecord.sellReqs[numReq].sellPrice,
                        settled: true    
                    }));

                } else {
                    GridData[gridId].buyReqs.push(BuyReq ({
                        buyerAccountAddr: AccountAddress,
                        qtyUnitsReq: units,
                        buyPrice: price,
                        settled: false
                    }));
                }
            }
        } else {
            GridData[gridId].buyReqs.push(BuyReq ({
                buyerAccountAddr: AccountAddress,
                qtyUnitsReq: units,
                buyPrice: price,
                settled: false
            }));
        }
    }

    function Sell(address AccountAddress, uint units, string memory gridId, uint price) public  {
        GridRecord memory gridRecord = GridData[gridId];
        if (gridRecord.buyReqs.length > 0) {
            for (int count = int(gridRecord.buyReqs.length - 1); count >= 0; count--) {
                uint numReq = uint(count);
                if (gridRecord.buyReqs[numReq].qtyUnitsReq <= units && gridRecord.buyReqs[numReq].buyPrice >= price) {
                    IssueSettlement(AccountAddress, gridRecord.buyReqs[numReq].buyerAccountAddr, gridRecord.buyReqs[numReq].qtyUnitsReq);
                    if (units > gridRecord.buyReqs[numReq].qtyUnitsReq) {
                        GridData[gridId].sellReqs.push(SellReq({
                            sellerAccountAddr: AccountAddress,
                            qtyUnitsAvail: units - gridRecord.buyReqs[numReq].qtyUnitsReq,
                            sellPrice: price,
                            settled: false
                        }));
                        GridData[gridId].buyReqs.push(BuyReq({
                            buyerAccountAddr: gridRecord.buyReqs[numReq].buyerAccountAddr,
                            qtyUnitsReq: 0,
                            buyPrice: gridRecord.buyReqs[numReq].buyPrice,
                            settled: true
                        }));

                    } else {
                        GridData[gridId].buyReqs.push(BuyReq({
                            buyerAccountAddr: gridRecord.buyReqs[numReq].buyerAccountAddr,
                            qtyUnitsReq: 0,
                            buyPrice: gridRecord.buyReqs[numReq].buyPrice,
                            settled: true
                        }));

                        GridData[gridId].sellReqs.push(SellReq({
                            sellerAccountAddr: AccountAddress,
                            qtyUnitsAvail: 0,
                            sellPrice: price,
                            settled: true
                        }));
                    }
                } else if (gridRecord.buyReqs[numReq].qtyUnitsReq > units && gridRecord.buyReqs[numReq].buyPrice >= price) {
                    IssueSettlement(AccountAddress, gridRecord.buyReqs[numReq].buyerAccountAddr, units);
                    GridData[gridId].buyReqs.push(BuyReq({
                            buyerAccountAddr: gridRecord.buyReqs[numReq].buyerAccountAddr,
                            qtyUnitsReq: gridRecord.buyReqs[numReq].qtyUnitsReq - units,
                            buyPrice: gridRecord.buyReqs[numReq].buyPrice,
                            settled: false
                        }));

                    GridData[gridId].sellReqs.push(SellReq({
                            sellerAccountAddr: AccountAddress,
                            qtyUnitsAvail: 0,
                            sellPrice: price,
                            settled: true
                        }));
                } else {
                    GridData[gridId].sellReqs.push(SellReq({
                        sellerAccountAddr: AccountAddress,
                        qtyUnitsAvail: units,
                        sellPrice: price,
                        settled: false
                    }));
                }

            }
            
        } else {
            GridData[gridId].sellReqs.push(SellReq({
                sellerAccountAddr: AccountAddress,
                qtyUnitsAvail: units,
                sellPrice: price,
                settled: false
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