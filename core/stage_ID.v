`include "defines.vh"


module STAGE_ID (
    input  wire                     clk,
    input  wire                     en,
    input  wire                     flush,
    input  wire                     stall,

    // from STAGE_FE

    input  wire [`INST_W-1:0]       inst,

    // interface with REGFILE

    output wire [`REG_ADDR_W-1:0]   regfile_addr1,
    output wire [`REG_ADDR_W-1:0]   regfile_addr2,
    input  wire [`DATA_W-1:0]       regfile_data1,
    input  wire [`DATA_W-1:0]       regfile_data2,
    
    // decoded instruction

    output wire                     out_reg_wr,
    output wire [`REG_ADDR_W-1:0]   out_reg_addr_rd,
    output wire [`REG_ADDR_W-1:0]   out_reg_addr_r1,
    output wire [`REG_ADDR_W-1:0]   out_reg_addr_r2,

    output wire [`DATA_W-1:0]       out_reg_data_r1,
    output wire [`DATA_W-1:0]       out_reg_data_r2,
);

    assign regfile_addr1 = out_reg_addr_r1;
    assign regfile_addr2 = out_reg_addr_r2;


    assign out_reg_wr           = 0;
    assign out_reg_addr_rd      = inst[11:7];
    assign out_reg_addr_r1      = inst[19:15];
    assign out_reg_addr_r2      = inst[24:20];

    assign out_reg_data_r1      = regfile_data1;
    assign out_reg_data_r2      = regfile_data2;


    // REGFILE #(
    //     .DATA_W(`DATA_W),
    //     .ADDR_W(`REG_ADDR_W)
    // ) regfile (
    //     .clk        (clk),
    //     .en         (en && !stall),
        
    //     .wr			(reg_rd),
    //     .addr_rd	(reg_addr_rd),
    //     .addr1		(reg_addr1),
    //     .addr2		(reg_addr2),
    //     .data_rd	(reg_data_rd),
    //     .data_out1	(reg_data1),
    //     .data_out2	(reg_data2)
    // );

endmodule