`timescale 1ns / 1ps


module MEM_WB(
    input CLK,RST,
    input [31:0] MEM_ReadData, MEM_Address,
    input [31:0] EXE_MEM_IR,
    input [4:0] EXE_MEM_WA,
    input EXE_MEM_RegWrite, EXE_MEM_MemtoReg,
    output reg [31:0] MEM_WB_IR,MEM_WB_Y,MEM_WB_MDR,
    output reg [4:0] MEM_WB_WA,
    output reg MEM_WB_RegWrite, MEM_WB_MemtoReg
    );
    
    always@(negedge CLK)
    begin
        MEM_WB_IR <= EXE_MEM_IR;                MEM_WB_WA <= EXE_MEM_WA;
        MEM_WB_MDR <= MEM_ReadData;             MEM_WB_Y <= MEM_Address;
        MEM_WB_RegWrite <= EXE_MEM_RegWrite;    MEM_WB_MemtoReg <= EXE_MEM_MemtoReg;
    end
endmodule
