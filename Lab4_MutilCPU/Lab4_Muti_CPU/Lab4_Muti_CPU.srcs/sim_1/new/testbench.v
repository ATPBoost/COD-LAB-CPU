`timescale 1ns / 1ps


    module testbench(
    );
    reg CLK,RST;
    
    Mulit_CPU CPU(.CLK(CLK), .RST(RST));

initial CLK = 1;
always #5 CLK = ~CLK;
initial
    begin
        RST = 1;
        #40 RST = 0;
    end
    
endmodule
