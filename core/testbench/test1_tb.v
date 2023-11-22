`timescale 1ns/1ns
`include "../defines.vh"

module test1_tb();

reg clk = 0;
reg en = 1;

reg [`INST_W-1:0] test_progmem [0:20];
initial begin
    test_progmem[0] = {12'd2,  5'd0, `func3_ADD_SUB, 5'd0, `OPCODE_ALUI};
    test_progmem[1] = {-12'd10, 5'd0, `func3_ADD_SUB, 5'd3, `OPCODE_ALUI};
    test_progmem[2] = {12'd11, 5'd1, `func3_ADD_SUB, 5'd4, `OPCODE_ALUI};
    test_progmem[3] = {7'd0, 5'd2, 5'd1, `func3_ADD_SUB, 5'd4, `OPCODE_ALUR};
    test_progmem[4] = {7'd0, 5'd2, 5'd1, `func3_AND, 5'd5, `OPCODE_ALUR};

    test_progmem[5] = {12'h100,  5'd0, `func3_ADD_SUB, 5'd1, `OPCODE_ALUI};
    test_progmem[6] = {-12'h001,  5'd1, `func3_ADD_SUB, 5'd1, `OPCODE_ALUI};
    test_progmem[7] = {12'h002,  5'd1, `func3_ADD_SUB, 5'd1, `OPCODE_ALUI};
    test_progmem[8] = {12'h004,  5'd1, `func3_ADD_SUB, 5'd1, `OPCODE_ALUI};
    test_progmem[9] = {12'h008,  5'd1, `func3_ADD_SUB, 5'd1, `OPCODE_ALUI};
    
    test_progmem[10] = {12'h001,  5'd0, `func3_ADD_SUB, 5'd2, `OPCODE_ALUI};
    test_progmem[11] = {12'h010,  5'd2, `func3_ADD_SUB, 5'd3, `OPCODE_ALUI};
    test_progmem[12] = {12'h000,  5'd0, `func3_ADD_SUB, 5'd0, `OPCODE_ALUI};
    test_progmem[13] = {12'h000,  5'd0, `func3_ADD_SUB, 5'd0, `OPCODE_ALUI};
    test_progmem[14] = {12'h000,  5'd0, `func3_ADD_SUB, 5'd0, `OPCODE_ALUI};
end



wire [`INST_ADDR_W-1:0]  progmem_addr;
wire [`INST_W-1:0]       progmem_data = test_progmem[progmem_addr];

CORE DUT (
    .clk            (clk),
    .en             (en),

    .progmem_data   (progmem_data),
    .progmem_addr   (progmem_addr)
);


wire [`DATA_W-1:0] REG1 = DUT.regfile.REGS[1];
wire [`DATA_W-1:0] REG2 = DUT.regfile.REGS[2];
wire [`DATA_W-1:0] REG3 = DUT.regfile.REGS[3];
wire [`DATA_W-1:0] REG4 = DUT.regfile.REGS[4];
wire [`DATA_W-1:0] REG5 = DUT.regfile.REGS[5];

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