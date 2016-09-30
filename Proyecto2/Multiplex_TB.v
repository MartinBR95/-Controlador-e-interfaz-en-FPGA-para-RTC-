`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   10:26:26 09/28/2016
// Design Name:   Multiplexado
// Module Name:   C:/Users/santiago/Documents/TEC/6_SEM/LAB_Digitales/Proyecto_2/multiplexado/Multiplex_TB.v
// Project Name:  multiplexado
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: Multiplexado
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module Multiplex_TB;

	// Inputs
	reg CLK;
	reg BEnv_Adress;
	reg BRes_Data;
	reg BEnv_Data;
	reg [6:0] Puntero;
	reg [7:0] ADRESS;
	reg Mod;
	reg UP;
	reg DOWN;

	// Outputs
	wire [7:0] Dout;
	wire [7:0] Mout;
	wire [7:0] Aout;
	wire [7:0] Hout;
	wire [7:0] Miout;
	wire [7:0] Sout;
	wire [7:0] HTout;
	wire [7:0] MiTout;
	wire [7:0] STout;

	// Bidirs
	wire [7:0] Multiplex;

	// Instantiate the Unit Under Test (UUT)
	Multiplexado uut (
		.CLK(CLK), 
		.BEnv_Adress(BEnv_Adress), 
		.BRes_Data(BRes_Data), 
		.BEnv_Data(BEnv_Data), 
		.Puntero(Puntero), 
		.ADRESS(ADRESS), 
		.Multiplex(Multiplex), 
		.Mod(Mod), 
		.UP(UP), 
		.DOWN(DOWN), 
		.Dout(Dout), 
		.Mout(Mout), 
		.Aout(Aout), 
		.Hout(Hout), 
		.Miout(Miout), 
		.Sout(Sout), 
		.HTout(HTout), 
		.MiTout(MiTout), 
		.STout(STout)
	);

	initial begin
		// Initialize Inputs
		CLK = 0;
		BEnv_Adress = 0;
		BRes_Data = 0;
		BEnv_Data = 0;
		Puntero = 0;
		ADRESS = 0;
		Mod = 0;
		UP = 0;
		DOWN = 0;
		
		always #5 CLK = ~CLK;

		// Wait 100 ns for global reset to finish
		#100;
		BEnv_Adress = 1'd0;
		BRes_Data = 1'd0;
		BEnv_Data = 1'd0;
		Puntero = 8'd1;
		ADRESS = 8'd1;
		Mod = 1'd1;
		UP = 1'd1;
		DOWN = 1'd0;
 
		#100;
		BEnv_Adress = 1'd1;
		BRes_Data = 1'd0;
		BEnv_Data = 1'd0;
		Mod = 1'd0;
		UP = 1'd0;
		DOWN = 1'd0;
		
		#100;
		BEnv_Adress = 1'd1;
		BRes_Data = 1'd1;
		BEnv_Data = 1'd1;
		Mod = 1'd1;
		UP = 1'd1;
		DOWN = 1'd1;
		

		#100;
		BEnv_Adress = 1'd1;
		BRes_Data = 1'd1;
		BEnv_Data = 1'd1;
		Mod = 1'd1;
		UP = 1'd1;
		DOWN = 1'd1;
		

		#100;
		BEnv_Adress = 1'd1;
		BRes_Data = 1'd1;
		BEnv_Data = 1'd1;
		Mod = 1'd1;
		UP = 1'd1;
		DOWN = 1'd1;
		
		
		// Add stimulus here

	end
      
endmodule

