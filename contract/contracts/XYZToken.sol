// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import { AddressArrayUtils } from "./lib/AddressArrayUtils.sol";

contract XYZToken is ERC20, ERC20Pausable, Ownable {

    using AddressArrayUtils for address[];

    modifier onlyManager() {
        require(msg.sender == manager, "Only manager can call");
        _;
    }

     // The manager has the privelege to add modules, remove, and set a new manager
    address public manager;

     // List of components
    address[] public components;

    // Mapping that stores all position information for a given component.
    // Position quantities are represented as virtual units;
    mapping(address => int256) public componentPositions;

    // The multiplier applied to the virtual position unit to achieve the real/actual unit.
    // This multiplier is used for efficiently modifying the entire position units (e.g. streaming fee)
    int256 public positionMultiplier;

    event ManagerEdited(address _newManager, address _oldManager);

    /* ============ Constructor ============ */

    /**
     * When a new Token is created, initializes Positions in default state and adds modules into pending state.
     * All parameter validations are on the VaultTokenCreator contract. Validations are performed already on the 
     * VaultTokenCreator. Initiates the positionMultiplier as 1e18 (no adjustments).
     *
     * @param _components             List of addresses of components for initial Positions
     * @param _units                  List of units. Each unit is the # of components per 10^18 of a SetToken
     * @param _manager                Address of the manager
     * @param _name                   Name of the vToken
     * @param _symbol                 Symbol of the vToken
     */
    constructor(
        address[] memory _components,
        int256[] memory _units,
        address _manager,
        string memory _name,
        string memory _symbol,
        address initialOwner
    )
        public
        ERC20(_name, _symbol)
        Ownable(initialOwner)
    {
        manager = _manager;
        positionMultiplier = 1e18;
        components = _components;

        // Positions are put in default state initially
        for (uint256 i = 0; i < _components.length; i++) {
            componentPositions[_components[i]] = _units[i];
        }
    }

    /**
     * Increases the "account" balance by the "quantity".
     */
    function mint(address _account, uint256 _quantity) external onlyManager {
        _mint(_account, _quantity);
    }

    /**
     * Decreases the "account" balance by the "quantity".
     * _burn checks that the "account" already has the required "quantity".
     */
    function burn(address _account, uint256 _quantity) external onlyManager {
        _burn(_account, _quantity);
    }

     /**
     * MANAGER ONLY. Changes manager; We allow null addresses in case the manager wishes to wind down the Token.
     */
    function setManager(address _manager) external onlyManager {
        address oldManager = manager;
        manager = _manager;

        emit ManagerEdited(_manager, oldManager);
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function _update(address from, address to, uint256 value)
        internal
        override(ERC20, ERC20Pausable)
    {
        super._update(from, to, value);
    }
     /* ============ External Getter Functions ============ */

    function getComponents() external view returns(address[] memory) {
        return components;
    }
}