import React, { useEffect, useState } from "react";
import { Button, Spin } from "antd";
// import { Button } from "antd";
import { useParams, useHistory } from "react-router-dom";
import { useUnlockState } from "../hooks"; 
const { ethers } = require("ethers");

export default function Level({ abis, userSigner, address, dreadGangAddress }) {
  const [name, setName] = useState();
  const [maxKeys, setMaxKeys] = useState();
  const [numberOfOwners, setNumberOfOwners] = useState();
  const [isManager, setIsManager] = useState();
  const [isLoading, setIsLoading] = useState();
  const [isDreadGangManager, setIsDreadGangManager] = useState();
  // const [keyGranterRole, setKeyGranterRole] = useState();
  // const [lockManagerRole, setLockManagerRole] = useState();

  let history = useHistory();
  let { id } = useParams();
  const publicLock = new ethers.Contract(id, abis.PublicLockV10.abi, userSigner);
  const hasValidKey = useUnlockState(publicLock, address);

  useEffect(() => {
    setIsLoading(true);
    let _name, _maxKeys, _numberOfOwners, _isManager, _isDreadGangLockManager; 
    const loadLevelData = async () => {
      _name = await publicLock.name();
      _maxKeys = await publicLock.maxNumberOfKeys();
      _numberOfOwners = await publicLock.totalSupply();
      _isManager = await publicLock.isLockManager(address);
      _isDreadGangLockManager = await publicLock.isLockManager(dreadGangAddress);

      setName(_name);
      setMaxKeys(_maxKeys.toNumber());
      setNumberOfOwners(_numberOfOwners.toNumber());
      setIsManager(_isManager);
      // setHasValidKey(_hasValidKey);
      console.log("ooo", _isDreadGangLockManager);
      setIsDreadGangManager(_isDreadGangLockManager);
      setIsLoading(false);
    };
    loadLevelData();
  }, [id, numberOfOwners, address]);
  console.log(publicLock);

  // useEffect(() => {
  //   const getRoles = async () => {
  //     const KEY_GRANTER_ROLE = await publicLock.KEY_GRANTER_ROLE();
  //     const LOCK_MANAGER_ROLE = await publicLock.LOCK_MANAGER_ROLE();
  //     setKeyGranterRole(KEY_GRANTER_ROLE);
  //     setLockManagerRole(LOCK_MANAGER_ROLE);
  //   };
  //   getRoles();
  // }, []);

  const grantKeys = async (receivers, exp, managers) => {
    try {
      const tx = await publicLock.grantKeys(receivers, exp, managers);
      console.log(tx);
    } catch (e) {
      console.log(e);
    }
  };

  const addLockManager = async () => {
    try {
      if (dreadGangAddress) {
        const tx = await publicLock.addLockManager(dreadGangAddress);
        console.log(tx);
      }
    } catch (e) {
      console.log(e);
    }
  };
  // console.log("DG.MM", isDreadGangManager);
  
    // useEffect(() => {
    //     (() => {
            // const tokenOfOwnerByIndex = async () => {
            //     let x = [];
            //     let y = await publicLock.balanceOf(address);
            //     for (let i = 0; i < y.toNumber(); i++){
            //         x[i] = await publicLock.tokenOfOwnerByIndex(address, i);

            //         return x[i].toNumber();
            //     }
            //     // return x;
            // }
            // tokenOfOwnerByIndex();
            // console.log("DDD", tokenOfOwnerByIndex());
            
            // const keyExpirationTimestampFor = async () => {
            //     let x = await publicLock.keyExpirationTimestampFor(tokenOfOwnerByIndex());
            //     console.log("XXXX", x.toNumber());
            // }
            // keyExpirationTimestampFor();
    //     })();
    // }, [])

  return (
    isLoading ? <Spin style={{marginTop: 30}}></Spin> :
    <div style={{ width: 600, margin: "auto", marginTop: 32, paddingBottom: 32 }}>
        <Button
          type="link"
          onClick={() => {
            history.push("/levels");
        }}>
          Back
        </Button>
        <h3>{name}</h3>
        <p>Max squad members: { maxKeys}</p>
        <p>Squad members: {numberOfOwners} / {maxKeys}</p>
        <Button
          color="primary"
          disabled={hasValidKey || !isDreadGangManager}
          onClick={() => {
            let addr = [];
            addr.push(address);
            let exp = 24 * 60 * 60; //24 hours
            grantKeys(addr, [exp],[dreadGangAddress])   
          }}
        >{!hasValidKey?"Claim spot": "Key owned"}</Button>
        {
          isDreadGangManager === false && isManager
          ? <Button onClick={addLockManager}>Make DreadGang Manager</Button>
          : ""
        }
    </div>
  );
}
