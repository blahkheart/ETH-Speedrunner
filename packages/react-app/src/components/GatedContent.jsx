import { Button, Card, Col, Input, Row, DatePicker, Select, Space, TimePicker } from "antd";
import React, { useState, useEffect } from "react";
import { useHistory } from "react-router-dom";
import ContentPaywall from "./ContentPaywall";
// const ethers = require("ethers");
// import { Paywall } from '@unlock-protocol/paywall';


/*
  ~ What it does? ~
  Displays a UI that reveals content based on whether a user is a member or not.
  ~ How can I use? ~
  <GatedContent
    address={address}
    publicLock={publicLock}
    targetNetwork={targetNetwork}
  />

  ~ Features ~
  - address={address} passes active user's address to the component to check whether they are members or not
  - publicLock={publicLock} passes the specific lock to check for the user's membership
  - targetNetwork={targetNetwork} passes the current app network to the <ContentPaywall /> to determine the network to connect to
*/


const GatedContent = ({ publicLock, address, targetNetwork }) => {
  const routeHistory = useHistory();
  const [isLoading, setIsLoading] = useState(false);
    const [hasValidKey, setHasValidKey] = useState(false);
    //
    // const [lockName, setLockName] = useState();
    

    //Check if user has valid key to specified lock
    //If true, display Gatedcontent
    //If false, display previewContent and display paywall

    // const paywallConfig = {
    //     "network": 4,
    //     "pessimistic": true,
    //     "locks": {
    //         "0x5C31a498C3811B67A0c5bd23Ca5be091e2a93eD9": {
    //           "network": 4,
    //           "name": "test"
    //         },
    //         "0x272c91225b590C32C9416e861547dF7D476Fa235": {
    //           "network": 4,
    //           "name": "DreadGang Presale Whitelist"
    //         }
    //     },
    //     "icon": "https://unlock-protocol.com/static/images/svg/unlock-word-mark.svg",
    //     "callToAction": {
    //         "default": "Please join the DG membership!"
    //     },
    //     "referrer": "0xCA7632327567796e51920F6b16373e92c7823854",
    //     "persistentCheckout": false,
    //     "metadataInputs": [
    //         {
    //             "name": "Name",
    //             "type": "text",
    //             "required": true
    //         }
    //     ]
    // };
    // useEffect(() => {
    //     const readyLockData = async () => {
    //         if (publicLock) {
    //             const lockName = await publicLock.name();
    //             setLockName(lockName);
    //        }    
    //     } 
    //     readyLockData();
    // }, [publicLock])

    // const paywallConfig = {
    //     "network": targetNetwork.chainId,
    //     "pessimistic": true,
    //     "locks": {
    //         "0x5C31a498C3811B67A0c5bd23Ca5be091e2a93eD9": {
    //           "network": targetNetwork.chainId,
    //           "name": lockName
    //         },
    //         "0x272c91225b590C32C9416e861547dF7D476Fa235": {
    //           "network": 4,
    //           "name": "DreadGang Presale Whitelist"
    //         }
    //     },
    //     "icon": "https://unlock-protocol.com/static/images/svg/unlock-word-mark.svg",
    //     "callToAction": {
    //         "default": "Please join the DG membership!"
    //     },
    //     "referrer": "0xCA7632327567796e51920F6b16373e92c7823854",
    //     "persistentCheckout": false,
    //     "metadataInputs": [
    //         {
    //             "name": "Name",
    //             "type": "text",
    //             "required": true
    //         }
    //     ]
    // };

// Configure networks to use
    // const networkConfigs = {
    //     1: {
    //         readOnlyProvider: 'HTTP PROVIDER',
    //         locksmithUri: 'https://locksmith.unlock-protocol.com',
    //         unlockAppUrl: 'https://app.unlock-protocol.com'
    //     },
    //     100: {
    //         readOnlyProvider: 'HTTP PROVIDER',
    //         locksmithUri: 'https://locksmith.unlock-protocol.com',
    //         unlockAppUrl: 'https://app.unlock-protocol.com'
    //     },
    //     4: {
    //         readOnlyProvider: targetNetwork.rpcUrl,
    //         locksmithUri: 'https://locksmith.unlock-protocol.com',
    //         unlockAppUrl: 'https://app.unlock-protocol.com'
    //     }
    // etc
    // }

    // const paywall = new Paywall(paywallConfig, networkConfigs);
    
    // console.log("PAYWALL", paywall);
    
    
  useEffect(() => {
    const isMember = async () => {
      if (publicLock) {
        const hasKey = await publicLock.getHasValidKey(address);
        setHasValidKey(hasKey);
      }
    }
    isMember();
  }, [address, publicLock]);

  const previewContent = (
    <>
      <div style={{ padding: 8, marginTop: 32, maxWidth: 592, margin: "auto" }}>
        <Card title="Preview Content">
          <div style={{ padding: 8 }}>
            Lorem ipsum dolor, sit amet consectetur adipisicing elit.
            In consectetur molestiae est perferendis voluptas suscipit
            neque quis facilis officia esse?
            Lorem ipsum dolor sit amet consectetur adipisicing elit.
            Velit omnis reprehenderit illum voluptatibus fuga sint tenetur
            debitis nisi quos. Placeat quos alias harum accusantium soluta,
            fugiat error nemo, illo dicta illum labore hic aliquid aspernatur?
            <ContentPaywall
              shape={"round"}
              size={"large"}
              displayText={"Become a member to view full content"}
              targetNetwork={targetNetwork}
              publicLock={publicLock}
            />
          </div>
        </Card>
      </div>
    </>
  );

  const gatedContent = (
    <>
      <div style={{ padding: 8, marginTop: 32, maxWidth: 592, margin: "auto" }}>
          <Card title="Gated Content">
            <div style={{ padding: 8 }}>
              YOU NOW HAVE ACCESS TO THE GATED CONTENT
            </div>
          </Card>
      </div>
    </>
  );

  return (
    <>
      <Row>
        <Col span={24}>
          { hasValidKey && hasValidKey !== false
            ? gatedContent
            : previewContent
          }
        </Col>
      </Row>
    </>
  );
};

export default GatedContent;
