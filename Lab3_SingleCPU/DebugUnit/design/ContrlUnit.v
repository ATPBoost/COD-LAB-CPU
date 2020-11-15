`timescale 1ns / 1ps


module ControlUnit(
        input zero,         //ALU�������Ƿ�Ϊ0��Ϊ0ʱ��Ϊ1
        input [5:0] op,     //ָ��Ĳ�����
        //output reg ExtSel,      //��������չ���ź�����Ϊ0ʱ��Ϊ0��չ������Ϊ������չ
        //output reg InsMemRW,    //ָ��Ĵ�����״̬��������Ϊ0��ʱ��дָ��Ĵ���������Ϊ��ָ��Ĵ���
        output  RegDst,      //д�Ĵ�����Ĵ����ĵ�ַ��Ϊ0��ʱ���ַ����rt��Ϊ1��ʱ���ַ����rd
        output  RegWrite,      //�Ĵ�����дʹ�ܣ�Ϊ1��ʱ���д
        output  ALUSrc,     //����ALU����B��ѡ��˵����룬Ϊ0��ʱ�����ԼĴ�����data2�����Ϊ1ʱ��������չ����������
        output  Jump,Branch,  //��ȡ��һ��pc�ĵ�ַ������ѡ������ѡ�������
        output  [2:0]ALUOp,  //ALU 8�����㹦��ѡ��(000-111)
        //output reg mRD,         //���ݴ洢���������źţ�Ϊ0��
        output  MemWrite,MemRead,         //���ݴ洢��д�����źţ�Ϊ1д
        output  MemtoReg    //���ݱ����ѡ��ˣ�Ϊ0����ALU�������������Ϊ1�������ݼĴ�����Data MEM�������        
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
