`timescale 1ns / 1ps


module pipeline(
    input CLK,RST
    );
    
    //==========================IF==================================
    wire [31:0] PC,NextPC,IR;
    wire [1:0] PCSrc;
    
    //--------------------------IF_ID--------------------------------
    wire [31:0] IF_ID_IR,IF_ID_NPC;
    
    
    //==========================ID==================================
    wire [5:0] op,funct;
    wire [4:0] rs,rt,rd;
    wire [15:0] Imm;
    wire [25:0]addr;
    wire [4:0] ReadReg1,ReadReg2;
    wire [31:0] ReadData1,ReadData2,Ext_Imm;
    
    wire ID_RegDst, ID_ALUSrc;   wire [2:0] ID_ALUOp;
    wire [1:0] ID_PCSrc;   //用来区分Jump和其他指令，原数据通路无
    wire ID_Branch, ID_Jump, ID_MemWrite, ID_MemRead; 
    wire ID_RegWrite,ID_MemtoReg;
    
    //--------------------------ID_EXE--------------------------------
    wire [31:0] ID_EXE_A, ID_EXE_B, ID_EXE_NPC, ID_EXE_IR, ID_EXE_EXT_IMM;
    //ID_EXE_EX
    wire ID_EXE_RegDst, ID_EXE_ALUSrc;   
    wire [2:0] ID_EXE_ALUOp;
    //ID_EXE_M
    wire ID_EXE_Branch, ID_EXE_Jump, ID_EXE_MemWrite, ID_EXE_MemRead; 
    //ID_EXE_WB
    wire ID_EXE_RegWrite,ID_EXE_MemtoReg;
    
    
    //==========================EXE==================================
    wire [31:0] EXE_ALUA, EXE_ALUB, EXE_ALURes, EXE_NPC_Branch, EXE_NPC_Jump;
    wire [4:0] EXE_WA;
    wire EXE_Zero;
    
    //-------------------------EXE_MEM--------------------------------
    wire [31:0] EXE_MEM_IR,EXE_MEM_Y,EXE_MEM_Zero,EXE_MEM_B,EXE_MEM_NPC_Branch,EXE_MEM_NPC_Jump;
    wire [4:0] EXE_MEM_WA;
    //EXE_MEM_M
    wire EXE_MEM_Branch, EXE_MEM_Jump, EXE_MEM_MemWrite, EXE_MEM_MemRead; 
    //EXE_MEM_WB
    wire EXE_MEM_RegWrite, EXE_MEM_MemtoReg;
    
    
    //==========================MEM=================================
    wire [31:0] MEM_WriteData, MEM_ReadData, MEM_Address;
    
    //------------------------MEM_WB---------------------------------
    wire [31:0] MEM_WB_IR,MEM_WB_Y,MEM_WB_MDR;
    
    wire [4:0] MEM_WB_WA;
    //MEM_WB_WB
    wire MEM_WB_RegWrite, MEM_WB_MemtoReg;
    
    
    //==========================WB==================================
    wire [4:0] WB_WA;
    wire [31:0] WB_WriteData;
    
    
    //IF
    mux4 MUXPC(.sel(PCSrc),.d0(IF_ID_NPC), .d1(EXE_MEM_NPC_Branch), .d2(EXE_MEM_NPC_Jump), .d3(32'b0), .out(NextPC));
    
    DFF DFFPC(.CLK(~CLK), .en(1), .RST(RST), .DIn(NextPC), .DOut(PC));
    InsMem IM(.a(PC[9:2]), .spo(IR));
    
    IF_ID IFID(.CLK(CLK), .RST(RST), .PC(PC), .IR(IR), 
               .IF_ID_IR(IF_ID_IR), .IF_ID_NPC(IF_ID_NPC));
    
    
    //ID
    InsCut IC(.instruction(IF_ID_IR), .op(op), .rs(rs), .rt(rt), .rd(rd), 
              .addr(addr), .immediate(Imm), .funct(funct));
    Control_Unit CU(
            .CLK(CLK), .RST(RST), .opcode(op), .funct(funct), 
            .RegDst(ID_RegDst), .ALUSrc(ID_ALUSrc),
            .ALUOp(ID_ALUOp), 
            .Branch(ID_Branch), .Jump(ID_Jump), .MemWrite(ID_MemWrite), .MemRead(ID_MemRead),
            .RegWrite(ID_RegWrite), .MemtoReg(ID_MemtoReg));
                    
    assign ReadReg1 = rs;
    assign ReadReg2 = rt;
    assign Ext_Imm = Imm[15] ? {16'hffff,Imm} : {16'h0000,Imm};
    
          
    RegFile RF(.clk(CLK), .ra0(ReadReg1), .ra1(ReadReg2), 
               .rd0(ReadData1), .rd1(ReadData2), 
               .wa(WB_WA), .we(MEM_WB_RegWrite), .wd(WB_WriteData));
    
    ID_EXE IDEXE(
        .CLK(CLK), .RST(RST), .IF_ID_IR(IF_ID_IR), .IF_ID_NPC(IF_ID_NPC), 
        .ReadData1(ReadData1), .ReadData2(ReadData2), .Ext_Imm(Ext_Imm), 
        .ID_RegDst(ID_RegDst), .ID_ALUSrc(ID_ALUSrc), .ID_ALUOp(ID_ALUOp),
        .ID_PCSrc(ID_PCSrc), .ID_Branch(ID_Branch), .ID_Jump(ID_Jump), .ID_MemWrite(ID_MemWrite), 
        .ID_MemRead(ID_MemRead), .ID_RegWrite(ID_RegWrite), .ID_MemtoReg(ID_MemtoReg),
        .ID_EXE_A(ID_EXE_A), .ID_EXE_B(ID_EXE_B), .ID_EXE_IR(ID_EXE_IR),
        .ID_EXE_NPC(ID_EXE_NPC), .ID_EXE_EXT_IMM(ID_EXE_EXT_IMM),
        .ID_EXE_RegDst(ID_EXE_RegDst), .ID_EXE_ALUSrc(ID_EXE_ALUSrc),
        .ID_EXE_ALUOp(ID_EXE_ALUOp), .ID_EXE_Branch(ID_EXE_Branch), .ID_EXE_Jump(ID_EXE_Jump),
        .ID_EXE_MemWrite(ID_EXE_MemWrite), .ID_EXE_MemRead(ID_EXE_MemRead),
        .ID_EXE_RegWrite(ID_EXE_RegWrite), .ID_EXE_MemtoReg(ID_EXE_MemtoReg));
    
    
    //EXE
    assign EXE_ALUA = ID_EXE_A;
    //assign EXE_ALUB = ID_EXE_ALUSrc ? ID_EXE_EXT_IMM : ID_EXE_B;
    mux2 #(32) MUX_ALUB(.sel(ID_EXE_ALUSrc), .d0(ID_EXE_B), .d1(ID_EXE_EXT_IMM), .out(EXE_ALUB));
    //assign EXE_WA = ID_EXE_RegDst ? ID_EXE_IR[15:11] : ID_EXE_IR[20:16];
    mux2 #(5) MUX_WA(.sel(ID_EXE_RegDst), .d0(ID_EXE_IR[20:16]), .d1(ID_EXE_IR[15:11]), .out(EXE_WA));
    assign EXE_NPC_Branch = ID_EXE_NPC + ID_EXE_EXT_IMM<<2;
    assign EXE_NPC_Jump = {ID_EXE_NPC[31:28],ID_EXE_IR[26:0],2'b00};
    
    ALU ALU_EXE(.a(EXE_ALUA), .b(EXE_ALUB), .ALUOp(ID_EXE_ALUOp), .y(EXE_ALURes), .zero(EXE_Zero));
    
    EXE_MEM EXEMEM(
        .CLK(CLK), .RST(RST), 
        .ID_EXE_IR(ID_EXE_IR), .ID_EXE_B(ID_EXE_B), 
        .EXE_ALURes(EXE_ALURes), .EXE_NPC_Branch(EXE_NPC_Branch), .EXE_NPC_Jump(EXE_NPC_Jump),
        .EXE_WA(EXE_WA),
        .ID_EXE_Branch(ID_EXE_Branch), .ID_EXE_Jump(ID_EXE_Jump), 
        .ID_EXE_MemWrite(ID_EXE_MemWrite), .ID_EXE_MemRead(ID_EXE_MemRead), 
        .ID_EXE_RegWrite(ID_EXE_RegWrite), .ID_EXE_MemtoReg(ID_EXE_MemtoReg),
        .EXE_Zero(EXE_Zero),
        .EXE_MEM_IR(EXE_MEM_IR), .EXE_MEM_Y(EXE_MEM_Y), .EXE_MEM_B(EXE_MEM_B), 
        .EXE_MEM_NPC_Branch(EXE_MEM_NPC_Branch), .EXE_MEM_NPC_Jump(EXE_MEM_NPC_Jump), 
        .EXE_MEM_WA(EXE_MEM_WA), 
        .EXE_MEM_Branch(EXE_MEM_Branch), .EXE_MEM_Jump(EXE_MEM_Jump), 
        .EXE_MEM_Zero(EXE_MEM_Zero),
        .EXE_MEM_MemWrite(EXE_MEM_MemWrite), .EXE_MEM_MemRead(EXE_MEM_MemRead), 
        .EXE_MEM_RegWrite(EXE_MEM_RegWrite), .EXE_MEM_MemtoReg(EXE_MEM_MemtoReg));
        
    
    //MEM
    assign PCSrc = EXE_MEM_Jump ? 2'b10 : (EXE_MEM_Zero ? (EXE_MEM_Branch ? 2'b01 : 2'b00) : 2'b00);
    assign MEM_WriteData = EXE_MEM_B;
    assign MEM_Address = EXE_MEM_Y;
    
    DataMem DM(.clk(CLK), .we(EXE_MEM_MemWrite), .a(MEM_Address[9:2]), 
               .d(MEM_WriteData), .spo(MEM_ReadData));
               
    MEM_WB MEMWB(
        .CLK(CLK), .RST(RST), .MEM_ReadData(MEM_ReadData), .MEM_Address(MEM_Address),
        .EXE_MEM_IR(EXE_MEM_IR), .EXE_MEM_WA(EXE_MEM_WA), 
        .EXE_MEM_RegWrite(EXE_MEM_RegWrite), .EXE_MEM_MemtoReg(EXE_MEM_MemtoReg),
        .MEM_WB_IR(MEM_WB_IR), .MEM_WB_Y(MEM_WB_Y), .MEM_WB_MDR(MEM_WB_MDR),
        .MEM_WB_WA(MEM_WB_WA), 
        .MEM_WB_RegWrite(MEM_WB_RegWrite), .MEM_WB_MemtoReg(MEM_WB_MemtoReg));
        
        //WB
        assign WB_WA = MEM_WB_WA;
        assign WB_WriteData = MEM_WB_MemtoReg ? MEM_WB_MDR : MEM_WB_Y;//调用寄存器操作在ID段
endmodule
