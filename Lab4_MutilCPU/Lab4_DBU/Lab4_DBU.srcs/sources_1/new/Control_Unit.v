`timescale 1ns / 1ps


module Control_Unit(
       input CLK,RST,
       input [5:0] op,     //ָ��Ĳ�����
       input [5:0] funct,
       input run,//����״̬����
       
       output reg [2:0] CUR_STATE,NEXT_STATE,
       output reg [1:0] PCSrc,  //����PC�ĸ�����Դ��0:PC+4(IF�׶ε�PC���£�������ALUOut)1:beq��Ӧ��ALUOut 2:Jumpָ��    
       output reg [2:0] ALUOp,        //ALUOP������
       output reg ALUSrcA,      //ѡ��ALU��A���� 0:ѡ��PC���PC+4.1:ѡ��Ĵ����Ѷ�������
       output reg [1:0] ALUSrcB,//ѡ��ALU��B���� 0:ѡ��Ĵ����Ѷ������� 1:4,���PC+4 2:ѡ����չ��������� 3:Jumpָ�����PCʱ��������
       output reg RegWrite,     //�Ĵ�����дʹ��
       output reg RegDst,       //ѡ��Ĵ�����д���ַ 0:rt 1:rd
       output reg PCWriteCond,  //beqָ��ʹ�ã������beqָ���zero�룬��zeroΪ1��PCwe=1
       output reg PCWrite,      //ѡ���Ƿ�дPC�����ȼ����ߣ�Ϊ1PCwe��Ϊ1
       output reg lorD,         //ѡ���ȡ����(1)����ָ��(0)
       output reg MemRead,      //���ݴ洢��дʹ��
       output reg MemWrite,     //���ݴ洢����ʹ�� dram����û��
       output reg MemtoReg,     //ѡ��д�ؼĴ�����������Դ 0: ALUOut 1: DataMem����
       output reg IRWrite       //ָ����£���IF�׶θ���
);

    
    parameter [2:0] INIT = 3'b000,IF = 3'b001,ID = 3'b010,EXE = 3'b011,MEM = 3'b100,WB = 3'b101,HLT = 3'b110;
    parameter [5:0] R_TYPE = 6'b000000,ADDI = 6'b001000,LW = 6'b100011,
                    SW = 6'b101011,BEQ = 6'b000100,JUMP = 6'b000010;
//��ʼ��״̬ΪINIT���������ź�Ϊ0
initial
begin
    CUR_STATE = INIT;
    // 2     3      1       2       1       1         1         1     1      1       1        1        1
    {PCSrc,ALUOp,ALUSrcA,ALUSrcB,RegWrite,RegDst,PCWriteCond,PCWrite,lorD,MemRead,MemWrite,MemtoReg,IRWrite} = 17'b0;
end

//״̬��
always@(posedge CLK) 
begin
       if(RST)
           CUR_STATE <= INIT;
       else if(run)
           CUR_STATE <= NEXT_STATE;
       else
           CUR_STATE <= CUR_STATE;
end

//״̬ת��
always@(*)
begin
    case(CUR_STATE)
        //ȡָ����׶θ�ָ����ͬ
        INIT: NEXT_STATE <= IF;
        IF:   NEXT_STATE <= ID;
        ID:   NEXT_STATE <= EXE;
        //��EXE�ο�ʼҪ���ǲ�ָͬ��ִ����ת���
        EXE:
        begin
            case(op)
                BEQ: NEXT_STATE <= IF;//beq
                JUMP: NEXT_STATE <= IF;//Jump
                default :  NEXT_STATE <= MEM;
            endcase
        end
        MEM:
        begin
            case(op)
                LW: NEXT_STATE <= WB;//lw
                default:   NEXT_STATE <= IF;
            endcase
        end
        WB: NEXT_STATE <= IF;
        default: NEXT_STATE <= INIT;
    endcase
end

//�Ը��������źŸ�ֵ
always@(*)
begin
    PCWrite = 0; PCSrc = 2'b00; PCWriteCond = 0; ALUSrcA = 0; ALUSrcB = 2'b00;
    ALUOp = 3'b000; MemtoReg = 0; RegWrite = 0; RegDst = 0;
    lorD = 0; IRWrite = 0; MemRead = 0; MemWrite = 0;
    case(CUR_STATE)
    IF:
    begin
        PCWrite = 1;
        ALUSrcB = 2'b01;
        IRWrite = 1;
        MemRead = 1;
    end
    ID:
    begin
        ALUSrcB = 2'b11;
    end
    EXE:
    begin
    case(op)
        R_TYPE:
        begin
            ALUSrcA = 1;
            case(funct)
                6'b100000:ALUOp = 3'b000;//add
                6'b100010:ALUOp = 3'b001;//sub
                6'b100100:ALUOp = 3'b010;//and
                6'b100101:ALUOp = 3'b011;//or
                6'b100110:ALUOp = 3'b100;//xor
                6'b100111:ALUOp = 3'b101;//nor
            endcase
        end
        ADDI:
        begin
            ALUSrcA = 1;    ALUSrcB = 2'b10;
        end
        LW:
        begin
           ALUSrcA = 1;    ALUSrcB = 2'b10;
        end
        SW:
        begin
            ALUSrcA = 1;    ALUSrcB = 2'b10;
        end
        BEQ:
        begin
            PCWrite = 0;    PCSrc = 2'b01;  PCWriteCond = 1;
            ALUSrcA = 1;    ALUSrcB = 2'b00;    ALUOp = 3'b001;
        end
        JUMP:
        begin
            PCWrite = 1;    PCSrc = 2'b10;
        end
    endcase
    end
    MEM:
    begin
    case(op)
        R_TYPE:
        begin
            RegWrite = 1;   RegDst = 1;
        end
        ADDI:
        begin
            RegWrite = 1;   RegDst = 0;
        end
        LW:
        begin
            lorD = 1;       
            MemRead = 1;    
        end
        SW:
        begin
            lorD = 1;       
            MemWrite = 1;
        end
        endcase
    end
    WB:
    begin
        MemtoReg = 1;
        RegWrite = 1;
    end
    endcase    
end
                
endmodule










