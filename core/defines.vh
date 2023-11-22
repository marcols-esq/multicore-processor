`define INST_ADDR_W 32
`define DATA_ADDR_W 32
`define REG_ADDR_W 5
`define INST_W 32
`define DATA_W 32

`define OPCODE_ALUI   7'b0010011
`define OPCODE_ALUR   7'b0110011

`define func7_ALU_0   7'b0000000
`define func7_ALU_1   7'b0100000

`define func3_ADD_SUB 3'b000
`define func3_XOR	  3'b100
`define func3_AND	  3'b111


`define ALU_SRC_W  2
`define ALU_SRC_R   `ALU_SRC_W'h0
`define ALU_SRC_IMM `ALU_SRC_W'h1

`define ALU_OP_ADD    4'b0000
`define ALU_OP_SUB    4'b1000
`define ALU_OP_XOR	  4'b0100
`define ALU_OP_AND	  4'b0111