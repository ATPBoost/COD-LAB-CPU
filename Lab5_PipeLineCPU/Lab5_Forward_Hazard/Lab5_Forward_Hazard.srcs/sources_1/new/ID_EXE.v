`timescale 1ns / 1ps


module ID_EXE(
    input CLK,RST,EN,
    input [31:0] ID_IR,ID_NPC,ID_ReadData1,ID_ReadData2,ID_EXT_IMM,
    input ID_RegDst,
    input [4:0] ID_WA,
    input [2:0] ID_ALUOp,
    input ID_ALUSrc,        
    //input ID_Branch, ID_Jump, 
    input ID_MemWrite, ID_MemRead, 
    input ID_RegWrite, ID_MemtoReg,
    
    output reg [31:0] EXE_A, EXE_B, EXE_IR, EXE_NPC, EXE_EXT_IMM,
    output reg EXE_RegDst,
    output reg [4:0] EXE_WA, 
    output reg [2:0] EXE_ALUOp,
    output reg [1:0] EXE_ALUSrc,
    
    //output reg EXE_Branch, EXE_Jump, 
    output reg EXE_MemWrite, EXE_MemRead, 
    output reg EXE_RegWrite, EXE_MemtoReg
    );
    

    always@(negedge CLK)
    begin
        if(RST)
    begin
        EXE_A <= 0;         EXE_B <= 0;
        EXE_IR <= 0;        EXE_NPC <= ID_NPC;
        EXE_EXT_IMM <= 0;
        EXE_RegDst <= 0;
        EXE_WA <= 0;        
        EXE_ALUOp <= 0;       
        EXE_ALUSrc <= 0;
        //EXE_Branch <= 0;    EXE_Jump <= 0;
        EXE_MemWrite <= 0;  EXE_MemRead <= 0;
        EXE_RegWrite <= 0;  EXE_MemtoReg <= 0;
    end
    else
    begin
        EXE_A <= ID_ReadData1;          EXE_B <= ID_ReadData2;
        EXE_IR <= ID_IR;                EXE_NPC <= ID_NPC;
        EXE_EXT_IMM <= ID_EXT_IMM;
        EXE_RegDst <= ID_RegDst;
        EXE_WA <= ID_WA;        
        EXE_ALUOp <= ID_ALUOp;       
        EXE_ALUSrc <= ID_ALUSrc;
        //EXE_Branch <= ID_Branch;        EXE_Jump <= ID_Jump;
        EXE_MemWrite <= ID_MemWrite;    EXE_MemRead <= ID_MemRead;
        EXE_RegWrite <= ID_RegWrite;    EXE_MemtoReg <= ID_MemtoReg;
    end
    end
endmodule
