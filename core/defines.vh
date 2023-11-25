`define INST_ADDR_W 32
`define DATA_ADDR_W 32
`define REG_ADDR_W 5
`define INST_W 32
`define DATA_W 32

`define OPCODE_LUI    7'b0110111
`define OPCODE_ALUI   7'b0010011
`define OPCODE_ALUR   7'b0110011
`define OPCODE_BRANCH 7'b1100011
`define OPCODE_JALR   7'b1100111
`define OPCODE_LOAD   7'b0000011
`define OPCODE_STORE  7'b0100011

// `define LINK_REG      `REG_ADDR_W'd2;

`define func7_ALU_0   7'b0000000
`define func7_ALU_1   7'b0100000

`define func3_ADD_SUB 3'b000
`define func3_SLL     3'b001
`define func3_SLT     3'b010
`define func3_SLTU    4'b011
`define func3_XOR	  3'b100
`define func3_SRL_SRA 3'b101
`define func3_OR      3'b110
`define func3_AND	  3'b111

`define func3_BEQ     3'b000
`define func3_BNE	  3'b001
`define func3_BLT	  3'b100
`define func3_BGE	  3'b101
`define func3_BLTU	  3'b110
`define func3_BGEU	  3'b111

`define func3_MEM_W   3'b010
`define func3_MEM_WA  3'b110

`define ALU_SRC_W     2
`define ALU_SRC_R     `ALU_SRC_W'h0
`define ALU_SRC_IMM   `ALU_SRC_W'h1
`define ALU_SRC_PC    `ALU_SRC_W'h2

`define ALU_OP_ADD    4'b0000
`define ALU_OP_SUB    4'b1000
`define ALU_OP_SLL    4'b0001
`define ALU_OP_SLT    4'b0010
`define ALU_OP_SLTU   4'b0011
`define ALU_OP_XOR	  4'b0100
`define ALU_OP_SRL    4'b0101
`define ALU_OP_SRA    4'b1101
`define ALU_OP_OR     4'b0110
`define ALU_OP_AND	  4'b0111
