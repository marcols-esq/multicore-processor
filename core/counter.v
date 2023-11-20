module COUNTER #(
    parameter integer W
)(
    input wire  clk,
    input wire  en,
    input wire  zero,
    input wire  set,
    
    input wire [W-1:0]  data_in,
    output reg [W-1:0]  value = 0
);

always @(posedge clk) begin
    if(en) begin
             if(zero) value <= 0;
        else if(set)  value <= data_in;
        else          value <= value + 1'd1;
    end
end

endmodule