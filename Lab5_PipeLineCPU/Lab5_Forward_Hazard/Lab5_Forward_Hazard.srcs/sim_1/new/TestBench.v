`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/06/17 13:04:58
// Design Name: 
// Module Name: TestBench
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


module TestBench();
    
    reg clk,rst;
    
    pipeline ppU(.CLK(clk), .RST(rst));
initial 
    clk = 1;
always 
    #5 clk = ~clk;
initial
    begin
        rst = 1;
        #40 rst = 0;
    end
endmodule
