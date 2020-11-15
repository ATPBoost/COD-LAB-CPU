`timescale 1ns / 1ps


module SingleCPU(
        input clk,rst,
        input [2:0]sel,             //����ѡ��
        input m_rf,                 //ѡ��datamem����regfile
        input [7:0]m_rf_addr,               //��ַ��DM��RFͨ��
        input succ,step_edg,                //PC��ת���
        output reg [31:0]status,    //��������selѡ���32λ����
        output reg [15:0]sw         //ledָʾ�ƿ���
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
    wire zero,RegDst,RegWrite,ALUSrc,Jump,Branch,MemWrite,MemRead,MemtoReg,PCWre;//PCWre����RUN
    wire [2:0] ALUOp;
    
    wire [31:0]m_data,rf_data;
    
    assign PCWre = succ ? 1 : (step_edg ? 1 : 0);
    assign Ex_Imm = immediate[15] ? {16'hffff,immediate} : {16'h0000,immediate};
    assign WriteReg = RegDst ? rd : rt;
    assign ALUSrcB = ALUSrc ? Ex_Imm : RF_ReadData2;
    assign RF_WriteData = MemtoReg ? ReadData : ALUout;
    assign WriteData = RF_ReadData2;
    
    InsCut IC(.instruction(instruction), .op(op), .rs(rs), .rt(rt), .rd(rd),
    .addr(addr), .immediate(immediate));
    
    ControlUnit CU(.op(op), .RegDst(RegDst), .RegWrite(RegWrite), .ALUSrc(ALUSrc),
    .Jump(Jump), .Branch(Branch), .ALUOp(ALUOp), .MemWrite(MemWrite), .MemRead(MemRead), .MemtoReg(MemtoReg));
    
    pcADD pcadd(.clk(clk), .rst(rst), .Branch(Branch), .zero(zero), .Jump(Jump), 
    .Ex_Imm(Ex_Imm), .addr(addr), .curPC(curPC), .nextPC(nextPC));
    
    PC PC(.clk(clk),.rst(rst), .PCWre(PCWre), .nextPC(nextPC), .curPC(curPC));
    
    RegFile RF(.clk(clk), .ra0(rs), .ra1(rt), .ra2(m_rf_addr), .rd0(RF_ReadData1), .rd1(RF_ReadData2), 
    .rd2(rf_data), .wa(WriteReg), .we(RegWrite), .wd(RF_WriteData));//���������˿ڼĴ����ѣ���֤�����ִ��ָ�������ݱ�����
    
    ALU alu(.a(RF_ReadData1), .b(ALUSrcB), .ALUOP(ALUOp), .y(ALUout), .zero(zero));
    
    InsMem IM(.a(curPC[9:2]), .spo(instruction));
    
    DataMem DM(ALUout[9:2], RF_ReadData2, m_rf_addr, clk, 
    MemWrite, ReadData, m_data);
    

    
    DataMem dm(.we(0), .a(m_rf_addr), .clk(clk), .d(0), .spo(m_data));      //��ȡ DataMem����
    
    always@(*)
    begin
       case(sel)    //����ѡ�����ݴ浽status��
       3'b000:  status = m_rf ? m_data : rf_data;
       3'b001:  status=curPC;
       3'b010:  status=nextPC;
       3'b011:  status=instruction;
       3'b100:  status=RF_ReadData1;
       3'b101:  status=RF_ReadData2;
       3'b110:  status=ALUout;
       3'b111:  status=ReadData;
       endcase
    end
    always@(*)
    begin
       if(sel != 0)      //���㣬��sw��ʾ�������ź�
       begin
            sw[15:12]=4'b0;
            sw[11:0]={Jump, Branch, RegDst, RegWrite, MemRead, MemtoReg, MemWrite, ALUOp, ALUSrc,zero};
       end
       else
            sw = 16'b0;
    end
    
endmodule
