`timescale 1ns / 1ps
module instruction_fetch(
    input clk, rst,                        // clock and reset
    // jal jalr
    input                   jump_flag_i,
    input   [31:0]          jump_addr_i,
    // beq bne blt bge
    input                   branch_flag_i, 
    input   [31:0]          branch_addr_i,
    
    // to alu
    output  [31:0]          inst_o,                 // instruction

    output  reg [31:0]      pc_o
    );

    ROM instmem(
        .clka(clk),
        .addra(pc_o[15:2]),
        .douta(inst_o)
    );

    reg [31:0]  next_pc;

    always @(*) begin
        if(jump_flag_i) begin
            next_pc = jump_addr_i;
        end
        else if(branch_flag_i) begin
            next_pc = branch_addr_i;
        end
        else begin
            next_pc = pc_o + 4;
        end
    end 

    always@ (negedge clk or posedge rst) begin
        if(rst) begin
            pc_o <= 32'h0;
        end
         else begin
            pc_o <= next_pc;
        end
    end

endmodule