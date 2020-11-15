`timescale 1ns / 1ps


module DBU_CPU(
    input CLK,RST,
    input [2:0]sel,             //功能选择
    input m_rf,                 //选择datamem还是regfile
    input [7:0]m_rf_addr,               //地址，DM和RF通用
    input succ,step_edg,                //PC跳转相关
    output reg [31:0]status,    //用来接收sel选择的32位数据
    output reg [15:0]sw         //led指示灯控制
    );
    
    wire [2:0] CUR_STATE;
    wire [31:0] CurPC,NextPC;
    wire [5:0] op;
    wire [4:0] rs,rt,rd,WriteReg;
    wire [15:0] immediate;
    wire [25:0] addr;
    wire [5:0] funct;
    
    wire[1:0] PCSrc,ALUSrcB;
    wire [2:0] ALUOp;
    wire run;
    wire ALUSrcA,RegWrite,RegDst,PCWriteCond,PCWrite,PCwe,
         lorD,MemRead,MemWrite,MemtoReg,IRWrite,zero;
    wire [31:0] IRIns,MemData,Mem_WriteData,
                ReadReg1,ReadReg2,ReadData1,ReadData2,Reg_WriteData,
                ALUA,ALUB,MemDataReg,A,B,ALUresult,
                Ex_Imm,
                m_data,rf_data;
                
    reg [31:0] ALUOut;
    wire [8:0] Address;
    
    
    assign run = succ ? 1 : step_edg;
    assign Ex_Imm = immediate[15] ? {16'hffff,immediate} : {16'h0000,immediate};
    assign PCwe = PCWrite|(PCWriteCond & zero);     //PCwe控制PC更新
    assign Address = lorD ? ALUOut[10:2] : CurPC[10:2]; //选择指令或数据
    assign MemDataReg = lorD ? MemData : MemDataReg;
    assign A = ReadData1,B = ReadData2;
    assign ALUA = ALUSrcA ? A : CurPC;
    assign ALUB = ALUSrcB[1] ? (ALUSrcB[0] ? (Ex_Imm << 2) : Ex_Imm) : (ALUSrcB[0] ? 32'b100 : B);
    
    assign WriteReg = RegDst ? rd : rt;
    assign Reg_WriteData = MemtoReg ? MemDataReg : ALUOut;
    always@(posedge CLK)
    begin
        if((op == 6'b100011 && CUR_STATE == 3'b100)|| !run)
            ALUOut = ALUOut;
        else
            ALUOut = ALUresult;
    end
    
    Memory Memm(.a(Address),.d(ReadData2),.clk(CLK),.we(MemWrite),.spo(MemData),.dpra(m_rf_addr),.dpo(m_data));
    RegFile RF(.clk(CLK), .ra0(rs), .ra1(rt), .ra2(m_rf_addr), .rd0(ReadData1), .rd1(ReadData2), .rd2(rf_data), 
               .wa(WriteReg), .we(RegWrite), .wd(Reg_WriteData));
    
    PC PC(.clk(CLK), .rst(RST), .PCwe(PCwe), .run(run), .NextPC(NextPC), .CurPC(CurPC));
    
    PCAdd PCAdd(.RST(RST), .addr(addr), .PCSrc(PCSrc), .CurPC(CurPC), .ALUresult(ALUresult), .ALUout(ALUOut), .NextPC(NextPC));
    
    IR IR(.Ins(MemData), .CLK(CLK), .IRWrite(IRWrite), .run(run), .IRIns(IRIns));
    
    InsCut IC(.instruction(IRIns), .op(op), .rs(rs), .rt(rt), .rd(rd),
    .addr(addr), .immediate(immediate), .funct(funct));
    
    Control_Unit CU(.CLK(CLK), .RST(RST), .op(op), .funct(funct), .run(run), .PCSrc(PCSrc), .ALUOp(ALUOp), .ALUSrcA(ALUSrcA),
          .ALUSrcB(ALUSrcB), .RegWrite(RegWrite), .RegDst(RegDst), .PCWriteCond(PCWriteCond),
          .PCWrite(PCWrite), .lorD(lorD), .MemRead(MemRead), .MemWrite(MemWrite), 
          .MemtoReg(MemtoReg), .IRWrite(IRWrite), .CUR_STATE(CUR_STATE));
          
    ALU ALU(.a(ALUA), .b(ALUB), .ALUOp(ALUOp), .y(ALUresult), .zero(zero));
    
    
    always@(*)
    begin
       case(sel)    //功能选择，数据存到status中
       3'b000:  status = m_rf ? m_data : rf_data;
       3'b001:  status=CurPC;
       3'b010:  status=IRIns;
       3'b011:  status=MemDataReg;
       3'b100:  status=A;
       3'b101:  status=B;
       3'b110:  status=ALUOut;
       endcase
    end
    always@(*)
    begin
       if(sel != 0)      //非零，在sw显示各控制信号
       begin
            sw[15:0]={PCSrc, PCwe, lorD, MemWrite, IRWrite, 
            RegDst, MemtoReg, RegWrite, ALUOp, ALUSrcA, ALUSrcB, zero};
       end
       else
            sw = 16'b0;
    end
    
endmodule
