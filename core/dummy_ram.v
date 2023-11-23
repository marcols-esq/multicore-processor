module DUMMY_RAM #(
	parameter integer DATA_W = 0,
	parameter integer ADDR_W = 0,
	parameter integer SIZE = 2**ADDR_W
) (
	input  wire 			 clk,
	input  wire				 en,
    
    output wire [DATA_W-1:0]        mem_data_r,
    input  wire [DATA_W-1:0]        mem_data_w,
    input  wire [ADDR_W-1:0]        mem_addr,
    input  wire                     mem_read,
    input  wire                     mem_write,
    output wire                     mem_wait

);

reg [DATA_W-1:0] data [1:SIZE-1];

reg [ADDR_W-1:0] last_read_addr = 0;
reg [DATA_W-1:0] last_read_data = 0;


assign mem_data_r = last_read_data;
assign mem_wait   = mem_read && (last_read_addr != mem_addr);

always @(posedge clk) begin
	if(en) begin
		if(mem_write) begin
            data[mem_addr] <= mem_data_w;
        end
        if(mem_read) begin
            #21 last_read_data <= data[mem_addr];
                last_read_addr <= mem_addr;
        end
	end
end


endmodule