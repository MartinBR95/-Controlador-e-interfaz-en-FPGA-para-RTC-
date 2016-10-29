`timescale 1ns / 1ns

module top_tb;

parameter T = 10;

reg clk, reset,IRQ;
wire AD, RD, WR, CS;
wire [7:0] bus;
reg [7:0] ps2_code;
wire [11:0] RGB;

always begin
  clk = ~clk;
  #(T/2);
end

top uut(clk,reset,IRQ,AD,RD,WR,CS,bus,RGB);

  initial begin
    reset = 1;
    clk = 0;
    IRQ = 1;
    #100;
    reset = 0;
    #10000;
    $stop;
  end




endmodule
