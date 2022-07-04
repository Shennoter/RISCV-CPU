`timescale 1ns / 1ps

module test_data_memory();
    reg clk = 1'b0;
    reg mem_read;
    reg mem_write;
    reg[32:0] write_data;
    reg[2:0] func3;
    reg[32:0] addr;
    wire[31:0] mem_data;
    reg writeflag = 1'b1;
    data_memory datamem(
        .clk(clk),
        .mem_read_i( mem_read),
        .mem_write_i(mem_write),
        .write_data_i(write_data),
        .func3_i(func3),
        .address(addr),
        .mem_data_o(mem_data)
    );
    
    always #5 clk = ~clk;
    initial begin
        clk = 1'b0;
        mem_read = 1'b0;
        mem_write = 1'b1;
        write_data = 32'h0;
        func3 = 2'b01;
        addr = 32'h0;
     end
        
     always@(posedge clk) begin
        if(writeflag)begin
            mem_read = 1'b0;
            mem_write = 1'b1;
            write_data = write_data + 4;
            end
        else begin
            mem_write = 1'b0;
            mem_read = 1'b1;
            $monitor(mem_data);
            addr = addr + 4;
            end
        writeflag = ~writeflag;
     end
endmodule
