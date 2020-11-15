`timescale 1ns / 1ps


module PC(
       input clk,rst,
       input PCwe,run,            //PCWrite | (PCWriteCond & zero)
       //input [1:0] PCSrc,             //����ѡ��������
       input [31:0] NextPC,  //��ָ���ַ
       output reg [31:0] CurPC //��ǰָ��ĵ�ַ
    );

    initial begin
        CurPC <= 32'b0;
    end

    always@(posedge clk)
    begin
        if(rst)
            begin
                CurPC <= 32'b0;
            end
        else 
            begin
                if(PCwe && run) // PCwe == 1
                    begin 
                        CurPC <= NextPC;
                    end
                else    // PCwe == 0 PC+4
                    begin
                        CurPC <= CurPC;
                    end
            end
    end
endmodule
