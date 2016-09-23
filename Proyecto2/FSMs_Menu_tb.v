`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:39:47 09/16/2016 
// Design Name: 
// Module Name:    FSMs_Menu_tb 
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
module FSMs_Menu_tb(
    );

//module FSMs_Menu (IRQ,Barriba,Babajo,Bderecha,Bizquierda,Bcentro,RST,FRW,Acceso,Mod,Alarma,STW,CLK,Dir,Numup,Numdown,Punt);


// Se definen las entradas de la UUT
reg CLK,IRQ,Barriba,Babajo,Bderecha,Bizquierda,Bcentro,RST,FRW;
// Se definen las entradas de la UUT
wire [6:0] Dir;
wire Acceso,Mod,Alarma,STW,Numup,Numdown;
wire [6:0] Punt;
FSMs_Menu FSMs_Menu_uut(.IRQ(IRQ),.Barriba(Barriba),.Babajo(Babajo),.Bderecha(Bderecha),.Bizquierda(Bizquierda),.Bcentro(Bcentro),.RST(RST),.FRW(FRW),.Acceso(Acceso),.Mod(Mod),.Alarma(Alarma),.STW(STW),.CLK(CLK),.Dir(Dir),.Numup(Numup),.Numdown(Numdown),.Punt(Punt));

localparam T=10;//ns



//Generacion del reloj
always
begin
	CLK<=1'b1;
	#(T/2);
	CLK<=1'b0;
	#(T/2);
end

//Inicializacion por reset
initial
begin
	RST<=1'b1; //inicializa el rst
	@(negedge CLK); //se espera al flanco negatico del relog
	#(T);// se espera a que pase el flanco positvo
	RST<=1'b0; //se pone en marcha la uut
end

//Prueba de funcionamiento
initial
begin
	IRQ <=0;
	Barriba<=0;
	Babajo<=0;
	Bderecha<=0;
	Bizquierda<=0;
	Bcentro<=0;
	FRW<=0;
	@(negedge RST); //espera al reinicio
	FRW<=0;//Estado 1 ,falso
	@(negedge CLK);
	FRW<=1;//Estado 1 ,verdadero	
	@(negedge CLK);
	//estado 2
	wait(Dir==7'h44);
	//estado 3	
	@(negedge CLK);
	Bderecha<=1;
	@(negedge CLK);
	Bderecha<=0;
	//estado 4, falso	
	//estado 2,
	wait(Dir==7'h44);
	IRQ<=1'b1;
	//estado 3
	@(negedge CLK);
	IRQ<=1'b0;
	Bcentro<=1'b1;
	wait(Mod==1'b1)
	Bcentro<=1'b1;
	//estado 2
	//estado 3
	//estado 4, verdadero	
	wait(STW==1'b1);
	wait(STW==1'b0);
	@(negedge CLK);
	$stop;
end

endmodule



















