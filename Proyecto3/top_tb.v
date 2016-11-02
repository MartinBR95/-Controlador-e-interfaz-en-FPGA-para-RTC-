`timescale 1ns / 1ns

module top_tb;

parameter T = 10;

// Inputs
reg clk, reset,IRQ;
reg [7:0] ps2_code;
reg sec;
// Outputs
wire CS;
wire RD;
wire WR;
wire AD;
wire [7:0] A_D_Bus;
wire [7:0] Segundos;


top uut(
  .clk(clk),
  .reset(reset),
  .IRQ(IRQ),
  .bus(A_D_Bus),
  .AD(AD),.WR(WR),.CS(CS),.RD(RD),
  .Segundos(Segundos)
//  .ps2_code(ps2_code)
  );

always begin
  clk = ~clk;
  #(T/2);
end



  initial begin
    reset = 1;
    clk = 0;
    IRQ = 1 ;
    #100;
    reset = 0;
    IRQ = 1;
    #6630;
    sec = 8'h09;
    $stop;
  end




endmodule
