# Quantum Contract

This code runs an onchain quantum emulator in an EVM smartcontract


## Features

Current version is v0.2

* Supports up to 4 qubits (v0.1) and 8 qubits (v0.2)
* v0.1 supports the following gates
  - I = Identity Gate
  - X = Not (Pauli-X) Gate
  - H = Hadamard Gate
  - CN = Control-Not Gate
  - CCN = Toffoli Gate
* v0.2 supports v0.1 gates plus the following gates
  - P = Phase shift pi/4 Gate  
  - T = Phase shift pi/8 Gate 
  - Y = Not (Pauli-Y) Gate
  - Z = Not (Pauli-Z) Gate
* Quantum circuit is interpreted (not compiled)

## How to use

v0.1 Contract deployed on Mumbai testnet 0x5eAbD701CBD6acB008e9F770A63E9fDFfB6f87c7. Go to https://tanteikg.github.io/QC/index1.html
1. Bell circuit - use runQScript with parameters 2,"HI,CN.". You should only get results 0 or 3
2. GHZ circuit - use runQScript with parameters 3,"HII,CNI,ICN.". You should only get results 0 or 7
3. Simon's algorithm (https://qiskit.org/textbook/ch-algorithms/simon.html) - use runQScript with parameters 4,"HHII,CINI,CIIN,ICNI,ICIN,IImm,HHII,mmII.". Ignore the 3rd and 4th bit. For the 1st 2 bits, you should only get 0 or 3 (i.e. results will be 0,3,12,15)
4. Grover's algorithm for 2 qubits. use runQScript with parameters 3,"HHI,IIX,IIH,III,CCN,III,IIH,IIX,HHI,XXI,IHI,CNI,IHI,XXI,HHI.". You should only get back 6 (i.e. 110)
5. Grover's algorithm for 3 qubits. use runQScript with parameters 4,"HHHI,IIIX,IIIH,IIII,CCCN,IIII,IIIH,IIIX,HHHI,XXXI,IIHI,CCNI,IIHI,XXXI,HHHI,IIIX,IIIH,IIII,CCCN,IIII,IIIH,IIIX,HHHI,XXXI,IIHI,CCNI,IIHI,XXXI,HHHI.". You should get 14 around 50% of the time.

v0.2 Contract deployed on Mumbai testnet 0x7718760b559a073D14CF26aA0F823Da860fc14d3. Go to https://tanteikg.github.io/QC/index.html
6. Shor's factoring 21 (Skosana and Tame). use qubits = 5, circuit =  "HHHII,IICIN,ICIIN,IIINC,ICICN,IIIIX,CIINC,IIIIX,IIINC,CIICN,IIINC,IIHII,ICPII,CITII,IHIII,CPIII,HIIII."
7. Shor's factoring 15 (Vandersypen et. al). use qubits = 7, circuit = "HHHIIII,IICINII,IICIINI,IIICINI,ICINICI,IIICINI,IIIINIC,ICIICIN,HIIIIII,CPIIIII,IHIIIII,CITIIII,ICPIIII,IIHIIII".

## Demo

Go to https://tanteikg.github.io/QC

for enquiries/feedback, please contact info@pqcee.com


