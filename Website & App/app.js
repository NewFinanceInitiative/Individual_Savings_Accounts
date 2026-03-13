// Import your contract ABI
const contractABI = [{"inputs":[],"stateMutability":"nonpayable","type":"constructor"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"user","type":"address"},{"indexed":false,"internalType":"address","name":"isaAddress","type":"address"}],"name":"ISACreated","type":"event"},{"inputs":[{"internalType":"uint256","name":"_locking_period","type":"uint256"},{"internalType":"address","name":"_newOwner","type":"address"}],"name":"createISA","outputs":[],"stateMutability":"payable","type":"function"},{"inputs":[{"internalType":"uint256","name":"","type":"uint256"}],"name":"deployedISAs","outputs":[{"internalType":"address","name":"","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"getAllISAs","outputs":[{"internalType":"address[]","name":"","type":"address[]"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"user","type":"address"}],"name":"getUserISAs","outputs":[{"internalType":"address[]","name":"","type":"address[]"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"owner","outputs":[{"internalType":"address","name":"","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"","type":"address"},{"internalType":"uint256","name":"","type":"uint256"}],"name":"userISAs","outputs":[{"internalType":"address","name":"","type":"address"}],"stateMutability":"view","type":"function"}];
const contractAddress = '0x62ec294C176770e4b8CcCbC6E0f8cb2e5B6109E4';

let web3;
let contract;
let userAccount;

// Connect to MetaMask
document.getElementById('connectWallet').addEventListener('click', async () => {
    if (window.ethereum) {
        web3 = new Web3(window.ethereum);
        try {
            await window.ethereum.request({ method: 'eth_requestAccounts' });
            const accounts = await web3.eth.getAccounts();
            userAccount = accounts[0];
            alert(`Wallet connected: ${userAccount}`);
            contract = new web3.eth.Contract(contractABI, contractAddress);
        } catch (error) {
            console.error('User denied wallet connection:', error);
        }
    } else {
        alert('Please install MetaMask to use this feature.');
    }
});

// Create Set Time ISA
document.getElementById('createSetTimeISA').addEventListener('click', async () => {
    if (!contract) {
        alert('Please connect your wallet first.');
        return;
    }

    try {

         let _locking_Period = prompt("Enter locking period:");
         let _owner = prompt("Enter owner address:");

        await contract.methods.createISA(_locking_Period, _owner).send({ from: userAccount, value: web3.utils.toWei('0.0001', 'ether') });
        alert('ISA successfully created!');
        console.log(_locking_Period, _owner);
    } catch (error) {
        console.error('Error creating ISA:', error);
        alert('Failed to create ISA.');
    }
});

// Get ISA Balance
document.getElementById('getISABalance').addEventListener('click', async () => {
    if (!contract) {
        alert('Please connect your wallet first.');
        return;
    }

    try {
        const deployedISAs = await contract.methods.userISAs(userAccount).call();
        if (deployedISAs.length == 0) {
            document.getElementById('balanceOutput').innerText = 'No ISAs found for this user.';
            return;
        }

        const isaAddress = deployedISAs[0];
        const isaContract = new web3.eth.Contract(contractABI, isaAddress);
        const balance = await isaContract.methods.GetBalance().call();
        document.getElementById('balanceOutput').innerText = `ISA Balance: ${web3.utils.fromWei(balance, 'ether')} ETH`;
    } catch (error) {
        console.error('Error fetching balance:', error);
        alert('Failed to get ISA balance.');
    }
});