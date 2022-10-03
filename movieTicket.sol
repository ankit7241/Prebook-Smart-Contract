// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";


contract NFT is ERC721URIStorage {
    using Strings for uint256;
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    address payable manager;
    address public customer;

    receive() external payable {}


    struct Ticket {
        address owner;
        uint256 seatNo ;
        uint256 movieId ;
        string movieName ;
        string showTime ;
        string imageNFT;
    }

    /// NFT token ID  => Ticket 
    mapping(uint256 => Ticket) tickets;
    

    struct Movie {
        string movie ;
        string showTime ;
        string showDate ;
        string imageAddress;
        mapping(uint256=>bool) seatsNotAvail;
    }

    /// movie id  => movie details
    mapping(uint256 => Movie) movies;

    // Refers to the movie id of the particular movie
    uint movieID;

    /// intializing the NFT ERC721 and making the manager to the person who deployed it i.e. me :)
    constructor() ERC721("Movie NFT", "MNFT") {
        manager=payable(msg.sender);
    }

    function addMovie(string memory movie) public
    {
        movies[movieID].movie=movie;
        movieID++;
    }

    function getImage(uint _movieId,string memory _image) public
    {
        movies[_movieId].imageAddress=_image;
    }

    function getManagerName() public view returns(address)
    {
        return manager;
    }

    function getMovie(uint movieId) public view returns(string memory)
    {
        return movies[movieId].movie;
    }

    

    //It will return true if that particular seat is not available
    function getSeatsNotAvail(uint _movieId, uint _seatNo) public view returns(bool notAvail) {
        return movies[_movieId].seatsNotAvail[_seatNo];
    }



    
     function generateNFT(uint256 tokenId) public view returns(string memory) {
        bytes memory svg = abi.encodePacked(
            '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350">',
            '<style>.base { fill: white; font-family: serif; font-size: 14px; }</style>',
            '<rect width="100%" height="100%" fill="black" />',
            '<text x="50%" y="40%" class="base" dominant-baseline="middle" text-anchor="middle">',
            "Movie Name: ",
            getMovieName(tokenId),
            '</text>',
            '<text x="50%" y="50%" class="base" dominant-baseline="middle" text-anchor="middle">',
            "Seat : ",
            // getSeat(tokenId),
            '</text>',
            '<text x="50%" y="40%" class="base" dominant-baseline="middle" text-anchor="middle">',
            "Screen : 2",
            '</svg>'
        );

        return
            string(
                abi.encodePacked(
                    "data:image/svg+xml;base64,",
                    Base64.encode(svg)
                )
            );
    }


        function generateNFT() public pure returns(string memory) {
        bytes memory svg = abi.encodePacked(
            
        );

        return
            string(
                abi.encodePacked(
                    "data:image/svg+xml;base64,",
                    Base64.encode(svg)
                )
            );
    }



    function getSeat(uint256 _tokenId) public view returns(uint256){
        return tickets[_tokenId].seatNo;
        
    }



    function getMovieName(uint256 _tokenId) public view returns(string memory){
        string memory name = tickets[_tokenId].movieName ;
        return name;
    }

     // to get the final tokenURI for a tokenId with metadata and svg together
    function getTokenURI(uint256 tokenId) public pure returns (string memory) {
        bytes memory dataURI = abi.encodePacked(
            "{",
            '"name": "Movie Ticket #',
            tokenId.toString(),
            '",',
            '"description": "Movie ticket as NFT ",',
            '"image": "https://ipfs.io/ipfs/QmTgqnhFBMkfT9s8PHKcdXBn1f5bG3Q5hmBaR4U6hoTvb1?filename=Chainlink_Elf.png' ,
               
            generateNFT(),
            '"',
            "}"
        );
        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(dataURI)
                )
            );
    }

     /// to mint a on chain NFT using mint and setting a token URI for the svg
    function mint(uint256 _movieId,uint256 _seatNo) public payable returns(uint256) {

        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        _safeMint(msg.sender, newItemId);
        Movie storage _movie = movies[_movieId];
        
        
        tickets[newItemId].owner=msg.sender;
        tickets[newItemId].movieId=_movieId;
        tickets[newItemId].seatNo=_seatNo;
        tickets[newItemId].movieName=_movie.movie;
        tickets[newItemId].showTime=_movie.showTime;
        _setTokenURI(newItemId, getTokenURI(newItemId));
        return(newItemId);
    
    }
    
}
