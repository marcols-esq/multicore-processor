`timescale 1ns/1ns
`include "../defines.vh"

module test1_tb();

reg clk = 0;
reg en = 1;



function [31:0] ADDR (input [4:0] r1, input [4:0] r2, input [4:0] rd); begin
    ADDR = {`func7_ALU_0, r2, r1, `func3_ADD_SUB, rd, `OPCODE_ALUR};
end
endfunction

function [31:0] ADDI (input [4:0] r1, input [11:0] imm, input [4:0] rd); begin
    ADDI = {imm, r1, `func3_ADD_SUB, rd, `OPCODE_ALUI};
end
endfunction

function [31:0] BRANCH (input [2:0] func3, input [4:0] r1, input [4:0] r2, input [10:0] insts_off); 
    reg [12:0] off;
begin
    off    = {insts_off, 2'b00};
    BRANCH = {off[12], off[10:5], r2, r1, func3, off[4:1], off[11], `OPCODE_BRANCH};
end
endfunction

reg [31:0] NOP = {12'h000,  5'd0, `func3_ADD_SUB, 5'd0, `OPCODE_ALUI};

reg [`INST_W-1:0] test_progmem [0:400];
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
    test_progmem[12] = NOP;
    test_progmem[13] = NOP;
    test_progmem[14] = NOP;

    test_progmem[15] = {12'h002,  5'd0, `func3_ADD_SUB, 5'd2, `OPCODE_ALUI};
    test_progmem[16] = NOP;
    test_progmem[17] = {12'h020,  5'd2, `func3_ADD_SUB, 5'd3, `OPCODE_ALUI};
    test_progmem[18] = NOP;
    test_progmem[19] = NOP;
    test_progmem[20] = NOP;
    
    test_progmem[21] = {12'h003,  5'd0, `func3_ADD_SUB, 5'd2, `OPCODE_ALUI};
    test_progmem[22] = NOP;
    test_progmem[23] = NOP;
    test_progmem[24] = {12'h030,  5'd2, `func3_ADD_SUB, 5'd3, `OPCODE_ALUI};
    test_progmem[25] = NOP;
    test_progmem[26] = NOP;
    test_progmem[27] = NOP;
    
    test_progmem[28] = {12'h004,  5'd0, `func3_ADD_SUB, 5'd2, `OPCODE_ALUI};
    test_progmem[29] = NOP;
    test_progmem[30] = NOP;
    test_progmem[31] = NOP;
    test_progmem[32] = {12'h040,  5'd2, `func3_ADD_SUB, 5'd3, `OPCODE_ALUI};
    test_progmem[33] = NOP;
    test_progmem[34] = NOP;

    test_progmem[35] = ADDI(5'd0, 12'd0,  5'd3);
    test_progmem[36] = ADDI(5'd0, 12'd2,  5'd2);
    test_progmem[37] = BRANCH(`func3_BEQ, 5'd2, 5'd2, 10'd10);
    test_progmem[38] = ADDI(5'd0, 12'd10, 5'd3);
    test_progmem[39] = ADDI(5'd0, 12'd11, 5'd3);
    
    test_progmem[45] = ADDI(5'd0, 12'd0, 5'd3);
    test_progmem[46] = ADDI(5'd0, 12'd1, 5'd3);
    test_progmem[47] = ADDI(5'd0, 12'd2, 5'd3);
    test_progmem[48] = ADDI(5'd3, 12'h10, 5'd3);
    test_progmem[49] = ADDI(5'd2, -12'h1, 5'd2);
    test_progmem[50] = BRANCH(`func3_BNE, 5'd2, 5'd0, -10'd2);
    
    test_progmem[51] = ADDI(5'd0, -12'h1, 5'd1);
    test_progmem[52] = ADDI(5'd0,  12'h1, 5'd2);
    test_progmem[53] = BRANCH(`func3_BLT,  5'd1, 5'd2, 10'd2);
    test_progmem[54] = ADDI(5'd0,  12'hAA, 5'd3);
    test_progmem[55] = BRANCH(`func3_BLTU, 5'd1, 5'd2, 10'd2);
    test_progmem[56] = ADDI(5'd0,  12'hBB, 5'd3);

end



wire [`INST_ADDR_W-1:0]  progmem_addr;
wire [`INST_W-1:0]       progmem_data = test_progmem[progmem_addr >> 2];

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