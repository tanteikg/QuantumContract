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
	console.log(desc," returned ",res1, " binary ",BigInt(res1).toString(2));

	desc = "Long 2 qubits"
	algo = "HH,IX,XI,CN,HH,XX,NC."
	numQubits = 2;
	res1 = await qContract.runQScript(numQubits,algo);
	console.log(desc," returned ",res1, " binary ",BigInt(res1).toString(2));

	desc = "GHZ state"
	algo = "HII,CNI,ICN.";
	numQubits = 3;
	res1 = await qContract.runQScript(numQubits,algo);
	console.log(desc," returned ",res1, " binary ",BigInt(res1).toString(2));
/*
	desc = "Simon's algorithm for s=11"
	algo = "HHII,CINI,CIIN,ICNI,ICIN,IImm,HHII,mmII."
	numQubits = 4;
	res1 = await qContract.runQScript(numQubits,algo);
	console.log(desc," returned ",res1, " binary ",BigInt(res1).toString(2));
*/
	desc = "Simon's algorithm in 2 parts"
	algo1 = "HHII,CINI,CIIN,ICNI"
	algo2 = "ICIN,IImm,HHII,mmII."
	numQubits = 4;
	var res2 = await qContract.beginQScript(numQubits);
	await res2.wait();
	res2 = await qContract.contQScript(algo1);
	await res2.wait();
	res2 = await qContract.contQScript(algo2);
	await res2.wait();
	res1 = await qContract.readStateQubits();
	console.log(desc," returned ",res1, " binary ",BigInt(res1).toString(2));

	desc = "Grover 2 qubit"
	algo = "HHI,IIX,IIH,III,CCN,III,IIH,IIX,HHI,XXI,IHI,CNI,IHI,XXI,HHI."
	
	algo1 = "HHI,IIX"
	algo2 = "IIH,III,CCN,III"
	algo3 = "IIH,IIX,HHI,XXI"
	algo4 = "IHI,CNI,IHI,XXI"
	algo5 = "HHI."

	numQubits = 3;

	var res2 = await qContract.beginQScript(numQubits);
	await res2.wait();
	res2 = await qContract.contQScript(algo1);
	await res2.wait();
	res2 = await qContract.contQScript(algo2);
	await res2.wait();
	res2 = await qContract.contQScript(algo3);
	await res2.wait();
	res2 = await qContract.contQScript(algo4);
	await res2.wait();
	res2 = await qContract.contQScript(algo5);
	await res2.wait();
	res1 = await qContract.readStateQubits();
	console.log(desc," returned ",res1, " binary ",BigInt(res1).toString(2));

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
