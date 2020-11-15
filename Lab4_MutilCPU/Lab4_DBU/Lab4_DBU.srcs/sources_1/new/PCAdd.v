`timescale 1ns / 1ps


module PCAdd(
        input RST,
        input [1:0] PCSrc,             //����ѡ��������
        //input [31:0] immediate,  //ƫ����
        input [25:0] addr,
        input [31:0] ALUout,ALUresult,
        input [31:0] CurPC,
        output reg[31:0] NextPC  //��ָ���ַ
    );
    
initial 
    begin
        NextPC = 0;
    end
    
always@(*)
    begin
        if(RST) 
        begin
            NextPC = 0;
        end
        else 
        begin
            case(PCSrc)
                2'b00: NextPC = ALUresult;
                2'b01: NextPC = ALUout;
                2'b10: NextPC = {CurPC[31:28],addr,2'b00};
            endcase
        end
    end
endmodule