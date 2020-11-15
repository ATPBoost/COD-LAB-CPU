`timescale 1ns / 1ps


module IR(
        input [31:0] Ins,
        input CLK,
        input IRWrite,
        output reg[31:0] IRIns
    );
    
initial 
    begin
        IRIns = 0;
    end
    
always@(posedge CLK)
    begin
        if(IRWrite)
            IRIns <= Ins;
    end
     
endmodule