`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   10:03:38 11/02/2016
// Design Name:   Conexion_CONTROL_VGA_TECLADO
// Module Name:   C:/PROYECTOS/VGA_4.7/TOP_TB.v
// Project Name:  VGA_4.7
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: Conexion_CONTROL_VGA_TECLADO
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module TOP_TB;

	// Inputs
	reg RST;
	reg CLK;
	reg ALARMA;
	reg WRITE_STROBE;
	reg [7:0] POR_ID;
	reg [7:0] OUT_PORT;
	reg ps2c;
	reg DATA_IN;
	reg SOLICITUD;

	// Outputs
	wire [11:0] RGB;
	wire VS;
	wire HS;
	wire [7:0] DATA_OUT_TEC;
	wire [7:0] TecladoREG_ANTERIOR;
	wire [7:0] TecladoREG;
	wire [9:0] ADDRV;
	wire [9:0] ADDRH;
	wire Video_ON;

	// Instantiate the Unit Under Test (UUT)
	Conexion_CONTROL_VGA_TECLADO uut (
		.RST(RST), 
		.CLK(CLK), 
		.ALARMA(ALARMA), 
		.WRITE_STROBE(WRITE_STROBE), 
		.POR_ID(POR_ID), 
		.OUT_PORT(OUT_PORT), 
		.RGB(RGB), 
		.VS(VS), 
		.HS(HS), 
		.ps2c(ps2c), 
		.DATA_IN(DATA_IN), 
		.DATA_OUT_TEC(DATA_OUT_TEC), 
		.SOLICITUD(SOLICITUD), 
		.TecladoREG_ANTERIOR(TecladoREG_ANTERIOR), 
		.TecladoREG(TecladoREG),
		.ADDRV(ADDRV), 
		.ADDRH(ADDRH),
		.Video_ON(Video_ON)
	);


	integer j; 
	integer i;

	always #5 CLK = ~CLK;

	initial begin
		// Initialize Inputs
		RST = 1;
		CLK = 0;
		ALARMA = 0;
		WRITE_STROBE = 0;
		POR_ID = 0;
		OUT_PORT = 0;
		ps2c = 0;
		DATA_IN = 0;
		SOLICITUD = 0;

		// Wait 100 ns for global reset to finish
		#100;
		RST = 0;
        
		// Add stimulus here

		j=0;
      i=0;
		  
		#100
		  		  
      //archivo txt para observar los bits, simulando una pantalla
      i = $fopen("archivosuyo.txt","w");
      for(j=0; j<383520; j=j+1)
		begin
        #40
        if(Video_ON) begin
          $fwrite(i,"%h",RGB);
        end
        else if(ADDRH == 641) $fwrite(i,"\n");
      end
		#16800000
		$fclose(i);
		$stop;
	end
      
endmodule

