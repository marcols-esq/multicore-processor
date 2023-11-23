`include "defines.vh"


module STAGE_ID (
    input  wire                     clk,
    input  wire                     en,
    input  wire                     stall,

    // from STAGE_FE

    input  wire                     flush,
    input  wire [`INST_W-1:0]       inst,
    input  wire [`INST_ADDR_W-1:0]  pc,

    // interface with REGFILE

    output wire [`REG_ADDR_W-1:0]   regfile_addr1,
    output wire [`REG_ADDR_W-1:0]   regfile_addr2,
    // input  wire [`DATA_W-1:0]       regfile_data1,
    // input  wire [`DATA_W-1:0]       regfile_data2,
    
    // decoded instruction

    output reg                      out_is_load,
    output reg                      out_is_store,
    output reg                      out_reg_wr,
    output reg  [`REG_ADDR_W-1:0]   out_reg_addr_rd,
    output reg  [`REG_ADDR_W-1:0]   out_reg_addr_r1,
    output reg  [`REG_ADDR_W-1:0]   out_reg_addr_r2,

    // output wire [`DATA_W-1:0]       out_reg_data_r1,
    // output wire [`DATA_W-1:0]       out_reg_data_r2,

    output reg  [3:0]               out_alu_op,
    output reg  [`ALU_SRC_W-1:0]    out_alu_src_arg1,
    output reg  [`ALU_SRC_W-1:0]    out_alu_src_arg2,
    output reg  [`DATA_W-1:0]       out_imm,

    // output wire [`DATA_W-1:0]       out_alu_arg1,
    // output wire [`DATA_W-1:0]       out_alu_arg2,

    output reg                      out_is_jump,
    output reg                      out_is_call,
    output reg                      out_is_ret,
    output reg                      out_is_branch,
    output reg  [2:0]               out_branch_type,


    output reg  [`INST_ADDR_W-1:0]  out_pc,
    output reg                      out_flush = 1'b1
);

    // decoedd instruction

    wire [6:0]              opcode          = inst[6:0];
    wire [2:0]              func3           = inst[14:12];
    wire [6:0]              func7           = inst[31:25];
    wire [11:0]             imm_I           = inst[31:20];
    wire [11:0]             imm_S           = {inst[31:25], inst[11:7]};
    wire [11:0]             imm_B           = {inst[31], inst[7], inst[30:25], inst[11:8]};
    wire [19:0]             imm_U           = inst[31:12];
    wire [19:0]             imm_J           = {inst[31], inst[19:12], inst[20], inst[30:21]};

    wire                    is_store        = !flush && (opcode == `OPCODE_STORE);
    wire                    is_load         = !flush && (opcode == `OPCODE_LOAD);

    wire                    is_lui          = opcode == `OPCODE_LUI;

    wire [`REG_ADDR_W-1:0]  reg_addr_rd     = inst[11:7];
    wire [`REG_ADDR_W-1:0]  reg_addr_r1     = is_lui ? `REG_ADDR_W'd0 : inst[19:15];
    wire [`REG_ADDR_W-1:0]  reg_addr_r2     = inst[24:20];


    wire                    is_alu_func7    = func7 == `func7_ALU_0 || 
                                              func7 == `func7_ALU_1;

    wire                    is_branch       = opcode == `OPCODE_BRANCH;
    wire [2:0]              branch_type     = func3;

    wire                    is_jump         = opcode == `OPCODE_JALR;
    // wire                    is_call         = is_jump && (reg_addr_rd == `LINK_REG && reg_addr_r1 != `LINK_REG);
    // wire                    is_ret          = is_jump && (reg_addr_rd == `LINK_REG && reg_addr_r1 == `LINK_REG);


    wire                    is_alu_r        = opcode == `OPCODE_ALUR && is_alu_func7;
    wire                    is_alu_imm      = opcode == `OPCODE_ALUI;

    wire                    is_alu          = is_alu_r || is_alu_imm;
    wire                    is_alu_rev      = func7[5] && is_alu_r;


    wire [3:0]              alu_op          = is_alu ? {is_alu_rev, func3} : `ALU_OP_ADD;


    wire [31:0]             imm             = 
        is_jump    ? { {20{inst[31]}}, imm_I} :
        is_load    ? { {20{inst[31]}}, imm_I} :
        is_alu_imm ? { {20{inst[31]}}, imm_I} :
        is_store   ? { {20{inst[31]}}, imm_S} :
        is_lui     ? { imm_U,          12'd0} :
        is_branch  ? { {19{inst[31]}}, imm_B, 1'b0 } :
                     32'hx;

    wire [`ALU_SRC_W-1:0]   alu_src_arg1    =
        is_branch  ? `ALU_SRC_PC :
                     `ALU_SRC_R;
    
    wire [`ALU_SRC_W-1:0]   alu_src_arg2    =
        is_alu_r   ? `ALU_SRC_R :
                     `ALU_SRC_IMM;

    
    wire                    reg_wr          = !flush && ((is_load || is_lui || is_alu || is_jump) ? reg_addr_rd != 0 : 1'b0);

    // wire [`DATA_W-1:0]      last_reg_data_r1 = regfile_data1;
    // wire [`DATA_W-1:0]      last_reg_data_r2 = regfile_data2;


    // interface with REGFILE

    assign regfile_addr1  = reg_addr_r1;
    assign regfile_addr2  = reg_addr_r2;

    // Pipelining registers


    always @(posedge clk) begin
        if(en && !stall) begin

            out_is_store         <= is_store;
            out_is_load          <= is_load;
            out_reg_wr           <= reg_wr;
            out_reg_addr_rd      <= reg_addr_rd;
            out_reg_addr_r1      <= reg_addr_r1;
            out_reg_addr_r2      <= reg_addr_r2;
            out_alu_op           <= alu_op;
            out_alu_src_arg1     <= alu_src_arg1;
            out_alu_src_arg2     <= alu_src_arg2;
            out_imm              <= imm;

            out_is_branch        <= is_branch;
            out_branch_type      <= branch_type;
            out_is_jump          <= is_jump;
            // out_is_call          <= is_call;
            // out_is_ret           <= is_ret;

            out_pc               <= pc;
            out_flush            <= flush;
        end
    end

    // assign out_reg_data_r1 = regfile_data1;
    // assign out_reg_data_r2 = regfile_data2;

endmodule