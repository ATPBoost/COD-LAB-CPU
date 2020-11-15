`timescale 1ns / 1ps


module ID_EXE(
    input CLK,RST,
    input [31:0] IF_ID_IR,IF_ID_NPC,ReadData1,ReadData2,Ext_Imm,
    input ID_RegDst, ID_ALUSrc,
    input [2:0] ID_ALUOp,
    input [1:0] ID_PCSrc,   //用来区分Jump和其他指令，原数据通路无
    input ID_Branch, ID_Jump, ID_MemWrite, ID_MemRead, 
    input ID_RegWrite,ID_MemtoReg,
    
    output reg [31:0] ID_EXE_A,ID_EXE_B,ID_EXE_IR,ID_EXE_NPC,ID_EXE_EXT_IMM,
    output reg ID_EXE_RegDst, ID_EXE_ALUSrc,   
    output reg [2:0] ID_EXE_ALUOp,
    output reg ID_EXE_Branch, ID_EXE_Jump, ID_EXE_MemWrite, ID_EXE_MemRead, 
    output reg ID_EXE_RegWrite,ID_EXE_MemtoReg
    );
    
    always@(negedge CLK)
    begin
        ID_EXE_A <= ReadData1;  ID_EXE_B <= ReadData2;
        ID_EXE_IR <= IF_ID_IR;
        ID_EXE_NPC <= IF_ID_NPC;
        ID_EXE_EXT_IMM <= Ext_Imm;
        ID_EXE_RegDst <= ID_RegDst;     ID_EXE_ALUSrc <= ID_ALUSrc;   
        ID_EXE_ALUOp <= ID_ALUOp;       ID_EXE_Branch <= ID_Branch;
        ID_EXE_Jump <= ID_Jump;         ID_EXE_MemWrite <= ID_MemWrite;
        ID_EXE_MemRead <= ID_MemRead;   ID_EXE_RegWrite <= ID_RegWrite;
        ID_EXE_MemtoReg <= ID_MemtoReg;
    end
endmodule
