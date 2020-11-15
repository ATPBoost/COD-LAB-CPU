`timescale 1ns / 1ps


module MEM_WB(
    input CLK,RST,
    input [31:0] MEM_ReadData, MEM_Y,
    input [4:0] MEM_WA,
    input MEM_RegWrite, MEM_MemtoReg,
    output reg [31:0] WB_Y, WB_MDR,
    output reg [4:0] WB_WA,
    output reg WB_RegWrite, WB_MemtoReg
    );
    
    always@(negedge CLK)
    begin
    if(RST)
    begin
        WB_WA <= 0;
        WB_MDR <= 0;         WB_Y <= 0;
        WB_RegWrite <= 0;    WB_MemtoReg <= 0;
    end
    else
    begin
        WB_WA <= MEM_WA;
        WB_MDR <= MEM_ReadData;         WB_Y <= MEM_Y;
        WB_RegWrite <= MEM_RegWrite;    WB_MemtoReg <= MEM_MemtoReg;
    end
    end
endmodule
