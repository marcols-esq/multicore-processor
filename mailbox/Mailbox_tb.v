`timescale 10ns/1ns

module Mailbox_tb;

 

  // Sygnały
  reg clk;
  reg rst;
  reg [31:0] data_in;
  reg write_enable;
  reg read_enable;
  wire [31:0] data_out;
  wire [1:0] state_output;
  wire rdy_wr_output;
  wire rdy_rd_output;

  // Instancja modułu Mailbox
  Mailbox uut (
    .clk(clk),
    .rst(rst),
    .data_in(data_in),
    .write_enable(write_enable),
    .read_enable(read_enable),
    .data_out(data_out),
    .state_output(state_output),
    .rdy_wr_output(rdy_wr_output),
    .rdy_rd_output(rdy_rd_output)
  );

  // Generacja zegara
  always begin
    #5 
    clk = ~clk;
  end

  // Blok początkowy
  initial begin
    // Inicjalizacja wejść
    clk = 0;
    rst = 1;
    data_in = 0;
    write_enable = 0;
    read_enable = 0;

    // Zastosowanie resetu
    #10 rst = 0;

    // Sekwencja testowa
    #10 data_in = 32'h12345678;
    write_enable = 1;

    #20 write_enable = 0;
    data_in = 32'h0;
    #30
    read_enable = 1;

    #30 read_enable = 0;
    #20 write_enable = 1;
        data_in = 32'h 87654321;


    // Dodaj więcej sekwencji testowych w razie potrzeby

    // Zakończ symulację
    #10 $finish;
  end
  
initial
 begin
    $dumpfile("Mailbox_tb.vcd");
    $dumpvars(0,Mailbox_tb);
 end

endmodule