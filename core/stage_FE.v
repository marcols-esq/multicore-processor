`include "defines.vh"


module STAGE_FE(
    input  wire                     clk,
    input  wire                     en,
    input  wire                     flush,
    input  wire                     stall,

    input  wire [`INST_W-1:0]       progmem_data,
    output wire [`INST_ADDR_W-1:0]  progmem_addr,


    output wire                     FE_flush,
    output wire [`INST_W-1:0]       FE_inst
);

    COUNTER #(
        .W(INST_ADDR_W),
        .INIT(0)
    ) program_counter (
        .clk        (clk),
        .en         (en && !stall),
        .zero       (flush),
        .set        (1'b0),
        
        .data_in    (0),
        .value      (progmem_addr)
    );

    assign FE_flush = flush;
    assign FE_inst  = progmem_data;

endmodule

module CROSSSTAGE_FE_ID (
    input  wire                     clk,
    input  wire                     en,
    input  wire                     stall,

    input  wire                     FE_flush,
    input  wire [`INST_W-1:0]       FE_inst,

    output wire                     FE_ID_flush,
    output wire [`INST_W-1:0]       FE_ID_inst
);


endmodule