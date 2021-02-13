/* eslint-disable jsx-a11y/accessible-emoji */

import { Address, Balance } from "../components";
import { Button, Card, DatePicker, Divider, Input, List, Progress, Slider, Spin, Switch, TimePicker } from "antd";
import React, { useState } from "react";
import { formatEther, parseEther } from "@ethersproject/units";

import { SyncOutlined } from '@ant-design/icons';

export default function ExampleUI({purpose, setPurposeEvents, address, mainnetProvider, userProvider, localProvider, yourLocalBalance, price, tx, readContracts, writeContracts }) {

  const [newPurpose, setNewPurpose] = useState("loading...");
  const [vaults, setVaults] = useState([]);
  const [newVaultAmount, setNewVaultAmount] = useState();
  const [newVaultDuration, setNewVaultDuration] = useState();
  
  const fetchVaults = async () => {
    console.log("fetching vaults")
    
    const vaultCountBN = await readContracts.Handcuffs.getVaultCount(address);
    const vaultCount = vaultCountBN.toNumber();

    console.log(vaultCount);

    const newVaults = [];

    for (let i = 0; i < vaultCount; i++) {
      console.log("fetching vault index " + i);
      const newVault = await readContracts.Handcuffs.getVaultInfo(address, i);
      console.log(newVault);
      const end = new Date(0);
      end.setUTCSeconds(newVault[1].toNumber());

      newVaults.push({
        amount: formatEther(newVault[0]),
        unlocked_timestamp: end
      })
    }

    setVaults(newVaults);
  }

  const renderVaultList = () => {
    return vaults.length == 0 ? 
      (<div></div>)
    :
      (
        <table>
        <tr>
          <th style={{padding:16}}>Vault Index</th>
          <th style={{padding:16}}>Amount</th>
          <th style={{padding:16}}>Uncuffed Time</th>
          <th style={{padding:16}}></th>
        </tr>
          {
            vaults.map((vault, i) => {
              return(
                <tr key={i}>
                  <td>{i}</td>
                  <td>{vault.amount}</td>
                  <td>{vault.unlocked_timestamp.toLocaleString()}</td>
                  <td>
                    <Button onClick={()=>{
                      console.log("withdrawing vault ",i);
                      tx( writeContracts.Handcuffs.withdraw(i) );
                      fetchVaults();
                    }}>Withdraw</Button>  
                  </td>
                </tr>
              )
            }
            )
          }
        </table>
      )
  }

  const createVault = () => {
    const durationSeconds = newVaultDuration * 60;
    const valueToSend = parseEther(newVaultAmount);

    tx( writeContracts.Handcuffs.deposit(durationSeconds, {
      value: valueToSend
    }) )

    setNewVaultAmount(null);
    setNewVaultDuration(null);
  }

  return (
    <div>
      {/*
        ⚙️ Here is an example UI that displays and sets the purpose in your smart contract:
      */}
      <div style={{border:"1px solid #cccccc", padding:16, width:400, margin:"auto",marginTop:64}}>
        <h2>Handcuffs</h2>
        
        Your Address:
        <Address
            value={address}
            ensProvider={mainnetProvider}
            fontSize={16}
        />

        <div>Your Balance: {yourLocalBalance?formatEther(yourLocalBalance):"..."}</div>

        <div style={{margin:8}}>
          <Button onClick={()=>{
            fetchVaults()
          }}>{vaults.length == 0 ? "Fetch Vaults" : "Refresh Vaults"}</Button>
        </div>

        <div>
          {renderVaultList()}
        </div>

        <Divider/>

        <div style={{margin:8}}>
          <Input
            placeholder="Amount (ETH)"
            onChange={e => setNewVaultAmount(e.target.value)}
            value={newVaultAmount}
          />
          <Input
            placeholder="Duration (mins)"
            onChange={e => setNewVaultDuration(e.target.value)}
            value={newVaultDuration}
          />
          <Button onClick={()=>{
            console.log("creating new vault")
            createVault()
          }}>Create Vault</Button>
        </div>


        <Divider/>
        <Divider/>
        <Divider/>

        <div style={{margin:8}}>
          <Input onChange={(e)=>{setNewPurpose(e.target.value)}} />
          <Button onClick={()=>{
            console.log("newPurpose",newPurpose)
            /* look how you call setPurpose on your contract: */
            tx( writeContracts.Handcuffs.setPurpose(newPurpose) )
          }}>Set Purpose</Button>
        </div>


        <Divider />

<<<<<<< HEAD
=======
        Your Address:
        <Address
            address={address}
            ensProvider={mainnetProvider}
            fontSize={16}
        />

>>>>>>> ff7ae3989937001f000d28e32191534aeba04ef4
        <Divider />

        ENS Address Example:
        <Address
          address={"0x34aA3F359A9D614239015126635CE7732c18fDF3"} /* this will show as austingriffith.eth */
          ensProvider={mainnetProvider}
          fontSize={16}
        />

        <Divider/>

        {  /* use formatEther to display a BigNumber: */ }
        <h2>Your Balance: {yourLocalBalance?formatEther(yourLocalBalance):"..."}</h2>

        OR

        <Balance
          address={address}
          provider={localProvider}
          price={price}
        />

        <Divider/>


        {  /* use formatEther to display a BigNumber: */ }
        <h2>Your Balance: {yourLocalBalance?formatEther(yourLocalBalance):"..."}</h2>

        <Divider/>



        Your Contract Address:
        <Address
<<<<<<< HEAD
            value={readContracts?readContracts.Handcuffs.address:readContracts}
=======
            address={readContracts?readContracts.YourContract.address:readContracts}
>>>>>>> ff7ae3989937001f000d28e32191534aeba04ef4
            ensProvider={mainnetProvider}
            fontSize={16}
        />

        <Divider />

        <div style={{margin:8}}>
          <Button onClick={()=>{
            /* look how you call setPurpose on your contract: */
            tx( writeContracts.Handcuffs.setPurpose("🍻 Cheers") )
          }}>Set Purpose to "🍻 Cheers"</Button>
        </div>

        <div style={{margin:8}}>
          <Button onClick={()=>{
            /*
              you can also just craft a transaction and send it to the tx() transactor
              here we are sending value straight to the contract's address:
            */
            tx({
              to: writeContracts.Handcuffs.address,
              value: parseEther("0.001")
            });
            /* this should throw an error about "no fallback nor receive function" until you add it */
          }}>Send Value</Button>
        </div>

        <div style={{margin:8}}>
          <Button onClick={()=>{
            /* look how we call setPurpose AND send some value along */
            tx( writeContracts.Handcuffs.setPurpose("💵 Paying for this one!",{
              value: parseEther("0.001")
            }))
            /* this will fail until you make the setPurpose function payable */
          }}>Set Purpose With Value</Button>
        </div>


        <div style={{margin:8}}>
          <Button onClick={()=>{
            /* you can also just craft a transaction and send it to the tx() transactor */
            tx({
              to: writeContracts.Handcuffs.address,
              value: parseEther("0.001"),
              data: writeContracts.Handcuffs.interface.encodeFunctionData("setPurpose(string)",["🤓 Whoa so 1337!"])
            });
            /* this should throw an error about "no fallback nor receive function" until you add it */
          }}>Another Example</Button>
        </div>

      </div>

      {/*
        📑 Maybe display a list of events?
          (uncomment the event and emit line in Handcuffs.sol! )
      */}
      <div style={{ width:600, margin: "auto", marginTop:32, paddingBottom:32 }}>
        <h2>Events:</h2>
        <List
          bordered
          dataSource={setPurposeEvents}
          renderItem={(item) => {
            return (
              <List.Item key={item.blockNumber+"_"+item.sender+"_"+item.purpose}>
                <Address
                    address={item[0]}
                    ensProvider={mainnetProvider}
                    fontSize={16}
                  /> =>
                {item[1]}
              </List.Item>
            )
          }}
        />
      </div>


      <div style={{ width:600, margin: "auto", marginTop:32, paddingBottom:256 }}>

        <Card>

          Check out all the <a href="https://github.com/austintgriffith/scaffold-eth/tree/master/packages/react-app/src/components" target="_blank" rel="noopener noreferrer">📦  components</a>

        </Card>

        <Card style={{marginTop:32}}>

          <div>
            There are tons of generic components included from <a href="https://ant.design/components/overview/" target="_blank" rel="noopener noreferrer">🐜  ant.design</a> too!
          </div>

          <div style={{marginTop:8}}>
            <Button type="primary">
              Buttons
            </Button>
          </div>

          <div style={{marginTop:8}}>
            <SyncOutlined spin />  Icons
          </div>

          <div style={{marginTop:8}}>
            Date Pickers?
            <div style={{marginTop:2}}>
              <DatePicker onChange={()=>{}}/>
            </div>
          </div>

          <div style={{marginTop:32}}>
            <Slider range defaultValue={[20, 50]} onChange={()=>{}}/>
          </div>

          <div style={{marginTop:32}}>
            <Switch defaultChecked onChange={()=>{}} />
          </div>

          <div style={{marginTop:32}}>
            <Progress percent={50} status="active" />
          </div>

          <div style={{marginTop:32}}>
            <Spin />
          </div>


        </Card>




      </div>


    </div>
  );
}
