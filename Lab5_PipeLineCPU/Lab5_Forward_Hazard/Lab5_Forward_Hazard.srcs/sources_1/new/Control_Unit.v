`timescale 1ns / 1ps


module Control_Unit(
    input CLK,RST,//ID_Zero,
    input [5:0] opcode,funct,
    //output reg [1:0] ID_PCSrc,
    output reg RegDst, ALUSrc,  
    output reg [2:0] ALUOp,
    output reg Branch, Jump, MemWrite, MemRead, 
    output reg RegWrite, MemtoReg
    );
    
    parameter [5:0] ADD = 6'b000000,ADDI = 6'b001000,LW = 6'b100011,
                    SW = 6'b101011,BEQ = 6'b000100,JUMP = 6'b000010;
    always@(*)
    if(RST)
    begin
        RegDst = 0;         ALUSrc = 0;
        ALUOp = 3'b000;     
        Branch = 0;         Jump = 0;
        MemWrite = 0;       MemRead = 0;
        RegWrite = 0;       MemtoReg = 0;
    end
    else
    begin
        case(opcode)
            ADD:
            begin    
                RegDst = 1;         ALUSrc = 0;
                ALUOp = 3'b000;     
                Branch = 0;         Jump = 0;
                MemWrite = 0;       MemRead = 0;
                RegWrite = 1;       MemtoReg = 0;
            end
            ADDI:
            begin

                RegDst = 0;         ALUSrc = 1;
                ALUOp = 3'b000;     
                Branch = 0;         Jump = 0;
                MemWrite = 0;       MemRead = 0;
                RegWrite = 1;       MemtoReg = 0;
            end
            LW:
            begin

                RegDst = 0;         ALUSrc = 1;
                ALUOp = 3'b000;     
                Branch = 0;         Jump = 0;
                MemWrite = 0;       MemRead = 1;
                RegWrite = 1;       MemtoReg = 1;
            end
            SW:
            begin

                RegDst = 1'bz;      ALUSrc = 1;
                ALUOp = 3'b000;     
                Branch = 0;         Jump = 0;
                MemWrite = 1;       MemRead = 0;
                RegWrite = 0;       MemtoReg = 1'bz;
            end
            BEQ:
            begin
                RegDst = 1'bz;      ALUSrc = 1'bz;
                ALUOp = 3'b001;     
                Branch = 1;         Jump = 0;
                MemWrite = 0;       MemRead = 0;
                RegWrite = 0;       MemtoReg = 1'bz;
            end
            JUMP:
            begin
                RegDst = 1'bz;      ALUSrc = 1'bz;
                ALUOp = 3'b000;     
                Branch = 0;         Jump = 1;
                MemWrite = 0;       MemRead = 0;
                RegWrite = 0;       MemtoReg = 1'bz;
            end
            default:
            begin
                RegDst = 0;         ALUSrc = 0;
                ALUOp = 3'b000;     
                Branch = 0;         Jump = 0;
                MemWrite = 0;       MemRead = 0;
                RegWrite = 0;       MemtoReg = 0;
            end
            endcase 
    end
    
    
endmodule
