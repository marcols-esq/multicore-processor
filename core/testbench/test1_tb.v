`timescale 1ns/1ns
`include "../defines.vh"

module test1_tb();

reg clk = 0;
reg en = 1;



function [31:0] ADDR (input [4:0] r1, input [4:0] r2, input [4:0] rd); begin
    ADDR = {`func7_ALU_0, r2, r1, `func3_ADD_SUB, rd, `OPCODE_ALUR};
end
endfunction

function [31:0] LUI (input [32:0] imm, input [4:0] rd); begin
    LUI = {imm[31:12], rd, `OPCODE_LUI};
end
endfunction
function [31:0] ADDI (input [4:0] r1, input [11:0] imm, input [4:0] rd); begin
    ADDI = {imm, r1, `func3_ADD_SUB, rd, `OPCODE_ALUI};
end
endfunction
function [31:0] JALR (input [4:0] r1, input [11:0] off, input [4:0] rd); begin
    JALR = {off, r1, 3'b000, rd, `OPCODE_JALR};
end
endfunction

function [31:0] BRANCH (input [2:0] func3, input [4:0] r1, input [4:0] r2, input [12:0] off); 
    // reg [12:0] off;
begin
    // off    = {insts_off, 2'b00};
    BRANCH = {off[12], off[10:5], r2, r1, func3, off[4:1], off[11], `OPCODE_BRANCH};
end
endfunction

function [31:0] LOAD (input [4:0] r1, input [11:0] imm, input [4:0] rd); begin
    LOAD = {imm, r1, 3'b010, rd, `OPCODE_LOAD};
end
endfunction
function [31:0] STORE (input [4:0] r1, input [11:0] imm, input [4:0] r2); begin
    STORE = {imm[11:5], r2, r1, 3'b010, imm[4:0], `OPCODE_STORE};
end
endfunction

reg [31:0] NOP = {12'h000,  5'd0, `func3_ADD_SUB, 5'd0, `OPCODE_ALUI};

reg [`INST_W-1:0] test_progmem [0:400];
initial begin
    test_progmem[0] = {12'd2,  5'd0, `func3_ADD_SUB, 5'd0, `OPCODE_ALUI};
    test_progmem[1] = {-12'd10, 5'd0, `func3_ADD_SUB, 5'd3, `OPCODE_ALUI};
    test_progmem[2] = JALR(5'd0, 12'd35*4, 5'd5);
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
    test_progmem[33] = JALR(5'd0, 12'd100 * 4, 5'd0);

    test_progmem[34] = NOP;
    test_progmem[35] = ADDI(5'd0, 12'd0,  5'd3);
    test_progmem[36] = ADDI(5'd0, 12'd2,  5'd2);
    test_progmem[37] = BRANCH(`func3_BEQ, 5'd2, 5'd2, 12'd10 * 4);
    test_progmem[38] = ADDI(5'd0, 12'd10, 5'd3);
    test_progmem[39] = ADDI(5'd0, 12'd11, 5'd3);
    
    test_progmem[45] = ADDI(5'd0, 12'd0, 5'd3);
    test_progmem[46] = ADDI(5'd0, 12'd1, 5'd3);
    test_progmem[47] = ADDI(5'd0, 12'd2, 5'd3);
    test_progmem[48] = ADDI(5'd3, 12'h10, 5'd3);
    test_progmem[49] = ADDI(5'd2, -12'h1, 5'd2);
    test_progmem[50] = BRANCH(`func3_BNE, 5'd2, 5'd0, -12'd2 * 4);
    
    test_progmem[51] = ADDI(5'd0, -12'h1, 5'd1);
    test_progmem[52] = ADDI(5'd0,  12'h2, 5'd2);
    test_progmem[53] = BRANCH(`func3_BLT,  5'd1, 5'd2, 12'd2 * 4);
    test_progmem[54] = ADDI(5'd0,  12'hAA, 5'd3);
    test_progmem[55] = BRANCH(`func3_BLTU, 5'd1, 5'd2, 12'd2 * 4);
    test_progmem[56] = ADDI(5'd0,  12'hBB, 5'd3);
    test_progmem[57] = JALR(5'd5, 12'd0, 5'd0);

    // test_progmem[99] = JALR(5'd0, 12'd99*4, 5'd0);

    test_progmem[100] = ADDI(5'd0, 12'd200,  5'd1);
    test_progmem[101] = LOAD(5'd1, -12'd100, 5'd2);
    test_progmem[102] = LOAD(5'd0, 12'd200,  5'd3);
    test_progmem[103] = LOAD(5'd1, 12'd100,  5'd4);
    
    test_progmem[104] = ADDR(5'd3, 5'd4,     5'd5);
    test_progmem[105] = STORE(5'd1, 12'd0,   5'd5);
    test_progmem[106] = LOAD(5'd0, 12'd200,  5'd1);
    test_progmem[107] = LUI(32'hABCDE000, 5'd1);
    test_progmem[108] = JALR(5'd1, -12'h4, 5'd0);
    
    // test_progmem[104] = NOP;
    // test_progmem[105] = NOP;
    // test_progmem[106] = NOP;
    // test_progmem[107] = ADDR(5'd3, 5'd4,     5'd5);
    // test_progmem[108] = STORE(5'd1, 12'd0,   5'd5);
    // test_progmem[109] = LOAD(5'd0, 12'd200,  5'd1);
    // test_progmem[110] = LUI(32'hABCDE000, 5'd1);
    // test_progmem[111] = JALR(5'd1, -12'h4, 5'd0);


end

wire [`INST_ADDR_W-1:0]  progmem_addr;
wire [`INST_W-1:0]       progmem_data = test_progmem[progmem_addr >> 2];


wire [`DATA_W-1:0]       mem_data_r;
wire [`DATA_W-1:0]       mem_data_w;
wire [`DATA_ADDR_W-1:0]  mem_addr;
wire                     mem_read;
wire                     mem_write;
wire                     mem_wait;

DUMMY_RAM  #(
	.DATA_W(`DATA_W),
	.ADDR_W(`DATA_ADDR_W),
	.SIZE(1000)
) ram (
	.clk(clk),
	.en(en),
    
    .mem_data_r (mem_data_r),
    .mem_data_w (mem_data_w),
    .mem_addr   (mem_addr),
    .mem_read   (mem_read),
    .mem_write  (mem_write),
    .mem_wait   (mem_wait)

);

initial begin
    ram.data[100] = 1;
    ram.data[200] = 4;
    ram.data[300] = 32'h1ABCDEF0;
end

CORE DUT (
    .clk            (clk),
    .en             (en),

    .progmem_data   (progmem_data),
    .progmem_addr   (progmem_addr),

    .mem_data_r (mem_data_r),
    .mem_data_w (mem_data_w),
    .mem_addr   (mem_addr),
    .mem_read   (mem_read),
    .mem_write  (mem_write),
    .mem_wait   (mem_wait)
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