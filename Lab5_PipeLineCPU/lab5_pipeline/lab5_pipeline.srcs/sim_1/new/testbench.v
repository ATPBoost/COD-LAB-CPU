`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/06/15 19:37:21
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


module testbench();
    reg CLK,RST;
    
    pipeline pipe(.CLK(CLK), .RST(RST));
    
    
initial CLK = 1;
always #5 CLK = ~CLK;
initial
    begin
        RST = 1;
        #40 RST = 0;
    end
endmodule
