// Test program for Michael's testbench (core/testbench/test1_tb.v), for core 0.
// Program starts with jump to memory initialization -- saves values where constants and variables are stored.
// After initialization, program jumps to the beginnig of proper program.

test_progmem[0] = NOP;
test_progmem[1] = JALR(5'd0, 12'd28, 5'd10); // CALL for saving start values to memory
test_progmem[2] = NOP;
test_progmem[3] = NOP;
test_progmem[4] = NOP;
test_progmem[5] = NOP;
test_progmem[6] = NOP;
test_progmem[7] = NOP;
test_progmem[8] = NOP;
test_progmem[9] = NOP;
	// INIT
test_progmem[10] = LOAD(5'd0, 12'h002, 5'd1);
test_progmem[11] = LOAD(5'd0, 12'h003, 5'd5);
test_progmem[12] = LOAD(5'd0, 12'h004, 5'd2);
test_progmem[13] = LOAD(5'd0, 12'h005, 5'd3);
	// MAIN:
test_progmem[14] = BRANCH(`func3_BGEU, 5'd2, 5'd3, 12'h00C);
test_progmem[15] = LOAD(5'd2, 12'h000, 5'd4);
test_progmem[16] = BRANCH(`func3_BEQ, 5'd1, 5'd4, 12'h003);
test_progmem[17] = ALUI(`ALU_OP_ADD, 5'd2, 12'b1, 5'd2);
test_progmem[18] = JALR(5'd0, 12'd14, 5'd0);
	// INCN
test_progmem[19] = LOAD_A(5'd5, 12'h000, 5'd6);
test_progmem[20] = ALUI(`ALU_OP_ADD, 5'd6, 12'b1, 5'd6);
test_progmem[21] = STORE_A(5'd5, 12'h000, 5'd6);
test_progmem[22] = ALUR(`ALU_OP_ADD, 5'd5, 5'd6, 5'd7);
test_progmem[23] = STORE(5'd7, 12'h000, 5'd2);
test_progmem[24] = ALUI(`ALU_OP_ADD, 5'd2, 12'b1, 5'd2);
test_progmem[25] = JALR(5'd0, 12'd14, 5'd0);
	// FIN
test_progmem[26] = NOP;
test_progmem[27] = JALR(5'd0, 12'hFFD, 5'd0);
	// SAVE START VALUES TO MEM
test_progmem[28] = ALUI(`ALU_OP_ADD, 5'd0, 12'h002, 5'd1);
test_progmem[29] = STORE(5'd1, 12'h000, 5'd1);
test_progmem[30] = ALUI(`ALU_OP_ADD, 5'd0, 12'h018, 5'd2);
test_progmem[31] = STORE(5'd1, 12'h001, 5'd2);
test_progmem[32] = ALUI(`ALU_OP_ADD, 5'd2, 12'h000, 5'd2);
test_progmem[33] = STORE(5'd1, 12'h003, 5'd2);
test_progmem[34] = ALUI(`ALU_OP_ADD, 5'd2, -12'h008, 5'd2);
test_progmem[35] = STORE(5'd1, 12'h002, 5'd2);

test_progmem[36] = ALUI(`ALU_OP_ADD, 5'd0, 12'h010, 5'd1);
test_progmem[37] = ALUI(`ALU_OP_ADD, 5'd0, 12'h002, 5'd2); // 2
test_progmem[38] = STORE(5'd1, 12'h000, 5'd2);
test_progmem[39] = ALUI(`ALU_OP_ADD, 5'd2, 12'h000, 5'd2); // 2
test_progmem[40] = STORE(5'd1, 12'h001, 5'd2);
test_progmem[41] = ALUI(`ALU_OP_ADD, 5'd2, 12'h003, 5'd2); // 5
test_progmem[42] = STORE(5'd1, 12'h002, 5'd2);
test_progmem[43] = ALUI(`ALU_OP_ADD, 5'd2, 12'h003, 5'd2); // 8
test_progmem[44] = STORE(5'd1, 12'h003, 5'd2);
test_progmem[45] = ALUI(`ALU_OP_ADD, 5'd2, -12'h006, 5'd2); // 2
test_progmem[46] = STORE(5'd1, 12'h004, 5'd2);
test_progmem[47] = ALUI(`ALU_OP_ADD, 5'd2, -12'h001, 5'd2); // 1
test_progmem[48] = STORE(5'd1, 12'h005, 5'd2);
test_progmem[49] = ALUI(`ALU_OP_ADD, 5'd2, 12'h002, 5'd2); // 3
test_progmem[50] = STORE(5'd1, 12'h006, 5'd2);
test_progmem[51] = ALUI(`ALU_OP_ADD, 5'd2, 12'h004, 5'd2); // 7
test_progmem[52] = STORE(5'd1, 12'h007, 5'd2);
test_progmem[53] = ALUI(`ALU_OP_ADD, 5'd0, 12'h000, 5'd2); // 0
test_progmem[54] = STORE(5'd1, 12'h008, 5'd2);
test_progmem[55] = JALR(5'd10, 12'h000, 5'd0);