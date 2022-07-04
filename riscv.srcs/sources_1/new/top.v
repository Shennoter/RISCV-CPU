`timescale 1ns / 1ps

module top (
    input oclk,             // bind to P17
    input rst,              // bind to a button
    output[31:0] fibonacci  // bind to LED
    );

    wire clk;
    
    // CU =  instruction_fetch + decoder
    // instruction_fetch out
    wire[31:0] inst;
    wire[31:0] pc;
    //decoder out
    wire jump_flag;
    wire[31:0] jump_addr;
    wire[31:0] branch_addr;
    wire[6:0] opcode;
    wire[31:0] alu_a;
    wire[31:0] alu_b;
    wire[2:0] func3;
    wire[4:0] rd;
    wire[3:0] alu_ctrl;
    wire mem_write;
    wire mem_read;
    wire mem_to_reg;
    wire reg_write;
    wire[31:0] imme;
    wire[31:0] read_data_2;
    
    //alu out
    wire branch_flag;
    wire[31:0] write_mem_data;
    wire[31:0] alu_result;
    wire[31:0] addr_result;
    
    // data_memory out
    wire[31:0] mem_data;
    assign fibonacci = mem_data;

    // IP
    cpuclk cpuclk(
        .clk_in1(oclk),
        .clk_out1(clk)
    );
        
    // modules
    instruction_fetch insf(
        .clk(clk),
        .rst(rst),
        // jal jalr
        .jump_flag_i(jump_flag),
        .jump_addr_i(jump_addr),
        // beq bne blt bge
        .branch_flag_i(branch_flag),
        .branch_addr_i(branch_addr),
        // to alu
        .inst_o(inst),
        .pc_o(pc)
    );
    
    alu alu(
        // from decoder
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
        
    data_memory datamem(
        .clk(clk),
        //from decoder
        .mem_read_i(mem_read),
        .mem_write_i(mem_write),
        .write_data_i(read_data_2),
        .func3_i(func3),
        // from alu
        .address(addr_result),
        
        .mem_data_o(mem_data)
    );
    
    decoder dc(
        // clock and reset
        .clk(clk),
        .rst(rst),
        // from instruction_fetch
        .pc_i(pc),
        .inst_i(inst),
        // from data_memory 
        .mem_data_i(mem_data),
        // from alu
        .alu_result_i(alu_result),
        
        // to instruction_fetch
        .jump_flag_o(jump_flag),
        .jump_addr_o(jump_addr),
        .branch_addr_o(branch_addr),
        // to alu
        .opcode_o(opcode),
        .alu_a_o(alu_a),
        .alu_b_o(alu_b),
        .func3_o(func3),
        .rd_o(rd),
        .alu_ctrl_o(alu_ctrl),
        .mem_write_o(mem_write),
        .mem_read_o(mem_read),
        .mem_to_reg_o(mem_to_reg),
        .reg_write_o(reg_write),
        .imme_o(imme),
        .read_data_2_o(read_data_2)
    );
endmodule
