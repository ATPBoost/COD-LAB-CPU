`timescale 1ns / 1ps


module EXE_MEM(
    input CLK,RST,
    input [31:0] EXE_IR, EXE_B, EXE_ALURes,//EXE_NPC_Branch,EXE_NPC_Jump,
    input [4:0] EXE_WA,
    //input ID_EXE_Branch, ID_EXE_Jump, EXE_Zero, 
    input EXE_MemWrite, EXE_MemRead,
    input EXE_RegWrite, EXE_MemtoReg,
    
    output reg [31:0] MEM_IR, MEM_Y, MEM_B,
    //output reg [31:0] MEM_NPC_Branch,MEM_NPC_Jump,
    output reg [4:0] MEM_WA,
    //output reg MEM_Branch, MEM_Jump, MEM_Zero, 
    output reg MEM_MemWrite, MEM_MemRead,
    output reg MEM_RegWrite, MEM_MemtoReg
    );
    
    always@(negedge CLK)
    begin
    if(RST)
    begin
        MEM_IR <= 0;        MEM_Y <= 0;
        MEM_B <= 0;         MEM_WA <= 0;
        MEM_MemWrite <= 0;  MEM_MemRead <= 0;
        MEM_RegWrite <= 0;  MEM_MemtoReg <= 0;
    end
    else
    begin
        MEM_IR <= EXE_IR;                MEM_Y <= EXE_ALURes;
        MEM_B <= EXE_B;                  MEM_WA <= EXE_WA;
        //MEM_Zero <= EXE_Zero;MEM_NPC_Branch <= NPC_Branch;MEM_NPC_Jump <= EXE_NPC_Jump;
        //MEM_Branch <= EXE_Branch;      MEM_Jump <= EXE_Jump;
        MEM_MemWrite <= EXE_MemWrite;    MEM_MemRead <= EXE_MemRead;
        MEM_RegWrite <= EXE_RegWrite;    MEM_MemtoReg <= EXE_MemtoReg;
    end
    end
endmodule