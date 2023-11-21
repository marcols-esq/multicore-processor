iverilog -I.. -o %1.out %1_tb.v ../*.v
vvp %1.out
