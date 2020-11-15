`timescale 1ns / 1ps


module Forwarding(
    input [4:0] EXE_Rs, EXE_Rt, ID_Rs, ID_Rt,
    input MEM_RegWrite, MEM_MemtoReg,
           WB_RegWrite, WB_MemtoReg,
    input [31:0] WB_WriteData, MEM_Y,
    input [4:0] MEM_WA,WB_WA,
    output reg [1:0] EXE_Forward_SelA, EXE_Forward_SelB,
                      ID_Forward_SelA, ID_Forward_SelB
    );
    
    
    always @(*) 
    begin
		EXE_Forward_SelA[1] = WB_RegWrite && (WB_WA != 0) && (MEM_WA != EXE_Rs) && (WB_WA == EXE_Rs);
		EXE_Forward_SelA[0] = MEM_RegWrite && (MEM_WA != 0) && (MEM_WA == EXE_Rs);
		EXE_Forward_SelB[1] = WB_RegWrite && (WB_WA != 0) && (MEM_WA != EXE_Rt) && (WB_WA == EXE_Rt);
		EXE_Forward_SelB[0] = MEM_RegWrite && (MEM_WA != 0) && (MEM_WA == EXE_Rt);	
	end
    /*BEQ的相关，因为提到了ID段，吐了
    input [4:0] ID_Rs,ID_Rt,
    output [1:0] ID_BEQ_SE
    */
    /*
    always@(*)
    begin
            ID_Forward_SelA = 2'b00;
            ID_Forward_SelB = 2'b00;
            EXE_Forward_SelA = 2'b00;
            EXE_Forward_SelB = 2'b00;
        //Reg[0] cannot Write!
        if(WB_RegWrite && (WB_WA != 5'b0)&& (MEM_WA != EXE_Rs) && (WB_WA == EXE_Rs))
            EXE_Forward_SelA = 2'b10;
        if(MEM_RegWrite && (MEM_WA != 5'b0) && (MEM_WA == EXE_Rs))
            EXE_Forward_SelA = 2'b01;
        if(WB_RegWrite && (WB_WA != 5'b0)&& (MEM_WA != EXE_Rt) && (WB_WA == EXE_Rt))
            EXE_Forward_SelB = 2'b10;
        if(MEM_RegWrite && (MEM_WA != 5'b0) && (MEM_WA == EXE_Rt))
            EXE_Forward_SelB = 2'b01;     
        //beq
        if(WB_RegWrite && (WB_WA != 5'b0)&& (MEM_WA != ID_Rs) && (WB_WA == ID_Rs))
            ID_Forward_SelA = 2'b10;
        if(MEM_RegWrite && (MEM_WA != 5'b0) && (MEM_WA == ID_Rs))
            ID_Forward_SelA = 2'b01;
        if(WB_RegWrite && (WB_WA != 5'b0)&& (MEM_WA != ID_Rt) && (WB_WA == ID_Rt))
            ID_Forward_SelB = 2'b10;
        if(MEM_RegWrite && (MEM_WA != 5'b0) && (MEM_WA == ID_Rt))
            ID_Forward_SelB = 2'b01;
        
    end
    */
    
    
endmodule