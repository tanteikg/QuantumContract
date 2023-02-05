// SPDX-License-Identifier: MIT with Commons Clause 
/*

Name: QuantumContract
Description: An on-chain quantum emulator running in an EVM smart contract
Author: Teik Guan Tan
Date: Feb 2023

MIT License

Copyright (c) 2023 pQCee Pte Ltd 

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

 * “Commons Clause” License Condition v1.0
 *
 * The Software is provided to you by the Licensor under the License, as defined below, subject to the following
 * condition.
 *
 * Without limiting other conditions in the License, the grant of rights under the License will not include, and
 * the License does not grant to you, the right to Sell the Software.
 *
 * For purposes of the foregoing, “Sell” means practicing any or all of the rights granted to you under the License
 * to provide to third parties, for a fee or other consideration (including without limitation fees for hosting or
 * consulting/ support services related to the Software), a product or service whose value derives, entirely or
 * substantially, from the functionality of the Software. Any license notice or attribution required by the License
 * must also include this Commons Clause License Condition notice.
 *
 * Software: QuantumContract
 *
 * License: MIT 1.0
 *
 * Licensor: pQCee Pte Ltd
*/

pragma solidity ^0.8.17;

import "hardhat/console.sol";

contract QuantumContract 
{
	uint8 constant MAX_QUBITS=4;
	uint256 constant MAX_IDX=2**MAX_QUBITS;
	bytes1 constant GATE_H      = 'H';
	bytes1 constant GATE_I      = 'I';
	bytes1 constant GATE_C      = 'C';
	bytes1 constant GATE_N      = 'N';
	bytes1 constant GATE_X      = 'X';
	bytes1 constant GATE_m      = 'm';
	bytes1 constant DELIM_NEXT  = ',';
	bytes1 constant DELIM_END   = '.';
	
	int256[MAX_IDX] stateQubits; 
	uint8 numStateQubits;

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
			Qubits[currState][nQidx] += 0-Qubits[currState][Qidx];
		}				
		else
		{
			Qubits[currState+mask][nQidx] += Qubits[currState][Qidx];
			Qubits[currState][nQidx] += Qubits[currState][Qidx];
		}

	}

	function qc_0(uint256 mask, uint256 currState, int256[2][MAX_IDX] memory Qubits, uint8 Qidx) internal pure 
	{
		uint8 nQidx = (Qidx == 0)?1:0;

		if ((mask & currState) == 0)
		{
			Qubits[currState][nQidx] += Qubits[currState][Qidx];
		}
	}

	function qc_1(uint256 mask, uint256 currState, int256[2][MAX_IDX] memory Qubits, uint8 Qidx) internal pure 
	{
		uint8 nQidx = (Qidx == 0)?1:0;

		if ((mask & currState) == mask)
		{
			Qubits[currState][nQidx] += Qubits[currState][Qidx];
		}
	}

	function qc_X(uint256 mask, uint256 currState, int256[2][MAX_IDX] memory Qubits, uint8 Qidx) internal pure 
	{
		uint8 nQidx = (Qidx == 0)?1:0;

		if ((mask & currState) != 0)
			Qubits[currState-mask][nQidx] += Qubits[currState][Qidx];
		else
			Qubits[currState+mask][nQidx] += Qubits[currState][Qidx];
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
		uint256 maxj=(2**numQubits);
		uint8 Qidx = 0;
		uint8 nQidx;

		mask = 1;
		mask <<= numQubits - 1;
		for (i=0;i<numQubits;i++)
		{
			nQidx = (Qidx == 0)?1:0;
			for (j=0;j<maxj;j++)
				Qubits[j][nQidx] = 0;
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
			else if (qAlgo[i] == GATE_m)
			{
				uint256 k = 0;
				nQidx = (Qidx == 0)?1:0;
				for (j = 0; j < maxj; j++)
				{
					Qubits[j][nQidx] =Qubits[j][Qidx];
					if (Qubits[j][nQidx] < 0)
						Qubits[j][nQidx] = 0 - Qubits[j][nQidx];
					k += uint(Qubits[j][nQidx]);
				}
				j = getRandom(k)+1;
				k = 0;
				while (j > uint(Qubits[k][nQidx]))
				{
					j -= uint(Qubits[k++][nQidx]);
				}	
				for (j = 0; j < maxj; j++)
					Qubits[j][nQidx] = 0;
				if ((k & mask) == 0)
				{
					for(j=0;j<maxj;j++)
					{
						if (Qubits[j][Qidx]!=0)
							qc_0(mask,j,Qubits,Qidx);
					}
				}
				else
				{
					for(j=0;j<maxj;j++)
					{
						if (Qubits[j][Qidx]!=0)
							qc_1(mask,j,Qubits,Qidx);
					}
				}
			}
			else if (qAlgo[i] == GATE_N)
			{
				uint256 tempVal = 1;
				tempVal <<= numQubits-1;
				uint256 cMask = 0;

				for (j=0;j<numQubits;j++)
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
			Qidx = nQidx;
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
				if (i < slen)
				{
					if (bytes(s)[i] == DELIM_END)
					{
						done = true;
					}
					else
						i++;
				}
				else
				{
					revert("unexpected end-of-algo without .");
				}
				

			}
		}

		// measure			

		i = 0;
		for (j = 0; j < (2**numQubits); j++)
		{
			if (Qubits[j][0] < 0)
				Qubits[j][0] = 0 - Qubits[j][0];
			i += uint(Qubits[j][0]);
		}
		j = getRandom(i)+1;
		ret = 0;
		while (j > uint(Qubits[ret][0]))
		{
			j -= uint(Qubits[ret++][0]);
		}	

		return ret;
			
	}

	function beginQScript(uint8 numQubits) public
	{
		uint256 i;
		uint256 maxi=2**numQubits;

		if (numQubits > MAX_QUBITS)
			revert("MAX_QUBITS exceeded");	
		numStateQubits = numQubits;
		stateQubits[0] = 1;
		for (i=1;i<maxi;i++)
			stateQubits[i] = 0;
		
	}

	function contQScript(string memory s) public 
	{
		uint8 numQubits = numStateQubits;
		int256[2][MAX_IDX] memory Qubits; 
		bytes1[] memory nextGate;
		bool done = false;
		bool cont = false;
		uint256 i = 0;
		uint256 j;
		uint256 slen = bytes(s).length; 

		for (i=0;i<(2**numQubits);i++)
		{
			Qubits[i][0] = stateQubits[i];
		}
	
		nextGate = new bytes1[](numQubits);
		console.log("%s called contQScript with string length %d",msg.sender,bytes(s).length);
		i = 0;

		while ((!done) && (!cont))
		{
			if (i + numQubits > slen)
			{
				if (bytes(s)[i] == DELIM_END)
				{
					done = true;
				}
				else
				{
					cont = true;
				}
			}
			else
			{
				for (j = 0;j < numQubits;j++)
				{
					nextGate[j] = bytes(s)[i++];
				}	
				numQubits = qc_exec(numQubits,nextGate,Qubits);
				if (i < slen)
				{
					if (bytes(s)[i] == DELIM_END)
					{
						done = true;
					}
					else
						i++;
				}
				else
					cont = true;

			}
		}
		for (i = 0;i < (2**numQubits);i++)
			stateQubits[i] = Qubits[i][0];

	}

	function readStateQubits() public view returns (uint256)
	{
		uint256 i;
		uint256 j;
		int256[MAX_IDX] memory tempQubits; 

		i = 0;
		for (j = 0; j < (2**numStateQubits); j++)
		{
			tempQubits[j] = stateQubits[j];
			if (tempQubits[j] < 0)
				tempQubits[j] = 0 - tempQubits[j];
			i += uint(tempQubits[j]);
		}
		if (i == 0)
			revert("unexpected 0 for i.");
		j = getRandom(i)+1;
		i = 0;
		while (j > uint(tempQubits[i]))
		{
			j -= uint(tempQubits[i++]);
		}	
		return i;

	}
}

