`timescale 1ns/1ns
`include "../defines.vh"

module test2_tb();

reg clk = 0;
reg en = 1;


function [31:0] LUI (input [32:0] imm, input [4:0] rd); begin
    LUI = {imm[31:12], rd, `OPCODE_LUI};
end
endfunction
function [31:0] ALUI (input [3:0] op, input [4:0] r1, input [11:0] imm, input [4:0] rd); begin
    if(op == `ALU_OP_SUB) begin
        $display("NIE MOŻNA ODEJMOWAĆ LICZB IMMIDIATE!! Zamiast tego dodaj liczbę przeciwną.");
        $stop;
    end
    ALUI = {imm[11:5] | (op[3] ? `func7_ALU_1 : `func7_ALU_0 ), imm[4:0], r1, op[2:0], rd, `OPCODE_ALUI};
end
endfunction
function [31:0] ALUR (input [3:0] op, input [4:0] r1, input [4:0] r2, input [4:0] rd); begin
    ALUR = {op[3] ? `func7_ALU_1 : `func7_ALU_0, r2, r1, op[2:0], rd, `OPCODE_ALUR};
end
endfunction
function [31:0] JALR (input [4:0] r1, input [11:0] off, input [4:0] rd); begin
    JALR = {off, r1, 3'b000, rd, `OPCODE_JALR};
end
endfunction

function [31:0] BRANCH (input [2:0] func3, input [4:0] r1, input [4:0] r2, input [11:0] off); 
    // reg [12:0] off;
begin
    // off    = {insts_off, 2'b00};
    // BRANCH = {off[12], off[10:5], r2, r1, func3, off[4:1], off[11], `OPCODE_BRANCH};
    BRANCH = {off[11:5], r2, r1, func3, off[4:0], `OPCODE_BRANCH}; // Uznaję, że każdy adres wskazuje na 32-bitowy word, nie na kolejne bajty
end
endfunction

function [31:0] LOAD (input [4:0] r1, input [11:0] imm, input [4:0] rd); begin
    LOAD = {imm, r1, `func3_MEM_W, rd, `OPCODE_LOAD};
end
endfunction
function [31:0] STORE (input [4:0] r1, input [11:0] imm, input [4:0] r2); begin
    STORE = {imm[11:5], r2, r1, `func3_MEM_W, imm[4:0], `OPCODE_STORE};
end
endfunction
function [31:0] LOAD_A (input [4:0] r1, input [11:0] imm, input [4:0] rd); begin
    LOAD_A = {imm, r1, `func3_MEM_WA, rd, `OPCODE_LOAD};
end
endfunction
function [31:0] STORE_A (input [4:0] r1, input [11:0] imm, input [4:0] r2); begin
    STORE_A = {imm[11:5], r2, r1, `func3_MEM_WA, imm[4:0], `OPCODE_STORE};
end
endfunction

reg [31:0] NOP = ALUI(`ALU_OP_ADD, 5'd0, 12'h000, 5'd0);

reg [`INST_W-1:0] test_progmem [0:400];
integer i = -1;
initial begin
    i=i+1; test_progmem[i] = ALUI(`ALU_OP_ADD, 5'd0, 12'hC, 5'd5);          // r5 = C
    i=i+1; test_progmem[i] = ALUI(`ALU_OP_ADD, 5'd0, 12'hD, 5'd4);          // r4 = D
    i=i+1; test_progmem[i] = STORE(5'd0, 12'd3, 5'd5);                      // store r5
    i=i+1; test_progmem[i] = LOAD(5'd0, 12'd3, 5'd3);                       // load  r5
    i=i+1; test_progmem[i] = ALUI(`ALU_OP_ADD, 5'd0, 12'hA, 5'd4);          // r4 = A
    i=i+1; test_progmem[i] = ALUI(`ALU_OP_ADD, 5'd0, 12'hB, 5'd5);          // r5 = B
    i=i+1; test_progmem[i] = STORE(5'd0, 12'd2, 5'd5);                      // store r5
    i=i+1; test_progmem[i] = LOAD(5'd0, 12'd2, 5'd3);                       // load  r5
    i=i+1; test_progmem[i] = ALUI(`ALU_OP_ADD, 5'd0, 12'hE, 5'd5);          // r5 = E
    i=i+1; test_progmem[i] = NOP;
    i=i+1; test_progmem[i] = NOP;
    i=i+1; test_progmem[i] = NOP;
    i=i+1; test_progmem[i] = NOP;
    i=i+1; test_progmem[i] = ALUI(`ALU_OP_ADD, 5'd0, 12'hF, 5'd4);          // r4 = F
    i=i+1; test_progmem[i] = STORE(5'd0, 12'd4, 5'd5);                      // store r5
    i=i+1; test_progmem[i] = LOAD(5'd0, 12'd4, 5'd3);                       // load  r5
    i=i+1; test_progmem[i] = ALUI(`ALU_OP_ADD, 5'd0, 12'hA, 5'd4);          // r4 = 7
    i=i+1; test_progmem[i] = ALUI(`ALU_OP_ADD, 5'd0, 12'hB, 5'd5);          // r5 = 8
    i=i+1; test_progmem[i] = NOP;
    i=i+1; test_progmem[i] = STORE(5'd0, 12'd2, 5'd5);                      // store r5
    i=i+1; test_progmem[i] = LOAD(5'd0, 12'd2, 5'd3);                       // load  r5
    i=i+1; test_progmem[i] = NOP;
end

wire [`INST_ADDR_W-1:0]  progmem_addr;
wire [`INST_W-1:0]       progmem_data = test_progmem[progmem_addr];


wire [`DATA_W-1:0]       mem_data_r;
wire [`DATA_W-1:0]       mem_data_w;
wire [`DATA_ADDR_W-1:0]  mem_addr;
wire                     mem_read;
wire                     mem_write;
wire                     mem_atomic;
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
    .mem_atomic (mem_atomic),
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
    .mem_atomic (mem_atomic),
    .mem_wait   (mem_wait)
);


wire [`DATA_W-1:0] REG1 = DUT.regfile.REGS[1];
wire [`DATA_W-1:0] REG2 = DUT.regfile.REGS[2];
wire [`DATA_W-1:0] REG3 = DUT.regfile.REGS[3];
wire [`DATA_W-1:0] REG4 = DUT.regfile.REGS[4];
wire [`DATA_W-1:0] REG5 = DUT.regfile.REGS[5];

always #10 clk = !clk;

reg [31:0] fifo_fetched_insts [0:4];
reg [31:0] fifo_jump_addreses [0:4];
reg        fifo_jumps         [0:4];


INST_MONITOR inst_monitor(
    .clk        (clk),
    .pc         (progmem_addr),
    .inst       (progmem_data),
    .flush      (DUT.stage_wb.flush),

    .is_jump        (DUT.jump),
    .jump_addr      (DUT.jump_addr),

    .reg_wr         (DUT.regfile_wr),
    .reg_addr_wr    (DUT.regfile_addr_wr),
    .reg_data_wr    (DUT.regfile_data_wr),

    .mem_data_r     (mem_data_r),
    .mem_data_w     (mem_data_w),
    .mem_addr       (mem_addr),
    .mem_read       (mem_read),
    .mem_write      (mem_write),
    .mem_wait       (mem_wait)
);

initial begin
    DUT.regfile.REGS[1] = 12;
    DUT.regfile.REGS[2] = 100;

    #2000;
    $finish;
end

initial begin
	$dumpfile("test2_tb.vcd");
	$dumpvars(0, test2_tb);
end


endmodule