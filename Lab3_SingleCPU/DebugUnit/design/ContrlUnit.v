`timescale 1ns / 1ps


module ControlUnit(
        input zero,         //ALU运算结果是否为0，为0时候为1
        input [5:0] op,     //指令的操作码
        //output reg ExtSel,      //立即数扩展的信号量，为0时候为0扩展，否则为符号扩展
        //output reg InsMemRW,    //指令寄存器的状态操作符，为0的时候写指令寄存器，否则为读指令寄存器
        output  RegDst,      //写寄存器组寄存器的地址，为0的时候地址来自rt，为1的时候地址来自rd
        output  RegWrite,      //寄存器组写使能，为1的时候可写
        output  ALUSrc,     //控制ALU数据B的选择端的输入，为0的时候，来自寄存器堆data2输出，为1时候来自扩展过的立即数
        output  Jump,Branch,  //获取下一个pc的地址的数据选择器的选择端输入
        output  [2:0]ALUOp,  //ALU 8种运算功能选择(000-111)
        //output reg mRD,         //数据存储器读控制信号，为0读
        output  MemWrite,MemRead,         //数据存储器写控制信号，为1写
        output  MemtoReg    //数据保存的选择端，为0来自ALU运算结果的输出，为1来自数据寄存器（Data MEM）的输出        
    );
    reg [9:0] code;
    
    
    always@(*) 
    begin
        //InsMemRW = (op == 6'b111111) ? 0 : 1;    
        case(op)
            //add
            6'b000000: code = 11'b1_1_0_0_0_000_0_0_0;
            //addi
            6'b001000: code = 11'b0_1_1_0_0_000_0_0_0;
            //lw
            6'b100011: code = 11'b0_1_1_0_0_000_0_1_1;
            //sw
            6'b101011: code = 11'b0_0_1_0_0_000_1_0_0;
            //beq
            6'b000100: code = 11'b0_0_0_0_1_001_0_0_0;
            //j
            6'b000010: code = 11'b0_0_0_1_0_000_0_0_0;
            default:   
            begin
                code = 11'b00000000000;
            end
        endcase
    end
    assign {RegDst,RegWrite,ALUSrc,Jump,Branch,ALUOp,MemWrite,MemRead,MemtoReg} = code;
endmodule
