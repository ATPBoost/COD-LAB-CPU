`timescale 1ns / 1ps


module IF_ID(
    input CLK,RST,
    input [31:0] PC,IR,
    output reg [31:0] IF_ID_IR,IF_ID_NPC
    );
    always@(negedge CLK)
    begin
        IF_ID_IR <= IR;
        IF_ID_NPC <= PC + 32'h0004;
    end
    
endmodule
