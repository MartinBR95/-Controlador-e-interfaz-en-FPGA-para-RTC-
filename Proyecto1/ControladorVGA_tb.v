//////////////////////////////////////////////////////////////////////////////////
// Universidad: Instituto Tecnologico de Costa Rica
// Estudiante: Martin Barquero
// 
// Create Date:    17:02:37 08/12/2016 
// Design Name: 
// Module Name:    Testbench 
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
module ControladorVGA_tb();

localparam T=20; //Define el periodo del reloj

//Define estradas del uut
reg clk,rst;
reg [2:0] RGB_in;
//Define salidas del uut
wire vsync,hsync,RGB_out;

//Instanciacion de el Controlador de VGA
ControladorVGA ControladorVGA_uut(.clk(clk), .rst(rst), .RBG_in(RBG_in), .hsync(hsync), .vsync(vsync));

//Generacion del reloj
always
begin

	clk=1b'1;
	#(T/2);
	clk=1b'0;
	#(T/2);

end

//Inicializacion por reset
initial
begin
	rst=1'b1; //inicializa el rst
	@(negedge clk); //se espera al flanco negatico del relog
	#(T);// se espera a que pase el flanco positvo
	rst=1'b0; //se pone en marcha la uut
end


//Prueba de funcionamiento
initial
begin
	RGB_in = 3'b000;//valor inicial
	@(negedge rst); //espera al reinicio
	
	wait(hsync | vsync ==0); //espera a que no se este escribiendo en pantalla
	@(negedge clk); //espera al eje negativo del relog para proporcionar una señal estable de  RBG_in
	RGB_in =  3'b001; //se prueba el siguiente valor
	
	wait(hsync | vsync ==0);
	@(negedge clk);
	RGB_in =  3'b010;
	
	wait(hsync | vsync ==0);
	@(negedge clk);
	RGB_in =  3'b011;
	
	wait(hsync | vsync ==0);
	@(negedge clk);
	RGB_in =  3'b100;
	
	wait(hsync | vsync ==0);
	@(negedge clk);
	RGB_in =  3'b101;
	
	wait(hsync | vsync ==0);
	@(negedge clk);
	RGB_in =  3'b110;
	
	wait(hsync | vsync ==0);
	@(negedge clk);
	RGB_in =  3'b111;
	
	$stop;
end
endmodule

















