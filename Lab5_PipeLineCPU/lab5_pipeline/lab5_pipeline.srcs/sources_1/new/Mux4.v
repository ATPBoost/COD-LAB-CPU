`timescale 1ns / 1ps


module mux4 #(parameter WIDTH = 32)(
    input [1:0] sel,
    input [WIDTH-1:0] d0,d1,d2,d3,
    output reg [WIDTH-1:0] out
    );
    
	always@(*)
		case(sel)
			2'b00: out=d0;
			2'b01: out=d1;
			2'b10: out=d2;
			2'b11: out=d3;
			default:;

		endcase

endmodule
