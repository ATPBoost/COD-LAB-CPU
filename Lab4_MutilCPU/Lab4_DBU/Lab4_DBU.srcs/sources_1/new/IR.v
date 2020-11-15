`timescale 1ns / 1ps


module IR(
        input [31:0] Ins,
        input CLK,
        input IRWrite,run,
        output reg[31:0] IRIns
    );
    
initial 
    begin
        IRIns = 0;
    end
    
always@(posedge CLK)
    begin
        if(IRWrite && run)
            IRIns <= Ins;
        else
            IRIns <= IRIns;
    end
     
endmodule