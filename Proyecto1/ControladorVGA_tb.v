//////////////////////////////////////////////////////////////////////////////////
// Universidad: Instituto Tecnologico de Costa Rica
// Estudiante: Martin Barquero
// 
// Create Date:    17:02:37 08/12/2016 
// Design Name: 
// Module Name:    ControladorVGA_tb 
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
`timescale 10ns / 1ps
module ControladorVGA_tb();

localparam T=20; //Define el periodo del reloj

//Define estradas del uut
reg clk,rst;
reg R,G,B;
//Define salidas del uut
wire vsync,hsync;
wire [2:0] L;

//Instanciacion de el Controlador de VGA
TOP TOP_uut(.R(R),.G(G),.B(B),.L(L),.clk(clk),.reset(rst),.hsinc(hsync),.vsinc(vsync),.ENclock(ENclock));

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


//Prueba de funcionamiento
initial
begin
	{R,G,B} <= 3'b000;//valor inicial
	@(negedge rst); //espera al reinicio
	
	@(negedge vsync);//espera a que no se este escribiendo en pantalla
	@(negedge clk); //espera al eje negativo del relog para proporcionar una señal estable de  RBG_in
	{R,G,B} <=  3'b001; //se prueba el siguiente valor
	
	@(negedge vsync);
	@(negedge clk);
	{R,G,B} <=  3'b010;
	
	@(negedge vsync);
	@(negedge clk);
	{R,G,B} <=  3'b011;
	
	@(negedge vsync);
	@(negedge clk);
	{R,G,B} <=  3'b100;
	
	@(negedge vsync);
	@(negedge clk);
	{R,G,B} <=  3'b101;
	
	@(negedge vsync);
	@(negedge clk);
	{R,G,B} <=  3'b110;
	
	@(negedge vsync);
	@(negedge clk);
	{R,G,B} <=  3'b111;
	
	$stop;
end
endmodule

















