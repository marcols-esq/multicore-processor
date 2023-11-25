`include "../defines.vh"

module INST_MONITOR (
    input        clk,
    input [31:0] pc,
    input [31:0] inst,
    input        flush,

    input        is_jump,
    input [31:0] jump_addr,

    input        reg_wr,
    input [4:0]  reg_addr_wr,
    input [31:0] reg_data_wr,
    
    input [31:0] mem_data_r,
    input [31:0] mem_data_w,
    input [31:0] mem_addr,
    input        mem_read,
    input        mem_write,
    input        mem_wait
);


    reg [31:0] FIFO_pc           [0:4];
    reg [31:0] FIFO_inst         [0:4];
    reg        FIFO_flush        [0:4];

    reg        FIFO_is_jump      [0:4];
    reg [31:0] FIFO_jump_addr    [0:4];

    reg        FIFO_reg_wr       [0:4];
    reg [4:0]  FIFO_reg_addr_wr  [0:4];
    reg [31:0] FIFO_reg_data_wr  [0:4];

    reg [31:0] FIFO_mem_data_r   [0:4];
    reg [31:0] FIFO_mem_data_w   [0:4];
    reg [31:0] FIFO_mem_addr     [0:4];
    reg        FIFO_mem_read     [0:4];
    reg        FIFO_mem_write    [0:4];
    reg        FIFO_mem_wait     [0:4];

    integer i;
    always @(posedge clk) begin
        if(!mem_wait) begin
            for(i=4; i>0; i=i-1) begin
                FIFO_inst         [i] = FIFO_inst         [i-1];
                FIFO_pc           [i] = FIFO_pc           [i-1];
                FIFO_flush        [i] = FIFO_flush        [i-1];
                FIFO_is_jump      [i] = FIFO_is_jump      [i-1];
                FIFO_jump_addr    [i] = FIFO_jump_addr    [i-1];
                FIFO_reg_wr       [i] = FIFO_reg_wr       [i-1];
                FIFO_reg_addr_wr  [i] = FIFO_reg_addr_wr  [i-1];
                FIFO_reg_data_wr  [i] = FIFO_reg_data_wr  [i-1];
                FIFO_mem_data_r   [i] = FIFO_mem_data_r   [i-1];
                FIFO_mem_data_w   [i] = FIFO_mem_data_w   [i-1];
                FIFO_mem_addr     [i] = FIFO_mem_addr     [i-1];
                FIFO_mem_read     [i] = FIFO_mem_read     [i-1];
                FIFO_mem_write    [i] = FIFO_mem_write    [i-1];
                FIFO_mem_wait     [i] = FIFO_mem_wait     [i-1];
            end
            FIFO_inst         [i] = inst         ;
            FIFO_pc           [i] = pc           ;
            FIFO_flush        [i] = flush        ;
            FIFO_is_jump      [i] = is_jump      ;
            FIFO_jump_addr    [i] = jump_addr    ;
            FIFO_reg_wr       [i] = reg_wr       ;
            FIFO_reg_addr_wr  [i] = reg_addr_wr  ;
            FIFO_reg_data_wr  [i] = reg_data_wr  ;
            FIFO_mem_data_r   [i] = mem_data_r   ;
            FIFO_mem_data_w   [i] = mem_data_w   ;
            FIFO_mem_addr     [i] = mem_addr     ;
            FIFO_mem_read     [i] = mem_read     ;
            FIFO_mem_write    [i] = mem_write    ;
            FIFO_mem_wait     [i] = mem_wait     ;

            if(FIFO_pc[4] >= 0) begin
                $write("[%dns] 0x%h (%d) : ", $time, FIFO_pc[4], FIFO_pc[4]);
                if(FIFO_reg_wr[0]) begin
                    $write("r%h <- 0x%h (%d) ", DEC_TO_2WIDE_HEX(FIFO_reg_addr_wr[0]), FIFO_reg_data_wr[0], FIFO_reg_data_wr[0] );
                end else if(FIFO_mem_write[1]) begin
                    $write("STORE  0x%h (%d) ", FIFO_mem_data_w[1], FIFO_mem_data_w[1]);
                end else if(FIFO_flush[0]) begin
                    $write("* * FLUSHED * * * * * * * * *  ");
                end else begin
                    $write("                               ");
                end
                if(!FIFO_flush[0]) begin
                    PRINT_INST_TO_ASM_STR(FIFO_inst[4]);
                    if(FIFO_is_jump[2]) begin
                        $write("  | PC  <- 0x%h (%d) ", FIFO_jump_addr[2], FIFO_jump_addr[2] );
                    end else if(FIFO_mem_write[1] || FIFO_mem_read[1]) begin
                    $write(" | ADDR = 0x%h (%d) ", FIFO_mem_addr[1], FIFO_mem_addr[1]);
                end
                end
                $display();
            end
        end



    end

function [7:0] DEC_TO_2WIDE_HEX (input [4:0] val); begin
    DEC_TO_2WIDE_HEX[3:0] = val % 10;
    DEC_TO_2WIDE_HEX[7:4] = val / 10;
end
endfunction

task automatic PRINT_INST_TO_ASM_STR (
    input [31:0]  inst
);
    reg [6:0]  opcode;
    reg [4:0]  rs1;
    reg [4:0]  rs2;
    reg [4:0]  rd;
    reg [2:0]  func3;
    reg [6:0]  func7;
    reg signed [31:0] imm;
    reg signed [11:0] imm_I;
    reg signed [11:0] imm_S;
    reg signed [11:0] imm_B;
    reg signed [19:0] imm_U;
    reg signed [19:0] imm_J;

    reg [7:0]  rs1_h;
    reg [7:0]  rs2_h;
    reg [7:0]  rd_h;
    reg signed [31:0] imm_s;
    reg [4*8-1:0] alu_op_str;
    reg [3*8-1:0] alu_op_f_str;
    reg [4*8-1:0] be_op_str;
    reg [2*8-1:0] be_op_f_str;
    reg [1*8-1:0] atomic_str;
begin
    opcode = inst[6:0];
    func3  = inst[14:12];
    func7  = inst[31:25];
    imm_I  = inst[31:20];
    imm_S  = {inst[31:25], inst[11:7]};
    imm_B  = {inst[31], inst[7], inst[30:25], inst[11:8]};
    imm_U  = inst[31:12];
    imm_J  = {inst[31], inst[19:12], inst[20], inst[30:21]};
    rd     = inst[11:7];
    rs1    = inst[19:15];
    rs2    = inst[24:20];

    rs1_h  = DEC_TO_2WIDE_HEX(rs1);
    rs2_h  = DEC_TO_2WIDE_HEX(rs2);
    rd_h   = DEC_TO_2WIDE_HEX(rd);
    case({func7[5] & (opcode == `OPCODE_ALUR || func3 == `func3_SRL_SRA), func3})
        `ALU_OP_ADD  : alu_op_str = "ADD ";
        `ALU_OP_SUB  : alu_op_str = "SUB ";
        `ALU_OP_SLL  : alu_op_str = "SLL ";
        `ALU_OP_SLT  : alu_op_str = "SLT ";
        `ALU_OP_SLTU : alu_op_str = "SLTU";
        `ALU_OP_XOR	 : alu_op_str = "XOR ";
        `ALU_OP_SRL  : alu_op_str = "SRL ";
        `ALU_OP_SRA  : alu_op_str = "SRA ";
        `ALU_OP_OR   : alu_op_str = "OR  ";
        `ALU_OP_AND	 : alu_op_str = "AND ";
    endcase
    case({func7[5] & (opcode == `OPCODE_ALUR || func3 == `func3_SRL_SRA), func3})
        `ALU_OP_ADD  : alu_op_f_str = " + ";
        `ALU_OP_SUB  : alu_op_f_str = " - ";
        `ALU_OP_SLL  : alu_op_f_str = "<< ";
        `ALU_OP_SLT  : alu_op_f_str = " < ";
        `ALU_OP_SLTU : alu_op_f_str = " < ";
        `ALU_OP_XOR	 : alu_op_f_str = " ^ ";
        `ALU_OP_SRL  : alu_op_f_str = ">> ";
        `ALU_OP_SRA  : alu_op_f_str = ">>>";
        `ALU_OP_OR   : alu_op_f_str = " | ";
        `ALU_OP_AND	 : alu_op_f_str = " & ";
    endcase
    
    case(func3)
        `func3_BEQ   : be_op_str = "BEQ ";
        `func3_BNE   : be_op_str = "BNE ";
        `func3_BLT   : be_op_str = "BLT ";
        `func3_BGE   : be_op_str = "BGE ";
        `func3_BLTU  : be_op_str = "BLTU";
        `func3_BGEU  : be_op_str = "BGEU";
    endcase
    case(func3)
        `func3_BEQ   : be_op_f_str = "==";
        `func3_BNE   : be_op_f_str = "!=";
        `func3_BLT   : be_op_f_str = "< ";
        `func3_BGE   : be_op_f_str = ">=";
        `func3_BLTU  : be_op_f_str = "< ";
        `func3_BGEU  : be_op_f_str = ">=";
    endcase
    atomic_str = func3 == `func3_MEM_WA ? "A" : " ";

    if((opcode == `OPCODE_ALUI || opcode == `OPCODE_ALUR) && rd == 0)
        $write("NOP");
    else case(opcode)
        `OPCODE_LUI    : begin imm_s = imm_U << 12; imm = imm_s; $write("LUI         r%h  =  0x%h (%d)",           rd_h,  imm, imm_s ); end
        `OPCODE_ALUI   : begin imm_s = imm_I;       imm = imm_s; $write(  "%s r%h <- r%h %s 0x%h (%d)",      alu_op_str, rd_h,  rs1_h, alu_op_f_str, imm, imm_s ); end
        `OPCODE_ALUR   : begin imm_s = imm_I;       imm = imm_s; $write(  "%s r%h <- r%h %s r%h",            alu_op_str, rd_h,  rs1_h, alu_op_f_str, rs2_h ); end
        `OPCODE_BRANCH : begin imm_s = imm_B << 1;  imm = imm_s; $write(  "%s r%h %s r%h,    0x%h (%d)",     be_op_str,  rs1_h, be_op_f_str, rs2_h, imm, imm_s ); end
        `OPCODE_JALR   : begin imm_s = imm_I;       imm = imm_s; $write("JALR r%h,   r%h  +  0x%h (%d)",     rd_h,  rs1_h, imm, imm_s ); end
        `OPCODE_LOAD   : begin imm_s = imm_I;       imm = imm_s; $write("LW%s  r%h <- M[r%h + 0x%h (%d)]",  atomic_str, rd_h,  rs1_h, imm, imm_s ); end
        `OPCODE_STORE  : begin imm_s = imm_S;       imm = imm_s; $write("SW%s  r%h -> M[r%h + 0x%h (%d)]",  atomic_str, rs2_h, rs1_h, imm, imm_s ); end
    endcase

end
endtask


endmodule