/////////////////////////////////////////////////////////////////////////////////
module ModuloVGA
	(
   input  CLK, RST,    		  			//Senal de reloj
   output reg[11:0]COLOR_OUT,  	   //bits de color hacia la VGA
   output HS,					  			//Sincronizacion horizontal
   output VS,							   //Sincronizacion vertical

	input[7:0]ANO,
	input[7:0]MES,
	input[7:0]DIA,

	input[7:0]HORA,
	input[7:0]MIN,
	input[7:0]SEG,
	
	input[7:0]HORAT,
	input[7:0]MINT,
	input[7:0]SEGT,
	
	///////////////////////////////////////////////////////////
	output wire video_ON,              //Parametros de simulacion
	output wire[9:0]ADDRV,
	output wire[9:0]ADDRH
	);	
		
	/////////////////////////// LLAMADO A MODULO DE SINCRONIA //////////////////////////////


	SINC SIM (CLK, RST, HS, VS, ADDRH, ADDRV);  //Sincronizacion para la VGA
	
	/////////////////////////////////////////////////////////////////////////////////////////
	
	
	/////////////////////////// Seccion de imprecion en pantalla /////////////////////////////
	
	/////// NUMEROS ///////
	
	/// PARAMETROS ///
	
	//Se determina que los numeros seran de una dimencion de 32x64
	//Estos numeros son llamados desde el modulo de Memoria 
	
	//Parametros en Y	
	localparam Fecha_Y_in  = 7'd127; 
	localparam Fecha_Y_off = 8'd191;
	
	localparam Hora_Y_in   = 8'd255;
	localparam Hora_Y_off  = 9'd319;
	
	localparam Timer_Y_in  = 9'd383;
	localparam Timer_Y_off = 9'd447;
	
	//Parametros en X
	localparam Columna_1_in  = 7'd127;
	localparam Columna_1_off = 8'd157;

	localparam Columna_2_in  = 8'd191;
	localparam Columna_2_off = 8'd223;

	localparam Columna_3_in  = 9'd287;
	localparam Columna_3_off = 9'd319;	

	localparam Columna_4_in  = 9'd351;
	localparam Columna_4_off = 9'd383;	

	localparam Columna_5_in  = 9'd415;
	localparam Columna_5_off = 9'd447;	
	
	localparam Columna_6_in  = 9'd479;
	localparam Columna_6_off = 9'd511;	
	
	
	/////////////////////////////////////////////////////////////////////////////////////////
	//////////////////////////// SELECCION DE DATOS DE SALIDA ///////////////////////////////

	/////
	//Numeros
	wire A1_ON ,A2_ON ;
	wire ME1_ON,ME2_ON;
	wire D1_ON ,D2_ON ;
	
	wire H1_ON ,H2_ON ;
	wire M1_ON ,M2_ON ;  //INDICADORES DE NUMERO ENCENDIDO 	
	wire S1_ON ,S2_ON ;
	
	wire HT1_ON,HT2_ON;
	wire MT1_ON,MT2_ON;	
	wire ST1_ON,ST2_ON;	
	
	assign A1_ON  = (Fecha_Y_in <= ADDRV) && (ADDRV <= Fecha_Y_off) && (Columna_1_in <= ADDRH) && (ADDRH <= Columna_1_off);
	assign A2_ON  = (Fecha_Y_in <= ADDRV) && (ADDRV <= Fecha_Y_off) && (Columna_2_in <= ADDRH) && (ADDRH <= Columna_2_off);
	assign ME1_ON = (Fecha_Y_in <= ADDRV) && (ADDRV <= Fecha_Y_off) && (Columna_3_in <= ADDRH) && (ADDRH <= Columna_3_off);
	assign ME2_ON = (Fecha_Y_in <= ADDRV) && (ADDRV <= Fecha_Y_off) && (Columna_4_in <= ADDRH) && (ADDRH <= Columna_4_off);
	assign D1_ON  = (Fecha_Y_in <= ADDRV) && (ADDRV <= Fecha_Y_off) && (Columna_5_in <= ADDRH) && (ADDRH <= Columna_5_off);
	assign D2_ON  = (Fecha_Y_in <= ADDRV) && (ADDRV <= Fecha_Y_off) && (Columna_6_in <= ADDRH) && (ADDRH <= Columna_6_off);
	
	assign H1_ON  = (Hora_Y_in  <= ADDRV) && (ADDRV  <= Hora_Y_off) && (Columna_1_in <= ADDRH) && (ADDRH <= Columna_1_off);
	assign H2_ON  = (Hora_Y_in  <= ADDRV) && (ADDRV  <= Hora_Y_off) && (Columna_2_in <= ADDRH) && (ADDRH <= Columna_2_off);
	assign M1_ON  = (Hora_Y_in  <= ADDRV) && (ADDRV  <= Hora_Y_off) && (Columna_3_in <= ADDRH) && (ADDRH <= Columna_3_off);
	assign M2_ON  = (Hora_Y_in  <= ADDRV) && (ADDRV  <= Hora_Y_off) && (Columna_4_in <= ADDRH) && (ADDRH <= Columna_4_off);
	assign S1_ON  = (Hora_Y_in  <= ADDRV) && (ADDRV  <= Hora_Y_off) && (Columna_5_in <= ADDRH) && (ADDRH <= Columna_5_off);
	assign S2_ON  = (Hora_Y_in  <= ADDRV) && (ADDRV  <= Hora_Y_off) && (Columna_6_in <= ADDRH) && (ADDRH <= Columna_6_off);
	
	assign HT1_ON = (Timer_Y_in <= ADDRV) && (ADDRV <= Timer_Y_off) && (Columna_1_in <= ADDRH) && (ADDRH <= Columna_1_off);
	assign HT2_ON = (Timer_Y_in <= ADDRV) && (ADDRV <= Timer_Y_off) && (Columna_2_in <= ADDRH) && (ADDRH <= Columna_2_off);
	assign MT1_ON = (Timer_Y_in <= ADDRV) && (ADDRV <= Timer_Y_off) && (Columna_3_in <= ADDRH) && (ADDRH <= Columna_3_off);
	assign MT2_ON = (Timer_Y_in <= ADDRV) && (ADDRV <= Timer_Y_off) && (Columna_4_in <= ADDRH) && (ADDRH <= Columna_4_off);
	assign ST1_ON = (Timer_Y_in <= ADDRV) && (ADDRV <= Timer_Y_off) && (Columna_5_in <= ADDRH) && (ADDRH <= Columna_5_off);
	assign ST2_ON = (Timer_Y_in <= ADDRV) && (ADDRV <= Timer_Y_off) && (Columna_6_in <= ADDRH) && (ADDRH <= Columna_6_off);
	///////
	
	reg [4:0]Selector = 5'd0;
	always @(posedge CLK)
	begin 
		if(A1_ON)  Selector = 5'd1;
		else Selector = Selector;
		
		if(A2_ON)  Selector = 5'd2;
		else Selector = Selector;
		
		if(ME1_ON) Selector = 5'd3;
		else Selector = Selector;
		
		if(ME2_ON) Selector = 5'd4;
		else Selector = Selector;
		
		if(D1_ON)  Selector = 5'd5;
		else Selector = Selector;
		
		if(D2_ON)  Selector = 5'd6;
		else Selector = Selector;
		
		if(H1_ON)  Selector = 5'd7;
		else Selector = Selector;
		
		if(H2_ON)  Selector = 5'd8;
		else Selector = Selector;
		
		if(M1_ON)  Selector = 5'd9;
		else Selector = Selector;
		
		if(M2_ON)  Selector = 5'd10;
		else Selector = Selector;
		
		if(S1_ON)  Selector = 5'd11;
		else Selector = Selector;
		
		if(S2_ON)  Selector = 5'd12;
		else Selector = Selector;
		
		if(HT1_ON) Selector = 5'd13;
		else Selector = Selector;
		
		if(HT2_ON) Selector = 5'd14;
		else Selector = Selector;
		
		if(MT1_ON) Selector = 5'd15;
		else Selector = Selector;
		
		if(MT2_ON) Selector = 5'd16;
		else Selector = Selector;
		
		if(ST1_ON) Selector = 5'd17;
		else Selector = Selector;
		
		if(ST2_ON) Selector = 5'd18;
		else Selector = Selector;	
	end 


	reg [3:0]rom;
	always @(posedge CLK)
	begin	
		case (Selector)
		5'd1  : rom = ANO[3:0];
		5'd2  : rom = ANO[7:4];
		5'd3  : rom = MES[3:0];
		5'd4  : rom = MES[7:4];
		5'd5  : rom = DIA[3:0];
		5'd6  : rom = DIA[7:4];

		5'd7  : rom = HORA[3:0];
		5'd8  : rom = HORA[7:4]; 
		5'd9  : rom = MIN[3:0] ;
		5'd10 : rom = MIN[7:4] ;
		5'd11 : rom = SEG[3:0] ;
		5'd12 : rom = SEG[7:4] ;
		
		5'd13 : rom = HORAT[3:0];
		5'd14 : rom = HORAT[7:4];
		5'd15 : rom = MINT[3:0] ;
		5'd16 : rom = MINT[7:4] ;
		5'd17 : rom = SEGT[3:0] ;
		5'd18 : rom = SEGT[7:4] ;
		
		default rom = 4'h0;
		endcase 
	end 
	
	wire [4:0]direccion; 
	assign direccion      = {ADDRV[5], ADDRV[4], ADDRV[3], ADDRV[2], ADDRV[1]};
	
	wire [3:0]direccion_data;
	assign direccion_data = {ADDRH[4], ADDRH[3], ADDRH[2], ADDRH[1]};
	
	wire [11:0]NUMEROS;
	
	Memoria_Numeros NUMEROS_MEM (direccion,rom, NUMEROS, direccion_data,CLK,RST,ADDRV); 
	
	//Seleccion de salida
	
	always @(posedge CLK)
	begin	
		case (Selector)	
		
		5'd1  : COLOR_OUT = NUMEROS;
		5'd2  : COLOR_OUT = NUMEROS;
		5'd3  : COLOR_OUT = NUMEROS;
		5'd4  : COLOR_OUT = NUMEROS;
		5'd5  : COLOR_OUT = NUMEROS;
		5'd6  : COLOR_OUT = NUMEROS;

		5'd7  : COLOR_OUT = NUMEROS;
		5'd8  : COLOR_OUT = NUMEROS; 
		5'd9  : COLOR_OUT = NUMEROS;
		5'd10 : COLOR_OUT = NUMEROS;
		5'd11 : COLOR_OUT = NUMEROS;
		5'd12 : COLOR_OUT = NUMEROS;
		
		5'd13 : COLOR_OUT = NUMEROS;
		5'd14 : COLOR_OUT = NUMEROS;
		5'd15 : COLOR_OUT = NUMEROS;
		5'd16 : COLOR_OUT = NUMEROS;
		5'd17 : COLOR_OUT = NUMEROS;
		5'd18 : COLOR_OUT = NUMEROS;
		
		default COLOR_OUT = 12'h000;
		endcase
		
	end
	
	/////////////////////////////////////////////////////////////////////////////////////////
	/////// Parametros para simulacion 
	localparam F_ONX  = 1'd0;
	localparam F_OFFX = 10'd639;

	localparam F_ONY  = 1'd0;
	localparam F_OFFY = 9'd479;
		
	assign video_ON = {F_ONY < ADDRV && F_OFFY > ADDRV && F_ONX < ADDRH && F_OFFX > ADDRH};
	//////
	/////////////////////////////////////////////////////////////////////////////////////////
endmodule 