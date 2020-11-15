`timescale 1ns / 1ps


module DebugUnit(
    input clk,rst,
    input succ,step,
    input [2:0]sel,
    input m_rf,
    input inc,dec,
    output [6:0] LED,
    output reg [7:0] AN
    );
    //取边沿去毛刺各个输入信号
    wire step_clean,step_edg,inc_clean,inc_edg,dec_clean,dec_edg;
    
    //jitter_clr j_step(clk,step,step_clean);
    EDG EDG_step(clk,step,step_edg);
    
    //jitter_clr j_inc(clk,inc,inc_clean);
    EDG EDG_inc(clk,inc,inc_edg);
    
    //jitter_clr j_dec(clk,dec,dec_clean);
    EDG EDG_dec(clk,dec,dec_edg);
    
    //sel = 0时查看运行结果相关变量
    reg [15:0] m_rf_addr;
    always@(negedge clk)
    begin
       if(rst)
          m_rf_addr<=0;
       else
       if(sel != 0)
            m_rf_addr<=m_rf_addr;
       else
       begin
           if(dec_edg)
              m_rf_addr<=m_rf_addr-1;
           if(inc_edg)
              m_rf_addr<=m_rf_addr+1;
       end
    end
    
    reg [31:0] count;
    reg [3:0] in;
    wire [31:0] status;
    wire [15:0] sw;
    /*
    distmem dm(in,LED);         //ROM存储7/8段数码管数字翻译信息
    always@(posedge clk)        //循环显示8个数字
    begin      
    if(count>=240000)         
        count<=32'h0;     
    else         
        count<=count+32'h1; 
    end 
    
    always@(posedge clk)
    begin
        if(count < 30000)
        begin
            AN<=8'b11111110;
            in<=status[3:0];
        end
        else if(count < 60000)
        begin
            AN<=8'b11111101;
            in<=status[7:4];
        end
        else if(count < 90000)
            begin
                AN<=8'b11111011;
                in<=status[11:8];
            end
        else if(count < 120000)
             begin
                 AN<=8'b11110111;
                 in<=status[15:12];
             end
         else if(count < 150000)
             begin
               AN<=8'b11101111;
               in<=status[19:16];
             end
             else if(count < 180000)
             begin
                AN<=8'b11011111;
                in<=status[23:20];
             end
              else if(count < 210000)
              begin
                   AN<=8'b10111111;
                   in<=status[27:24];
              end
                 else 
                 begin
                     AN<=8'b01111111;
                     in<=status[31:28];
                 end
    end
    */
    
    DBU_CPU DBU_CPU(.CLK(clk),.RST(rst),.sel(sel),.m_rf(m_rf),
    .m_rf_addr(m_rf_addr),.succ(succ), .step_edg(step_edg), .status(status),.sw(sw));
    
endmodule
