`timescale 1ns/1ns
`include "../core/defines.vh"
`include "./src/FIFO.v"

module my_cache(
	input	clk,

	// CPU interface
	input [`DATA_W-1:0]			cpu_data_w,
	input [`DATA_ADDR_W-1:0]	cpu_addr,
	input						cpu_read,
	input						cpu_write,
	input						cpu_atomic,
	output reg					cpu_wait,
	output reg [`DATA_W-1:0]	cpu_data_r,

	// RAM interface
	output reg [`DATA_W-1:0]		ram_data_w,
	output reg [`DATA_ADDR_W-1:0]	ram_addr,
	output reg						ram_read,
	output reg						ram_write,
	output							ram_atomic,
	input							ram_wait,
	input	[`DATA_W-1:0]			ram_data_r,

	input							FIFO_clr_n
);
// valid[533] to_sync[532] 20_oldest_addr_b[531:511] 32_data_b*16[511:0]
//wire [1+20+16*`DATA_W-1:0] 

function [32-1:0] READ_DOUBLE (input [3:0] shift, input [7:0] line);
	case (shift)
		0:		READ_DOUBLE = cache_page [line] [1*32-1:0*32];
		1:		READ_DOUBLE = cache_page [line] [2*32-1:1*32];
		2:		READ_DOUBLE = cache_page [line] [3*32-1:2*32];
		3:		READ_DOUBLE = cache_page [line] [4*32-1:3*32];
		4:		READ_DOUBLE = cache_page [line] [5*32-1:4*32];
		5:		READ_DOUBLE = cache_page [line] [6*32-1:5*32];
		6:		READ_DOUBLE = cache_page [line] [7*32-1:6*32];
		7:		READ_DOUBLE = cache_page [line] [8*32-1:7*32];
		8:		READ_DOUBLE = cache_page [line] [9*32-1:8*32];
		9:		READ_DOUBLE = cache_page [line] [10*32-1:9*32];
		10:		READ_DOUBLE = cache_page [line] [11*32-1:10*32];
		11:		READ_DOUBLE = cache_page [line] [12*32-1:11*32];
		12:		READ_DOUBLE = cache_page [line] [13*32-1:12*32];
		13:		READ_DOUBLE = cache_page [line] [14*32-1:13*32];
		14:		READ_DOUBLE = cache_page [line] [15*32-1:14*32];
		default READ_DOUBLE = cache_page [line] [16*32-1:15*32];
	endcase
endfunction

task REFRESH(input [3:0] shift, input [7:0] line, input [31:0] source_data);
	case (shift)
		0:		cache_page [line] [1*32-1:0*32] <= source_data;
		1:		cache_page [line] [2*32-1:1*32] <= source_data;
		2:		cache_page [line] [3*32-1:2*32] <= source_data;
		3:		cache_page [line] [4*32-1:3*32] <= source_data;
		4:		cache_page [line] [5*32-1:4*32] <= source_data;
		5:		cache_page [line] [6*32-1:5*32] <= source_data;
		6:		cache_page [line] [7*32-1:6*32] <= source_data;
		7:		cache_page [line] [8*32-1:7*32] <= source_data;
		8:		cache_page [line] [9*32-1:8*32] <= source_data;
		9:		cache_page [line] [10*32-1:9*32] <= source_data;
		10:		cache_page [line] [11*32-1:10*32] <= source_data;
		11:		cache_page [line] [12*32-1:11*32] <= source_data;
		12:		cache_page [line] [13*32-1:12*32] <= source_data;
		13:		cache_page [line] [14*32-1:13*32] <= source_data;
		14:		cache_page [line] [15*32-1:14*32] <= source_data;
		default cache_page [line] [16*32-1:15*32] <= source_data;
	endcase
endtask

reg [533:0] cache_page [0:255];
reg [4:0] i = 0;
reg [8:0] j = 0;
reg [7:0] fifo_in = 0;
wire [7:0] fifo_out = 0;
reg push = 0;
reg pop = 0;
wire [7:0] fifo_cnt;

always @(posedge clk) begin
	if (cpu_write || cpu_read) begin																					// if write or read
		if ((cache_page [cpu_addr[11:4]] [531:512] !== cpu_addr[31:12]) || (cache_page [cpu_addr[11:4]] [533] !== 1)) begin		// if line not in cache or not valid
			cpu_wait <= 1'b1;
			ram_read <= 1'b1;
			cache_page [cpu_addr[11:4]] [531:512] <= cpu_addr[31:12];
			for	 (i = 0; i < 16; i=i+1) begin
				wait (ram_wait == 0);														// remove the need for wait with two ifs
				ram_addr <= {cpu_addr[31:12], cpu_addr[11:4], i[3:0]};
				REFRESH(i[3:0],cpu_addr[11:4],ram_data_r[31:0]);
			end
			ram_read <= 1'b0;
			cache_page [cpu_addr[11:4]] [533] <= 1'b1;										// set valid bit
		end
	end

	if (cpu_write) begin																	// -------- Write --------
		if ((cache_page [cpu_addr[11:4]] [531:512] == cpu_addr[31:12]) && (cache_page [cpu_addr[11:4]] [533])) begin	// check if 20 page bits match & if valid
			cache_page [cpu_addr[11:4]] [531:512] <= cpu_addr[31:12];						// update page address received from CPU
			REFRESH(cpu_addr[3:0],cpu_addr[11:4],cpu_data_w[31:0]);
			cache_page [cpu_addr[11:4]] [533] <= 1'b1;										// set valid bit
			cache_page [cpu_addr[11:4]] [532] <= 1'b1;										// set to_sync bit
			fifo_in [7:0] <= cpu_addr[11:4];
			cpu_wait <= 1'b0;
			push <= 1'b1;
			@(posedge clk)
			push <= 1'b0;
		end
	end 
	else if (cpu_read) begin																// -------- Read --------
		if ((cache_page [cpu_addr[11:4]] [531:512] == cpu_addr[31:12]) && (cache_page [cpu_addr[11:4]] [533])) begin	// check if 20 page bits match & if valid
			cpu_data_r <= READ_DOUBLE(cpu_addr[3:0],cpu_addr[11:4]);
			cpu_wait <= 1'b0;
		end
	end
	else if (fifo_cnt > 0) begin
		if (cache_page [fifo_out] [533:532] == 2'b11) begin									// if valid and to_sync (newer data not synced with ram)
			for (i = 0; i < 16; i=i+1) begin
				ram_addr <= {cache_page[fifo_out][531:512], fifo_out, i[3:0]};
				ram_write <= 1'b0;
				wait (ram_wait == 0);														// remove the need for wait with two ifs
				ram_data_w <= READ_DOUBLE(i[3:0],fifo_out);
				ram_write <= 1'b1;
			end																				// ### remove this for, one check is enough
			cache_page [fifo_out] [532] <= 1'b0;											// reset to_sync bit
		end
		pop <= 1;
		@(posedge clk)
		pop <= 0;
	end
end

FIFO #(
	.FIFO_WIDTH(8),
	.FIFO_DEPTH(256),
	.FIFO_PNTR_W(8),
	.FIFO_CNTR_W(8)
)FIFO_sync(
	.data_in(fifo_in),
	.clk(clk),
	.FIFO_clr_n(FIFO_clr_n),
	.FIFO_reset_n(1'b1),
	.push(push),
	.pop(pop),
	.cnt(fifo_cnt),

	.data_out(fifo_out)
);

endmodule

/* TODO
- jak ustawiać not valid linii cache'a (osobna szyna adresowa pomiędzy cache'ami czy output do ramu inout)
- skąd się biorą dane i adresy atomic. (wewnętrzne szyny adresowe pomiędzy cache'ami czy od strony RAMu)
