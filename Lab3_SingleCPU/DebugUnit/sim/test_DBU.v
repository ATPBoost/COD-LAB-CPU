`timescale 1ns / 1ps


module test_DBU();
parameter HALF_CLK = 2,CLK = 4;

reg clk, rst, succ, step;
reg [2:0] sel;
reg m_rf, inc, dec;
wire [6:0] LED;

initial                 //clk : 50cycles
begin
    clk = 0;
    repeat(100)
        #HALF_CLK clk = ~clk;
    $finish;
end

initial
begin
    succ = 1;
    #(20*CLK) succ = 0;
end
initial
begin
    step = 0;
    #(38*CLK) step = 1;
    repeat(2)
    begin
        #CLK step = 1;
        #(2*CLK) step = 0;
    end
end
    

initial
begin
    m_rf = 1;
    sel = 0;
    #(15*CLK)
    m_rf = 0;
    sel = 0;
    #(20*CLK)
    sel = 1;
    #(3*CLK)
    sel = 2;
    #(3*CLK)
    sel = 3;
    #(3*CLK)
    sel = 4;
    #(3*CLK)
    sel = 5;
    
    
end

initial 
begin
    rst = 1;
    #CLK rst = 0;
end

/**** inc 优先级比 dec 高 ***/
initial
begin
    inc = 0;
    repeat(16)
    begin
        #CLK inc = 1;
        #CLK inc = 0;
    end
end

initial
begin
    dec = 0;
    #(36*CLK)
    repeat(6)
    begin
        #CLK dec = 1;
        #CLK dec = 0;
    end
end

    DebugUnit dbu(.clk(clk), .rst(rst), .succ(succ), .step(step), .sel(sel), .m_rf(m_rf), .inc(inc), 
                .dec(dec), .LED(LED));
endmodule

