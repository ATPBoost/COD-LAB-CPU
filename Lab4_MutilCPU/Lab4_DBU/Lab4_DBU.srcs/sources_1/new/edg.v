`timescale 1ns / 1ps


module EDG(
    input clk,
    input button,
    output button_edg
    );
    reg button_r1,button_r2;
    always@(posedge clk)
        button_r1<=button;
    always@(posedge clk)
        button_r2<=button_r1;
    assign button_edg=button_r1&(~button_r2);
endmodule