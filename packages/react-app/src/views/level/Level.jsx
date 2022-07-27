import React, { useEffect, useState } from "react";
import { Button, Card, Col, Space, Spin, Input, Row, Divider } from "antd";
// import { Button, Box, Center, Menu, MenuButton, MenuList, MenuItem, Text, Tooltip, Spinner } from "@chakra-ui/react";
// import { ArrowBackIcon, ChevronDownIcon, QuestionOutlineIcon } from "@chakra-ui/icons";
import { useParams, useHistory } from "react-router-dom";
// import { VoteTable, ViewTable, ReceiptsTable, Distribute, Metadata } from "./components";

export default function Level({
  address,
  mainnetProvider,
  localProvider,
  userSigner,
  targetNetwork,
  tx,
  readContracts,
  writeContracts,
  yourLocalBalance,
}) {
  const routeHistory = useHistory();
  let { id } = useParams();

//   const [partyData, setPartyData] = useState({});
//   const [accountVoteData, setAccountVoteData] = useState(null);
//   const [loading, setLoading] = useState(true);
//   const [showDebug, setShowDebug] = useState(false);
//   const [canVote, setCanVote] = useState(false);
//   const [isParticipant, setIsParticipant] = useState(false);
//   const [distribution, setDistribution] = useState();
//   const [strategy, setStrategy] = useState("quadratic");
//   const [isPaid, setIsPaid] = useState(true);
//   const [amountToDistribute, setAmountToDistribute] = useState(0);
    
    useEffect(() => {
        // setLoading(true);
        (async () => {
    //   const res = await fetch(`${process.env.REACT_APP_API_URL}/party/${id}`);
    //   const party = await res.json();
    //   const submitted = party.ballots.filter(b => b.data.ballot.address.toLowerCase() === address);
    //   const participating = party.participants.map(adr => adr.toLowerCase()).includes(address);
    //   setAccountVoteData(submitted);
    //   setCanVote(submitted.length === 0 && participating);
    //   setIsPaid(party.receipts.length > 0);
    //   setIsParticipant(participating);
    //   setPartyData(party);
    //   setLoading(false);
        try {
            let nftData;
            let nftLevel;
            // const _level = await readContracts.DreadGang.publicLock.maxNumberOfKeys();
            let _level;
            if (_level) {
                nftLevel = _level.toNumber();
                console.log(nftLevel);
            }
            setNftData(nftData);
        } catch (e) {
          console.log(e);
        }
    })();
  }, [address]);

 

    return (
      <Row>
        <Col>
          <Button
            size="lg"
            onClick={() => {
              routeHistory.push("/");
            }}
          >
            Back
          </Button>
          <Card>
            Lorem ipsum dolor sit amet consectetur adipisicing elit.
            Quam explicabo quae amet, temporibus eveniet corporis ea
            fugiat rerum accusamus ipsam odio totam blanditiis omnis
            maxime ipsum ab impedit enim perspiciatis.
          </Card>
        </Col>
      </Row>
    );
}
