`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date:    02:26:19 09/16/2016
// Design Name:
// Module Name:    M_VGA_tb
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
module M_VGA_tb();

localparam T=20; //Define el periodo del reloj

//Define las salidas

wire HS,VS,ENClock;
wire [11:0] COLOR_OUT;   //bits de color hacia la VGA
wire video_on;
wire [9:0] ADDRH;
wire [9:0] ADDRV;

//Define las entradas
reg clk,rst;
reg [7:0]DIA_T;          //Senal de dia de la RTC
reg [7:0]MES_T;          //Senal de mes de la RTC
reg [7:0]ANO_T;          //Senal de ano de la RTC
reg [7:0]HORA_T;         //Senal de horas de la RTC
reg [7:0]MINUTO_T;       //Senal de minutos de la RTC
reg [7:0]SEGUNDO_T;      //Senal de segundos de la RTC
reg [7:0]HORAT_T;        //Senal de horas de temporizador de la RTC
reg [7:0]MINUTOT_T;      //Senal de minutos de temporizador de la RTC
reg [7:0]SEGUNDOT_T; 	 //Senal de segundos de temporizador de la RTC
reg ALARMA;

//Prueba de funcionamiento
initial
begin

end


//Instanciacion de el Controlador de VGA
ModuloVGA TOP
	(
   clk,rst,    		  //Senal de reloj
   COLOR_OUT,  //bits de color hacia la VGA
   HS,					  //Sincronizacion horizontal
   VS,					  //Sincronizacion vertical
	ENClock,
	DIA_T,         //Senal de dia de la RTC
	MES_T,         //Senal de mes de la RTC
	ANO_T,         //Senal de ano de la RTC
	HORA_T,        //Senal de horas de la RTC
	MINUTO_T,      //Senal de minutos de la RTC
	SEGUNDO_T,     //Senal de segundos de la RTC
	HORAT_T,       //Senal de horas de temporizador de la RTC
	MINUTOT_T,     //Senal de minutos de temporizador de la RTC
	SEGUNDOT_T,	  //Senal de segundos de temporizador de la RTC
	ALARMA,
	video_on,
	ADDRH,
	ADDRV
	);

integer j;
integer i;

always #5 clk = ~clk;

initial
   begin

		  {DIA_T} <= 8'h10;         //Senal de dia de la RTC
		  {MES_T} <= 8'h04;         //Senal de mes de la RTC
		  {ANO_T} <= 8'h00;         //Senal de ano de la RTC
		  {HORA_T} <= 8'h50;        //Senal de horas de la RTC
		  {MINUTO_T} <= 8'h00;      //Senal de minutos de la RTC
		  {SEGUNDO_T} <= 8'h00;     //Senal de segundos de la RTC
		  {HORAT_T} <= 8'h00;       //Senal de horas de temporizador de la RTC
		  {MINUTOT_T} <= 8'h00;     //Senal de minutos de temporizador de la RTC
		  {SEGUNDOT_T} <= 8'h00;	  //Senal de segundos de temporizador de la RTC
		  {ALARMA} <= 1'h0;
		  clk = 0;
		  rst = 1;

		  j=0;
        i=0;

		  #100

        rst = 0;

        //archivo txt para observar los bits, simulando una pantalla
        i = $fopen("archivosuyo.txt","w");
        for(j=0; j<383520; j=j+1)
		  begin
          #40
          if(video_on) begin
            $fwrite(i,"%h",COLOR_OUT);
          end
          else if(ADDRH ==641) $fwrite(i,"\n");
       end
    #16800000
    $fclose(i);
    $stop;
end
endmodule
