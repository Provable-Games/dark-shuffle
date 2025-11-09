import {
  initMetagame,
  MetagameProvider as MetagameSDKProvider,
} from "metagame-sdk";
import { useEffect, useState } from "react";
import { useDynamicConnector } from "./starknet";

export const MetagameProvider = ({ children }) => {
  const [metagameClient, setMetagameClient] = useState(undefined);
  const { currentNetworkConfig } = useDynamicConnector();

  useEffect(() => {
    if (!currentNetworkConfig) {
      setMetagameClient(undefined);
      return;
    }

    // Initialize Metagame SDK
    initMetagame({
      toriiUrl: currentNetworkConfig.toriiUrl,
      worldAddress: currentNetworkConfig.manifest.world.address,
    })
      .then(setMetagameClient)
      .catch((error) => {
        console.error(
          `Failed to initialize Metagame SDK for chain ${currentNetworkConfig.chainId}:`,
          error
        );
        setMetagameClient(undefined);
      });
  }, [currentNetworkConfig]);

  if (!metagameClient) {
    return (
      <div className="flex items-center justify-center min-h-screen">
        <div className="text-center">
          <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-purple-600 mx-auto"></div>
          <p className="mt-2 text-gray-600">Initializing Metagame SDK...</p>
        </div>
      </div>
    );
  }

  return (
    <MetagameSDKProvider metagameClient={metagameClient}>
      {children}
    </MetagameSDKProvider>
  );
};
