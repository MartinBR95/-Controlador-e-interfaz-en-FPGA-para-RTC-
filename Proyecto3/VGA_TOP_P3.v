`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
module VGA_TOP_P3
(		input wire[7:0]TecladoREG,
		input wire[7:0]TecladoREG_ANTERIOR,

		/////////////////////////////			
		//ENTRADA									
		input wire RST,				
		input wire CLK,
		input ALARMA,
	
		//SEALES PROBENIENTES DEL CONTROL 	
		input wire WRITE_STROBE,            //Seal de actualizar registro (en flanco de subida)
		input wire[7:0]POR_ID,              //Donde escribo
		input wire[7:0]OUT_PORT,            //Datos de entrada		
														
		/////////////////////////////			
		//SALIDAS									
		output reg[11:0]RGB,
		output wire VS,
		output wire HS
);	

wire[9:0]ADDRV;
wire[9:0]ADDRH;

reg[7:0]ANO = 8'h00;
reg[7:0]MES = 8'h00;
reg[7:0]DIA = 8'h00;

reg[7:0]HORA = 8'h00;
reg[7:0]MIN = 8'h00;
reg[7:0]SEG = 8'h00;
	
reg[7:0]HORAT = 8'h00;
reg[7:0]MINT = 8'h00;
reg[7:0]SEGT = 8'h00;
reg[7:0]Puntero = 8'h00;
	
localparam PUN_S  = 8'd14;
	
localparam ANO_S  = 8'h07; 
localparam MES_S  = 8'h06; 
localparam DIA_S  = 8'h05; 
		
localparam SEG_S  = 8'h02; 
localparam MIN_S  = 8'h03; 
localparam HORA_S = 8'h04; 
		
localparam SEGT_S = 8'h08; 
localparam MINT_S = 8'h09; 
localparam HORAT_S= 8'h0a; 
				
always@(posedge CLK)
begin
	if(WRITE_STROBE)
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
		
			PUN_S   : Puntero = OUT_PORT;

		default  begin
					ANO = ANO;
					MES = MES;
					DIA = DIA;

					HORA = HORA;
					MIN  = MIN;
					SEG  = SEG;
	
					HORAT = HORAT;
					MINT  = MINT;
					SEGT  = SEGT;
					Puntero = Puntero;
					end 
		endcase 
	end
			
	else 
	begin
		ANO = ANO;
		MES = MES;
		DIA = DIA;

		HORA = HORA;
		MIN  = MIN;
		SEG  = SEG;
	
		HORAT = HORAT;
		MINT  = MINT;
		SEGT  = SEGT;
		Puntero = Puntero;
	end 
end 


wire[4:0]Selector;
wire[11:0]COLOR_OUT;

ModuloVGA VGA (CLK, RST, COLOR_OUT, HS, VS, ANO, MES, DIA, HORA, MIN, SEG, HORAT, MINT, SEGT,ALARMA, ADDRV, ADDRH, Selector);	

///
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
	else 
	begin
		case(Puntero)
			8'h24 : begin if(((Selector == 8'd3)||(Selector == 8'd2))  && COLOR_OUT != 12'h000) RGB = 12'hF00;	//dia
							  else RGB = COLOR_OUT; end

			8'h25 : begin if(((Selector == 8'd5)||(Selector == 8'd4))  && COLOR_OUT != 12'h000) RGB = 12'hF00;	//mes
							  else RGB = COLOR_OUT; end

			8'h26 : begin if(((Selector == 8'd7)||(Selector == 8'd6))  && COLOR_OUT != 12'h000) RGB = 12'hF00;	//ano
							  else RGB = COLOR_OUT; end

			8'h23 : begin if(((Selector == 8'd9)||(Selector == 8'd8))  && COLOR_OUT != 12'h000) RGB = 12'hF00;	//hora
							  else RGB = COLOR_OUT; end

			8'h22 : begin if(((Selector == 8'd11)||(Selector == 8'd10))&& COLOR_OUT != 12'h000) RGB = 12'hF00;	//min
							  else RGB = COLOR_OUT; end

			8'h21 : begin if(((Selector == 8'd13)||(Selector == 8'd12))&& COLOR_OUT != 12'h000) RGB = 12'hF00;	//seg
							  else RGB = COLOR_OUT; end

			8'h43 : begin if(((Selector == 8'd15)||(Selector == 8'd14))&& COLOR_OUT != 12'h000) RGB = 12'hF00;	//horat
							  else RGB = COLOR_OUT; end

			8'h42 : begin if(((Selector == 8'd17)||(Selector == 8'd16))&& COLOR_OUT != 12'h000) RGB = 12'hF00; //mint
							  else RGB = COLOR_OUT; end

			8'h41 : begin if(((Selector == 8'd19)||(Selector == 8'd18))&& COLOR_OUT != 12'h000) RGB = 12'hF00; //Segt
							  else RGB = COLOR_OUT; end
			
		default RGB = COLOR_OUT;
		endcase 
	end 
	end 

endmodule 