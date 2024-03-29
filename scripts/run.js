const main = async () => 
{
	const [owner, randomPerson] = await hre.ethers.getSigners();
	const quantumContractFactory = await hre.ethers.getContractFactory("QuantumContract");
	const qContract = await quantumContractFactory.deploy();
	await qContract.deployed();
	console.log("Contract deployed to:", qContract.address);
	console.log("Contract deployed by:",owner.address);

	var randomSeed = Math.floor(Math.random() * 65536)
	var res1;
	var numQubits;
	var algo;
	var desc;
	var res;
	var res2;

	desc = "Bell state"
	algo = "HI,CN.";
	numQubits = 2;
	res1 = await qContract.runQScript(numQubits,algo,randomSeed);
	console.log(desc," returned ",res1, " binary ",BigInt(res1).toString(2));

	res = await qContract.updateEval(0);
	await res.wait();

	res = await qContract.subscribeQScript({value:ethers.utils.parseEther("0.001")});
	await res.wait();

	res1 = await qContract.checkSubscription();
	console.log("checkSubscription returned ",res1);

	res = await qContract.collectSubscription();
	await res.wait();
	
	desc = "GHZ state"
	algo = "HII,CNI,ICN.";
	numQubits = 3;
	res1 = await qContract.runQScript(numQubits,algo,randomSeed);
	console.log(desc," returned ",res1, " binary ",BigInt(res1).toString(2));

	numQubits = 3;
	algo = "HHH.";
	res2 = await qContract.nftQScript(numQubits,algo,randomSeed);
	console.log(desc," NFT returned ",res2);

	desc = "Simon's algorithm for s=11"
	algo = "HHII,CINI,CIIN,ICNI,ICIN,IImm,HHII,mmII."
	numQubits = 4;
	res1 = await qContract.runQScript(numQubits,algo,randomSeed);
	console.log(desc," returned ",res1, " binary ",BigInt(res1).toString(2));

	desc = "Grover 2 qubit"
	numQubits = 3;
	algo = "HHI,IIX,IIH,III,CCN,III,IIH,IIX,HHI,XXI,IHI,CNI,IHI,XXI,HHI."
	res1 = await qContract.runQScript(numQubits,algo,randomSeed);
	console.log(desc," returned ",res1, " binary ",BigInt(res1).toString(2));

	res2 = await qContract.nftQScript(numQubits,algo,randomSeed);
	console.log(desc," NFT returned ",res2);

	desc = "Grover 3 qubit"
	numQubits = 4;
	algo = "HHHI,IIIX,IIIH,IIII,CCCN,IIII,IIIH,IIIX,HHHI,XXXI,IIHI,CCNI,IIHI,XXXI,HHHI,IIIX,IIIH,IIII,CCCN,IIII,IIIH,IIIX,HHHI,XXXI,IIHI,CCNI,IIHI,XXXI,HHHI."
	res1 = await qContract.runQScript(numQubits,algo,randomSeed);
	console.log(desc," returned ",res1, " binary ",BigInt(res1).toString(2));

	res2 = await qContract.nftQScript(numQubits,algo,randomSeed);
	console.log(desc," NFT returned ",res2);

	desc = "Shor factoring 21 (Skosana and Tame)"
	numQubits = 5;
	algo = "HHHII,IICIN,ICIIN,IIINC,ICICN,IIINC,IIIIX,CIINC,IIIIX,IIINC,CIICN,IIINC,IIHII,ICpII,CItII,IHIII,CpIII,HIIII."
//	algo = "HHHII,IICIN,ICIIN,IIINC,ICICN,IIIIX,CIINC,IIIIX,IIINC,CIICN,IIINC,IIHII,ICZII,ICPII,CIZII,CIPII,CITII,IHIII,CZIII,CPIII,HIIII."
	res1 = await qContract.runQScript(numQubits,algo,randomSeed);
	console.log(desc," returned ",res1, " binary ",BigInt(res1).toString(2));

	res2 = await qContract.nftQScript(numQubits,algo,randomSeed);
	console.log(desc," NFT returned ",res2);
/*
	desc = "Shor factoring 15 (Vandersypen et. al)"
	numQubits = 7;
	algo = "HHHIIII,IICINII,IICIINI,IIICINI,ICINICI,IIICINI,IIIINIC,ICIICIN,HIIIIII,CPIIIII,IHIIIII,CITIIII,ICPIIII,IIHIIII." 
	res1 = await qContract.runQScript(numQubits,algo,randomSeed);
	console.log(desc," returned ",res1, " binary ",BigInt(res1).toString(2));

*/
	
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
