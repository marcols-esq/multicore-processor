`timescale 1ns/1ns
//`include "../core/defines.vh"

module cache_tb();

reg clk = 1;
reg [31:0] cpu_data_w;
reg [31:0] cpu_addr;
reg cpu_read;
reg cpu_write;
reg cpu_atomic;
wire cpu_wait;
wire [31:0] cpu_data_r;

wire [31:0] ram_data_w;
wire [31:0] ram_addr;
wire ram_read;
wire ram_write;
wire ram_atomic;
reg ram_wait;
reg [31:0] ram_data_r;

reg FIFO_clr_n;

my_cache UUT(
	.clk(clk),

	.cpu_data_w(cpu_data_w),	//32
	.cpu_addr(cpu_addr),		//32
	.cpu_read(cpu_read),
	.cpu_write(cpu_write),
	.cpu_atomic(cpu_atomic),

	.ram_wait(ram_wait),
	.ram_data_r(ram_data_r),		//32


	.ram_data_w(ram_data_w),	//32
	.ram_addr(ram_addr),		//32
	.ram_read(ram_read),
	.ram_write(ram_write),
	.ram_atomic(ram_atomic),

	.cpu_wait(cpu_wait),
	.cpu_data_r(cpu_data_r),	//32

	.FIFO_clr_n(FIFO_clr_n)
);

always #5 clk = ~clk;

initial begin
	cpu_data_w = 0;
	cpu_addr = 0;
	cpu_read = 0;
	cpu_write = 0;
	cpu_atomic = 0;
	ram_wait = 0;
	ram_data_r = 0;
	FIFO_clr_n = 0;

	#10 FIFO_clr_n = 1;
	#10 cpu_addr = 32'd39;
	#10 cpu_data_w = 32'd1115;
		ram_wait = 1;
	#10 cpu_write = 1;
	#10 ram_wait = 0;
	#20 cpu_write = 0;

	#10 cpu_addr = 32'd67;
	#10 cpu_data_w = 32'd7777;
		ram_wait = 1;
	#10 cpu_write = 1;
	#10 ram_wait = 0;
	#20 cpu_write = 0;

	#10 cpu_read = 1;
	#10 cpu_read = 0;
	#10 cpu_addr = 32'd40;
	#10 cpu_read = 1;
	#10 cpu_read = 0;
	#10 cpu_addr = 32'd41;
	#10 cpu_read = 1;
	#10 cpu_read = 0;
	#10 cpu_addr = 32'd70;
	   ram_wait = 1;
	#10 cpu_read = 1;
	#10 ram_wait = 0;
	#10 cpu_read = 0;
	#10 cpu_addr = 32'd71;
	#10 cpu_read = 1;
	#10 cpu_read = 0;
	#10 cpu_addr = 32'd72;
	#10 cpu_read = 1;
	#10 cpu_read = 0;
	
end

initial begin
	$dumpfile("output/cache_tb.lxt");
	$dumpvars(0, cache_tb);
	$dumpon;
	#2000 $finish;
end

endmodule