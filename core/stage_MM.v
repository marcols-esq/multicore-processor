`include "defines.vh"


module STAGE_MM (
    input  wire                     clk,
    input  wire                     en,
    input  wire                     stall,

    // from STAGE_EX

    input  wire                     flush,

	input  wire 					is_load,
	input  wire 					is_store,
	input  wire 					reg_wr,
	input  wire [`REG_ADDR_W-1:0]	reg_addr_rd,
	input  wire [`DATA_W-1:0]		reg_data_rd,
	input  wire [`DATA_ADDR_W-1:0]  alu_mem_addr,

    output wire [`DATA_W-1:0]       ffw_MM_data_wr,

	// Interface with RAM
	
    input  wire [`DATA_W-1:0]       mem_data_r,
    output wire [`DATA_W-1:0]       mem_data_w,
    output wire [`DATA_ADDR_W-1:0]  mem_addr,
    output                          mem_read,
    output                          mem_write,
    // input                           mem_wait,

    // To STAGE_WB

	output reg  					out_reg_wr,
	output reg  [`REG_ADDR_W-1:0]	out_reg_addr_rd,
	output reg  [`DATA_W-1:0]		out_reg_data_rd,

	output reg 						out_flush = 1'b1
    
);

	// Interface with RAM

	assign mem_write	= is_store && !flush;
	assign mem_read 	= is_load  && !flush;
	assign mem_addr	    = alu_mem_addr;

	assign mem_data_w	= out_reg_data_rd;

	wire [`DATA_W-1:0] true_data_to_wr = is_load ? mem_data_r : reg_data_rd;
	
	assign ffw_MM_data_wr = true_data_to_wr;

    // Pipelining registers

    always @(posedge clk) begin
        if(en && !stall) begin
			out_reg_wr			<= reg_wr || is_load;
			out_reg_addr_rd		<= reg_addr_rd;
			out_reg_data_rd		<= true_data_to_wr;
			out_flush			<= flush;
        end
    end


endmodule