import { Blockie } from "./";
import { Button, Input } from "antd";
// import { Box, Textarea, HStack, Text, Tag, TagLabel, Spacer, TagCloseButton, Wrap, Spinner } from "@chakra-ui/react";
import React, { useState, useEffect } from "react";
// import { useColorModeValue } from "@chakra-ui/color-mode";

// probably we need to change value={toAddress} to address={toAddress}
const { TextArea } = Input;
/*
  ~ What it does? ~
  Displays an address input with QR scan option
  ~ How can I use? ~
  <MultiAddressInput
    // autoFocus
    ensProvider={mainnetProvider}
    placeholder="Enter address"
    value={toAddress}
    onChange={setToAddress}
  />
  ~ Features ~
  - Provide ensProvider={mainnetProvider} and your address will be replaced by ENS name
              (ex. "0xa870" => "user.eth") or you can enter directly ENS name instead of address
  - Provide placeholder="Enter address" value for the input
  - Value of the address input is stored in value={toAddress}
  - Control input change by onChange={setToAddress}
                          or onChange={address => { setToAddress(address);}}
*/

export default function MultiAddressInput(props) {
  const { ensProvider, value, onChange } = props;
  const [isLoading, setIsLoading] = useState(false);

  const addressBadge = d => {
    return (
      <div key={d.input}>
        {/* <HStack spacing={4}> */}
          <div size="md" key="md" borderRadius="full" variant="solid">
            <div> 
              <Blockie address={d.address} size={5} scale={3} />
            </div>
            <span color={d.isValid ? "default" : "red.300"}>{d.input}</span>
            <Button
              onClick={e => {
                onChange(value.filter(obj => obj.input !== d.input));
              }}
            />
          </div>
        {/* </HStack> */}
      </div>
    );
  };

  const handleChange = e => {
    const lastInput = e.target.value[e.target.value.length - 1];
    if (lastInput === "," || lastInput === "\n") {
        const splitInput = e.currentTarget.value
          .split(/[ ,\n]+/)
          .filter(c => c !== "")
          .map(async uin => {
            // Data model
            let val = { input: uin, isValid: null, address: null, ens: null };
            try {
              if (uin.endsWith(".eth") || uin.endsWith(".xyz")) {
                val.address = await ensProvider.resolveName(uin);
                val.ens = uin;
              } else {
                val.ens = await ensProvider.lookupAddress(uin);
                val.address = uin;
              }
              val.isValid = true;
            } catch {
              val.isValid = false;
              console.log("Bad Address: " + uin);
            }
            return val;
          });
        setIsLoading(true);
        Promise.all(splitInput)
          .then(d => {
            onChange([...value, ...d]);
          })
          .finally(_ => setIsLoading(false));
        e.target.value = "";
    }
  };

  return (
    <div >
      <div>{value && value.map(addressBadge)}</div>
      <TextArea
        resize="none"
        variant="unstyled"
        size="lg"
        placeholder={props.placeholder}
        onChange={handleChange}
      />
      <div>
        {/* <Spacer /> */} &nbsp;
        {/* {isLoading ? <Spinner size="sm" /> : <Text color="gray">{`Count: ${value.length}`}</Text>} */}
      </div>
    </div>
  );
}
