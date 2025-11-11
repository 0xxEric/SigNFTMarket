// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Permit.sol";

import {MyToken} from "src/MyToken.sol";
import {MyNFT} from "src/MyNFT_ERC20Permit.sol";
import {NFTMarket} from "src/NFTmarket_ERC20Permit.sol";

import "../src/IERC4494.sol";

contract Permit_FullFlow is Script {
    address internal constant add0 = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    address internal constant add1 = 0x70997970C51812dc3A010C7d01b50e0d17dc79C8;
    address internal constant add2 = 0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC;
    address internal constant add3 = 0x90F79bf6EB2c4f870365E785982E1f101E93b906;
    address internal constant add4 = 0x15d34AAf54267DB7D7c367839AAf71A00a2C6A65;
    address payable internal _feeRecipient = payable(add0);
    uint96 platformFeeBps = 100;
    uint256 listingFeeWei = 0.1 ether;

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
        nft = new MyNFT("WestD_NFT", "WDN");
        market = new NFTMarket(_feeRecipient, platformFeeBps, listingFeeWei);
        paymentToken = new MyToken("WestD_Token", "WTK");
        console.log("deployed successfully!");
        console.log("address of paymentToken:", address(paymentToken));
        console.log("address of NFT:", address(nft));
        console.log("address of market:", address(market));
        market.setPaymentTokenAllowed(address(paymentToken), true);
        vm.stopBroadcast();
    }

    function mint_and_init() public {
        vm.startBroadcast(deployerPrivateKey);
        // add0 transfer some ERC20 token to add1,2,3
        paymentToken.transfer(add1, 100 ether);
        paymentToken.transfer(add2, 200 ether);
        paymentToken.transfer(add3, 300 ether);
        // mint NFT
        nft.mint(add1, "NFT of add1-0", add4, 100); //ID:0
        nft.mint(add1, "NFT of add1-1", add4, 100); //ID:1
        nft.mint(add2, "NFT of add2-2", add4, 200); //ID:2
        nft.mint(add3, "NFT of add3-3", add4, 300); //ID:3
        vm.stopBroadcast();
    }

    //take add1 as seller, add3 as buyer.
    function permitSig_buyer(
        uint256 privatekey,
        uint256 price
    ) public view returns (uint8 v,bytes32 r,bytes32 s, uint256 deadline) {
        // generate the signature of buyer.
        uint256 nonce = IERC20Permit(paymentToken).nonces(add1);
        uint256 deadline = block.timestamp + 3600;
        address buyer_Address = vm.addr(privatekey);
        bytes32 structHash = keccak256(
            abi.encode(
                keccak256(
                    "Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"
                ),
                buyer_Address,
                address(market),
                price,
                nonce,
                deadline
            )
        );
        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                IERC20Permit(paymentToken).DOMAIN_SEPARATOR(),
                structHash
            )
        );
        (uint8 _v, bytes32 _r, bytes32 _s) = vm.sign(privatekey, digest);
        // bytes memory buyer_PermitSig = abi.encodePacked(r, s, v);
        console.log("buyer permit sig:");
        console.log(uint256(v));
        console.logBytes32(r);
        console.logBytes32(s);
        return (_v,_r,_s, deadline);
    }

    function permitSig_seller(
        uint256 privatekey,
        uint256 tokenId
    ) public view returns (bytes memory, uint256 deadline) {
        // generate the signature of seller.
        uint256 Id = tokenId;
        uint256 deadline2 = block.timestamp + 3600;
        uint256 nftNonce = IERC4494(nft).get_nonces(tokenId);
        bytes32 nftStructHash = keccak256(
            abi.encode(
                keccak256(
                    "Permit(address spender,uint256 tokenId,uint256 nonce,uint256 deadline)"
                ),
                address(market), // spender
                Id, // tokenId
                nftNonce, // nonce
                deadline2 // deadline
            )
        );
        bytes32 nftDigest = keccak256(
            abi.encodePacked("\x19\x01", nft.DOMAIN_SEPARATOR(), nftStructHash)
        );
        (uint8 v2, bytes32 r2, bytes32 s2) = vm.sign(privatekey, nftDigest);
        bytes memory seller_PermitSig = abi.encodePacked(r2, s2, v2);

        console.log("seller permit sig:");
        console.log(uint256(v2));
        console.logBytes32(r2);
        console.logBytes32(s2);
        return (seller_PermitSig, deadline2);
    }

    function trade() public {
        // seller1
        vm.startBroadcast(PrivateKey1);
        uint256 tokenId1 = 0;
        (bytes memory sig1, uint256 deadline1) = permitSig_seller(
            PrivateKey1,
            tokenId1
        );
        nft.permit(address(market), tokenId1, deadline1, sig1); //check the permit
        market.listItem{value: listingFeeWei}(
            address(nft),
            tokenId1,
            50 ether,
            address(paymentToken)
        );
        console.log("==add1 listing NFT (tokenId=0, price=50WTK) ==");
        vm.stopBroadcast();

        // seller2
        vm.startBroadcast(PrivateKey2);
        uint256 tokenId2 = 2;
        (bytes memory sig2, uint256 deadline2) = permitSig_seller(
            PrivateKey2,
            tokenId2
        );
        nft.permit(address(market), tokenId2, deadline2, sig2); //check the permit
        market.listItem{value: listingFeeWei}(
            address(nft),
            tokenId2,
            100 ether,
            address(paymentToken)
        );
        console.log("==add2 listing NFT (tokenId=2, price=100WTK) ==");
        vm.stopBroadcast();

        //buyer
        vm.startBroadcast(PrivateKey3);
        uint256 total_price=300 ether;
        // paymentToken.approve(address(market), 300 ether);
        (uint8 v,bytes32 r,bytes32 s, uint256 deadline)=permitSig_buyer(PrivateKey3,total_price);
        paymentToken.permit(add3,address(market),total_price,deadline,v,r,s);

        market.buyItem(address(nft), tokenId1, address(paymentToken));
        market.buyItem(address(nft), tokenId2, address(paymentToken));
        console.log("==add3 bue NFT ID0&2 ==");

        console.log(
            "add1 balance of paymenttoken:",
            paymentToken.balanceOf(add0)
        );
        console.log(
            "add1 balance of paymenttoken:",
            paymentToken.balanceOf(add1)
        );
        console.log(
            "add1 balance of paymenttoken:",
            paymentToken.balanceOf(add2)
        );
        console.log(
            "add1 balance of paymenttoken:",
            paymentToken.balanceOf(add3)
        );
        console.log(
            "add1 balance of paymenttoken:",
            paymentToken.balanceOf(add4)
        );
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
