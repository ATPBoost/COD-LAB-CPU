`timescale 1ns / 1ps



module ALU
    #(parameter N = 32)
    (
    input [N-1:0] a,b,
    input [2:0] ALUOP,
    
    output reg [N-1:0] y,         
    output reg cf,of,zero,sf
    );
    
always@(*)
    begin
        case(ALUOP)
            3'b000:  {cf,y} = a+b;
            3'b001:  {cf,y} = a-b;
            3'b010:  {cf,y} = a&b;
            3'b011:  {cf,y} = a|b;
            3'b100:  {cf,y} = a^b;
            default: y = 4'bz;
        endcase
        zero = (y == 0) ? 1 : 0;
    end
endmodule
