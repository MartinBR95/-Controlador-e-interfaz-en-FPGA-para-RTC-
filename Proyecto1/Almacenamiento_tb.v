//////////////////////////////////////////////////////////////////////////////////
// Tecnologico de Costa Rica
// Estudiante: Martin Barquero Retana 
// 
// Create Date:    22:29:07 08/16/2016 
// Design Name: 
// Module Name:    Almacenamiento_tb 
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
module Almacenamiento_tb();
localparam T=20; //Define el periodo del reloj


//Define estradas del uut
reg clk,rst;
reg [2:0] direccion;
reg [3:0] rom;
//Define salidas del uut
wire [7:0] rom_data;

//Instanciacion de el Controlador de VGA
Almacenamiento Almacenamiento_uut(.direccion(direccion),.rom(rom), .rom_data(rom_data));
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

	{direccion,rom} <= 7'b0000000;
	@(negedge rst);
	#(T)
	repeat(7'b1011110)
	begin
	{direccion,rom} <=  {direccion,rom} + 1;
	#(T);
	end
	$stop;

end
endmodule
