// SPDX-License-Identifier: MIT
// The code base was taken from Set Protocol's repository, and modified by @0xVato
pragma solidity ^0.8.20;

import { XYZToken } from "./XYZToken.sol";
import { AddressArrayUtils } from "./lib/AddressArrayUtils.sol";

// VaultCreator is a contract factory that creates new ERC20 tokens that function as vaults.
contract VaultCreator {

   using AddressArrayUtils for address[];
   event NewVaultCreated(address indexed _vToken, address _manager, string _name, string _symbol);

   /**
     * Creates a TokenVault smart contract. The vTokens are composed
     * of positions that are instantiated as DEFAULT (positionState = 0) state.
     *
     * @param _components             List of addresses of components for initial Positions
     * @param _units                  List of units. Each unit is the # of components per 10^18 of a SetToken
     * @param _manager                Address of the manager
     * @param _name                   Name of the SetToken
     * @param _symbol                 Symbol of the SetToken
     * @return address                Address of the newly created vToken
    */
    function create(
        address[] memory _components,
        int256[] memory _units,
        address _manager,
        string memory _name,
        string memory _symbol
    )
        external
        returns (address)
    {
        require(_components.length > 0, "Must have at least 1 component");
        require(_components.length == _units.length, "Component and unit lengths must be the same");
        require(!_components.hasDuplicate(), "Components must not have a duplicate");
        require(_manager != address(0), "Manager must not be empty");

        for (uint256 i = 0; i < _components.length; i++) {
            require(_components[i] != address(0), "Component must not be null address");
            require(_units[i] > 0, "Units must be greater than 0");
        }

        // Creates a new vToken instance
        XYZToken vToken = new XYZToken(
            _components,
            _units,
            _manager,
            _name,
            _symbol,
            0xCC93cBC4Baf4D217Da6b930A6eAB175b5a23fE52
        );

        emit NewVaultCreated(address(vToken), _manager, _name, _symbol);

        return address(vToken);
    }
}