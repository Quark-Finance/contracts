// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";


contract QuarkNFT is ERC721 {

    uint256 counter;


    constructor() ERC721("QuarkNFT", "QuarkNFT") {

    }

    function mint() public returns (uint256){
        uint256 id = counter +1;

        _mint(msg.sender, id);

        return id;
    }
}