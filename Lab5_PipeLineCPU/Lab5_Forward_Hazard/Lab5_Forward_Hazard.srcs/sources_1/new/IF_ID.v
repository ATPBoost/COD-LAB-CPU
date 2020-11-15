`timescale 1ns / 1ps


module IF_ID(
    input CLK,RST,EN,
    input [31:0] IF_PC, IF_NPC, IF_IR,
    output [31:0] ID_PC, ID_NPC, ID_IR
    );

	 DFF dff1(.CLK(~CLK), .en(EN), .RST(RST), .DIn(IF_PC), .DOut(ID_PC));
	 DFF dff2(.CLK(~CLK), .en(EN), .RST(RST), .DIn(IF_NPC), .DOut(ID_NPC));
	 DFF dff3(.CLK(~CLK), .en(EN), .RST(RST), .DIn(IF_IR), .DOut(ID_IR));

/*    
always@(negedge CLK)
    begin
    if(RST)
    begin
        ID_PC <= 32'b0;
        ID_IR <= 32'b0;
        ID_NPC <= 32'b0;
    end
    else if(EN)
    begin
        ID_PC <= IF_PC;
        ID_IR <= IF_IR;
        ID_NPC <= IF_NPC;
    end
    end
*/    
endmodule
