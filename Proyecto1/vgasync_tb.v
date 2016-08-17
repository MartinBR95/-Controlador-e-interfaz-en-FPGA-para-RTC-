//////////////////////////////////////////////////////////////////////////////////
// Tecnologico de Costa Rica
// Estudiante: Martin Barquero Retana 
// 
// Create Date:    20:16:22 08/16/2016 
// Design Name: 
// Module Name:    vgasync_tb 
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
module vgasync_tb();

localparam T=20; //Define el periodo del reloj

//Define estradas del uut
reg clk,rst;
//Define salidas del uut
wire vsync,hsync,ENclock,px_X,px_Y;

//Instanciacion de el Controlador de VGA
vgasync vgasync_uut(.clk(clk), .rst(rst), .hsync(hsync), .vsync(vsync), .ENclock(ENclock), .px_X(px_X), .px_Y(px_Y));

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
	@(negedge rst); //espera al reinicio
	@(posedge clk); //espera al primer flanco de subida del reloj
	repeat(840000) @(posedge clk);//espera a que se haga un barrido completo de la pantalla
	$stop;
end



endmodule
