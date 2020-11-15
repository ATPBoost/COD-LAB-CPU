`timescale 1ns / 1ps


module SingleCPU(
        input clk,rst
         );
    //PC��ر���
    wire [31:0] curPC,nextPC;
    
    //ָ����ر���
    wire [31:0] instruction;
    wire [5:0] op;
    wire [4:0] rs,rt,rd;
    wire [15:0] immediate;
    wire [25:0] addr;
    
    //�����洢������ѡ����ALU�ӿ�
    wire [4:0] WriteReg;                //�Ĵ�����д�ص�ַ
    wire [31:0] ALUSrcB;                //ALU�ڶ�����
    wire [31:0] RF_ReadData1,RF_ReadData2,ALUout;//�Ĵ���������Լ�ALU���
    wire [31:0] RF_WriteData,WriteData,ReadData;         //���ݴ洢���������
    wire [31:0] Ex_Imm;                  //λ��չ���Imm
    //��������ر���
    wire zero,PCWre,RegDst,RegWrite,ALUSrc,Jump,Branch,MemWrite,MemtoReg;
    wire [2:0] ALUOp;
    
    assign Ex_Imm = immediate[15] ? {16'hffff,immediate} : {16'h0000,immediate};
    assign WriteReg = RegDst ? rd : rt;
    assign ALUSrcB = ALUSrc ? Ex_Imm : RF_ReadData2;
    assign RF_WriteData = MemtoReg ? ReadData : ALUout;
    assign WriteData = RF_ReadData2;
    
    InsCut IC(.instruction(instruction), .op(op), .rs(rs), .rt(rt), .rd(rd),
    .addr(addr), .immediate(immediate));
    
    ControlUnit CU(.op(op), .PCWre(PCWre), .RegDst(RegDst), .RegWrite(RegWrite), .ALUSrc(ALUSrc),
    .Jump(Jump), .Branch(Branch), .ALUOp(ALUOp), .MemWrite(MemWrite), .MemtoReg(MemtoReg));
    
    pcADD pcadd(.clk(clk), .rst(rst), .Branch(Branch), .zero(zero), .Jump(Jump), 
    .Ex_Imm(Ex_Imm), .addr(addr), .curPC(curPC), .nextPC(nextPC));
    
    PC PC(.clk(clk),.rst(rst), .PCWre(PCWre), .nextPC(nextPC), .curPC(curPC));
    
    RegFile RF(.clk(clk), .ra0(rs), .ra1(rt), .rd0(RF_ReadData1), .rd1(RF_ReadData2), 
    .wa(WriteReg), .we(RegWrite), .wd(RF_WriteData));
    
    ALU alu(.a(RF_ReadData1), .b(ALUSrcB), .ALUOP(ALUOp), .y(ALUout), .zero(zero));
    
    InsMem IM(.a(curPC[9:2]), .spo(instruction));
    
    DataMem DM(.we(MemWrite), .a(ALUout[9:2]), .clk(clk), .d(RF_ReadData2), .spo(ReadData));
    
    
endmodule
