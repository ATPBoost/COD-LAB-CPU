`timescale 1ns / 1ps


module Hazard(
    input CLK,RST,
    input [5:0] ID_Opcode,
    input [4:0] ID_Rs, ID_Rt, EXE_WA,MEM_WA,WB_WA,
    input ID_Branch, EXE_MemRead, MEM_MemRead,WB_MemRead,
    output PC_EN, IF_ID_EN, ID_EXE_FLUSH,
    output reg [2:0] Count
    );
    
    //wire LW_FLUSH, BEQ_FLUSH;
    //若为LW + ALU指令且ALU使用寄存器和LW存入寄存器一样，则stall一周期
    //若ALU接BEQ指令，则stall两周期
    assign ID_EXE_FLUSH = 
        (
        (((EXE_WA==ID_Rs) || (EXE_WA==ID_Rt)) && (EXE_MemRead||ID_Opcode==6'b000100))
        ||
        (((MEM_WA==ID_Rs)||(MEM_WA ==ID_Rt)) && (MEM_MemRead || ID_Opcode==6'b000100))
        )
        &&
        (Count != 3);
        	
	assign IF_ID_EN = ~ID_EXE_FLUSH;//条件成立则为0，保持寄存器不更新
	assign PC_EN = ~ID_EXE_FLUSH;//条件成立则为0，保持寄存器不更新
	
	always@(posedge CLK or posedge RST)
	begin
	   if(RST)
	       Count <= 0;
	   else if(((EXE_WA == ID_Rs) || (EXE_WA == ID_Rt))&& 
	             (ID_Opcode == 6'b000100) && (Count != 1) && (Count != 2))
	       Count <= 1;
	   else if(Count == 1)
	       Count <= 2;
	   else if(Count == 2)
	       Count <= 3;
	   else if(Count == 3)
	       Count <= 0;
    end          
endmodule