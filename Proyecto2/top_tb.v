`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date:   15:48:41 09/22/2016
// Design Name:   top
// Module Name:   /media/juan/DEB4252DB425099B/Users/Juan/Documents/GitHub/LAB_SISTEMAS_DIGITALES_Grupo_6/Proyecto2/top_tb.v
// Project Name:  Proyecto2
// Target Device:
// Tool versions:
// Description:
//
// Verilog Test Fixture created by ISE for module: top
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
////////////////////////////////////////////////////////////////////////////////

module top_tb;

	// Inputs
	reg IRQ;
	reg Barriba;
	reg Babajo;
	reg Bderecha;
	reg Bizquierda;
	reg Bcentro;
	reg RST;
	reg CLK;

	// Outputs
	wire [7:0] Dir;
	wire [6:0] Punt;
	wire CS;
	wire RD;
	wire WR;
	wire AD;

	// Instantiate the Unit Under Test (UUT)
	top uut (
		.IRQ(IRQ),
		.Barriba(Barriba),
		.Babajo(Babajo),
		.Bderecha(Bderecha),
		.Bizquierda(Bizquierda),
		.Bcentro(Bcentro),
		.RST(RST),
		.CLK(CLK),
		.Dir(Dir),
		.Punt(Punt),
		.CS(CS),
		.RD(RD),
		.WR(WR),
		.AD(AD)
	);

	localparam  T = 10;

//Generacion del reloj
	always begin
		CLK<=1'b1;
		#(T/2);
		CLK<=1'b0;
		#(T/2);
	end

	initial begin
		// Initialize Inputs
		IRQ = 0;
		Barriba = 0;
		Babajo = 0;
		Bderecha = 0;
		Bizquierda = 0;
		Bcentro = 0;
		RST = 1;
		CLK = 0;

		// Wait 100 ns for global reset to finish
		#100;
		RST = 0;
		wait(Dir==7'h44);
		//estado 3
		@(negedge CLK);
		Bderecha<=1;
		@(negedge CLK);
		Bcentro<=1'b1;
		Bderecha<=0;
		//estado 4, falso
		//estado 2,
		wait(Dir==7'h44);
		#50000;
		IRQ<=1'b1;
		//estado 3		
		@(negedge CLK);
		Bcentro<=1'b1;
		IRQ<=1'b0;
		Bcentro<=1'b1;
		@(negedge CLK);
		$stop;


		// Add stimulus here

	end

endmodule
