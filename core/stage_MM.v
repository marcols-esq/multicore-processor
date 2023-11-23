`include "defines.vh"


module STAGE_MM (
    input  wire                     clk,
    input  wire                     en,
    input  wire                     stall,

    // from STAGE_EX

    input  wire                     flush,

	input  wire 					reg_wr,
	input  wire [`REG_ADDR_W-1:0]	reg_addr_rd,
	input  wire [`DATA_W-1:0]		reg_data_rd,


    // To STAGE_WB

	output reg  					out_reg_wr,
	output reg  [`REG_ADDR_W-1:0]	out_reg_addr_rd,
	output reg  [`DATA_W-1:0]		out_reg_data_rd,

	output reg 						out_flush = 1'b1
    
);

	// TODO

    // Pipelining registers

    always @(posedge clk) begin
        if(en && !stall) begin
			out_reg_wr			<= reg_wr;
			out_reg_addr_rd		<= reg_addr_rd;
			out_reg_data_rd		<= reg_data_rd;
			out_flush			<= flush;
        end
    end


endmodule