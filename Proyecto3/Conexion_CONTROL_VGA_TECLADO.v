//////////////////////////////////////////////////////////////////////////////////
module Conexion_CONTROL_VGA_TECLADO			
	(	
		/////////////////////////////			
		//ENTRADA	  							
		input wire RST,				
		input wire CLK,
		input ALARMA, 
						  
		//SEÑALES PROBENIENTES DEL CONTROL 	
		input wire WRITE_STROBE,            //Señal de actualizar registro (en flanco de subida)
		input wire[7:0]POR_ID,              //Donde escribo
		input wire[7:0]OUT_PORT,            //Datos de entrada		
						   							
		/////////////////////////////			
		//SALIDAS	   							
		output wire[11:0]RGB,
		output wire VS,
		output wire HS,
		
		//TECLADO
		input ps2c,
		input DATA_IN,
		output[7:0]DATA_OUT_TEC,
		input SOLICITUD, 
		output[7:0]TecladoREG_ANTERIOR,
		output[7:0]TecladoREG
		);
			
		VGA_TOP_P3 VGA(TecladoREG, TecladoREG_ANTERIOR, RST, CLK, ALARMA, WRITE_STROBE, POR_ID, OUT_PORT, RGB, VS, HS);

		TraductorPS2 TECLADO(DATA_IN,ps2c,CLK,RST,DATA_OUT_TEC,SOLICITUD,TecladoREG_ANTERIOR,TecladoREG);

endmodule 