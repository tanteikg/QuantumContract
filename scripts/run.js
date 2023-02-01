const main = async () => 
{
	const [owner, randomPerson] = await hre.ethers.getSigners();
	const quantumContractFactory = await hre.ethers.getContractFactory("QuantumContract");
	const qContract = await quantumContractFactory.deploy();
	await qContract.deployed();
	console.log("Contract deployed to:", qContract.address);
	console.log("Contract deployed by:",owner.address);

	const res1 = await qContract.runQScript(2,"HI,CN.");
	console.log("runQScript returned ",res1, " binary ",BigInt(res1).toString(2));


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
