`timescale 1ns/1ns
`include "../defines.vh"

module test1_tb();

reg clk = 0;
reg en = 1;

wire [`INST_W-1:0]       progmem_data = {progmem_addr[7:0], progmem_addr[7:0], progmem_addr[7:0], progmem_addr[7:0]};
wire [`INST_ADDR_W-1:0]  progmem_addr;

CORE DUT (
    .clk            (clk),
    .en             (en),

    .progmem_data   (progmem_data),
    .progmem_addr   (progmem_addr)
);

always #10 clk = !clk;

initial begin
    #2000;
    $finish;
end

initial begin
	$dumpfile("test1_tb.vcd");
	$dumpvars(0, test1_tb);
end


endmodule