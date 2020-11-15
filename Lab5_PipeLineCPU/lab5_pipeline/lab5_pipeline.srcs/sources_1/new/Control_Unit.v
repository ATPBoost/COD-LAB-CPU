`timescale 1ns / 1ps


module Control_Unit(
    input CLK,RST,
    input [5:0] opcode,funct,
    //output reg [1:0] PCSrc,
    output reg RegDst, ALUSrc,  //暂时一位，forwarding时位数改变
    output reg [2:0] ALUOp,
    output reg Branch, Jump, MemWrite, MemRead, 
    output reg RegWrite, MemtoReg
    );
    
    parameter [5:0] ADD = 6'b000000,ADDI = 6'b001000,LW = 6'b100011,
                    SW = 6'b101011,BEQ = 6'b000100,JUMP = 6'b000010;
    always@(negedge CLK or posedge RST)
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
                RegDst = 1;         ALUSrc = 1;
                ALUOp = 3'b000;     
                Branch = 0;         Jump = 0;
                MemWrite = 0;       MemRead = 0;
                RegWrite = 1;       MemtoReg = 0;
            end
            LW:
            begin
                RegDst = 1;         ALUSrc = 1;
                ALUOp = 3'b000;     
                Branch = 0;         Jump = 0;
                MemWrite = 0;       MemRead = 1;
                RegWrite = 1;       MemtoReg = 1;
            end
            SW:
            begin
                RegDst = 1'bx;      ALUSrc = 1;
                ALUOp = 3'b000;     
                Branch = 0;         Jump = 0;
                MemWrite = 1;       MemRead = 0;
                RegWrite = 0;       MemtoReg = 1'bx;
            end
            BEQ:
            begin
                RegDst = 1'bx;      ALUSrc = 0;
                ALUOp = 3'b001;     
                Branch = 1;         Jump = 0;
                MemWrite = 0;       MemRead = 0;
                RegWrite = 0;       MemtoReg = 1'bx;
            end
            JUMP:
            begin
                RegDst = 1'bx;      ALUSrc = 1'bx;
                ALUOp = 3'b000;     
                Branch = 0;         Jump = 1;
                MemWrite = 0;       MemRead = 0;
                RegWrite = 0;       MemtoReg = 1'bx;
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
