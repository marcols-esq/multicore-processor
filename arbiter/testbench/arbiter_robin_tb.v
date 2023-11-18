`timescale 1ns/100ps

module arbiter_robin_tb;

parameter NumOfRequesters = 4;

reg CLK;
reg [(NumOfRequesters - 1):0] REQ;
wire [(NumOfRequesters - 1):0] ACCESS;

arbiter #(
    .NumOfRequesters(NumOfRequesters),
    .RoundRobin(1)
) ARBITER (
    .CLK(CLK),
    .REQ(REQ),
    .ACCESS(ACCESS)
);

always #5 CLK = ~CLK;
initial begin
    CLK = 0;
    REQ = 0;

    #15 REQ[1] = 1;
    REQ[2] = 1;
    #10 REQ[1] = 0;
    #10 REQ[2] = 0;
    #20 REQ[3] = 1;
    #10 REQ[2] = 1;
    REQ[1] = 1;
    #10 REQ[3] = 0;
    #10 REQ[0] = 1;
    #10 REQ[1] = 0;
    #10 REQ[2] = 0;
    #10 REQ[0] = 0;
    #50 $finish;
end

initial begin
	$dumpfile("arbiter_robin_tb.vcd");
	$dumpvars(0, arbiter_robin_tb);
	$dumpon;
end

endmodule