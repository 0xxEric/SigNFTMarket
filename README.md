# SigNFTMarket
SigNFTMarket — A signature-based NFT marketplace enabling seamless trading with ERC20 and NFT permits.

**SigNFTMarket** is a gas-efficient NFT marketplace powered by **ERC20 Permit** and **NFT Permit**.  
It allows users to trade NFTs with just a signature — no prior approvals needed.

## 🚀 Features
- **Permit-based Trading** — Users sign once to authorize both NFT and token transfers.  
- **Gas Efficient** — Avoids extra approval transactions.  
- **ERC20 & NFT Support** — Works with any ERC20 token supporting `permit()` and NFTs supporting `permit-like` authorization.  
- **Secure & Transparent** — All trades are executed via smart contracts on-chain.

## 🧩 Tech Stack
- **Solidity** — Smart contracts for marketplace and permit logic  
- **OpenZeppelin** — Base standards and security modules  
- **Hardhat / Foundry** — For development and testing  
