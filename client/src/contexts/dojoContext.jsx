import { getContractByName } from "@dojoengine/core";
import { useAccount, useConnect } from "@starknet-react/core";
import { useSnackbar } from "notistack";
import React, { createContext, useEffect, useState } from "react";
import { CallData, RpcProvider } from 'starknet';
import { VRF_PROVIDER_ADDRESS } from "../helpers/constants";
import { translateEvent } from "../helpers/events";
import { useDynamicConnector } from "./starknet";

export const DojoContext = createContext()

export const DojoProvider = ({ children }) => {
  const { currentNetworkConfig } = useDynamicConnector();
  const { account, address, isConnecting } = useAccount()
  const { connect, connector, connectors } = useConnect();
  const { enqueueSnackbar } = useSnackbar()

  const [userName, setUserName] = useState()
  const [customName, setCustomName] = useState(localStorage.getItem("customName"))

  let cartridge = connectors.find(conn => conn.id === "controller")
  let provider = new RpcProvider({ nodeUrl: currentNetworkConfig.rpcUrl });

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
      let contractAddress = getContractByName(currentNetworkConfig.manifest, currentNetworkConfig.namespace, txs[txs.length - 1].contractName)?.address

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
      const tx = await account.execute(txs);
      await new Promise(resolve => setTimeout(resolve, 1000));
      const receipt = await account.waitForTransaction(tx.transaction_hash, { retryInterval: 500 })

      if (receipt.execution_status === "REVERTED") {
        console.log('contract error', receipt)
        return
      }

      const translatedEvents = receipt.events.map(event => translateEvent(event, currentNetworkConfig.manifest))
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
        network: currentNetworkConfig.chainId,
        userName,
        customName,
        playerName: customName || userName || "None",
        executeTx,
        setCustomName,
      }}
    >
      {children}
    </DojoContext.Provider>
  );
};