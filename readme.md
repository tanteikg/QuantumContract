# Quantum Contract

This code runs an onchain quantum emulator in an EVM smartcontract


## Features

Current version is v0.1
* Supports up to 4 qubits
* Supports the following gates
  - I = Identity Gate
  - X = Not Gate
  - H = Hadamard Gate
  - CN = Control-Not Gate
  - CCN = Toffoli Gate
* Quantum circuit is interpreted (not compiled)

## How to use

Contract deployed on Mumbai testnet 0x5eAbD701CBD6acB008e9F770A63E9fDFfB6f87c7
1. Bell circuit - use runQScript with parameters 2,"HI,CN.". You should only get results 0 or 3
2. GHZ circuit - use runQScript with parameters 3,"HII,CNI,ICN.". You should only get results 0 or 7
3. Simon's algorithm (https://qiskit.org/textbook/ch-algorithms/simon.html) - use runQScript with parameters 4,"HHII,CINI,CIIN,ICNI,ICIN,IImm,HHII,mmII.". Ignore the 3rd and 4th bit. For the 1st 2 bits, you should only get 0 or 3 (i.e. results will be 0,3,12,15)
4. Grover's algorithm for 2 qubits. use runQScript with parameters 3,"HHI,IIX,IIH,III,CCN,III,IIH,IIX,HHI,XXI,IHI,CNI,IHI,XXI,HHI.". You should only get back 6 (i.e. 110)
5. Grover's algorithm for 3 qubits. use runQScript with parameters 4,"HHHI,IIIX,IIIH,IIII,CCCN,IIII,IIIH,IIIX,HHHI,XXXI,IIHI,CCNI,IIHI,XXXI,HHHI,IIIX,IIIH,IIII,CCCN,IIII,IIIH,IIIX,HHHI,XXXI,IIHI,CCNI,IIHI,XXXI,HHHI.". You should get 14 around 50% of the time.





