`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date:    15:25:36 09/22/2016
// Design Name:
// Module Name:    top
// Project Name:
// Target Devices:
// Tool versions:
// Description:
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////
module top(
  input wire IRQ,Barriba,Babajo,Bderecha,Bizquierda,Bcentro,RST,CLK,
  output wire [7:0] Dir,
  output wire [6:0] Punt,
  output wire CS, RD, WR, AD
  );

  wire FRW, Mod, Acceso, STW, Numup, Numdown, Alarma;

  FSMs_Menu MasterControl(IRQ,Barriba,Babajo,Bderecha,Bizquierda,Bcentro,RST,FRW,Acceso,Mod,Alarma,STW,CLK,Dir,Numup,Numdown,Punt);
  transfer RTCControl(Acceso,~Mod,CLK,RST,AD,CS,RD,WR,FRW);




endmodule
