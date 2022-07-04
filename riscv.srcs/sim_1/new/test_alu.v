`timescale 1ns / 1ps

module test_alu();
    reg[31:0] alu_a;
    reg[31:0] alu_b;
    reg[31:0] imme;
    reg[2:0] func3;
    reg[3:0] alu_ctrl;
    reg[31:0] read_data_2;
    reg mem_write;
    
    wire branch_flag;
    wire[31:0] write_mem_data;
    wire[31:0] alu_result;
    wire[31:0] addr_result;
    
    alu alu(
        .alu_a_i(alu_a),
        .alu_b_i(alu_b),
        .imme_i(imme),
        .func3_i(func3),
        .alu_ctrl_i(alu_ctrl),
        .read_data_2_i(read_data_2),
        .mem_write_i(mem_write),
        
        .branch_flag_o(branch_flag),
        .write_mem_data_o(write_mem_data),
        .alu_result_o(alu_result),
        .addr_result_o(addr_result)
    );
    
    initial begin
     alu_a = 32'b0;
        alu_b = 32'b0;
        imme = 32'b0;
        func3 = 3'b0;
        alu_ctrl = 4'b0;
        read_data_2 = 4'b0;
        mem_write =4'b0;
    
        // test for sb sh sw
        // look write_mem_data
        #10 mem_write = 1'b1;
        read_data_2 = 32'b0000_0000_0000_1101_0011_1011_1111_0100;
        #5 func3 = 3'b001;
        #5 func3 = 3'b010;
        
        // test for general alu: branch and any other ariths
        // see alu_result, branch_flag
        #10 alu_ctrl = 4'b0001;//beq
        #5 alu_a = 32'b1;
        #10 alu_ctrl = 4'b0010;//bnq
        #5 alu_a = 32'b0;
        #10 alu_ctrl = 4'b0011;//blt
        #5 alu_a = 32'b1;
        #10 alu_ctrl = 4'b0100;//bge
        #5 alu_a = 32'b0;
        
        // set alu_a and alu_b
        #10 alu_a = 32'h000000ab;
        alu_b = 32'h000000cd;
        
        #10 alu_ctrl = 4'b1000;//add
        #10 alu_ctrl = 4'b1001;//sub
        #10 alu_ctrl = 4'b1010;//sll
        #10 alu_ctrl = 4'b1011;//xor
        #10 alu_ctrl = 4'b1100;//sra
        #10 alu_ctrl = 4'b1101;//srl
        #10 alu_ctrl = 4'b1110;//or
        #10 alu_ctrl = 4'b1111;//and
    end
endmodule
