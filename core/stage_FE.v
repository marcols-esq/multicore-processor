`include "defines.vh"


module STAGE_FE(
    input  wire                     clk,
    input  wire                     en,
    input  wire                     flush,
    input  wire                     stall,

    // Interface with PROGRAM MEMORY

    input  wire [`INST_W-1:0]       progmem_data,
    output wire [`INST_ADDR_W-1:0]  progmem_addr,

    // Fetched instruction

    output reg                      out_flush,
    output reg  [`INST_W-1:0]       out_inst
);


    // Program counter
    reg [`INST_ADDR_W-1:0] PC = 0;    

    assign progmem_addr = PC;
    wire [`INST_W-1:0] inst = progmem_data;

    always @(posedge clk) begin
        if(en && !stall) begin
            PC <= flush ? 0 : PC + 1'd1;
        end
    end
    
    // Pipelining registers

    always @(posedge clk) begin
        if(en && !stall) begin
            out_flush <= flush;
            out_inst  <= inst;
        end
    end

endmodule


// COUNTER #(
//     .W(INST_ADDR_W),
//     .INIT(0)
// ) program_counter (
//     .clk        (clk),
//     .en         (en && !stall),
//     .zero       (flush),
//     .set        (1'b0),
    
//     .data_in    (0),
//     .value      (progmem_addr)
// );