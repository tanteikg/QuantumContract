const main = async () => 
{
	const [owner, randomPerson] = await hre.ethers.getSigners();
	const quantumContractFactory = await hre.ethers.getContractFactory("QuantumContract");
	const qContract = await quantumContractFactory.deploy();
	await qContract.deployed();
	console.log("Contract deployed to:", qContract.address);
	console.log("Contract deployed by:",owner.address);

	var res1;
	var numQubits;
	var algo;
	var desc;

	desc = "Bell state"
	algo = "HI,CN.";
	numQubits = 2;
	res1 = await qContract.runQScript(numQubits,algo);
	console.log(algo," returned ",res1, " binary ",BigInt(res1).toString(2));

	res1 = await qContract.runQScript(numQubits,algo);
	console.log(algo," returned ",res1, " binary ",BigInt(res1).toString(2));

	desc = "Long 2 qubits"
	algo = "HH,IX,XI,CN,HH,XX,NC."
	numQubits = 2;
	res1 = await qContract.runQScript(numQubits,algo);
	console.log(algo," returned ",res1, " binary ",BigInt(res1).toString(2));

	desc = "GHZ state"
	algo = "HII,CNI,ICN.";
	numQubits = 3;
	res1 = await qContract.runQScript(numQubits,algo);
	console.log(algo," returned ",res1, " binary ",BigInt(res1).toString(2));

	desc = "Grover 2 qubit"
	algo = "HHI,IIX,IIH,III,CCN,III,IIH,IIX,HHI,XXI,IHI,CNI,IHI,XXI,HHI."

	desc = "Simon's algorithm for s=11"
	algo = "HHII,CINI,CIIN,ICNI,ICIN,IImm,HHII,mmII."
	numQubits = 4;
	res1 = await qContract.runQScript(numQubits,algo);
	console.log(algo," returned ",res1, " binary ",BigInt(res1).toString(2));

};

const runMain = async () => 
{
	try 
	{
		await main();
		process.exit(0); // exit Node process without error
	} catch (error) 
	{
		console.log(error);
		process.exit(1); // exit Node process while indicating 'Uncaught Fatal Exception' error
	}
  // Read more about Node exit ('process.exit(num)') status codes here: https://stackoverflow.com/a/47163396/7974948
};

runMain();
