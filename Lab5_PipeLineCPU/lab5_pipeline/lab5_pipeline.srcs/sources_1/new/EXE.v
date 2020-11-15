`timescale 1ns / 1ps


module EXE_MEM(
    input CLK,RST,
    input [31:0] ID_EXE_IR,ID_EXE_B,EXE_ALURes,EXE_NPC_Branch,EXE_NPC_Jump,
    input [4:0] EXE_WA,
    input ID_EXE_Branch, ID_EXE_Jump, ID_EXE_MemWrite, ID_EXE_MemRead,
    input ID_EXE_RegWrite, ID_EXE_MemtoReg,EXE_Zero,
    
    output reg [31:0] EXE_MEM_IR,EXE_MEM_Y,EXE_MEM_B,
    output reg [31:0] EXE_MEM_NPC_Branch,EXE_MEM_NPC_Jump,
    output reg [4:0] EXE_MEM_WA,
    output reg EXE_MEM_Branch, EXE_MEM_Jump, EXE_MEM_Zero, EXE_MEM_MemWrite, EXE_MEM_MemRead,
    output reg EXE_MEM_RegWrite, EXE_MEM_MemtoReg
    );
    
    always@(negedge CLK)
    begin
        EXE_MEM_IR <= ID_EXE_IR;                EXE_MEM_Y <= EXE_ALURes;
        EXE_MEM_B <= ID_EXE_B;                  EXE_MEM_Zero <= EXE_Zero;
        EXE_MEM_NPC_Branch <= EXE_NPC_Branch;   EXE_MEM_NPC_Jump <= EXE_NPC_Jump;
        
        EXE_MEM_WA <= EXE_WA;
        
        EXE_MEM_Branch <= ID_EXE_Branch;        EXE_MEM_Jump <= ID_EXE_Jump;
        EXE_MEM_MemWrite <= ID_EXE_MemWrite;    EXE_MEM_MemRead <= ID_EXE_MemRead;
        EXE_MEM_RegWrite <= ID_EXE_RegWrite;    EXE_MEM_MemtoReg <= ID_EXE_MemtoReg;
    end    
endmodule