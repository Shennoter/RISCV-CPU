`timescale 1ns / 1ps
`include "constant.v"
module decoder(
    // clock and reset
    input               clk, rst      ,               
    // from instruction_fetch
    input   [31:0]      pc_i          ,
    input   [31:0]      inst_i        ,
    // from data_memory 
    input   [31:0]      mem_data_i    ,
    // from alu
    input   [31:0]      alu_result_i  ,

    // to instruction_fetch
    output              jump_flag_o   ,
    output  [31:0]      jump_addr_o   ,
    output  [31:0]      branch_addr_o ,
    // to alu
    output  [6:0]       opcode_o      ,      // opcode
    output  [31:0]      alu_a_o       ,      // alu first input
    output  [31:0]      alu_b_o       ,      // alu second input
    output  [2:0]       func3_o       ,      // also to data_memory
    output  [4:0]       rd_o          ,      // $rd
    output  reg [3:0]   alu_ctrl_o    ,      // to control how alu behaves
    output              mem_write_o   ,      // 1 need to write memory, for IL-type
    output              mem_read_o    ,      // 1 need to read memory, for S-type
    output              mem_to_reg_o  ,      // 1 need to write data from memory to register, for IL-type
    output              reg_write_o   ,      // 1 need to write register
    output  [31:0]      imme_o        ,      // the immediate after sign extension
    output  [31:0]      read_data_2_o        // R[$rs2]
    );

    // decoder
    wire R_type, I_type, S_type, SB_type, U_type, UJ_type;
    wire[6:0] func7;
    // controller
    wire[1:0] alu_op;
    wire alu_src;
    // read and write registers
    wire[4:0] write_reg;                           // register to be written
    wire[31:0] write_data;                         // data to be written in register
    wire[4:0] rs1;
    wire[4:0] rs2;
    wire[31:0] read_data_1;
    wire[31:0] read_data_2;    // R[$rs1], R[$rs2]

    // decode the instruction
    assign func7       =    inst_i[31:25]  ;
    assign func3_o     =    inst_i[14:12]  ;
    assign opcode_o    =    inst_i[6:0]    ;

    assign R_type      =    (opcode_o == `R_TYPE)  ;
    assign I_type      =    (opcode_o == `II_TYPE) || (opcode_o == `IL_TYPE) || (opcode_o == `JALR_OPC);
    assign S_type      =    (opcode_o == `S_TYPE)  ;
    assign SB_type     =    (opcode_o == `SB_TYPE) ; 
    assign U_type      =    (opcode_o == `U_TYPE)  ;
    assign UJ_type     =    (opcode_o == `JAL_OPC) ;

    // sign extension
    assign imme_o      =    I_type   ?   {{20{inst_i[31]}},inst_i[31:20]}                              :
                            S_type   ?   {{20{inst_i[31]}},inst_i[31:25],inst_i[11:7]}                 :
                            SB_type  ?   {{20{inst_i[31]}},inst_i[7],inst_i[30:25],inst_i[11:8],1'b0}  :
                            U_type   ?   {inst_i[31:12],12'b0}                                         :
                            UJ_type  ?   {{12{inst_i[31]}},inst_i[19:12],inst_i[20],inst_i[30:21],1'b0}:
                            32'b0;

    // control unit
    assign alu_op                =     (S_type || U_type || (opcode_o  == `IL_TYPE) || (opcode_o == `JALR_OPC)) ? 2'b00:
                                       (SB_type) ? 2'b01 :
                                       (R_type || (opcode_o == `II_TYPE)) ? 2'b10 : 
                                       2'b11;

    assign mem_read_o            =    (opcode_o == `IL_TYPE)  ;
    assign mem_write_o           =    S_type                  ;
    assign mem_to_reg_o          =    (opcode_o == `IL_TYPE)  ;

    assign reg_write_o           =    (R_type || I_type || U_type || UJ_type)  ;

    assign alu_src               =    (R_type || SB_type)     ;

    assign alu_a_o               =    (jump_flag_o)     ?   pc_i            :   read_data_1;
    assign alu_b_o               =    (jump_flag_o)     ?   32'h4:
                                        (alu_src)       ?   read_data_2     :   imme_o;

    always@(*) begin
        if(rst)begin
            alu_ctrl_o = 4'b0000;
        end
        else begin
            case(alu_op)
                2'b00: alu_ctrl_o = 4'b1000;                   // load or store
                2'b01: begin                                   // conditional branch 
                    case(func3_o)
                        3'b000:   alu_ctrl_o   =   4'b0001;    // beq
                        3'b001:   alu_ctrl_o   =   4'b0010;    // bne
                        3'b100:   alu_ctrl_o   =   4'b0011;    // blt
                        3'b101:   alu_ctrl_o   =   4'b0100;    // bge
                        3'b110:   alu_ctrl_o   =   4'b0101;    // bltu
                        3'b111:   alu_ctrl_o   =   4'b0110;    // bgeu
                        default : alu_ctrl_o   =   4'b0000;    // nothing
                    endcase
                end
                2'b10: begin                                   // R_type or II_type
                    case(func3_o)
                        3'b000: begin
                            if(R_type)begin                    // R_type
                                alu_ctrl_o     =   (~func7[5])  ?  4'b1000  :  4'b1001;   // add : sub 
                            end
                            else begin                         // II_TYPE
                                alu_ctrl_o     =   4'b1000;    // addi
                            end
                        end
                        3'b001: alu_ctrl_o     =   4'b1010;    // sll  slli
                        3'b100: alu_ctrl_o     =   4'b1011;    // xor  xori
                        3'b101: begin
                            if(func7[5])
                                alu_ctrl_o     =   4'b1100;    // sra  srai
                            else
                                alu_ctrl_o     =   4'b1101;    // srl  srli
                            end
                        3'b110: alu_ctrl_o     =   4'b1110;    // or   ori
                        3'b111: alu_ctrl_o     =   4'b1111;    // and  andi
                        default : alu_ctrl_o   =   4'b0000;    // nothing
                    endcase
                end
                default : alu_ctrl_o           =   4'b0000;    // nothing
            endcase
        end
    end

    // read and write register
    assign rs1                   =     inst_i[19:15]  ;
    assign rs2                   =     inst_i[24:20]  ;
    assign rd_o                  =     inst_i[11:7]   ;
    
    assign reg_write_o           =     (R_type || I_type || U_type || UJ_type);
    assign write_reg             =     (reg_write_o || (opcode_o == `JAL_OPC || opcode_o == `JALR_OPC)) ? rd_o : 5'b0;
    assign write_data            =     (opcode_o == `JAL_OPC) || (opcode_o == `JALR_OPC) ? pc_i : 
                                        (mem_to_reg_o) ? mem_data_i : alu_result_i;

    reg[31:0] reg_group[31:0]; // totally 32 registers
    integer i;
    always @(posedge clk or posedge rst) begin
        if(rst) for (i = 0; i <= 31; i = i+1) reg_group[i] <= 32'b0;
        else if(reg_write_o)
            reg_group[write_reg] <= write_data;
    end

    assign read_data_1           =     reg_group[rs1] ;
    assign read_data_2           =     reg_group[rs2] ;
    assign read_data_2_o         =     read_data_2    ;

    // jump and branch
    assign jump_flag_o           =    (opcode_o == `JAL_OPC) || (opcode_o == `JALR_OPC)  ;
    assign jump_addr_o           =    (opcode_o == `JALR_OPC)  ?   alu_a_o + imme_o  :
                                      (opcode_o == `JAL_OPC) ?   pc_i + imme_o     :
                                      32'b0;
    assign branch_addr_o         =    (SB_type)         ?   pc_i + imme_o     :   32'b0;

endmodule