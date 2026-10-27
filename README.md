# Overview
The purpose of today's lab was to create a BRAM Fifo in Vivado using either VHDL or Verilog, with the option of inferring a BRAM primatively or using the IP catalog for the BRAM only. This lab will serve as a foundation for the AXI lab. Also a Python script will generate a set of inputs to be tested with a TCL script which will automate the usage of the Python script.git
# Testing Strategy
A series of cases were set up in the Testbench to check for proper operations. Writing and reading operations with various inputs and the assertion keyword was utilized, as well as viewing the waveform to ensure no errors occurred.
# Verification
Both the TCL and Python script were added to the Vivado project to ensure no errors occurred on usage, no errors occurred.
# Issues
Currently, the FIFO is writing and reading properly, however there was some confusion as to the purpose of the Python script's purpose. The values were hard coded into the Testbench already (using the same values that were written into the Python script), but the instructor verified that the FIFO was working as intended as the waveform demonstrates proper operation. Also the utilization report showed that the BRAM was being used in the design.
# References
ECE520L_Lab_3_BRAM_Fifo_Manual
