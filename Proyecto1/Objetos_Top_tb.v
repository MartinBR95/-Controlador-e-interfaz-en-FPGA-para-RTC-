//////////////////////////////////////////////////////////////////////////////////
// Tecnologico de Costa Rica
// Estudiante: Martin Barquero Retana 
// 
// Create Date:    20:47:21 08/16/2016 
// Design Name: 
// Module Name:    Objetos_top_tb
// Project Name:   Controlador de VGA
// Target Devices: Nexys2(Spartan 3E)
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
`timescale 1ns / 10ps
module Objetos_top_tb();

localparam T=20; //Define el periodo del reloj
localparam R=1,G=1,B=1;//define el color con el que se probara el modulo


//Es preferible definir los parametros de retraso y tiempo de
//display como constantes que se pueden modificar y ajustar al
//dispositivo especfifico a utilizar.

	localparam HD = 640;
	localparam HF = 48;
	localparam HB = 16;
	localparam HR = 96;
	localparam VD = 480;
	localparam VF = 10;
	localparam VB = 33;
	localparam VR = 2;	

//Define estradas del uut
reg clk,rst;
reg [9:0] X;
reg [9:0] Y;
//Define salidas del uut
wire [2:0] L;

//Instanciacion de el Controlador de VGA
Objetos_Top Objetos_Top_uut(.L(L),.X(X),.Y(Y),.R(R),.G(G),.B(B));
//Generacion del reloj
always
begin
	clk<=1'b1;
	#(T/2);
	clk<=1'b0;
	#(T/2);
end

//Inicializacion por reset
initial
begin
	rst<=1'b1; //inicializa el rst
	@(negedge clk); //se espera al flanco negatico del relog
	#(T);// se espera a que pase el flanco positvo
	rst<=1'b0; //se pone en marcha la uut
end

initial
begin
	X=10'h0;
	Y=10'h0;
	@(negedge rst); //espera al reinicio
	#(T);
     repeat (HD+HF+HB+HR-1) //Prueba los valores de X
	begin
		X<=X+1;
		
		repeat (VD+VF+VB+VR-1)  //Prueba los valores de Y
		begin
			Y<=Y+1;
			#(T);
		end	
		#(T);	
     end
	$stop;
end
endmodule
