`timescale 1ns/1ps
module data_memory (
    input              clk          ,
    // from decoder
    input              mem_read_i   ,
    input              mem_write_i  ,
    input   [31:0]     write_data_i ,
    input   [2:0]      func3_i      ,
    // from alu
    input   [31:0]     address      ,
    
    output  reg [31:0]   mem_data_o
    );

    wire clock;
    assign clock = ~clk;
    wire[31:0] read_data;
    RAM ram (
        .clka(clock),              // input wire clka
        .wea(mem_write_i),           // input wire [0 : 0] wea
        .addra(address[15:2]),     // input wire [13 : 0] addra // address in byte, but addra in word
        .dina(write_data_i),         // input wire [31 : 0] dina
        .douta(read_data)          // output wire [31 : 0] douta
    );

    always @(*) begin
        if(mem_read_i)
            case (func3_i)
                3'b000: mem_data_o = {{24{read_data[7]}}, read_data[7:0]}    ;  // lb
                3'b001: mem_data_o = {{16{read_data[15]}}, read_data[15:0]}  ;  // lh
                3'b010: mem_data_o = read_data                               ;  // lw
                3'b100: mem_data_o = {24'b0, read_data[7:0]}                 ;  // lbu
                3'b101: mem_data_o = {16'b0, read_data[15:0]}                ;  // lhu
                default: mem_data_o = 32'b0;
            endcase
    end
     
endmodule