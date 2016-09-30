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
  input wire IRQ,Bderecha,Barriba,Babajo,Bizquierda,Bcentro,RST,CLK,Alarma_stop,ALARMA,
  output wire CS, RD, WR, AD, HS, VS,
  inout wire [7:0] A_D_Bus,
  output wire [11:0] RGB,
  input wire Timmer_ON
);

  wire [7:0] Dir, DIA_T, MES_T, ANO_T, HORA_T, MINUTO_T, SEGUNDO_T, HORAT_T, MINUTOT_T, SEGUNDOT_T;
  wire [6:0] Punt;
  wire FRW, Mod, Acceso, Numup, Numdown, Alarma, ASend, Send, Fetch;

  FSMs_Menu MasterControl(IRQ,Alarma_stop,Timmer_ON,Barriba,Babajo,Bderecha,Bizquierda,Bcentro,RST,FRW,Acceso,Mod,CLK,Dir,Punt);
  
  transfer RTCControl(Acceso,~Mod,CLK,RST,AD,CS,RD,WR,FRW,ASend,Send,Fetch);
  Multiplexado Memoria(CLK,RST,ASend,Fetch,Send,Punt,Dir,A_D_Bus,Barriba,Babajo,DIA_T,MES_T,ANO_T,HORA_T,MINUTO_T,SEGUNDO_T,HORAT_T,MINUTOT_T,SEGUNDOT_T);
  VGATop_2 GeneradorImagen(Punt,CLK,RST,RGB,HS,VS,DIA_T,ALARMA,MES_T,ANO_T,HORA_T,MINUTO_T,SEGUNDO_T,HORAT_T,MINUTOT_T,SEGUNDOT_T);

endmodule
