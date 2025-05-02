import { DojoProvider as _dojoProvider, getContractByName } from "@dojoengine/core";
import { useAccount, useConnect, useContract, useDisconnect, useNetwork } from "@starknet-react/core";
import { useSnackbar } from "notistack";
import React, { createContext, useEffect, useState } from "react";
import { CallData, RpcProvider } from 'starknet';
import { dojoConfig } from "../../dojo.config";
import Lords from "../abi/Lords.json";
import { fetchBalances } from "../api/starknet";
import { VRF_PROVIDER_ADDRESS } from "../helpers/constants";
import { translateEvent } from "../helpers/events";

export const DojoContext = createContext()

export const DojoProvider = ({ children }) => {
  const { contract: lordsContract } = useContract({ address: dojoConfig.lordsAddress, abi: Lords });

  const { chain } = useNetwork()
  const { account, address, isConnecting } = useAccount()
  const { connect, connector, connectors } = useConnect();
  const { disconnect } = useDisconnect()
  const { enqueueSnackbar } = useSnackbar()

  const [balances, setBalances] = useState({ eth: BigInt(0), lords: BigInt(0) })
  const [userName, setUserName] = useState()
  const [customName, setCustomName] = useState(localStorage.getItem("customName"))

  const dojoprovider = new _dojoProvider(dojoConfig.manifest, dojoConfig.rpcUrl);
  let provider = new RpcProvider({ nodeUrl: dojoConfig.rpcUrl });
  let cartridge = connectors.find(conn => conn.id === "controller")

  const getBalances = async () => {
    let balanceData = await fetchBalances(address ?? "0x0", lordsContract)

    setBalances(balanceData)
  }

  useEffect(() => {
    if (account) {
      if (account.walletProvider?.account?.channel?.nodeUrl && account.walletProvider.account.channel.nodeUrl !== dojoConfig.rpcUrl) {
        disconnect()
      } else {
        getBalances();
      }
    }
  }, [account]);

  useEffect(() => {
    async function controllerName() {
      try {
        const name = await connector?.username()
        if (name) {
          setUserName(name)
        }
      } catch (error) {
      }
    }

    controllerName()
  }, [connector])

  const executeTx = async (txs, includeVRF) => {
    if (!account) {
      connect({ connector: cartridge })
      return
    }

    if (includeVRF) {
      let contractAddress = getContractByName(dojoConfig.manifest, dojoConfig.namespace, txs[txs.length - 1].contractName)?.address

      txs.unshift({
        contractAddress: VRF_PROVIDER_ADDRESS,
        entrypoint: 'request_random',
        calldata: CallData.compile({
          caller: contractAddress,
          source: { type: 0, address: account.address }
        })
      })
    }

    try {
      const tx = await dojoprovider.execute(account, txs, dojoConfig.namespace, { version: "1" });
      await new Promise(resolve => setTimeout(resolve, 1000));
      const receipt = await provider.waitForTransaction(tx.transaction_hash, { retryInterval: 500 })

      if (receipt.execution_status === "REVERTED") {
        console.log('contract error', receipt)
        return
      }

      const translatedEvents = receipt.events.map(event => translateEvent(event))
      console.log('translatedEvents', translatedEvents)
      return translatedEvents.filter(Boolean)
    } catch (ex) {
      if (ex) {
        console.log(ex)
        enqueueSnackbar(ex.issues ? ex.issues[0].message : 'Something went wrong', { variant: 'error', anchorOrigin: { vertical: 'bottom', horizontal: 'right' } })
      }
    }
  }

  return (
    <DojoContext.Provider
      value={{
        provider,
        address: address,
        connecting: isConnecting,
        network: chain.network,
        userName,
        customName,
        playerName: customName || userName || "None",
        balances,
        executeTx,
        getBalances,
        setCustomName,
      }}
    >
      {children}
    </DojoContext.Provider>
  );
};