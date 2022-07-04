import { Button, Card, Col, Space, Spin, Input, List, Menu, Row, Divider } from "antd";
import "antd/dist/antd.css";
import { useContractReader } from "eth-hooks";
import React, { useState, useEffect } from "react";
import { useHistory } from "react-router-dom";
const { ethers } = require("ethers");


const Dashboard = ({ address, mainnetProvider, yourCollectibles, tx, readContracts, writeContracts, targetNetwork }) => {
  const routeHistory = useHistory();
  const [isLoading, setIsLoading] = useState(false);
  const [nftData, setNftData] = useState({});
  const [levelLockAddress, setLevelLockAddress] = useState();
//   const [nftLevel, setNftLevel] = useState();
  const [levelUpAddress, setLevelUpAddress] = useState();
  const [levelingUp, setLevelingUp] = useState();
  const [tokenId, setTokenId] = useState();
  const [tokenToLoadId, setTokenToLoadId] = useState();
  const [minTargetLevel, setMinTargetLevel] = useState();
  const costToLevelUp = "0.005";
  const { Meta } = Card;
 
  const loadNFTData = async () => {
    try {
        let nftData;
        let nftLevel;
        const _level = await readContracts.DreadGang.getLevel(address, tokenToLoadId);
        if (_level) {
            nftLevel = _level.toNumber();
            if (yourCollectibles && yourCollectibles.length) {
                for (let i = 0; i < yourCollectibles.length; i++) {
                    let id = yourCollectibles[i].id.toNumber();
                    if (id == tokenToLoadId) {
                        nftData = { ...yourCollectibles[i], nftLevel };
                    }
                }
            }
        }
        setNftData(nftData);
    } catch (e) {
        console.log(e);
    }
  }


  const nftPreview = (
      <>
        <Row>
          <Col>    
            <div style={{ padding: 8, marginTop: 32, width: 450, margin: "auto" }}>
              <Card title="Street Cred">
                <div style={{ padding: 8, display: "flex" }}>
                <Input
                    style={{ textAlign: "center", marginBottom: 15 }}
                    placeholder={"Enter token Id"}
                    type="number"
                    value={tokenToLoadId}
                    onChange={e => {
                        const newValue = e.target.value;
                        setTokenToLoadId(newValue);
                    }}
                />
                <Button
                    type={"danger"}
                    loading={isLoading}
                    onClick={async () => {
                        setIsLoading(true);
                        loadNFTData();
                        setIsLoading(false);
                    }}
                    disabled={isLoading}
                >
                    Load
                </Button>
                </div>
                <div style={{ padding: 8, display: "flex", justifyContent: "center" }}>
                  {nftData ? (
                    <Card
                      hoverable
                      style={{
                        width: 240,
                      }}
                      cover={<img alt="NFT Info" src={nftData ? nftData.image : "https://os.alipayobjects.com/rmsportal/QBnOOoLaAfKPirc.png"} />}
                    >
                      <Meta title={nftData && nftData.name ? nftData.name : "DreadGang #1"} description={nftData && nftData.nftLevel >= 0 ? `Level: ${nftData.nftLevel}` : <Spin size="small" />} />
                    </Card>) : (
                    <Space size="middle">
                        <Spin />
                    </Space>
                  )}
                </div>
              </Card>
            </div>
          </Col>
        </Row>
      </>
  );

  const createLevel = (
    <>
        <div style={{ padding: 8, marginTop: 32, width: 300, margin: "auto" }}>
            <Card title="Create level">
                <div style={{ padding: 8 }}>
                    <Input
                      style={{ textAlign: "center", marginBottom: 15 }}
                      placeholder={"Lock address"}
                      value={levelLockAddress}
                      onChange={e => {
                        const newValue = e.target.value;
                        setLevelLockAddress(newValue);
                      }}
                    />
                    <Input
                      style={{ textAlign: "center" }}
                      placeholder={"Minimum target level"}
                      value={minTargetLevel}
                      onChange={e => {
                        const newValue = e.target.value;
                        setMinTargetLevel(newValue);
                      }}
                    />
                </div>
                <div style={{ padding: 8 }}>
                <Button
                    type={"danger"}
                    loading={false}
                    onClick={async () => {
                        setLevelingUp(true);
                        await tx(writeContracts.DreadGang.createLevelUpLock(levelLockAddress, minTargetLevel, { value: ethers.utils.parseEther(costToLevelUp) }));
                        setLevelingUp(false);
                    }}
                    disabled={false}
                >
                    Create New Level
                </Button>
                </div>
            </Card>
        </div>
    </>
  );
    
    const levelUp = (
        <>

            <div style={{ padding: 8, marginTop: 32, width: 300, margin: "auto" }}>
                <Card title="Level Up">
                    <div style={{ padding: 8 }}>
                
                        <Input
                            style={{ textAlign: "center", marginBottom: 15 }}
                            placeholder={"Level lock address"}
                            value={levelUpAddress}
                            onChange={e => {
                              const newValue = e.target.value;
                              setLevelUpAddress(newValue);
                            }}
                        />
            
                        <Input
                            style={{ textAlign: "center" }}
                            placeholder={"Token Id"}
                            value={tokenId}
                            onChange={e => {
                                const newValue = e.target.value;
                                console.log("New lv", newValue);
                                setTokenId(newValue);
                            }}
                        />
                    </div>
                    
                    <div style={{ padding: 8 }}>
                        <Button
                            type={"primary"}
                            loading={levelingUp}
                            onClick={async () => {
                                setLevelingUp(true);
                                await tx(writeContracts.DreadGang.levelUp(levelUpAddress, tokenId, { value: ethers.utils.parseEther(costToLevelUp)}));
                                setLevelingUp(false);
                            }}
                            disabled={false}
                        >
                            Level Up
                        </Button>
                    </div>
                </Card>
            </div> 

      </>
    );

  return (
    <>
      <Row>
        <Col>
            {nftPreview}
            <Divider />
            {createLevel}   
            <Divider />
            {levelUp}    
        </Col>      
      </Row>
    </>
  );
};

export default Dashboard;
