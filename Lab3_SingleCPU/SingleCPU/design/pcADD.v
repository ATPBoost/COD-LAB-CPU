`timescale 1ns / 1ps


module pcADD(
        input clk,rst,               //时钟
        input Branch,zero,Jump,             //数据选择器输入
        input [31:0] Ex_Imm,  //偏移量
        input [25:0] addr,
        input [31:0] curPC,
        output reg[31:0] nextPC  //新指令地址
    );

    initial begin
        nextPC <= 32'b0;
    end
    reg [31:0] pc;
    always@(negedge clk)
    begin
        if(rst) begin
            nextPC <= 32'b0;
        end
        else begin
            pc <= curPC + 32'b0100;
            case({Branch&zero,Jump})
                2'b00: nextPC <= curPC + 32'b0100;
                2'b10: nextPC <= curPC + 32'b0100 + (Ex_Imm<<2);
                2'b01: nextPC <= {pc[31:28],addr,2'b00};
                default: ;
            endcase
        end
    end
endmodule
