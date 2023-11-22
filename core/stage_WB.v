`include "defines.vh"


module STAGE_WB (
    // input  wire                     clk,
    // input  wire                     en,
    input  wire                     stall,

    // from STAGE_MM

    input  wire                     flush,

	input  wire 					reg_wr,
	input  wire [`REG_ADDR_W-1:0]	reg_addr_rd,
	input  wire [`DATA_W-1:0]		alu_res,

    // interface with REGFILE

	output wire 					regfile_wr,
	output wire [`REG_ADDR_W-1:0]	regfile_addr_wr,
	output wire [`DATA_W-1:0]		regfile_data_wr
    
);

    assign regfile_wr           =   reg_wr && !flush && !stall;
    assign regfile_addr_wr      =   reg_addr_rd;
    assign regfile_data_wr      =   alu_res;


endmodule