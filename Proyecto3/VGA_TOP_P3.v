`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
module VGA_TOP_P3
(		//TECLADO
		input wire[7:0]TecladoREG,          //Registro del teclado
		input wire[7:0]TecladoREG_ANTERIOR, //Registro anterior del teclado

		/////////////////////////////			
		//ENTRADA									
		input wire RST,				         //Reinicio
		input wire CLK,							//Reloj de la FPGA
	
		//SEÑALES PROBENIENTES DEL CONTROL 	
		input wire WRITE_STROBE,            //Señal de actualizar registro (en flanco de subida)
		input wire[7:0]POR_ID,              //Donde escribo
		input wire[7:0]OUT_PORT,            //Datos de entrada		
		input ALARMA,								//Señal de alarma (IRQ)
														
		/////////////////////////////			
		//SALIDAS									
		output reg[11:0]RGB,                //Señales del VGA
		output wire VS,                     //Sincronia 
		output wire HS
);	

/*
Tres secciones

1- Seccion de creacion de registros 
2- Seccion de llamado de modulo VGA
3- Seccion de salida final
*/

////////////////////////////////////////////////////////////////////////////////////
//////////////////////////     SECCION DE REGISTROS       //////////////////////////
////////////////////////////////////////////////////////////////////////////////////

//Registros para modificar segun datos entrantes 
reg[7:0]ANO   = 8'h10;   //Registro de años
reg[7:0]MES   = 8'h20;   //Registro de meses
reg[7:0]DIA   = 8'h30;	  //Registro de años

reg[7:0]HORA  = 8'h40;  //Registro de horas
reg[7:0]MIN   = 8'h50;  //Registro de minutos
reg[7:0]SEG   = 8'h60;  //Registro de segundos

reg[7:0]HORAT = 8'h70; //Registro de horas de timer
reg[7:0]MINT  = 8'h80; //Registro de minutos de timer
reg[7:0]SEGT  = 8'h90; //Registro de segundos de timer 

reg[7:0]Punt  = 8'h00;  //Registro de Punteros

// Direccion de POR_ID para modificar registros 
localparam PUN_S  = 8'h0E;  //Direccion para modificar registro de puntero

localparam ANO_S  = 8'h07;  //Direccion para modificar registro de años
localparam MES_S  = 8'h06;  //Direccion para modificar registro de meses
localparam DIA_S  = 8'h05;  //Direccion para modificar registro de dias

localparam SEG_S  = 8'h02;  //Direccion para modificar registro de segundos
localparam MIN_S  = 8'h03;  //Direccion para modificar registro de minutos
localparam HORA_S = 8'h04;  //Direccion para modificar registro de horas

localparam SEGT_S = 8'h08;  //Direccion para modificar registro de segundos del timer
localparam MINT_S = 8'h09;  //Direccion para modificar registro de minutos del timer
localparam HORAT_S= 8'h0A;  //Direccion para modificar registro de horas del timer 
				
always@(posedge CLK)
begin
	if(WRITE_STROBE) //Si hay una señal de escritura se modifica uno de los registros 
	begin
		case(POR_ID)
				ANO_S   : ANO   = OUT_PORT;
				MES_S   : MES   = OUT_PORT;
				DIA_S   : DIA   = OUT_PORT;
				SEG_S   : SEG   = OUT_PORT;
				MIN_S   : MIN   = OUT_PORT;
				HORA_S  : HORA  = OUT_PORT;
				SEGT_S  : SEGT  = OUT_PORT;
				MINT_S  : MINT  = OUT_PORT;
				HORAT_S : HORAT = OUT_PORT;
				PUN_S   : Punt  = OUT_PORT;
		endcase 
	end
			
	else             //De lo contrario se mantienen los datos existentes 
	begin	ANO   = ANO  ; MES  = MES ; DIA  = DIA ;
			HORA  = HORA ; MIN  = MIN ; SEG  = SEG ;
			HORAT = HORAT;	MINT = MINT; SEGT = SEGT;
			Punt  = Punt; end  
end 



////////////////////////////////////////////////////////////////////////////////////
//////////////////////////     LLAMADO A MODULO VGA       //////////////////////////
////////////////////////////////////////////////////////////////////////////////////

wire[9:0]ADDRV;      //Puntero Horizontal de pantalla
wire[9:0]ADDRH;		//Puntero Vertical de pantalla

wire[4:0]Selector;	//Seccion de pantalla que se esta pintando
wire[11:0]COLOR_OUT;	//Señales de salida del modulo VGA (Colores sin modificar)

ModuloVGA VGA (
			.CLK(CLK),
			.RST(RST),
			.COLOR_OUT(COLOR_OUT),
			.HS(HS),
			.VS(VS),
			.ANO(ANO),
			.MES(MES),
			.DIA(DIA),
			.HORA(HORA),
			.MIN(MIN),
			.SEG(SEG),
			.HORAT(HORAT),
			.MINT(MINT),
			.SEGT(SEGT),
			.ALARMA(~ALARMA),
			.ADDRV(ADDRV),
			.ADDRH(ADDRH),
			.SelecOUT(Selector));	
///

////////////////////////////////////////////////////////////////////////////////////
/////////////////////////       SECCION DE SALIDA         //////////////////////////
////////////////////////////////////////////////////////////////////////////////////

//Parametros de flechas
localparam UP_X_in  = 10'd490;
localparam UP_X_end = 10'd521;
localparam UP_Y_in  = 7'd67;
localparam UP_Y_end = 7'd92;

localparam DO_X_in  = 10'd490;
localparam DO_X_end = 10'd521;
localparam DO_Y_in  = 7'd95;
localparam DO_Y_end = 7'd115;

localparam RI_X_in  = 10'd522;
localparam RI_X_end = 10'd550;
localparam RI_Y_in  = 7'd95;
localparam RI_Y_end = 7'd115;

localparam LE_X_in  = 10'd465;
localparam LE_X_end = 10'd487;
localparam LE_Y_in  = 7'd95;
localparam LE_Y_end = 7'd115;

wire UP,DO,RI,LE;

assign UP = (UP_X_in <= ADDRH) && (ADDRH <= UP_X_end) && (UP_Y_in <= ADDRV) && (ADDRV <= UP_Y_end) && (TecladoREG == 8'h75) && (TecladoREG_ANTERIOR != 8'hF0);
assign DO = (DO_X_in <= ADDRH) && (ADDRH <= DO_X_end) && (DO_Y_in <= ADDRV) && (ADDRV <= DO_Y_end) && (TecladoREG == 8'h72) && (TecladoREG_ANTERIOR != 8'hF0);
assign RI = (RI_X_in <= ADDRH) && (ADDRH <= RI_X_end) && (RI_Y_in <= ADDRV) && (ADDRV <= RI_Y_end) && (TecladoREG == 8'h74) && (TecladoREG_ANTERIOR != 8'hF0);
assign LE = (LE_X_in <= ADDRH) && (ADDRH <= LE_X_end) && (LE_Y_in <= ADDRV) && (ADDRV <= LE_Y_end) && (TecladoREG == 8'h6B) && (TecladoREG_ANTERIOR != 8'hF0);


always @(posedge CLK)
	begin 
	if ((UP || DO || RI || LE) && (COLOR_OUT == 12'hFFF)) RGB = 12'hF00;
	else begin
		case(Punt)
			8'h24 : 	if(((Selector == 8'd3)||(Selector == 8'd2)) && COLOR_OUT != 12'h000) RGB = 12'hF00;	 //dia
						else RGB = COLOR_OUT; 

			8'h25 : 	if(((Selector == 8'd5)||(Selector == 8'd4)) && COLOR_OUT != 12'h000) RGB = 12'hF00;  //mes
						else RGB = COLOR_OUT; 

			8'h26 : 	if(((Selector == 8'd7)||(Selector == 8'd6)) && COLOR_OUT != 12'h000) RGB = 12'hF00;  //ano
						else RGB = COLOR_OUT; 

			8'h23 : 	if(((Selector == 8'd9)||(Selector == 8'd8)) && COLOR_OUT != 12'h000) RGB = 12'hF00;	 //hora
						else RGB = COLOR_OUT; 

			8'h22 : 	if(((Selector == 8'd11)||(Selector == 8'd10))&& COLOR_OUT != 12'h000) RGB = 12'hF00; //min
						else RGB = COLOR_OUT; 

			8'h21 : 	if(((Selector == 8'd13)||(Selector == 8'd12))&& COLOR_OUT != 12'h000) RGB = 12'hF00; //seg
						else RGB = COLOR_OUT; 

			8'h43 : 	if(((Selector == 8'd15)||(Selector == 8'd14))&& COLOR_OUT != 12'h000) RGB = 12'hF00; //horat
						else RGB = COLOR_OUT; 

			8'h42 : 	if(((Selector == 8'd17)||(Selector == 8'd16))&& COLOR_OUT != 12'h000) RGB = 12'hF00; //mint
						else RGB = COLOR_OUT; 

			8'h41 :	if(((Selector == 8'd19)||(Selector == 8'd18))&& COLOR_OUT != 12'h000) RGB = 12'hF00; //Segt
						else RGB = COLOR_OUT;
			
		default RGB = COLOR_OUT;

		endcase end 
end 

endmodule 