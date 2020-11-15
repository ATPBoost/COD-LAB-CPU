`timescale 1ns / 1ps


//D���������������¸��Ĵ����ź�
module DFF #(parameter WIDTH = 32) ( //Data Flip-Flop 
    input CLK,RST,
    input en,
    input [WIDTH-1:0] DIn,
    output reg [WIDTH-1:0] DOut
    );
	always@(posedge CLK)
	begin
		if(RST)
			DOut <= 0;
		else if(en)
			DOut <= DIn;
	end
endmodule
