`include "defines.vh"


module STAGE_EX (
    input  wire                     clk,
    input  wire                     en,
    input  wire                     stall,

    // from STAGE_ID

    input  wire                     flush,
    input  wire [`INST_ADDR_W-1:0]  pc,

    input  wire                     reg_wr,
    input  wire [`REG_ADDR_W-1:0]   reg_addr_rd,
    input  wire [`REG_ADDR_W-1:0]   reg_addr_r1,
    input  wire [`REG_ADDR_W-1:0]   reg_addr_r2,

    input  wire [3:0]               alu_op,
	input  wire [`ALU_SRC_W-1:0]    alu_src_arg1,
	input  wire [`ALU_SRC_W-1:0]    alu_src_arg2,
    
	input  wire [`DATA_W-1:0]		imm,
	input  wire [`DATA_W-1:0]		reg_data_r1,
	input  wire [`DATA_W-1:0]		reg_data_r2,

    input  wire                     is_branch,
    input  wire [2:0]               branch_type,

	// FFW From STAGE_EX
    input  wire                     ffw_EX_reg_wr,
    input  wire [`REG_ADDR_W-1:0]   ffw_EX_reg_addr_rd,
    input  wire [`DATA_W-1:0]   	ffw_EX_reg_data_rd,
	// FFW From STAGE_MM
    input  wire                     ffw_MM_reg_wr,
    input  wire [`REG_ADDR_W-1:0]   ffw_MM_reg_addr_rd,
    input  wire [`DATA_W-1:0]   	ffw_MM_reg_data_rd,
	// // FFW From STAGE_WB
    // input  wire                     ffw_WB_reg_wr,
    // input  wire [`REG_ADDR_W-1:0]   ffw_WB_reg_addr_rd,
    // input  wire [`DATA_W-1:0]   	ffw_WB_reg_data_rd,

    // JUMPS

    output wire                     jump,
    output wire [`INST_ADDR_W-1:0]  jump_addr,

    // Execution result

    output reg                      out_reg_wr,
    output reg  [`REG_ADDR_W-1:0]   out_reg_addr_rd,
	output reg  [`DATA_W-1:0]		out_alu_res,

	output reg 						out_flush = 1'b1
    
);

	// Argumennts decode

	
    wire [`DATA_W-1:0] reg_data_r1_ffw = 
		(ffw_EX_reg_wr && ffw_EX_reg_addr_rd == reg_addr_r1) ? 	ffw_EX_reg_data_rd :
		(ffw_MM_reg_wr && ffw_MM_reg_addr_rd == reg_addr_r1) ? 	ffw_MM_reg_data_rd :
		// (ffw_WB_reg_wr && ffw_WB_reg_addr_rd == reg_addr_r1) ? 	ffw_WB_reg_data_rd :
																reg_data_r1;

    wire [`DATA_W-1:0] reg_data_r2_ffw = 
		(ffw_EX_reg_wr && ffw_EX_reg_addr_rd == reg_addr_r2) ? 	ffw_EX_reg_data_rd :
		(ffw_MM_reg_wr && ffw_MM_reg_addr_rd == reg_addr_r2) ? 	ffw_MM_reg_data_rd :
		// (ffw_WB_reg_wr && ffw_WB_reg_addr_rd == reg_addr_r2) ? 	ffw_WB_reg_data_rd :
																reg_data_r2;
	
    wire [`DATA_W-1:0] alu_arg1 = alu_src_arg1 == `ALU_SRC_PC  ? pc  : reg_data_r1_ffw;
    wire [`DATA_W-1:0] alu_arg2 = alu_src_arg2 == `ALU_SRC_IMM ? imm : reg_data_r2_ffw;


	// ALU

	wire [`DATA_W-1:0] alu_res = 
		alu_op == `ALU_OP_ADD ?	alu_arg1 + alu_arg2 :
		alu_op == `ALU_OP_SUB ? alu_arg1 - alu_arg2 :
		alu_op == `ALU_OP_AND ? alu_arg1 & alu_arg2 :
		alu_op == `ALU_OP_XOR ? alu_arg1 ^ alu_arg2 :
		`DATA_W'bx;

    // JUMPS

    wire signed [`DATA_W-1:0]  reg_data_r1_ffw_s = reg_data_r1_ffw; 
    wire signed [`DATA_W-1:0]  reg_data_r2_ffw_s = reg_data_r2_ffw; 
    wire               branch_condition = 
        branch_type == `func3_BEQ   ? reg_data_r1_ffw   == reg_data_r2_ffw     :
        branch_type == `func3_BNE   ? reg_data_r1_ffw   != reg_data_r2_ffw     :
        branch_type == `func3_BLT   ? reg_data_r1_ffw_s <  reg_data_r2_ffw_s   :
        branch_type == `func3_BGE   ? reg_data_r1_ffw_s >= reg_data_r2_ffw_s   :
        branch_type == `func3_BLTU  ? reg_data_r1_ffw   <  reg_data_r2_ffw     :
        branch_type == `func3_BGEU  ? reg_data_r1_ffw   >= reg_data_r2_ffw     :
                                      1'b0;
    wire               perform_branch = is_branch && branch_condition;

    assign             jump         = perform_branch && !flush;
    assign             jump_addr    = alu_res;

    // Pipelining registers

    always @(posedge clk) begin
        if(en && !stall) begin
			out_alu_res 	<= alu_res;
			out_reg_wr 		<= reg_wr && !flush;
			out_reg_addr_rd <= reg_addr_rd;
			out_flush		<= flush;
        end
    end


endmodule