`timescale 1ns / 1ps


module Mulit_CPU(
    input CLK,RST
    );
    
    wire [2:0] CUR_STATE;
    wire [31:0] CurPC,NextPC;
    wire [5:0] op;
    wire [4:0] rs,rt,rd,WriteReg;
    wire [15:0] immediate;
    wire [25:0] addr;
    
    wire[1:0] PCSrc,ALUSrcB;
    wire [2:0] ALUOp;
    wire ALUSrcA,RegWrite,RegDst,PCWriteCond,PCWrite,PCwe,
         lorD,MemRead,MemWrite,MemtoReg,IRWrite,zero;
    wire [31:0] IRIns,MemData,Mem_WriteData,
                ReadReg1,ReadReg2,ReadData1,ReadData2,Reg_WriteData,
                ALUA,ALUB,MemDataReg,A,B,ALUresult,
                Ex_Imm;
    reg [31:0] ALUOut;
    wire [8:0] Address;
                
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
        if(op == 6'b100011 && CUR_STATE == 3'b100)
            ALUOut = ALUOut;
        else
            ALUOut = ALUresult;
    end
    
    Memory Memm(.we(MemWrite), .a(Address), .clk(CLK), .d(ReadData2), .spo(MemData));
    RegFile RF(.clk(CLK), .ra0(rs), .ra1(rt), .rd0(ReadData1), .rd1(ReadData2), 
               .wa(WriteReg), .we(RegWrite), .wd(Reg_WriteData));
    
    PC PC(.clk(CLK), .rst(RST), .PCwe(PCwe), .NextPC(NextPC), .CurPC(CurPC));
    
    PCAdd PCAdd(.RST(RST), .addr(addr), .PCSrc(PCSrc), .CurPC(CurPC), .ALUresult(ALUresult), .ALUout(ALUOut), .NextPC(NextPC));
    
    IR IR(.Ins(MemData), .CLK(CLK), .IRWrite(IRWrite), .IRIns(IRIns));
    
    InsCut IC(.instruction(IRIns), .op(op), .rs(rs), .rt(rt), .rd(rd),
    .addr(addr), .immediate(immediate));
    
    Control_Unit CU(.CLK(CLK), .RST(RST), .op(op), .PCSrc(PCSrc), .ALUOp(ALUOp), .ALUSrcA(ALUSrcA),
          .ALUSrcB(ALUSrcB), .RegWrite(RegWrite), .RegDst(RegDst), .PCWriteCond(PCWriteCond),
          .PCWrite(PCWrite), .lorD(lorD), .MemRead(MemRead), .MemWrite(MemWrite), 
          .MemtoReg(MemtoReg), .IRWrite(IRWrite), .CUR_STATE(CUR_STATE));
          
    ALU ALU(.a(ALUA), .b(ALUB), .ALUOp(ALUOp), .y(ALUresult), .zero(zero));
    
    
endmodule