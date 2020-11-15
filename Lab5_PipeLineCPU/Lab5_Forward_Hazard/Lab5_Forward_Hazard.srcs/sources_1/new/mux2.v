`timescale 1ns / 1ps


module mux2 #(parameter WIDTH = 32)(
    input sel,
    input [WIDTH-1:0] d0,
    input [WIDTH-1:0] d1,
    output [WIDTH-1:0] out
    );
	assign out = (sel == 1'b1 ? d1 : d0);

endmodule
