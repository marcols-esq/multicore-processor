`timescale 1ns/1ns

module FIFO_tb #(
	parameter FIFO_DEPTH = 256,
	parameter FIFO_WIDTH = 8,
	parameter FIFO_PNTR_W = 4,
	parameter FIFO_CNTR_W = 4
);

wire	[FIFO_WIDTH-1:0]	data_out;
reg		[FIFO_WIDTH-1:0]	data_in;
reg	clk, FIFO_clr_n, FIFO_reset_n, push, pop;

always #5 clk = ~clk;
initial begin
	clk = 1'b0;
	FIFO_reset_n = 1'b1;
	FIFO_clr_n = 1'b0;
	push = 0;
	pop = 0;
	#10 FIFO_clr_n = 1'b1;
	#5 data_in = 8'hA2;
	push = 1;
	#5 push = 0;
	#5 data_in = 8'hA8;
	push = 1;
	#5 push = 0;
	#5 data_in = 8'h1C;
	push = 1;
	#5 push = 0;
	#5 data_in = 8'h8B;
	push = 1;
	#5 push = 0;
	#5 pop = 1;
	#5 pop = 0;
	#5 pop = 1;
	#5 pop = 0;
	#5 pop = 1;
	#5 pop = 0;
	#5 pop = 1;
	#5 pop = 0;

end

FIFO #(
	.FIFO_WIDTH(FIFO_WIDTH),
	.FIFO_DEPTH(FIFO_DEPTH),
	.FIFO_PNTR_W(FIFO_PNTR_W),
	.FIFO_CNTR_W(FIFO_CNTR_W)
)UUT(
	.data_in(data_in),
	.clk(clk),
	.FIFO_clr_n(FIFO_clr_n),
	.FIFO_reset_n(FIFO_reset_n),
	.push(push),
	.pop(pop),

	.data_out(data_out)
);

initial begin
	$dumpfile ("output/FIFO_tb.lxt");
	$dumpvars (0, FIFO_tb);
	#1000 $finish;
end

endmodule
