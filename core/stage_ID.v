`include "defines.vh"


module STAGE_ID (
    input  wire                     clk,
    input  wire                     en,
    input  wire                     stall,

    // from STAGE_FE

    input  wire                     flush,
    input  wire [`INST_W-1:0]       inst,

    // interface with REGFILE

    output wire [`REG_ADDR_W-1:0]   regfile_addr1,
    output wire [`REG_ADDR_W-1:0]   regfile_addr2,
    input  wire [`DATA_W-1:0]       regfile_data1,
    input  wire [`DATA_W-1:0]       regfile_data2,
    
    // decoded instruction

    output reg                      out_reg_wr,
    output reg  [`REG_ADDR_W-1:0]   out_reg_addr_rd,
    output reg  [`REG_ADDR_W-1:0]   out_reg_addr_r1,
    output reg  [`REG_ADDR_W-1:0]   out_reg_addr_r2,

    output wire [`DATA_W-1:0]       out_reg_data_r1,
    output wire [`DATA_W-1:0]       out_reg_data_r2
);

    // decoedd instruction

    wire reg_wr           = 0;
    wire reg_addr_rd      = inst[11:7];
    wire reg_addr_r1      = inst[19:15];
    wire reg_addr_r2      = inst[24:20];

    wire reg_data_r1      = regfile_data1;
    wire reg_data_r2      = regfile_data2;
    
    // interface with REGFILE

    assign regfile_addr1  = reg_addr_r1;
    assign regfile_addr2  = reg_addr_r2;


    // Pipelining registers

    always @(posedge clk) begin
        if(en && !stall) begin
            out_reg_wr           <= reg_wr;
            out_reg_addr_rd      <= reg_addr_rd;
            out_reg_addr_r1      <= reg_addr_r1;
            out_reg_addr_r2      <= reg_addr_r2;
            // out_reg_data_r1      <= reg_data_r1;
            // out_reg_data_r2      <= reg_data_r2;
        end
    end

    assign out_reg_data_r1 = reg_data_r1;
    assign out_reg_data_r2 = reg_data_r2;

endmodule