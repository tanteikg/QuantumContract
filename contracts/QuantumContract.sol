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
		uint randomHash = uint(keccak256(abi.encode(block.difficulty, block.timestamp)));
		return randomHash % range;
	}

	function qc_H(uint256 mask, uint256 currState, int256[] memory Qubits) internal pure 
	{
		if ((mask & currState) != 0)
		{
			Qubits[currState-mask] += Qubits[currState];
			Qubits[currState] = 0 - Qubits[currState];
		}				
		else
		{
			Qubits[currState+mask] += Qubits[currState];
			Qubits[currState] = Qubits[currState];
		}

	}

	function qc_X(uint256 mask, uint256 currState, int256[] memory Qubits) internal pure 
	{
		if ((mask & currState) != 0)
			Qubits[currState-mask] += Qubits[currState];
		else
			Qubits[currState+mask] += Qubits[currState];
	}

	function qc_I(uint256 mask, uint256 currState, int256[] memory Qubits) internal pure 
	{
		if ((mask & currState) != 0)
			Qubits[currState] = Qubits[currState];
		else
			Qubits[currState] = Qubits[currState];
	}

	function qc_CN(uint256 cMask, uint256 mask, uint256 currState, int256[] memory Qubits) internal pure 
	{
		if (((cMask & currState) == cMask) && (cMask != 0))
		{
			if ((mask & currState) != 0)
				Qubits[currState-mask] += Qubits[currState];
			else
				Qubits[currState+mask] += Qubits[currState];
		}
		else
			Qubits[currState] = Qubits[currState];

	}

	function qc_exec(uint8 numQubits, bytes1[] memory qAlgo, int256[] memory Qubits) internal pure returns (uint8)
	{
		uint256 mask;
		uint256 i;
		uint256 j;
		uint256 maxj=2^numQubits;

		mask = 1;
		mask <<= numQubits - 1;
		for (i=0;i<numQubits;i++)
		{
			if (qAlgo[i] == GATE_H)
			{
				for(j=0;j<maxj;j++)
				{
					if (Qubits[j]!=0)
						qc_H(mask,j,Qubits);
				}
			}
			else if ((qAlgo[i] == GATE_I) || (qAlgo[i] == GATE_C))
			{
				for(j=0;j<maxj;j++)
				{
					if (Qubits[j]!=0)
						qc_I(mask,j,Qubits);
				}
			}
			else if (qAlgo[i] == GATE_X)
			{
				for(j=0;j<maxj;j++)
				{
					if (Qubits[j]!=0)
						qc_X(mask,j,Qubits);
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
					if (Qubits[j]!=0)
						qc_CN(cMask,mask,j,Qubits);
				}
			}
			else
			{
				revert("Unknown or unsupported gate");
			}
			mask >>=1;
		}
				
		return numQubits;
	}

	function runQScript(uint8 numQubits, string memory s) public view returns (uint256) 
	{
		int256[] memory Qubits; 
		bytes1[] memory nextGate;
		uint256 ret;
		bool done = false;
		uint256 i = 0;
		uint256 j;
		uint256 slen = bytes(s).length; 

		if (numQubits > MAX_QUBITS)
			revert("MAX_QUBITS exceeded");	

		Qubits = new int256[](2^numQubits);
		Qubits[0] = 1; // start with all qubits = 0;
		nextGate = new bytes1[](numQubits);
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
		while (j > uint(Qubits[ret]))
		{
			j -= uint(Qubits[ret++]);
		}	
		return ret;
			
	}


}
