`timescale 1ns / 1ps


module RegFile(

input clk,						//时钟（上升沿有效）
input [4:0] ra0,				//读端口0地址
input [4:0] ra1, 				//读端口1地址
input [4:0] ra2,

output [31:0] rd0, 	//读端口0数据
output [31:0] rd1, 	//读端口1数据
output [31:0] rd2,

input [4:0] wa, 				//写端口地址
input we,					//写使能，高电平有效
input [31:0] wd 		//写端口数据
);

reg [31:0]REG[0:31];    //定义寄存器堆的寄存器
integer i;

//初始化寄存器堆数据为0
initial
    for(i = 0;i < 32;i = i + 1)
        REG[i] <= 0;
//同步写操作，需时钟控制
always@(negedge clk)
    begin
    if(wa > 0)
    begin
        if(we)
            REG[wa] <= wd;
    end
    end

//异步读操作，不需时钟控制，组合逻辑
assign rd0 = REG[ra0];
assign rd1 = REG[ra1];
assign rd2 = REG[ra2];

endmodule