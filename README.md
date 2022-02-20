# 🏗 scaffold-eth | 🏰 BuidlGuidl

## 🚩 Challenge 1: 🥩 Decentralized Staking App

> 🦸 A superpower of Ethereum is allowing you, the builder, to create a simple set of rules that an adversarial group of players can use to work together. In this challenge, you create a decentralized application where users can coordinate a group funding effort. If the users cooperate, the money is collected in a second smart contract. If they defect, the worst that can happen is everyone gets their money back. The users only have to trust the code.

> 🏦 Build a `Staker.sol` contract that collects **ETH** from numerous addresses using a payable `stake()` function and keeps track of `balances`. After some `deadline` if it has at least some `threshold` of ETH, it sends it to an `ExampleExternalContract` and triggers the `complete()` action sending the full balance. If not enough **ETH** is collected, allow users to `withdraw()`.

> 🎛 Building the frontend to display the information and UI is just as important as writing the contract. The goal is to deploy the contract and the app to allow anyone to stake using your app. Use a `Stake(address,uint256)` event to <List/> all stakes.

> 🏆 The final **deliverable** is deploying a decentralized application to a public blockchain and then `yarn build` and `yarn surge` your app to a public webserver. Share the url in the [Challenge 1 telegram channel](https://t.me/joinchat/E6r91UFt4oMJlt01) to earn a collectible and cred! || Part of the challenge is making the **UI/UX** enjoyable and clean! 🍾


🧫 Everything starts by ✏️ Editing `Staker.sol` in `packages/hardhat/contracts`

---
### Checkpoint 0: 📦 install 📚

Want a fresh cloud environment? Click this to open a gitpod workspace, then skip to Checkpoint 1 after the tasks are complete.

[![Open in Gitpod](https://gitpod.io/button/open-in-gitpod.svg)](https://gitpod.io/#https://github.com/scaffold-eth/scaffold-eth-challenges/tree/challenge-1-decentralized-staking)


```bash

git clone https://github.com/scaffold-eth/scaffold-eth-challenges.git challenge-1-decentralized-staking

cd challenge-1-decentralized-staking

git checkout challenge-1-decentralized-staking

yarn install

```

🔏 Edit your smart contract `Staker.sol` in `packages/hardhat/contracts`

<<<<<<< HEAD
---

### Checkpoint 1: 🔭 Environment 📺

You'll have three terminals up for:

`yarn start` (react app frontend)

`yarn chain` (hardhat backend)

`yarn deploy` (to compile, deploy, and publish your contracts to the frontend)

> 💻 View your frontend at http://localhost:3000/

> 👩‍💻 Rerun `yarn deploy --reset` whenever you want to deploy new contracts to the frontend.

---

### Checkpoint 2: 🥩 Staking 💵

You'll need to track individual `balances` using a mapping:
```solidity
mapping ( address => uint256 ) public balances;
=======
```sh
cd challenge-0-simple-nft
yarn start
>>>>>>> 373aa9d20583bb494de1b7d6bf8ec7db6347d296
```

And also track a constant `threshold` at ```1 ether```
```solidity
uint256 public constant threshold = 1 ether;
```

<<<<<<< HEAD
> 👩‍💻 Write your `stake()` function and test it with the `Debug Contracts` tab in the frontend

#### 🥅 Goals

- [ ] Do you see the balance of the `Staker` contract go up when you `stake()`?
- [ ] Is your `balance` correctly tracked?
- [ ] Do you see the events in the `Staker UI` tab?


---

### Checkpoint 3: 🔬 State Machine / Timing ⏱

> ⚙️  Think of your smart contract like a *state machine*. First, there is a **stake** period. Then, if you have gathered the `threshold` worth of ETH, there is a **success** state. Or, we go into a **withdraw** state to let users withdraw their funds.

Set a `deadline` of ```block.timestamp + 30 seconds```
```solidity
uint256 public deadline = block.timestamp + 30 seconds;
```

👨‍🏫 Smart contracts can't execute automatically, you always need to have a transaction execute to change state. Because of this, you will need to have an `execute()` function that *anyone* can call, just once, after the `deadline` has expired.

> 👩‍💻 Write your `execute()` function and test it with the `Debug Contracts` tab

If the `address(this).balance` of the contract is over the `threshold` by the `deadline`, you will want to call: ```exampleExternalContract.complete{value: address(this).balance}()```

If the balance is less than the `threshold`, you want to set a `openForWithdraw` bool to `true` and allow users to `withdraw(address payable)` their funds.

(You'll have 30 seconds after deploying until the deadline is reached, you can adjust this in the contract.)

> 👩‍💻 Create a `timeLeft()` function including ```public view returns (uint256)``` that returns how much time is left.

⚠️ Be careful! if `block.timestamp >= deadline` you want to ```return 0;```

⏳ The time will only update if a transaction occurs. You can see the time update by getting funds from the faucet just to trigger a new block.

> 👩‍💻 You can call `yarn deploy --reset` any time you want a fresh contract

#### 🥅 Goals
- [ ] Can you see `timeLeft` counting down in the `Staker UI` tab when you trigger a transaction with the faucet?
- [ ] If you `stake()` enough ETH before the `deadline`, does it call `complete()`?
- [ ] If you don't `stake()` enough can you `withdraw(address payable)` your funds?


---


### Checkpoint 4: 💵 Receive Function / UX 🙎

🎀 To improve the user experience, set your contract up so it accepts ETH sent to it and calls `stake()`. You will use what is called the `receive()` function.

> Use the [receive()](https://docs.soliditylang.org/en/v0.8.9/contracts.html?highlight=receive#receive-ether-function) function in solidity to "catch" ETH sent to the contract and call `stake()` to update `balances`.

---
#### 🥅 Goals
- [ ] If you send ETH directly to the contract address does it update your `balance`?

---

## ⚔️ Side Quests
- [ ] Can execute get called more than once, and is that okay?
- [ ] Can you stake and withdraw freely after the `deadline`, and is that okay?
- [ ] What are other implications of *anyone* being able to withdraw for someone?

---

## 🐸 It's a trap!
- [ ] Make sure funds can't get trapped in the contract! **Try sending funds after you have executed! What happens?**
- [ ] Try to create a [modifier](https://solidity-by-example.org/function-modifier/) called `notCompleted`. It will check that `ExampleExternalContract` is not completed yet. Use it to protect your `execute` and `withdraw` functions.

---

#### ⚠️ Test it!
-  Now is a good time to run `yarn test` to run the automated testing function. It will test that you hit the core checkpoints.  You are looking for all green checkmarks and passing tests!

---

### Checkpoint 5: 🚢 Ship it 🚁

📡 Edit the `defaultNetwork` to [your choice of public EVM networks](https://ethereum.org/en/developers/docs/networks/) in `packages/hardhat/hardhat.config.js`

👩‍🚀 You will want to run `yarn account` to see if you have a **deployer address**

🔐 If you don't have one, run `yarn generate` to create a mnemonic and save it locally for deploying.

⛽️ You will need to send ETH to your **deployer address** with your wallet.

 >  🚀 Run `yarn deploy` to deploy your smart contract to a public network (selected in hardhat.config.js)

---

### Checkpoint 6: 🎚 Frontend 🧘‍♀️

 > 📝 Edit the `targetNetwork` in `App.jsx` (in `packages/react-app/src`) to be the public network where you deployed your smart contract.

> 💻 View your frontend at http://localhost:3000/

 👩‍🎤 Take time to craft your user experience...

 📡 When you are ready to ship the frontend app...

 📦  Run `yarn build` to package up your frontend.
 
 > 📝 If you plan on submitting this challenge, be sure to set your ```deadline``` to at least ```block.timestamp + 72 hours```

💽 Upload your app to surge with `yarn surge` (you could also `yarn s3` or maybe even `yarn ipfs`?)

> 📝 you will use this deploy URL to submit to [SpeedRun](https://speedrunethereum.com).

🚔 Traffic to your url might break the [Infura](https://infura.io/) rate limit, edit your key: `constants.js` in `packages/ract-app/src`.

🎖 Show off your app by pasting the url in the [Challenge 1 telegram channel](https://t.me/joinchat/E6r91UFt4oMJlt01) 🎖

---
### Checkpoint 7: 📜 Contract Verification

Update the api-key in packages/hardhat/package.json file. You can get your key [here](https://etherscan.io/myapikey).

![Screen Shot 2021-11-30 at 10 21 01 AM](https://user-images.githubusercontent.com/9419140/144075208-c50b70aa-345f-4e36-81d6-becaa5f74857.png)

> Now you are ready to run the `yarn verify --network your_network` command to verify your contracts on etherscan 🛰

---

=======
```sh
cd challenge-0-simple-nft
yarn deploy 
```

> You can `yarn deploy --reset` to deploy a new contract any time.

📱 Open http://localhost:3000 to see the app

---

# Checkpoint 1: ⛽️  Gas & Wallets 👛

> ⛽️ You'll need to get some funds from the faucet for gas. 

![image](https://user-images.githubusercontent.com/2653167/142483294-ff4c305c-0f5e-4099-8c7d-11c142cb688c.png)

> 🦊 At first, please **don't** connect MetaMask. If you already connected, please click **logout**:

![image](https://user-images.githubusercontent.com/2653167/142484483-1439d925-8cef-4b1a-a4b2-0f022eebc0f6.png)


> 🔥 We'll use **burner wallets** on localhost...


> 👛 Explore how **burner wallets** work in 🏗 scaffold-eth by opening a new *incognito* window and navigate it to http://localhost:3000. You'll notice it has a new wallet address in the top right. Copy the incognito browsers' address and send localhost test funds to it from your first browser: 

![image](https://user-images.githubusercontent.com/2653167/142483685-d5c6a153-da93-47fa-8caa-a425edba10c8.png)

> 👨🏻‍🚒 When you close the incognito window, the account is gone forever. Burner wallets are great for local development but you'll move to more permanent wallets when you interact with public networks.

---

# Checkpoint 2: 🖨 Minting 

> ✏️ Mint some NFTs!  Click the `MINT NFT` button in the YourCollectables tab.  

![MintNFT](https://user-images.githubusercontent.com/12072395/145692116-bebcb514-e4f0-4492-bd10-11e658abaf75.PNG)


👀 You should see your collectibles start to show up:

![nft3](https://user-images.githubusercontent.com/526558/124386983-48965300-dcb3-11eb-88a7-e88ad6307976.png)

👛 Open an **incognito** window and navigate to http://localhost:3000 

🎟 Transfer an NFT to the incognito window address using the UI:

![nft5](https://user-images.githubusercontent.com/526558/124387008-58ae3280-dcb3-11eb-920d-07b6118f1ab2.png)

👛 Try to mint an NFT from the incognito window. 

> Can you mint an NFT with no funds in this address?  You might need to grab funds from the faucet to pay the gas!

🕵🏻‍♂️ Inspect the `Debug Contracts` tab to figure out what address is the `owner` of `YourCollectible`?

🔏 You can also check out your smart contract `YourCollectible.sol` in `packages/hardhat/contracts`.

💼 Take a quick look at your deploy script `00_deploy_your_contract.js` in `packages/hardhat/deploy`.

📝 If you want to make frontend edits, open `App.jsx` in `packages/react-app/src`.

---

# Checkpoint 3: 💾 Deploy it! 🛰

🛰 Ready to deploy to a public testnet?!?

> Change the `defaultNetwork` in `packages/hardhat/hardhat.config.js` to `rinkeby`

![networkSelect](https://user-images.githubusercontent.com/12072395/146871168-29b3d87a-7d25-4972-9b3c-0ec8c979171b.PNG)

🔐 Generate a **deployer address** with `yarn generate`

![nft7](https://user-images.githubusercontent.com/526558/124387064-7d0a0f00-dcb3-11eb-9d0c-195f93547fb9.png)

👛 View your **deployer address** using `yarn account` 

![nft8](https://user-images.githubusercontent.com/526558/124387068-8004ff80-dcb3-11eb-9d0f-43fba2b3b791.png)

⛽️ Use a faucet like [faucet.paradigm.xyz](https://faucet.paradigm.xyz/) to fund your **deployer address**.

> ⚔️ **Side Quest:** Keep a 🧑‍🎤 [punkwallet.io](https://punkwallet.io/) on your phone's home screen and keep it loaded with testnet eth. 🧙‍♂️ You'll look like a wizard when you can fund your **deployer address** from your phone in seconds. 

🚀 Deploy your NFT smart contract:

```sh
yarn deploy
```

> 💬 Hint: You can set the `defaultNetwork` in `hardhat.config.js` to `Rinkeby` OR you can `yarn deploy --network rinkeby`. 

---

# Checkpoint 4: 🚢 Ship it! 🚁

> ✏️ Edit your frontend `App.jsx` in `packages/react-app/src` to change the `targetNetwork` to `NETWORKS.rinkeby`:

![image](https://user-images.githubusercontent.com/2653167/142491593-a032ebf2-38c7-4d1c-a4c5-5e02485e21b4.png)

You should see the correct network in the frontend (http://localhost:3000):

![nft10](https://user-images.githubusercontent.com/526558/124387099-9a3edd80-dcb3-11eb-9a57-54a7d370589a.png)

🎫 Ready to mint a batch of NFTs for reals?  Use the `MINT NFT` button.

![MintNFT2](https://user-images.githubusercontent.com/12072395/145692572-d61c971d-7452-4218-9c66-d675bb78a9dc.PNG)


📦 Build your frontend:

```sh
yarn build
```

💽 Upload your app to surge:
```sh
yarn surge
```
(You could also `yarn s3` or maybe even `yarn ipfs`?)

⚠️ Run the automated testing function to make sure your app passes

```sh
yarn test
```
![testOutput](https://user-images.githubusercontent.com/12072395/152587433-8314f0f1-5612-44ae-bedb-4b3292976a9f.PNG)

---

# Checkpoint 5: 📜 Contract Verification

Update the `api-key` in `packages/hardhat/package.json` file. You can get your key [here](https://etherscan.io/myapikey).

![Screen Shot 2021-11-30 at 10 21 01 AM](https://user-images.githubusercontent.com/9419140/144075208-c50b70aa-345f-4e36-81d6-becaa5f74857.png)

> Now you are ready to run the `yarn verify --network your_network` command to verify your contracts on etherscan 🛰

---

# Checkpoint 6: 💪 Flex!

> 🎖 Show off your app by pasting the surge url in the [Challenge 0 telegram channel](https://t.me/+Y2vqXZZ_pEFhMGMx) 🎖

---

👩‍❤️‍👨 Share your public url with a friend and ask them for their address to send them a collectible :)

![nft15](https://user-images.githubusercontent.com/526558/124387205-00c3fb80-dcb4-11eb-9e2f-29585e323037.gif)

---

# ⚔️ Side Quests

## 🐟 Open Sea
> Add your contract to OpenSea
> 1. hover over your profile photo in the top right and navigate to `Collections` or go to `https://opensea.io/collections`
> ![my_collections](https://user-images.githubusercontent.com/46639943/150223014-92a2e32d-d2a2-4fd4-ac3b-bd2d0fcb5840.png)
> 2. click the vertical elipsis and select `Import an existing smart contract`
> ![import_contract](https://user-images.githubusercontent.com/46639943/150225448-815a17c1-4ea6-4663-8aff-8f757bebbb54.png)
> 3. select `Live on a testnet`
> ![live_on_testnet](https://user-images.githubusercontent.com/46639943/150229334-038100bb-22e0-4240-a293-c2b88adc1219.png)
> 4. be sure you're on the same network you deployed to and enter your contract address!
> ![contract_address](https://user-images.githubusercontent.com/46639943/150229361-e50e8c57-3918-450f-8bee-29cf42d65b52.png)


(It can take a while before they show up, but here is an example:)
https://testnets.opensea.io/assets/0xc2839329166d3d004aaedb94dde4173651babccf/1

## 🔶 Infura
> You will need to get a key from infura.io and paste it into constants.js in packages/react-app/src:

![nft13](https://user-images.githubusercontent.com/526558/124387174-d83c0180-dcb3-11eb-989e-d58ba15d26db.png)

---

>>>>>>> 373aa9d20583bb494de1b7d6bf8ec7db6347d296
> 🏃 Head to your next challenge [here](https://speedrunethereum.com).

> 💬 Problems, questions, comments on the stack? Post them to the [🏗 scaffold-eth developers chat](https://t.me/joinchat/F7nCRK3kI93PoCOk)
