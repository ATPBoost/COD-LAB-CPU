`timescale 1ns / 1ps


module Control_Unit(
       input CLK,RST,
       input [5:0] op,     //指令的操作码
       input [5:0] funct,
       input run,//控制状态更新
       
       output reg [2:0] CUR_STATE,NEXT_STATE,
       output reg [1:0] PCSrc,  //控制PC的更新来源，0:PC+4(IF阶段的PC更新，不进入ALUOut)1:beq对应的ALUOut 2:Jump指令    
       output reg [2:0] ALUOp,        //ALUOP不解释
       output reg ALUSrcA,      //选择ALU的A输入 0:选择PC完成PC+4.1:选择寄存器堆读出数据
       output reg [1:0] ALUSrcB,//选择ALU的B输入 0:选择寄存器堆读出数据 1:4,完成PC+4 2:选择扩展后的立即数 3:Jump指令计算PC时的立即数
       output reg RegWrite,     //寄存器堆写使能
       output reg RegDst,       //选择寄存器堆写入地址 0:rt 1:rd
       output reg PCWriteCond,  //beq指令使用，如果是beq指令，和zero与，若zero为1则PCwe=1
       output reg PCWrite,      //选择是否写PC，优先级更高，为1PCwe即为1
       output reg lorD,         //选择读取数据(1)还是指令(0)
       output reg MemRead,      //数据存储器写使能
       output reg MemWrite,     //数据存储器读使能 dram还是没用
       output reg MemtoReg,     //选择写回寄存器堆数据来源 0: ALUOut 1: DataMem数据
       output reg IRWrite       //指令更新，在IF阶段更新
);

    
    parameter [2:0] INIT = 3'b000,IF = 3'b001,ID = 3'b010,EXE = 3'b011,MEM = 3'b100,WB = 3'b101,HLT = 3'b110;
    parameter [5:0] R_TYPE = 6'b000000,ADDI = 6'b001000,LW = 6'b100011,
                    SW = 6'b101011,BEQ = 6'b000100,JUMP = 6'b000010;
//初始化状态为INIT，各控制信号为0
initial
begin
    CUR_STATE = INIT;
    // 2     3      1       2       1       1         1         1     1      1       1        1        1
    {PCSrc,ALUOp,ALUSrcA,ALUSrcB,RegWrite,RegDst,PCWriteCond,PCWrite,lorD,MemRead,MemWrite,MemtoReg,IRWrite} = 17'b0;
end

//状态机
always@(posedge CLK) 
begin
       if(RST)
           CUR_STATE <= INIT;
       else if(run)
           CUR_STATE <= NEXT_STATE;
       else
           CUR_STATE <= CUR_STATE;
end

//状态转移
always@(*)
begin
    case(CUR_STATE)
        //取指译码阶段各指令相同
        INIT: NEXT_STATE <= IF;
        IF:   NEXT_STATE <= ID;
        ID:   NEXT_STATE <= EXE;
        //从EXE段开始要考虑不同指令执行跳转情况
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

//对各个控制信号赋值
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










