`timescale 1ns / 1ps

module test_decoder(
    );

//in
 reg clk = 1'b0;
 reg rst = 1'b0;
reg[31:0] pc = 32'b0;
wire[31:0] inst;
wire[31:0] mem_data;
wire[31:0] alu_result;
//out
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

always #5 clk = ~clk;

initial #10 begin
    rst = 1;
    #10 rst = 0;
end

always@(posedge clk) begin
    pc = pc + 4;
end

endmodule
