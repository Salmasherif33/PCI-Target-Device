# PCI-Target-Device

In this project, I implement a PCI target device (slave) in Verilog. The project
should achieve the following goals.
1. When the PCI target device receives the command and recognize its address, the
following should be done.
a. The DEVSEL should be configured properly (asserted low at certain time).
b. The TRDY should be configured properly (asserted low at certain time).
2. If the received command in PCI target device is a read operation.
a. The target device should start sending out a frame upon having FRAME signal
asserted to low.
b. The target device should stop sending out a frame upon having FRAME signal
asserted to high.

3. If the received command in PCI target device is a write operation.
a. The target device should start saving the received data in an internal storage
with respect to byte enable (BE) bits upon having FRAME signal asserted to low.
b. The target device should stop saving the received data in internal storage upon
having FRAME signal asserted to high.

4. A testbench to simulate different read/write scenarios (act as a
simplified PCI master device).
5. Testbench should verify write command by doing the following.
a. Sending a write command.
b. Followed by a read command with same address used for the previous write
command.

6. It is assumed that the PCI master device granted the PCI bus to initiate the transaction
with the target. So, no need to implement the PCI arbiter.
