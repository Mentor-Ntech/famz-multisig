// This setup uses Hardhat Ignition to manage smart contract deployments.
// Learn more about it at https://hardhat.org/ignition

import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const muiltiSigModule = buildModule("muiltiSigModule", (m) => {
  const signer1 = "0x5c7e85c6e93570Ba4f45e41aB41ee8e06e14772F";
  const signer2  = "0x20f572F3Be903eb0F3d86311a253Dbe2BaB8812E";
  

  const owners = [signer1, signer2];

  
  const multiSig = m.contract("MultiSigWallet", [owners, 2]);

  return { multiSig };
});

export default muiltiSigModule;
