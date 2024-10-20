To see the implementation of the front end (with api routes using next.js), and also Sign and Dynamic implementations, go to: https://github.com/Quark-Finance/frontend

Also, our live demo: https://quark-finance.vercel.app/


Quark is an Omnichain Asset Management Protocol, leveraging LayerZero and Unichain to bring universal liquidity to the world. Our core product are the QuarkVaults, our solution to bring Revolutionize asset management. 

QuarkVaults are omnichain vaults that enable the manager to operate in Defi protocols across many chains, leveraing all kinds of yields available. However, in order to have alignment of interests with depositors (investors), we created **Managemente Policies** and **Deposit Policies.** These smart contracts exists to ensure users that the manager will have to be compliant with the rules.

Two examples of policies created by us are Hyperdrive Policy and StoryPolicy. Through that policies, the manager of a vault created with one of them will only be able to invest in Hyperdrive protocol (on Sepolia Testnet), making long or short positions or buy 

This archicteture is fully modular in the sense that anyone is able to create their own policy (following our interfaces) and create a vault that is regulated by them. After that, users are able to deposit funds (stablecoins) in the vault, allowing the manager to invest that money in the best strategies possible (following the policies).


Deployed Contracts:

  -------- Hub Chain DEPLOYMENT --------  Unchain
  
  Chain Id:  1301
  
  currency address:  0x68A4AC5F5942744BCbd51482F9b81e9FA3408139
  
  Owner address:  0x000ef5F21dC574226A06C76AAE7060642A30eB74
  
  Endpoint Hub Chain address:  0xb8815f3f882614048CbE201a67eF9c6F10fe5035
  
  Factory address:  0x9F0a79c5A1Fb5f7E2221Ddda85362f97FF847F66
  

  -------- Spoke Chain  DEPLOYMENT -------- Sepolia
  
  Chain Id:  11155111
  
  Registry address:  0xc8db794088542F878a734c4f23E22b04F498B80F
  
