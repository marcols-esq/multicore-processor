`timescale 1ns/100ps

module arbiter #(
    parameter NumOfRequesters = 4,
    // Set to 1 for Round-Robin arbitration, set to 0 for priortization
    parameter RoundRobin = 0
) (
    input CLK,
    input [(NumOfRequesters - 1):0] REQ,
    output reg [(NumOfRequesters - 1):0] ACCESS
);

integer i;
integer priority;
reg [($clog2((NumOfRequesters - 1)) - 1):0] last_access;

initial 
begin
    ACCESS <= '0;
    last_access <= 0;
    priority <= 0;
end

always @(posedge CLK)
begin
    if (REQ) begin
        if (REQ[last_access] == 0) begin
            if (RoundRobin) begin
                ACCESS = '0;
                // patient wait (with dead cycles)
                // last_access = last_access + 1; 
                // if (REQ[last_access] == 1) begin
                //     ACCESS[last_access] <= 1;
                // end
                // jumping in
                while (REQ[last_access] != 1) begin
                    last_access = last_access + 1;
                end
                ACCESS[last_access] <= 1;
            end
            else begin
                ACCESS = '0;
                for(i = (NumOfRequesters - 1); i >= 0; i = i - 1) begin
                    if (REQ[i] == 1) begin 
                        priority = i;
                    end
                end

                ACCESS[priority] <= 1;
                last_access <= priority;
            end
        end
    end
    else begin
        ACCESS <= '0;
    end
end

endmodule