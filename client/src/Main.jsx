import { createRoot } from "react-dom/client";

import App from "./App";

// Dojo related imports
import { createDojoConfig } from "@dojoengine/core";
import { init } from "@dojoengine/sdk";
import { DojoSdkProvider } from "@dojoengine/sdk/react";
import { useEffect, useState } from "react";
import { MetagameProvider } from "./contexts/metagame";
import {
  DynamicConnectorProvider,
  useDynamicConnector,
} from "./contexts/starknet";
import "./index.css";

function DojoApp() {
  const { currentNetworkConfig } = useDynamicConnector();
  const [sdk, setSdk] = useState(null);

  useEffect(() => {
    async function initializeSdk() {
      try {
        const initializedSdk = await init({
          client: {
            toriiUrl: currentNetworkConfig.toriiUrl,
            worldAddress: currentNetworkConfig.manifest.world.address,
          },
          domain: {
            name: "Dark Shuffle",
            version: "1.0",
            chainId: currentNetworkConfig.chainId,
            revision: "1",
          },
        });
        setSdk(initializedSdk);
      } catch (error) {
        console.error("Failed to initialize SDK:", error);
      }
    }

    if (currentNetworkConfig) {
      initializeSdk();
    }
  }, [currentNetworkConfig]);

  return (
    <DojoSdkProvider
      sdk={sdk}
      dojoConfig={createDojoConfig(currentNetworkConfig)}
      clientFn={() => { }}
    >
      <MetagameProvider>
        <App />
      </MetagameProvider>
    </DojoSdkProvider>
  );
}

async function main() {
  createRoot(document.getElementById("root")).render(
    <DynamicConnectorProvider>
      <DojoApp />
    </DynamicConnectorProvider>
  );
}

main().catch((error) => {
  console.error("Failed to initialize the application:", error);
});
