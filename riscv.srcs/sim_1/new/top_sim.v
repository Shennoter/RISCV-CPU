`timescale 1ns / 1ps

module top_sim();

reg rst;
reg oclk;
wire[31:0] fibonacci;

top top(
    .oclk(oclk),
    .rst(rst),
    .fibonacci(fibonacci)
);

always #100 oclk = ~oclk;
initial begin
    rst = 1'b0;
    oclk = 1'b0;
    #50 rst = 1;
    #50 rst = 0;
end

endmodule
