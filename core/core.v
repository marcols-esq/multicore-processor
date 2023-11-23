`include "defines.vh"

module CORE (
    input  wire                     clk,
    input  wire                     en,

    input  wire [`INST_W-1:0]       progmem_data,
    output wire [`INST_ADDR_W-1:0]  progmem_addr
);


// STAGE FE with JUMPS

wire                     jump;
wire [`INST_ADDR_W-1:0]  jump_addr;
wire                     flush_jump;


wire                     FE_ID_flush;
wire [`INST_ADDR_W-1:0]  FE_ID_pc;
wire [`INST_W-1:0]       FE_ID_inst;


STAGE_FE stage_fe(
    .clk            (clk),
    .en             (en),
    .stall          (1'b0),
    .flush          (1'b0),

    // Jumps
    
    .jump           (jump),
    .jump_addr      (jump_addr),

    // Interface with PROGRAM MEMORY

    .progmem_data   (progmem_data),
    .progmem_addr   (progmem_addr),

    // Fetched instruction

    .out_flush_jump (flush_jump),
    .out_inst       (FE_ID_inst),

    .out_pc         (FE_ID_pc),
    .out_flush      (FE_ID_flush)
);

// STAGE ID with REGFILE

 wire                   regfile_wr;
 wire [`REG_ADDR_W-1:0] regfile_addr_wr;
 wire [`REG_ADDR_W-1:0] regfile_addr1;
 wire [`REG_ADDR_W-1:0] regfile_addr2;
 wire [`DATA_W-1:0]     regfile_data_wr;
 wire [`DATA_W-1:0]     regfile_data1;
 wire [`DATA_W-1:0]     regfile_data2;

REGFILE #(
	.DATA_W(`DATA_W),
	.ADDR_W(`REG_ADDR_W)
) regfile (
	.clk            (clk),
	.en             (en),

	.wr             (regfile_wr),
	.addr_wr        (regfile_addr_wr),
	.addr1          (regfile_addr1),
	.addr2          (regfile_addr2),
	.data_wr        (regfile_data_wr),
	.data_out1      (regfile_data1),
	.data_out2      (regfile_data2)
);

wire                     ID_EX_flush;
wire [`INST_ADDR_W-1:0]  ID_EX_pc;
wire                     ID_EX_reg_wr;
wire [`REG_ADDR_W-1:0]   ID_EX_reg_addr_rd;
wire [`REG_ADDR_W-1:0]   ID_EX_reg_addr_r1;
wire [`REG_ADDR_W-1:0]   ID_EX_reg_addr_r2;

wire [3:0]               ID_EX_alu_op;
wire [`ALU_SRC_W-1:0]    ID_EX_alu_src_arg1;
wire [`ALU_SRC_W-1:0]    ID_EX_alu_src_arg2;
wire [`DATA_W-1:0]       ID_EX_imm;

wire                     ID_EX_is_jump;
wire                     ID_EX_is_branch;
wire [2:0]               ID_EX_branch_type;

STAGE_ID stage_id (
    .clk            (clk),
    .en             (en),
    .stall          (1'b0),

    // from STAGE_FE

    .flush          (FE_ID_flush || flush_jump),
    .inst           (FE_ID_inst),
    .pc             (FE_ID_pc),

    // interface with REGFILE

    .regfile_addr1  (regfile_addr1),
    .regfile_addr2  (regfile_addr2),
    // .regfile_data1  (regfile_data1),
    // .regfile_data2  (regfile_data2),
    
    // decoded instruction

    .out_reg_wr          (ID_EX_reg_wr),
    .out_reg_addr_rd     (ID_EX_reg_addr_rd),
    .out_reg_addr_r1     (ID_EX_reg_addr_r1),
    .out_reg_addr_r2     (ID_EX_reg_addr_r2),

    .out_alu_op          (ID_EX_alu_op),
    .out_alu_src_arg1    (ID_EX_alu_src_arg1),
    .out_alu_src_arg2    (ID_EX_alu_src_arg2),

    .out_is_jump         (ID_EX_is_jump),
    .out_is_branch       (ID_EX_is_branch),
    .out_branch_type     (ID_EX_branch_type),

    .out_imm             (ID_EX_imm),

    .out_pc              (ID_EX_pc),
    .out_flush           (ID_EX_flush)
);


// STAGE EX

wire                    EX_MM_reg_wr;
wire [`REG_ADDR_W-1:0]  EX_MM_reg_addr_rd;
wire [`DATA_W-1:0]		EX_MM_reg_data_rd;

wire					EX_MM_flush;

wire [`DATA_W-1:0]		MM_WB_reg_data_rd;
wire                    MM_WB_reg_wr;
wire [`REG_ADDR_W-1:0]  MM_WB_reg_addr_rd;

STAGE_EX stage_ex(
    .clk                        (clk),
    .en                         (en),
    .stall                      (1'b0),

    // from STAGE_ID

    .flush                      (ID_EX_flush || flush_jump),
    .pc                         (ID_EX_pc),

    .reg_wr                     (ID_EX_reg_wr),
    .reg_addr_rd                (ID_EX_reg_addr_rd),
    .reg_addr_r1                (ID_EX_reg_addr_r1),
    .reg_addr_r2                (ID_EX_reg_addr_r2),

    .alu_op                     (ID_EX_alu_op),
	.alu_src_arg1               (ID_EX_alu_src_arg1),
	.alu_src_arg2               (ID_EX_alu_src_arg2),

    .imm                        (ID_EX_imm),
    .reg_data_r1                (regfile_data1),
    .reg_data_r2                (regfile_data2),

    .is_jump                    (ID_EX_is_jump),
    .is_branch                  (ID_EX_is_branch),
    .branch_type                (ID_EX_branch_type),
    

	// FFW From STAGE_EX
    .ffw_EX_reg_wr              (EX_MM_reg_wr),
    .ffw_EX_reg_addr_rd         (EX_MM_reg_addr_rd),
    .ffw_EX_reg_data_rd         (EX_MM_reg_data_rd),
	// FFW From STAGE_MM
    .ffw_MM_reg_wr              (MM_WB_reg_wr),
    .ffw_MM_reg_addr_rd         (MM_WB_reg_addr_rd),
    .ffw_MM_reg_data_rd         (MM_WB_reg_data_rd),
	// // FFW From STAGE_WB
    // .ffw_WB_reg_wr              (regfile_wr),
    // .ffw_WB_reg_addr_rd         (regfile_addr_wr),
    // .ffw_WB_reg_data_rd         (regfile_data_wr),

    // JUMP
    
    .jump                       (jump),
    .jump_addr                  (jump_addr),

    // Execution result

    .out_reg_wr                 (EX_MM_reg_wr),
    .out_reg_addr_rd            (EX_MM_reg_addr_rd),
	.out_reg_data_rd            (EX_MM_reg_data_rd),

	.out_flush                  (EX_MM_flush)
    
);

// STAGE_MM

wire					MM_WB_flush;

STAGE_MM stage_mm (
    .clk                        (clk),
    .en                         (en),
    .stall                      (1'b0),

    // from STAGE_EX

    .flush                      (EX_MM_flush),

	.reg_wr                     (EX_MM_reg_wr),
	.reg_addr_rd                (EX_MM_reg_addr_rd),
	.reg_data_rd                (EX_MM_reg_data_rd),


    // To STAGE_WB

	.out_reg_wr                 (MM_WB_reg_wr),
	.out_reg_addr_rd            (MM_WB_reg_addr_rd),
	.out_reg_data_rd            (MM_WB_reg_data_rd),

	.out_flush                  (MM_WB_flush)
);

// STAGE_WB

STAGE_WB stage_wb (
    // .clk                        (clk),
    // .en                         (en),
    .stall                      (1'b0),

    // from STAGE_MM

    .flush                      (MM_WB_flush),

	.reg_wr                     (MM_WB_reg_wr),
	.reg_addr_rd                (MM_WB_reg_addr_rd),
	.reg_data_rd                (MM_WB_reg_data_rd),

    // interface with REGFILE

	.regfile_wr                 (regfile_wr),
	.regfile_addr_wr            (regfile_addr_wr),
	.regfile_data_wr            (regfile_data_wr)
);

endmodule