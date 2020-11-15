`timescale 1ns / 1ps


module PC(
       input clk,rst,
       input PCWre,             //�Ƿ�����µĵ�ַ��0-�����ģ�1-���Ը���
       //input [1:0] PCSrc,             //����ѡ��������
       input [31:0] nextPC,  //��ָ���ַ
       output reg [31:0] curPC //��ǰָ��ĵ�ַ
    );

    initial begin
        curPC <= 32'b0;
    end

    always@(posedge clk)
    begin
        if(rst)
            begin
                curPC <= 32'b0;
            end
        else 
            begin
                if(PCWre) // PCWre == 1
                    begin 
                        curPC <= nextPC;
                    end
                else    // PCWre == 0, halt
                    begin
                        curPC <= curPC;
                    end
            end
    end
endmodule
