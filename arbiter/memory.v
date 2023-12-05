module memory #(
    parameter DataWidth = 8,
    parameter AddrSpaceWidth = 1024,
    parameter NumOfRequesters = 4
) (
    input CLK,
    input [(DataWidth - 1):0] ADDR,
    input [(DataWidth - 1):0] DATA_IN,
    input WRITE,
    output [(DataWidth - 1):0] DATA_OUT
);

reg [(DataWidth - 1):0] MEM [(AddrSpaceWidth - 1):0];

always @(posedge CLK)
begin
    if (WRITE) begin
        MEM[ADDR] <= DATA_IN;
    end
    else begin
        MEM <= MEM;
    end
end

assign DATA_OUT = MEM[ADDR];

endmodule