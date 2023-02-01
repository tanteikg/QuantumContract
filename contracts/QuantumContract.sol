// SPDX-License-Identifier: MIT with Commons Clause 

pragma solidity ^0.8.17;

import "hardhat/console.sol";

contract QuantumContract 
{
	uint8 constant MAX_QUBITS=7;
	uint256 constant MAX_IDX=2**MAX_QUBITS;
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
		uint randomHash = uint(keccak256(abi.encode(block.difficulty, block.timestamp)));
		return randomHash % range;
	}

	function qc_H(uint256 mask, uint256 currState, int256[2][MAX_IDX] memory Qubits, uint8 Qidx) internal pure 
	{
		uint8 nQidx = (Qidx == 0)?1:0;
		if ((mask & currState) != 0)
		{
			Qubits[currState-mask][nQidx] += Qubits[currState][Qidx];
			Qubits[currState][nQidx] += 0 - Qubits[currState][Qidx];
		}				
		else
		{
			Qubits[currState+mask][nQidx] += Qubits[currState][Qidx];
			Qubits[currState][nQidx] += Qubits[currState][Qidx];
		}

	}

	function qc_X(uint256 mask, uint256 currState, int256[2][MAX_IDX] memory Qubits, uint8 Qidx) internal view 
	{
		uint8 nQidx = (Qidx == 0)?1:0;
		//console.log("mask %d currState %d Q0 ",mask,currState);
		//console.log("Q0 %d Q1 %d ",uint(Qubits[0][Qidx]),uint(Qubits[1][Qidx]));
		//console.log("Q2 %d Q3 %d ",uint(Qubits[2][Qidx]),uint(Qubits[3][Qidx]));

		if ((mask & currState) != 0)
			Qubits[currState-mask][nQidx] += Qubits[currState][Qidx];
		else
			Qubits[currState+mask][nQidx] += Qubits[currState][Qidx];
		//console.log("new Q0 %d Q1 %d ",uint(Qubits[0][nQidx]),uint(Qubits[1][nQidx]));
		//console.log("new Q2 %d Q3 %d ",uint(Qubits[2][nQidx]),uint(Qubits[3][nQidx]));
	}

	function qc_I(uint256 mask, uint256 currState, int256[2][MAX_IDX] memory Qubits, uint8 Qidx) internal pure 
	{
		uint8 nQidx = (Qidx == 0)?1:0;
		Qubits[currState][nQidx] = Qubits[currState][Qidx];
	}

	function qc_CN(uint256 cMask, uint256 mask, uint256 currState, int256[2][MAX_IDX] memory Qubits, uint8 Qidx) internal pure 
	{
		uint8 nQidx = (Qidx == 0)?1:0;
		if (((cMask & currState) == cMask) && (cMask != 0))
		{
			if ((mask & currState) != 0)
				Qubits[currState-mask][nQidx] += Qubits[currState][Qidx];
			else
				Qubits[currState+mask][nQidx] += Qubits[currState][Qidx];
		}
		else
			Qubits[currState][nQidx] = Qubits[currState][Qidx];

	}

	function qc_exec(uint8 numQubits, bytes1[] memory qAlgo, int256[2][MAX_IDX] memory Qubits) internal view returns (uint8)
	{
		uint256 mask;
		uint256 i;
		uint256 j;
		uint256 maxj=2**numQubits;
		uint8 Qidx = 0;

		mask = 1;
		mask <<= numQubits - 1;
		for (i=0;i<numQubits;i++)
		{
			if (qAlgo[i] == GATE_H)
			{
				for(j=0;j<maxj;j++)
				{
					if (Qubits[j][Qidx]!=0)
						qc_H(mask,j,Qubits,Qidx);
				}
			}
			else if ((qAlgo[i] == GATE_I) || (qAlgo[i] == GATE_C))
			{
				for(j=0;j<maxj;j++)
				{
					if (Qubits[j][Qidx]!=0)
						qc_I(mask,j,Qubits,Qidx);
				}
			}
			else if (qAlgo[i] == GATE_X)
			{
				for(j=0;j<maxj;j++)
				{
					if (Qubits[j][Qidx]!=0)
						qc_X(mask,j,Qubits,Qidx);
				}
			}
			else if (qAlgo[i] == GATE_N)
			{
				uint256 tempVal = 1;
				tempVal <<= numQubits-1;
				uint256 cMask = 0;

				for (j=0;i<numQubits;j++)
				{
					if (qAlgo[j] == GATE_C)
						cMask += tempVal;
					tempVal>>=1;
				}
				for(j=0;j<maxj;j++)
				{
					if (Qubits[j][Qidx]!=0)
						qc_CN(cMask,mask,j,Qubits,Qidx);
				}
			}
			else
			{
				revert("Unknown or unsupported gate");
			}
			mask >>=1;
			for (j=0;j<maxj;j++)
				Qubits[j][Qidx] = 0;
			if (Qidx == 0)
				Qidx = 1;
			else
				Qidx = 0;
		}
		if (Qidx == 1)
			for (j=0;j<maxj;j++)
				Qubits[j][0] = Qubits[j][1];

				
		return numQubits;
	}

	function runQScript(uint8 numQubits, string memory s) public view returns (uint256) 
	{
		int256[2][MAX_IDX] memory Qubits; 
		bytes1[] memory nextGate;
		uint256 ret = 0;
		bool done = false;
		uint256 i = 0;
		uint256 j;
		uint256 slen = bytes(s).length; 

		if (numQubits > MAX_QUBITS)
			revert("MAX_QUBITS exceeded");	
		for (i=0;i<(2**numQubits);i++)
		{
			Qubits[i][0] = Qubits[i][1] = 0;
		}
		Qubits[0][0] = 1; // start with all qubits = 0;
	
		nextGate = new bytes1[](numQubits);
		console.log("%s called runQScript with string length %d",msg.sender,bytes(s).length);
		i = 0;

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
		for (j = 0; j < (2**numQubits); j++)
			i += uint(Qubits[j][0]);
		j = getRandom(i)+1;
		ret = 0;
		while (j > uint(Qubits[ret][0]))
		{
			j -= uint(Qubits[ret++][0]);
		}	

		return ret;
			
	}


}