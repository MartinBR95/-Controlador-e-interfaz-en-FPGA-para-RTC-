//////////////////////////////////////////////////////////////////////////////////
module Conexion_CONTROL_VGA_TECLADO
	(	/////////////////////////////
		input wire CLK,		               //Se�al de reloj de la FPGA
		input wire RST,                     //Se�al de reseteo
		input wire[7:0]POR_ID,              //Direccion donde se debe de leer los datos

		/////////   VGA   /////////
		//Entradas
		input ALARMA,                       //Se�al de alarma
		input wire WRITE_STROBE,            //Se�al de actualizar registro (en flanco de subida)
		input wire[7:0]OUT_PORT,            //Datos de entrada
		//Salidas
		output wire[11:0]RGB,               //Salidas a pantallas
		output wire VS,                     //Sincronia vertical para pantalla
		output wire HS,                     //Sincronia horzontal para pantalla

		///////// TECLADO /////////
		//Entradas
		/////////////////////////////////// SIMULACION
		input wire UP,
		input wire DOWN,
		input wire NEXT,
		input wire PREV,
		input wire TT,
		input wire AL,
		///////////////////////////////////

		input ps2c,                         //Reloj proveniente del teclado
		input DATA_IN,                      //Datos provenientes del teclado (En forma serial)
		input SOLICITUD,                    //Solicitud de leer el registro de salida del teclado
		//Salidas
		output[7:0]DATA_OUT_TEC,            //Datos de salida del teclado (En paralelo)

		///////// MUSICA  /////////
		//Salidas
		output speaker
		);

		wire [7:0]TecladoREG_ANTERIOR, TecladoREG;  //Cables de conexion entre el teclado y la VGA

		wire ON;
		assign ON = (CLK && ~ALARMA);

		//////
		VGA_TOP_P3 VGA(       //Llamada a modulo de VGA
				.TecladoREG(TecladoREG),
				.TecladoREG_ANTERIOR(TecladoREG_ANTERIOR),
				.RST(RST),
				.CLK(CLK),
				.ALARMA(ALARMA),
				.WRITE_STROBE(WRITE_STROBE),
				.POR_ID(POR_ID),
				.OUT_PORT(OUT_PORT),
				.RGB(RGB),
				.VS(VS),
				.HS(HS));

		//////

	/*	JOKER UUT (
				.CLK(CLK),
				.RST(RST),

				.UP(UP),
				.DOWN(DOWN),
				.NEXT(NEXT),
				.PREV(PREV),

				.S_DATA(SOLICITUD),

				.TT(TT),
				.AL(AL),

				.DATA_REG(TecladoREG),
				.OUT_DEC(DATA_OUT_TEC),
				.POR_ID(POR_ID)
			);*/
		TraductorPS2 TECLADO( //Llamada a modulo de teclado
				.DATA_IN(DATA_IN),
				.ps2c(ps2c),
				.Reloj(CLK),
				.RST(RST),
				.OUT_DEC(DATA_OUT_TEC),
				.S_DATA(SOLICITUD),
				.DATA_REG_ANTERIOR(TecladoREG_ANTERIOR),
				.DATA_REG(TecladoREG),
				.POR_ID(POR_ID));

		//////
	//	MUSICA ALARM(        //Llamada a modulo de musica
		 //	.clk(ON),
			//	.speaker(speaker));

endmodule
