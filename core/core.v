`include "defines.vh"

module CORE (
    input  wire                     clk,
    input  wire                     en,

    input  wire [`INST_W-1:0]       progmem_data,
    output wire [`INST_ADDR_W-1:0]  progmem_addr
);


// STAGE FE

wire                     FE_ID_flush;
wire [`INST_W-1:0]       FE_ID_inst;


STAGE_FE stage_fe(
    .clk            (clk),
    .en             (en),
    .stall          (1'b0),
    .flush          (1'b0),

    // Interface with PROGRAM MEMORY

    .progmem_data   (progmem_data),
    .progmem_addr   (progmem_addr),

    // Fetched instruction

    .out_flush      (FE_ID_flush),
    .out_inst       (FE_ID_inst)
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
wire                     ID_EX_reg_wr;
wire [`REG_ADDR_W-1:0]   ID_EX_reg_addr_rd;
wire [`REG_ADDR_W-1:0]   ID_EX_reg_addr_r1;
wire [`REG_ADDR_W-1:0]   ID_EX_reg_addr_r2;

wire [3:0]               ID_EX_alu_op;
wire [`ALU_SRC_W-1:0]    ID_EX_alu_src_arg1;
wire [`ALU_SRC_W-1:0]    ID_EX_alu_src_arg2;
wire [`DATA_W-1:0]       ID_EX_imm;

STAGE_ID stage_id (
    .clk            (clk),
    .en             (en),
    .stall          (1'b0),

    // from STAGE_FE

    .flush          (FE_ID_flush),
    .inst           (FE_ID_inst),

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

    .out_imm             (ID_EX_imm),

    .out_flush           (ID_EX_flush)
);


// STAGE EX

wire [`DATA_W-1:0]		EX_MM_alu_res;
wire                    EX_MM_reg_wr;
wire [`REG_ADDR_W-1:0]  EX_MM_reg_addr_rd;

wire					EX_MM_flush;

STAGE_EX stage_ex(
    .clk                        (clk),
    .en                         (en),
    .stall                      (1'b0),

    // from STAGE_ID

    .flush                      (ID_EX_flush),

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
    
    // Execution result

	.out_alu_res                (EX_MM_alu_res),
    .out_reg_wr                 (EX_MM_reg_wr),
    .out_reg_addr_rd            (EX_MM_reg_addr_rd),

	.out_flush                  (EX_MM_flush)
    
);

// STAGE_MM


wire [`DATA_W-1:0]		MM_WB_alu_res;
wire                    MM_WB_reg_wr;
wire [`REG_ADDR_W-1:0]  MM_WB_reg_addr_rd;

wire					MM_WB_flush;

STAGE_MM stage_mm (
    .clk                        (clk),
    .en                         (en),
    .stall                      (1'b0),

    // from STAGE_EX

    .flush                      (EX_MM_flush),

	.reg_wr                     (EX_MM_reg_wr),
	.reg_addr_rd                (EX_MM_reg_addr_rd),
	.alu_res                    (EX_MM_alu_res),


    // To STAGE_WB

	.out_reg_wr                 (MM_WB_reg_wr),
	.out_reg_addr_rd            (MM_WB_reg_addr_rd),
	.out_alu_res                (MM_WB_alu_res),

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
	.alu_res                    (MM_WB_alu_res),

    // interface with REGFILE

	.regfile_wr                 (regfile_wr),
	.regfile_addr_wr            (regfile_addr_wr),
	.regfile_data_wr            (regfile_data_wr)
);

endmodule