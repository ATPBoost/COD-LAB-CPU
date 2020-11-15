`timescale 1ns / 1ps


module RegFile(

input clk,						//ʱ�ӣ���������Ч��
input [4:0] ra0,				//���˿�0��ַ
input [4:0] ra1, 				//���˿�1��ַ
input [4:0] ra2,

output [31:0] rd0, 	//���˿�0����
output [31:0] rd1, 	//���˿�1����
output [31:0] rd2,

input [4:0] wa, 				//д�˿ڵ�ַ
input we,					//дʹ�ܣ��ߵ�ƽ��Ч
input [31:0] wd 		//д�˿�����
);

reg [31:0]REG[0:31];    //����Ĵ����ѵļĴ���
integer i;

//��ʼ���Ĵ���������Ϊ0
initial
    for(i = 0;i < 32;i = i + 1)
        REG[i] <= 0;
//ͬ��д��������ʱ�ӿ���
always@(negedge clk)
    begin
    if(wa > 0)
    begin
        if(we)
            REG[wa] <= wd;
    end
    end

//�첽������������ʱ�ӿ��ƣ�����߼�
assign rd0 = REG[ra0];
assign rd1 = REG[ra1];
assign rd2 = REG[ra2];

endmodule