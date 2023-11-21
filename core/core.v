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

 wire [`REG_ADDR_W-1:0] regfile_addr_wr = 0;
 wire [`REG_ADDR_W-1:0] regfile_addr1;
 wire [`REG_ADDR_W-1:0] regfile_addr2;
 wire [`DATA_W-1:0]     regfile_data_wr = 0;
 wire [`DATA_W-1:0]     regfile_data1;
 wire [`DATA_W-1:0]     regfile_data2;

REGFILE #(
	.DATA_W(`DATA_W),
	.ADDR_W(`REG_ADDR_W)
) regfile (
	.clk            (clk),
	.en             (en),

	.wr             (1'b0),
	.addr_wr        (regfile_addr_wr),
	.addr1          (regfile_addr1),
	.addr2          (regfile_addr2),
	.data_wr        (regfile_data_wr),
	.data_out1      (regfile_data1),
	.data_out2      (regfile_data2)
);

wire                     ID_EX_reg_wr;
wire [`REG_ADDR_W-1:0]   ID_EX_reg_addr_rd;
wire [`REG_ADDR_W-1:0]   ID_EX_reg_addr_r1;
wire [`REG_ADDR_W-1:0]   ID_EX_reg_addr_r2;
wire [`DATA_W-1:0]       ID_EX_reg_data_r1;
wire [`DATA_W-1:0]       ID_EX_reg_data_r2;

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
    .regfile_data1  (regfile_data1),
    .regfile_data2  (regfile_data2),
    
    // decoded instruction

    .out_reg_wr      (ID_EX_reg_wr),
    .out_reg_addr_rd (ID_EX_reg_addr_rd),
    .out_reg_addr_r1 (ID_EX_reg_addr_r1),
    .out_reg_addr_r2 (ID_EX_reg_addr_r2),
    .out_reg_data_r1 (ID_EX_reg_data_r1),
    .out_reg_data_r2 (ID_EX_reg_data_r2)
);


endmodule