// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract EnergyTrading {

    struct EnergyOffer {
        address seller;
        uint256 energyAmount; // in kWh
        uint256 pricePerUnit; // in wei per kWh
        bool isAvailable;
    }

    uint256 public offerCount;
    mapping(uint256 => EnergyOffer) public offers;

    event EnergyListed(uint256 offerId, address indexed seller, uint256 amount, uint256 pricePerUnit);
    event EnergyPurchased(uint256 offerId, address indexed buyer, uint256 totalPrice);

    // Function to list energy for sale
    function listEnergy(uint256 _energyAmount, uint256 _pricePerUnit) external {
        require(_energyAmount > 0, "Energy amount must be > 0");
        require(_pricePerUnit > 0, "Price must be > 0");

        offerCount++;
        offers[offerCount] = EnergyOffer(msg.sender, _energyAmount, _pricePerUnit, true);

        emit EnergyListed(offerCount, msg.sender, _energyAmount, _pricePerUnit);
    }

    // Function to purchase energy from a listed offer
    function purchaseEnergy(uint256 _offerId) external payable {
        EnergyOffer storage offer = offers[_offerId];
        require(offer.isAvailable, "Offer not available");

        uint256 totalPrice = offer.energyAmount * offer.pricePerUnit;
        require(msg.value >= totalPrice, "Insufficient payment");

        offer.isAvailable = false;
        payable(offer.seller).transfer(totalPrice);

        emit EnergyPurchased(_offerId, msg.sender, totalPrice);
    }
}
