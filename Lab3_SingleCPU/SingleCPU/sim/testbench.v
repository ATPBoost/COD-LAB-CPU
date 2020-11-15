`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/05/14 12:14:25
// Design Name: 
// Module Name: testbench
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module testbench(
    );
    reg clk,rst;
    
    SingleCPU CPU(.clk(clk), .rst(rst));

initial clk = 1;
always #5 clk = ~clk;
initial
    begin
        rst = 1;
        #40 rst = 0;
    end
    
endmodule
