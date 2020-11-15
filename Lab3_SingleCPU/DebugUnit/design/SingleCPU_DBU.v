`timescale 1ns / 1ps


module SingleCPU(
        input clk,rst,
        input [2:0]sel,             //功能选择
        input m_rf,                 //选择datamem还是regfile
        input [7:0]m_rf_addr,               //地址，DM和RF通用
        input succ,step_edg,                //PC跳转相关
        output reg [31:0]status,    //用来接收sel选择的32位数据
        output reg [15:0]sw         //led指示灯控制
         );
    //PC相关变量
    wire [31:0] curPC,nextPC;
    
    //指令相关变量
    wire [31:0] instruction;
    wire [5:0] op;
    wire [4:0] rs,rt,rd;
    wire [15:0] immediate;
    wire [25:0] addr;
    
    //各个存储器，多选器，ALU接口
    wire [4:0] WriteReg;                //寄存器堆写回地址
    wire [31:0] ALUSrcB;                //ALU第二输入
    wire [31:0] RF_ReadData1,RF_ReadData2,ALUout;//寄存器堆输出以及ALU输出
    wire [31:0] RF_WriteData,WriteData,ReadData;         //数据存储器输入输出
    wire [31:0] Ex_Imm;                  //位扩展后的Imm
    //控制器相关变量
    wire zero,RegDst,RegWrite,ALUSrc,Jump,Branch,MemWrite,MemRead,MemtoReg,PCWre;//PCWre就是RUN
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
    .rd2(rf_data), .wa(WriteReg), .we(RegWrite), .wd(RF_WriteData));//例化三读端口寄存器堆，保证数码管执行指令后的数据被读出
    
    ALU alu(.a(RF_ReadData1), .b(ALUSrcB), .ALUOP(ALUOp), .y(ALUout), .zero(zero));
    
    InsMem IM(.a(curPC[9:2]), .spo(instruction));
    
    DataMem DM(ALUout[9:2], RF_ReadData2, m_rf_addr, clk, 
    MemWrite, ReadData, m_data);
    

    
    DataMem dm(.we(0), .a(m_rf_addr), .clk(clk), .d(0), .spo(m_data));      //读取 DataMem数据
    
    always@(*)
    begin
       case(sel)    //功能选择，数据存到status中
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
       if(sel != 0)      //非零，在sw显示各控制信号
       begin
            sw[15:12]=4'b0;
            sw[11:0]={Jump, Branch, RegDst, RegWrite, MemRead, MemtoReg, MemWrite, ALUOp, ALUSrc,zero};
       end
       else
            sw = 16'b0;
    end
    
endmodule
