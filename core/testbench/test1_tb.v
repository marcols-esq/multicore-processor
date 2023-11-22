`timescale 1ns/1ns
`include "../defines.vh"

module test1_tb();

reg clk = 0;
reg en = 1;

reg [`INST_W-1:0] test_progmem [0:10];
initial begin
    test_progmem[0] = {12'd2,  5'd0, `func3_ADD_SUB, 5'd0, `OPCODE_ALUI};
    test_progmem[1] = {12'd10, 5'd0, `func3_ADD_SUB, 5'd2, `OPCODE_ALUI};
    test_progmem[2] = {12'd11, 5'd1, `func3_ADD_SUB, 5'd2, `OPCODE_ALUI};
    test_progmem[3] = {7'd0, 5'd2, 5'd1, `func3_ADD_SUB, 5'd2, `OPCODE_ALUR};
    test_progmem[4] = {7'd0, 5'd2, 5'd1, `func3_AND, 5'd2, `OPCODE_ALUR};
end



wire [`INST_ADDR_W-1:0]  progmem_addr;
wire [`INST_W-1:0]       progmem_data = test_progmem[progmem_addr];

CORE DUT (
    .clk            (clk),
    .en             (en),

    .progmem_data   (progmem_data),
    .progmem_addr   (progmem_addr)
);

always #10 clk = !clk;

initial begin
    DUT.regfile.REGS[1] = 12;
    DUT.regfile.REGS[2] = 100;

    #2000;
    $finish;
end

initial begin
	$dumpfile("test1_tb.vcd");
	$dumpvars(0, test1_tb);
end


endmodule