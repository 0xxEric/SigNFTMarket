// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import "forge-std/console.sol";

import {MyToken} from "src/MyToken.sol";
import {MyNFT} from "src/MyNFT.sol";
import {NFTMarket} from  "src/NFTMarket.sol";

contract FullFlow is Script {

    address internal constant add0 = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    address internal constant add1 = 0x70997970C51812dc3A010C7d01b50e0d17dc79C8;
    address internal constant add2 = 0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC;
    address internal constant add3 = 0x90F79bf6EB2c4f870365E785982E1f101E93b906;
    address internal constant add4 = 0x15d34AAf54267DB7D7c367839AAf71A00a2C6A65;
    address payable internal _feeRecipient = payable(add0);
    uint96 platformFeeBps=100;
    uint256 listingFeeWei=0.1 ether;

    MyToken public paymentToken;
    MyNFT public nft;
    NFTMarket public market;

    uint256 deployerPrivateKey = vm.envUint("ANVIL_PRIVATE_KEY_0");
    uint256 PrivateKey1 = vm.envUint("ANVIL_PRIVATE_KEY_1");
    uint256 PrivateKey2 = vm.envUint("ANVIL_PRIVATE_KEY_2");
    uint256 PrivateKey3 = vm.envUint("ANVIL_PRIVATE_KEY_3");
    uint256 PrivateKey4 = vm.envUint("ANVIL_PRIVATE_KEY_4");

    function setup() public {
        
        vm.startBroadcast(deployerPrivateKey);
        console.log("===start deploying with add0===");
        nft = new MyNFT("WestD_NFT","WDN");
        market=new NFTMarket(_feeRecipient,platformFeeBps,listingFeeWei); 
        paymentToken=new MyToken("WestD_Token","WTK");
        console.log("deployed successfully!");
        console.log("address of paymentToken:",address(paymentToken));
        console.log("address of NFT:",address(nft));
        console.log("address of market:",address(market));
        market.setPaymentTokenAllowed(address(paymentToken),true);
        vm.stopBroadcast();
    }


    function mint_and_init() public {
        vm.startBroadcast(deployerPrivateKey);
        // add0 transfer some ERC20 token to add1,2,3
        paymentToken.transfer(add1,100 ether);
        paymentToken.transfer(add2,200 ether);
        paymentToken.transfer(add3,300 ether);
        // mint NFT
        nft.mint(add1,"NFT of add1-0",add4,100); //ID:0
        nft.mint(add1,"NFT of add1-1",add4,100); //ID:1
        nft.mint(add2,"NFT of add2-2",add4,200); //ID:2
        nft.mint(add3,"NFT of add3-3",add4,300); //ID:3
        vm.stopBroadcast();
    }


    function trade() public{
        vm.startBroadcast(PrivateKey1);
        nft.approve(address(market),0);
        market.listItem{value: listingFeeWei}(address(nft),0,50 ether,address(paymentToken));
        console.log("==add0 listing NFT (tokenId=0, price=100WTK) ==");
        vm.stopBroadcast();

        vm.startBroadcast(PrivateKey2);
        nft.approve(address(market),2);
        market.listItem{value: listingFeeWei}(address(nft),2,100 ether,address(paymentToken));
        console.log("==add0 listing NFT (tokenId=0, price=100WTK) ==");
        vm.stopBroadcast();

        vm.startBroadcast(PrivateKey3);
        paymentToken.approve(address(market),300 ether);
        market.buyItem(address(nft),0,address(paymentToken));
        market.buyItem(address(nft),2,address(paymentToken));
        console.log("==add3 bue NFT ID0&2 ==");

       console.log("add1 balance of paymenttoken:", paymentToken.balanceOf(add0));
       console.log("add1 balance of paymenttoken:", paymentToken.balanceOf(add1));
       console.log("add1 balance of paymenttoken:", paymentToken.balanceOf(add2));
       console.log("add1 balance of paymenttoken:", paymentToken.balanceOf(add3));
       console.log("add1 balance of paymenttoken:", paymentToken.balanceOf(add4));
       //If Plantfee=1%(for add0),royaltyBps of NFT(0)=1%,royaltyBps of NFT(2)=2%,royaltyfee for add4. NFT(0) sell for 50,NFT(2) sell for 100,
       //then,caculate the balance: add0=1000-100-200-300+(50+100)*1%=401.5
       //add1=100+50-50*(1+1)%（royaltyfee+plantfee)=149
       //add2=200+100-100*(2+1)%=297
       //add3=300-100-50=150
       //add4=50*1%+100*2%=2.5(royaltyfee)
       // the listingFee：the sellers(add1 add2),send eth(not erc20 token) to add0. not show in balance of paymenttoken
        vm.stopBroadcast();
    }


    function run() public {
        setup();
        mint_and_init();
        trade();
    }
}


