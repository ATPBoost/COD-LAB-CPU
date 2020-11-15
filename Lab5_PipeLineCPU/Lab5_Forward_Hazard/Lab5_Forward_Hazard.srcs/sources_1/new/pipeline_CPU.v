`timescale 1ns / 1ps


module pipeline(
    input CLK,RST
    );
    
    //==========================IF==================================
    wire [31:0] IF_PC,IF_PC_Plus,IF_NPC,IF_IR;
    wire [1:0] PCSrc;
    wire PC_EN, IF_ID_EN, IF_ID_FLUSH;
    //--------------------------IF_ID--------------------------------
    //wire [31:0] IF_ID_IR,IF_ID_NPC;
    
    
    //==========================ID==================================
    wire ID_EXE_FLUSH;
    wire [2:0] Count;
    
    wire [31:0] ID_PC,ID_NPC,ID_IR;
    wire [5:0] ID_Opcode,ID_Funct;
    wire [4:0] ID_Rs, ID_Rt, ID_Rd, ID_WA;
    wire [15:0] ID_IMM;
    wire [25:0] ID_ADDR;
    wire [4:0] ID_ReadReg1,ID_ReadReg2;
    wire [31:0] ID_ReadData1,ID_ReadData2,ID_EXT_IMM,
                ID_NPC_Branch,ID_NPC_Jump;
    
    //  R-type + BEQ 相关处理变量
    wire [1:0] Beq_SelA,Beq_SelB;            
    wire [31:0] ID_Beq_A,ID_Beq_B;      
    
    
    wire ID_ALUSrc;      //0: EXE_B(包括Forward的数据，前接一个选择器)   1: EXE_EXT_IMM
    wire [2:0] ID_ALUOp;
    wire [1:0] ID_PCSrc;
    wire ID_RegDst;   
    wire ID_Branch, ID_Jump, ID_Zero;
    wire ID_MemWrite, ID_MemRead; 
    wire ID_RegWrite, ID_MemtoReg;
    
    
    //==========================EXE==================================
    wire [31:0] EXE_IR, EXE_NPC, EXE_A, EXE_B, EXE_EXT_IMM, EXE_ALURes,
                EXE_ALUA, EXE_ALUB, EXE_NPC_Branch, EXE_NPC_Jump;
    wire EXE_ALUSrc; 
    wire [4:0] EXE_WA;
    wire [2:0] EXE_ALUOp;
    wire [1:0] EXE_PCSrc;
    wire EXE_RegDst;
    //wire EXE_Branch, EXE_Jump, EXE_Zero;
    wire EXE_MemWrite, EXE_MemRead;
    wire EXE_RegWrite, EXE_MemtoReg;
    //Forwarding相关变量
    wire [4:0] EXE_Rs, EXE_Rt;
    wire [1:0] EXE_Forward_SelA,        //00: EXE_A  01: MEM_Y  10: WB_WriteData 
               EXE_Forward_SelB;        //00: EXE_B  01: MEM_Y  10: WB_WriteData
    wire [31:0] EXE_Forward_A, EXE_Forward_B;   //即ALUA，ALUB
    

    //==========================MEM=================================
    wire [31:0] MEM_WriteData, MEM_ReadData, MEM_Address;
    wire [31:0] MEM_IR, MEM_Y, MEM_MDR, MEM_B;
    wire [4:0] MEM_WA;
    //wire MEM_Branch, MEM_Jump, MEM_Zero;
    wire MEM_MemWrite, MEM_MemRead; 
    wire MEM_RegWrite, MEM_MemtoReg;

    
    //==========================WB==================================
    wire [4:0] WB_WA;
    wire [31:0] WB_MDR, WB_Y, WB_WriteData;
    wire WB_RegWrite, WB_MemtoReg;
    
    //IF
    //mux4 MUXPC(.sel(PCSrc),.d0(IF_ID_NPC), .d1(EXE_MEM_NPC_Branch), .d2(EXE_MEM_NPC_Jump), .d3(32'b0), .out(NextPC));
    mux4 MUXPC(.sel(ID_PCSrc),.d0(IF_PC_Plus), .d1(ID_NPC_Branch), .d2(ID_NPC_Jump), .d3(32'b0), .out(IF_NPC));
    
    DFF DFFPC(.CLK(~CLK), .en(PC_EN), .RST(RST), .DIn(IF_NPC), .DOut(IF_PC));
    InsMem IM(.a(IF_PC[9:2]), .spo(IF_IR));
    
    ALU ALUPC_plus_4(.a(IF_PC), .b(32'h0004), .ALUOp(3'b000), .y(IF_PC_Plus));
    
    IF_ID IFID(
            .CLK(CLK), .RST(RST || (/*ID_EXE_FLUSH*/IF_ID_FLUSH)), .EN(IF_ID_EN),
            .IF_PC(IF_PC), .IF_IR(IF_IR), .IF_NPC(IF_PC_Plus),//这里写入PC+4为了计算Beq和Jump
            .ID_PC(ID_PC), .ID_IR(ID_IR), .ID_NPC(ID_NPC));
    
    //////////////////////////////////////////////////////////////////////////////////////////////////
    //ID
    //Jump和Beq在ID段写回新指令
    InsCut IC(
        .instruction(ID_IR), .op(ID_Opcode), .rs(ID_Rs), .rt(ID_Rt), 
        .rd(ID_Rd), .addr(ID_ADDR), .immediate(ID_IMM), .funct(ID_Funct));
        
    Control_Unit CU(
            .CLK(CLK), .RST(RST), .opcode(ID_Opcode), .funct(ID_Funct), 
            .RegDst(ID_RegDst), .ALUSrc(ID_ALUSrc),
            .ALUOp(ID_ALUOp), 
            .Branch(ID_Branch), .Jump(ID_Jump), .MemWrite(ID_MemWrite), .MemRead(ID_MemRead),
            .RegWrite(ID_RegWrite), .MemtoReg(ID_MemtoReg));
                               
    assign ID_ReadReg1 = ID_Rs;
    assign ID_ReadReg2 = ID_Rt;
    assign ID_EXT_IMM = ID_IMM[15] ? {16'hffff,ID_IMM} : {16'h0000,ID_IMM};
    
    mux2 #(5) MUX_WA(.sel(ID_RegDst), .d0(ID_IR[20:16]), .d1(ID_IR[15:11]), .out(ID_WA));
          
    RegFile RF(.clk(CLK), .ra0(ID_ReadReg1), .ra1(ID_ReadReg2), 
               .rd0(ID_ReadData1), .rd1(ID_ReadData2), 
               .wa(WB_WA), .we(WB_RegWrite), .wd(WB_WriteData));
 
    //assign ID_Zero = (ID_Beq_A == ID_Beq_B) ? 1 : 0;
    ALU ALU_ID_BEQ(.a(ID_ReadData1), .b(ID_ReadData2), .ALUOp(3'b001), .zero(ID_Zero));
    //ALU ALU_ID_BEQ(.a(ID_Beq_A), .b(ID_Beq_B), .ALUOp(3'b001), .zero(ID_Zero));

    //ALU ALU_BEQ(.a(ID_NPC), .b(ID_EXT_IMM[29:0]<<2), .ALUOp(3'b000), .y(ID_NPC_Branch));
    
    assign ID_PCSrc = ID_Jump ? 2'b10 : (ID_Zero ? (ID_Branch ? 2'b01 : 2'b00) : 2'b00);
    assign ID_NPC_Branch = ID_NPC + (ID_EXT_IMM<<2);
    assign ID_NPC_Jump = {ID_NPC[31:28],ID_IR[26:0],2'b00};
    //ID段的相关处理通过Hazard暂停实现
    Hazard Hazard(
            .CLK(CLK), .RST(RST), .ID_Opcode(ID_Opcode), 
            .ID_Rs(ID_Rs), .ID_Rt(ID_Rt), .EXE_WA(EXE_WA), .MEM_WA(MEM_WA),
            .EXE_MemRead(EXE_MemRead), .MEM_MemRead(MEM_MemRead),
            .PC_EN(PC_EN), .IF_ID_EN(IF_ID_EN), .ID_EXE_FLUSH(ID_EXE_FLUSH),
            .Count(Count));

    assign IF_ID_FLUSH = (ID_PCSrc == 2'b00) ? 1'b0 :           //正常跳转不stall
                                (ID_PCSrc == 2'b10) ? 1'b1 :    //Jump stall一个周期
                                    (Count == 3) ? 1'b1 : 1'b0; //Beq stall若有相关stall两个周期
                                    
    
    
    
    ID_EXE IDEXE(
        .CLK(CLK), .RST(RST || ID_EXE_FLUSH), 
        .ID_IR(ID_IR), .ID_NPC(ID_NPC), 
        .ID_ReadData1(ID_ReadData1), .ID_ReadData2(ID_ReadData2), .ID_EXT_IMM(ID_EXT_IMM), 
        .ID_RegDst(ID_RegDst), .ID_ALUOp(ID_ALUOp),
        .ID_ALUSrc(ID_ALUSrc), //.ID_ALUSrcB(ID_ALUSrcB), 
        //.ID_Branch(ID_Branch), .ID_Jump(ID_Jump), 
        .ID_MemWrite(ID_MemWrite), .ID_MemRead(ID_MemRead), 
        .ID_RegWrite(ID_RegWrite), .ID_MemtoReg(ID_MemtoReg),
        .EXE_A(EXE_A), .EXE_B(EXE_B), .EXE_IR(EXE_IR),
        .EXE_NPC(EXE_NPC), .EXE_EXT_IMM(EXE_EXT_IMM),
        .EXE_RegDst(EXE_RegDst), .EXE_ALUOp(EXE_ALUOp),
        .EXE_ALUSrc(EXE_ALUSrc), //.EXE_ALUSrcB(EXE_ALUSrcB),
        //.EXE_Branch(EXE_Branch), .EXE_Jump(EXE_Jump),
        .ID_WA(ID_WA), .EXE_WA(EXE_WA),
        .EXE_MemWrite(EXE_MemWrite), .EXE_MemRead(EXE_MemRead),
        .EXE_RegWrite(EXE_RegWrite), .EXE_MemtoReg(EXE_MemtoReg));
    /////////////////////////////////////////////////////////////////////////////////////////////////
    
    //EXE
    assign EXE_Rs = EXE_IR[25:21];
    assign EXE_Rt = EXE_IR[20:16];
    
    Forwarding Forward(
        .ID_Rs(ID_Rs), .ID_Rt(ID_Rt),
        .EXE_Rs(EXE_Rs), .EXE_Rt(EXE_Rt), 
        .MEM_RegWrite(MEM_RegWrite), .MEM_MemtoReg(MEM_MemtoReg),
        .WB_RegWrite(WB_RegWrite), .WB_MemtoReg(WB_MemtoReg),
        .WB_WriteData(WB_WriteData), .MEM_Y(MEM_Y),
        .MEM_WA(MEM_WA),.WB_WA(WB_WA),
        .EXE_Forward_SelA(EXE_Forward_SelA), .EXE_Forward_SelB(EXE_Forward_SelB),
        .ID_Forward_SelA(ID_Forward_SelA), .ID_Forward_SelB(ID_Forward_SelB)
        );
    
    mux4 #(32) MUX_Forward_A(
        .sel(EXE_Forward_SelA), .d0(EXE_A), .d1(MEM_Y), 
        .d2(WB_WriteData), .d3(32'b0), .out(/*EXE_Forward_A*/EXE_ALUA));
    //assign EXE_ALUB = ID_EXE_ALUSrc ? ID_EXE_EXT_IMM : ID_EXE_B;
    mux4 #(32) MUX_Forward_B(
        .sel(EXE_Forward_SelB), .d0(EXE_B), .d1(MEM_Y), 
        .d2(WB_WriteData), .d3(32'b0), .out(EXE_Forward_B));
    //assign EXE_WA = ID_EXE_RegDst ? ID_EXE_IR[15:11] : ID_EXE_IR[20:16];
    mux2 #(32) MUX_ALUB(.sel(EXE_ALUSrc), .d0(EXE_Forward_B), .d1(EXE_EXT_IMM), .out(EXE_ALUB));
    
    //mux2 #(5) MUX_WA(.sel(EXE_RegDst), .d0(EXE_IR[20:16]), .d1(EXE_IR[15:11]), .out(EXE_WA));
    
    ALU ALU_EXE(.a(EXE_ALUA), .b(EXE_ALUB), .ALUOp(EXE_ALUOp), .y(EXE_ALURes)/*, .zf(EXE_Zero)*/);
    /*
    assign EXE_NPC_Branch = EXE_NPC + EXE_EXT_IMM<<2;
    assign EXE_NPC_Jump = {EXE_NPC[31:28],EXE_IR[26:0],2'b00}; 
    assign PCSrc = EXE_Jump ? 2'b10 : (EXE_Zero ? (EXE_Branch ? 2'b01 : 2'b00) : 2'b00);
    */
    
    
    EXE_MEM EXEMEM(
        .CLK(CLK), .RST(RST), 
        .EXE_IR(EXE_IR), .EXE_B(EXE_B), 
        .EXE_ALURes(EXE_ALURes), 
        //.EXE_NPC_Branch(EXE_NPC_Branch), .EXE_NPC_Jump(EXE_NPC_Jump),
        .EXE_WA(EXE_WA),
        //.EXE_Branch(EXE_Branch), .EXE_Jump(EXE_Jump), .EXE_Zero(EXE_Zero),
        .EXE_MemWrite(EXE_MemWrite), .EXE_MemRead(EXE_MemRead), 
        .EXE_RegWrite(EXE_RegWrite), .EXE_MemtoReg(EXE_MemtoReg),
        .MEM_IR(MEM_IR), .MEM_Y(MEM_Y), .MEM_B(MEM_B), 
        //.MEM_NPC_Branch(MEM_NPC_Branch), .MEM_NPC_Jump(MEM_NPC_Jump), 
        .MEM_WA(MEM_WA), 
        //.MEM_Branch(MEM_Branch), .MEM_Jump(MEM_Jump), .MEM_Zero(MEM_Zero),
        .MEM_MemWrite(MEM_MemWrite), .MEM_MemRead(MEM_MemRead), 
        .MEM_RegWrite(MEM_RegWrite), .MEM_MemtoReg(MEM_MemtoReg));
        
        
    /////////////////////////////////////////////////////////////////////////////////////////////////
    //MEM
    //assign PCSrc = EXE_MEM_Jump ? 2'b10 : (EXE_MEM_Zero ? (EXE_MEM_Branch ? 2'b01 : 2'b00) : 2'b00);
    //assign MEM_WriteData = MEM_B;
    //assign MEM_Address = MEM_Y;
    
    DataMem DM(.clk(CLK), .we(MEM_MemWrite), .a(MEM_Y[9:2]), 
               .d(MEM_B), .spo(MEM_ReadData));
               
    MEM_WB MEMWB(
        .CLK(CLK), .RST(RST), 
        .MEM_ReadData(MEM_ReadData), .MEM_Y(MEM_Y),
        .MEM_WA(MEM_WA), 
        .MEM_RegWrite(MEM_RegWrite), .MEM_MemtoReg(MEM_MemtoReg),
        .WB_Y(WB_Y), .WB_MDR(WB_MDR),
        .WB_WA(WB_WA), 
        .WB_RegWrite(WB_RegWrite), .WB_MemtoReg(WB_MemtoReg));
        
 
    /////////////////////////////////////////////////////////////////////////////////////////   
    //WB
        //assign WB_WriteData = WB_MemtoReg ? WB_MDR : WB_Y;//调用寄存器操作在ID段
        mux2 Mux_MemtoReg(.sel(WB_MemtoReg), .d0(WB_Y), .d1(WB_MDR), .out(WB_WriteData));
endmodule
