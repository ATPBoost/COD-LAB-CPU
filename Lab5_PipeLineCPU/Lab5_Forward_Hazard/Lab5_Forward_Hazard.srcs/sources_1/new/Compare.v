`timescale 1ns / 1ps



module Compare(
    input [31:0] a,b,
    output equal
    );

    assign equal = (a==b) ? 1 : 0;
    
endmodule
