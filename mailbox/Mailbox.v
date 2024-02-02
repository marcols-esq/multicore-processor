module Mailbox (
  input wire clk,
  input wire rst,
  input wire [31:0] data_in,
  input wire write_enable,
  input wire read_enable,
  output reg [31:0] data_out,
  output wire [1:0] state_output,
  output wire rdy_wr_output,
  output wire rdy_rd_output
);

  reg [31:0] mailbox_data;
  reg [1:0] state;
  reg rdy_wr;
  reg rdy_rd;

  always @(posedge clk or posedge rst) begin
    if (rst) begin  //reset
      state <= 2'b00;
      mailbox_data <= 32'b0;
      data_out <= 32'b0;
		rdy_wr <= 1'b1;
		rdy_rd <= 1'b0;
    end else begin
      case (state)
        2'b00: begin //oczekiwanie
          if (write_enable) begin
			   rdy_wr <= 1'b0;
				rdy_rd <= 1'b1;
            state <= 2'b01;
            mailbox_data <= data_in;
          end else if (read_enable) begin
			   rdy_wr <= 1'b1;
				rdy_rd <= 1'b0;
            state <= 2'b10;
            data_out <= mailbox_data;
          end
        end

        2'b01: begin //zapis
          if (write_enable==0) begin
				if(read_enable)begin
					rdy_wr <= 1'b0;
					rdy_rd <= 1'b1;
					state <= 2'b10;
					data_out <= mailbox_data;
				end
				else begin
					rdy_wr <= 1'b0;
					rdy_rd <= 1'b1;
					state <= 2'b00;
          //mailbox_data <= data_in;

				end
          end
        end

        2'b10: begin //odczyt
          if (read_enable==0) begin
				if(write_enable)begin
					rdy_wr <= 1'b0;
					rdy_rd <= 1'b1;
					state <= 2'b01;
					mailbox_data <= data_in;
				end
				else begin
					rdy_wr <= 1'b1;
					rdy_rd <= 1'b0;
					state <= 2'b00;
          //data_out <= mailbox_data;
				end
          end
        end
      endcase
    end
  end

  assign state_output = state;
  assign rdy_wr_output = rdy_wr;
  assign rdy_rd_output = rdy_rd;

endmodule



