// SPDX-License-Identifier: MIT with Commons Clause 

pragma solidity ^0.8.17;

import "hardhat/console.sol";

contract QuantumContract 
{
	uint8 constant MAX_QUBITS=7;
	bytes1 constant GATE_H      = 'H';
	bytes1 constant GATE_I      = 'I';
	bytes1 constant GATE_C      = 'C';
	bytes1 constant GATE_N      = 'N';
	bytes1 constant GATE_X      = 'X';
	bytes1 constant DELIM_NEXT  = ',';
	bytes1 constant DELIM_END   = '.';

	constructor() 
	{
		console.log("Welcome to pQCee QuantumContract");
    	}

	function getRandom(uint256 range) private view returns (uint) 
	{
		uint randomHash = uint(keccak256(block.difficulty, now));
		return randomHash % range;
	}

	function qc_H(uint256 mask, uint256 currState, int256[] memory Qubits) internal view
	{
		Qubits[currState] += 1; 

	}
	
	function qc_exec(uint8 numQubits, byte[] memory nextGate, int256[] memory Qubits) internal view returns (uint8)
	{

		return numQubits;
	}

	function runQScript(uint8 numQubits, string memory s) public view returns (uint256) 
	{
		int256[] memory Qubits; 
		byte[] memory nextGate;
		uint256 ret;
		bool done = false;
		uint256 len;
		uint256 i = 0;
		uint256 j;
		uint256 slen = bytes(s).length; 

		if (numQubits > MAX_QUBITS)
			revert("MAX_QUBITS exceeded");	

		Qubits = new int256[](2^numQubits);
		nextGate = new byte[](numQubits);
		console.log("%s called runQScript with string length %d",msg.sender,bytes(s).length);
		while (!done)
		{
			if (i + numQubits > slen)
			{
				if (bytes(s)[i] == DELIM_END)
				{
					done = true;
				}
				else
				{
					revert("unexpected end-of-algo without .");
				}
			}
			else
			{
				for (j = 0;j < numQubits;j++)
				{
					nextGate[j] = bytes(s)[i++];
				}	
				numQubits = qc_exec(numQubits,nextGate,Qubits);
				if (bytes(s)[i] == DELIM_END)
				{
					done = true;
				}
				else
					i++;

			}
		}
		// measure			
		i = 0;
		for (j = 0; j < (2^numQubits); j++)
			i += uint(Qubits[j]);
		j = getRandom(i);
		ret = 0;
		while (j > Qubit[ret])
		{
			j -= Qubit[ret++];
		}	
		return ret;
			
	}


}
