`timescale 1ns / 1ps


module PC(
       input clk,rst,
       input PCWre,             //是否接受新的地址。0-不更改；1-可以更改
       //input [1:0] PCSrc,             //数据选择器输入
       input [31:0] nextPC,  //新指令地址
       output reg [31:0] curPC //当前指令的地址
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
