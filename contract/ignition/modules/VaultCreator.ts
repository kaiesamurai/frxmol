import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const indexAddresses = [
    "0xa0289cBbEB673b8787C9C61Bf03914068A033651",
    "0x2A19790B6Dd1fC70e45e6F0D64A1a61C79a5Da0c",
    "0x013Cb2854daAD8203C6686682f5d876e5D3de4a2"
];

const ONE_HUNDRED_GWEI: bigint = 100_000_000_000n; //100 gwei

const VaultCreatorModule = buildModule("VaultCreatorModule", (m) => {
  
  //const addressArrayUtils = m.library("AddressArrayUtils");
  const vault = m.contract("VaultCreator", []
  /*{
    libraries: {
        AddressArrayUtils: addressArrayUtils,
    },
  }*/);

  const createVault = m.call(vault, "create", [
    indexAddresses,
    [ONE_HUNDRED_GWEI, ONE_HUNDRED_GWEI, ONE_HUNDRED_GWEI],
    "0xE303127A49B05A0671c235E7aD78d05bE11BBAA2",
    "vDEPIN",
    "vDEPIN",
  ])

  console.log({ ...createVault });

  const value = m.readEventArgument(createVault, "NewVaultCreated", "_vToken");
  console.log(value);

  return { vault };
});

export default VaultCreatorModule;
