`timescale 1ns/1ns

module FIFO #(
	parameter FIFO_WIDTH = 0,
	parameter FIFO_DEPTH = 0,
	parameter FIFO_PNTR_W = 0,
	parameter FIFO_CNTR_W = 0
)(
	input	[FIFO_WIDTH-1:0]	data_in,
	input	clk, FIFO_clr_n, FIFO_reset_n, push, pop,

	output	[FIFO_WIDTH-1:0]	data_out,
	output reg [FIFO_PNTR_W-1:0] cnt

);

reg [FIFO_WIDTH-1:0] FIFO [0:FIFO_DEPTH-1];
reg [FIFO_PNTR_W-1:0] top;
reg [FIFO_PNTR_W-1:0] btm;


reg [FIFO_DEPTH:0] i = 0;

always @(posedge clk or negedge FIFO_clr_n) begin
	if (!FIFO_clr_n) begin
		top <= 0;
		btm <= 0;
		cnt <= 0;
		for (i = 0; i < FIFO_DEPTH; i=i+1)
									FIFO[i] <= 0;
	end
	if (!FIFO_reset_n) begin
		top <= 0;
		btm <= 0;
		cnt <= 0;
	end else 
	case ({push,pop})
		2'b10: //write
			begin
				FIFO[top] <= data_in;
				top <= top + 1;
				cnt <= cnt + 1;
			end
		2'b01: //read
			begin
				btm <= btm + 1;
				cnt <= cnt - 1;
			end
		2'b11:
			begin
				FIFO[top] <= data_in;
				top <= top + 1;
				btm <= btm + 1;
			end
	endcase
end

assign data_out = FIFO[btm];

endmodule