// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import '@openzeppelin/contracts/access/Ownable.sol';

contract Tickets is ERC721 {
    constructor() ERC721("Ticket", "TICKET") {}

    struct Ticket {
        address owner;
        string uid;
        string title;
        string seat;
        string time;
        uint256 price;
    }

    mapping(uint256 => Ticket) public tickets;
    uint256 public nextTicketId;

    function createTicket(string memory uid, string memory title, string memory seat, string memory time, uint256 amount, uint256 price) public {
        for (uint256 i = 0; i < amount; i++) {
          tickets[nextTicketId] = Ticket(msg.sender, uid, title, seat, time, price);
          nextTicketId++;
        }
    }

    function getAllTickets() public view returns (Ticket[] memory) {
        Ticket[] memory result = new Ticket[](nextTicketId);
        for (uint256 ticketId = 0; ticketId < nextTicketId; ticketId++) {
            result[ticketId] = tickets[ticketId];
        }
        return result;
    }

    function getTicketIds(string memory uid) public view returns (uint256[] memory) {
        uint256[] memory result = new uint256[](nextTicketId);
        uint256 resultIndex = 0;
        for (uint256 ticketId = 0; ticketId < nextTicketId; ticketId++) {
            if (keccak256(bytes(tickets[ticketId].uid)) == keccak256(bytes(uid))) {
                result[resultIndex] = ticketId;
                resultIndex++;
            }
        }
        return result;
    }

    function purchaseTicket(uint256 ticketId) public payable {
        Ticket storage ticket = tickets[ticketId];
        require(msg.value >= ticket.price, "Not enough Ether sent.");
        
        uint256 sellerShare = msg.value / 100 * 97;
        payable(ticket.owner).transfer(sellerShare);
        
        // 티켓 소유권 변경
        ticket.owner = msg.sender;
    }

    function getTicketsByOwnerId(address owner) public view returns (Ticket[] memory) {
        Ticket[] memory result = new Ticket[](nextTicketId);
        uint256 resultIndex = 0;
        for (uint256 ticketId = 0; ticketId < nextTicketId; ticketId++) {
            if (tickets[ticketId].owner == owner) {
                result[resultIndex] = tickets[ticketId];
                resultIndex++;
            }
        }
        return result;
    }
}
