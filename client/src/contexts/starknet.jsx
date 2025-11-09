import {
  getNetworkConfig
} from "../helpers/networkConfig";
import { stringToFelt } from "../helpers/utilities";
import ControllerConnector from "@cartridge/connector/controller";
import { mainnet, sepolia } from "@starknet-react/chains";
import { argent, braavos, jsonRpcProvider, StarknetConfig, useInjectedConnectors, voyager } from "@starknet-react/core";
import {
  createContext,
  useCallback,
  useContext,
  useState
} from "react";

const DynamicConnectorContext = createContext(
  null
);

const controllerConfig = getNetworkConfig(import.meta.env.VITE_PUBLIC_CHAIN);
const cartridgeController =
  typeof window !== "undefined"
    ? new ControllerConnector({
      policies: controllerConfig.policies,
      namespace: controllerConfig.namespace,
      slot: controllerConfig.slot,
      preset: controllerConfig.preset,
      chains: controllerConfig.chains,
      defaultChainId: stringToFelt(controllerConfig.chainId).toString(),
      tokens: {
        erc20: []
      },
    })
    : null;

export function DynamicConnectorProvider({ children }) {
  const getInitialNetwork = () => {
    return getNetworkConfig(import.meta.env.VITE_PUBLIC_CHAIN);
  };

  const [currentNetworkConfig, setCurrentNetworkConfig] =
    useState(getInitialNetwork);

  const { connectors } = useInjectedConnectors({
    recommended: [
      argent(),
      braavos(),
    ],
    includeRecommended: "onlyIfNoConnectors",
  });

  const rpc = useCallback(() => {
    return { nodeUrl: controllerConfig.chains[0].rpcUrl };
  }, []);

  return (
    <DynamicConnectorContext.Provider
      value={{
        setCurrentNetworkConfig,
        currentNetworkConfig,
      }}
    >
      <StarknetConfig
        chains={[mainnet, sepolia]}
        provider={jsonRpcProvider({ rpc })}
        connectors={[...connectors, cartridgeController]}
        explorer={voyager}
        autoConnect
      >
        {children}
      </StarknetConfig>
    </DynamicConnectorContext.Provider>
  );
}

export function useDynamicConnector() {
  const context = useContext(DynamicConnectorContext);
  if (!context) {
    throw new Error(
      "useDynamicConnector must be used within a DynamicConnectorProvider"
    );
  }
  return context;
}
