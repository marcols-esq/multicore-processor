module REGFILE #(
	parameter integer DATA_W = 0,
	parameter integer ADDR_W = 0,
	parameter integer SIZE = 2**ADDR_W
) (
	input  wire 			 clk,
	input  wire				 en,
	input  wire				 stall,
	input  wire 			 wr,

	input  wire [ADDR_W-1:0] addr_wr,
	input  wire [ADDR_W-1:0] addr1,
	input  wire [ADDR_W-1:0] addr2,

	input  wire [DATA_W-1:0] data_wr,
	output reg  [DATA_W-1:0] data_out1,
	output reg  [DATA_W-1:0] data_out2
);

reg [DATA_W-1:0] REGS [1:SIZE-1];

always @(posedge clk) begin
	if(en && !stall) begin
		if(wr && addr_wr != 0) begin
			REGS[addr_wr] <= data_wr;
		end
		data_out1 <= addr1 ? ((wr && addr1 == addr_wr) ? data_wr : REGS[addr1]) : 0;
		data_out2 <= addr2 ? ((wr && addr2 == addr_wr) ? data_wr : REGS[addr2]) : 0;
	end
end


endmodule