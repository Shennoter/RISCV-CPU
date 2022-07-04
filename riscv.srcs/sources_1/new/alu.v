`timescale 1ns / 1ps
module alu (
    // from decoder
    input   [31:0]        alu_a_i          ,
    input   [31:0]        alu_b_i          ,
    input   [31:0]        imme_i           ,
    input   [2:0]         func3_i          ,
    input   [3:0]         alu_ctrl_i       ,
    input   [31:0]        read_data_2_i    ,
    input                 mem_write_i      ,

    output  reg           branch_flag_o    ,
    output  reg   [31:0]  write_mem_data_o ,
    output  reg   [31:0]  alu_result_o     ,
    output  [31:0]        addr_result_o
    );
    
    assign addr_result_o = alu_result_o;
    
    always @(*) begin
        if(mem_write_i) begin
            case(func3_i)
                3'b000: write_mem_data_o    =    {24'b0, read_data_2_i[7:0]}  ;   // sb
                3'b001: write_mem_data_o    =    {16'b0, read_data_2_i[15:0]} ;   // sh
                3'b010: write_mem_data_o    =    read_data_2_i                ;   // sw
                default: write_mem_data_o   =    32'b0                        ;
            endcase
        end
        else
            write_mem_data_o   =    32'b0;
    end

    always @(*) begin
        case (alu_ctrl_i)
            4'b0001: begin     // beq
                alu_result_o = 32'b0;
                branch_flag_o=(alu_a_i == alu_b_i);
            end
            4'b0010: begin     // bnq
                alu_result_o = 32'b0;
                branch_flag_o=(alu_a_i != alu_b_i);
            end
            4'b0011: begin      // blt
                alu_result_o = 32'b0;
                branch_flag_o=(alu_a_i < alu_b_i);
            end
            4'b0100: begin      // bge
                alu_result_o = 32'b0;
                branch_flag_o=(alu_a_i >= alu_b_i);
            end    
            4'b0000: alu_result_o = alu_a_i + alu_b_i;                       // load store jalr utype
            4'b1000: alu_result_o = $signed(alu_a_i) + $signed(alu_b_i);     // add addi
            4'b1001: alu_result_o = $signed(alu_a_i) - $signed(alu_b_i);     // sub
            4'b1010: alu_result_o = alu_a_i << alu_b_i;                      // sll slli
            4'b1011: alu_result_o = alu_a_i ^ alu_b_i;                       // xor xori
            4'b1100: alu_result_o = $signed(alu_a_i) >>> alu_b_i;            // sra srai
            4'b1101: alu_result_o = alu_a_i >> alu_b_i;                      // srl srli 
            4'b1110: alu_result_o = alu_a_i | alu_b_i;                       // or ori 
            4'b1111: alu_result_o = alu_a_i & alu_b_i;                       // and andi
            default: begin
                alu_result_o = 32'b0;
                branch_flag_o = 1'b0;
            end
        endcase
    end

endmodule