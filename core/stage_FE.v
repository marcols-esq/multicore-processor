`include "defines.vh"


module STAGE_FE(
    input  wire                     clk,
    input  wire                     en,
    input  wire                     flush,
    input  wire                     stall,

    // Jumps

    input  wire                     jump,
    input  wire [`INST_ADDR_W-1:0]  jump_addr,

    // Interface with PROGRAM MEMORY

    input  wire [`INST_W-1:0]       progmem_data,
    output wire [`INST_ADDR_W-1:0]  progmem_addr,

    // Fetched instruction

    output reg  [`INST_ADDR_W-1:0]  out_pc,
    output reg  [`INST_W-1:0]       out_inst,
    output reg                      out_flush_jump,
    output reg                      out_flush = 1'b1
);


    // Program counter
    reg  [`INST_ADDR_W-1:0] PC      = 0;
    wire [`INST_ADDR_W-1:0] PC_next = jump ? jump_addr : PC + 3'h4;    

    assign progmem_addr = PC;
    wire [`INST_W-1:0] inst = progmem_data;

    always @(posedge clk) begin
        if(en && !stall) begin
            PC <= flush ? 0 : PC_next;
        end
    end

    // assign out_pc = PC;
    
    // Pipelining registers

    always @(posedge clk) begin
        if(en && !stall) begin
            out_flush       <= flush;
            out_flush_jump  <= jump;
            out_inst        <= inst;
            out_pc          <= PC;
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