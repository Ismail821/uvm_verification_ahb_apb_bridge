# Verification of AHB to APB Brdige with UVM
Co Authored by Abhishek (@ShotoTodorokiJr)

UVM Verification enviroinment for AHB to APB bridge.
Supports upto 8 APB slave Devices. 

Documentation still under progress.

Tools used: 
Cadence Xcelium 

The DUT is designed in Verilog with the main State machine with reference from the arm developer website with the inclusive of PREADY and PSLVERR, to consider the availability of the APB Slaves.
The FSM is Designed based on the Architecture given in the ARM developer page here: https://developer.arm.com/documentation/ddi0170/a/AHB-Modules/APB-bridge/Function-and-operation-of-module

![image](https://github.com/Ismail821/uvm_verification_ahb_apb_bridge/assets/80463970/2b9c0e23-0507-44b7-bb06-dda3b6c030b9)


The RTL Consists of the following:
- Macro definitions
- Parameters
- Port declarations
- A combination logic to decide the validity of the transaction.
- A sequential logic to for the assignment of the States
- And a FSM logic making the transfer of the data and Following the protocol.
- And a Combinational logic to decide the slave select based on the address

The Test Bench Architecture is defined as follows:
![image](https://github.com/Ismail821/uvm_verification_ahb_apb_bridge/assets/80463970/bc66ec0b-c631-47ed-880e-9f6a822a933f)


The testbench provides the value for all the APB slaves simultaneously for every cycle and sends them to the DUT as

Test Cases:
The Names are as ahb_apb_bridge_testname_test.sv, where the testname tells about the type of test. All the 5 Testcases are derived from the ahb_apb_bridge_base_test.sv
The files consist of 5 Testcases:

- `ahb_apb_bridge_burst_read_test.sv`: Does continuous Burst Read to any randomly selected apb Slaves through the DUT. The Data Requested when the HREADY is HIGH is not delivered.
- `ahb_apb_bridge_burst_write_test.sv`: Does continuous Burst Write to any randomly selected apb Slaves through the DUT. The Data written when the HREADY is HIGH is not delivered.
- `ahb_apb_bridge_single_read_test.sv`: Does a single read to any randomly selected Apb Slaves through the DUT.
- `ahb_apb_bridge_single_write_test.sv`: Does single write to any randomly selected Apb Slaves through the DUT.
- `ahb_apb_bridge_random_test.sv`: Does Random Read/Write to any randomly selected Apb Slaves through the DUT, it can include burst write and burst read too.

The Sequence generaes the Random sequence with given constraints while the driver maitains the protocol by asserting the signals at appropriate time
