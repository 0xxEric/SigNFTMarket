<<<<<<< HEAD
## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

-   **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
-   **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
-   **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
-   **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```
=======
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
>>>>>>> 374c93cace3ab3d5fa04840501a2ba0ddc871c79
