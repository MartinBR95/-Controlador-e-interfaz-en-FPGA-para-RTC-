`timescale 1ns / 1ps

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
	
	input ALARMA,
	
	///////////////////////////////////////////////////////////
	output wire[9:0]ADDRV,
	output wire[9:0]ADDRH,
	output wire[4:0]SelecOUT
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
	localparam Fecha_Y_in  = 6'd63 ; 
	localparam Fecha_Y_off = 7'd127;
	
	localparam Hora_Y_in   = 8'd191;
	localparam Hora_Y_off  = 8'd255;
	
	localparam Timer_Y_in  = 9'd319;
	localparam Timer_Y_off = 9'd383;
	
	//Parametros en X
	localparam Columna_1_in  = 7'd95 ;
	localparam Columna_1_off = 8'd127;
	
	localparam Columna_2_in  = 8'd128;
	localparam Columna_2_off = 8'd159;
	
	localparam Columna_3_in  = 8'd191;
	localparam Columna_3_off = 8'd223;	
	
	localparam Columna_4_in  = 8'd224;
	localparam Columna_4_off = 8'd255;	
	
	localparam Columna_5_in  = 9'd287;
	localparam Columna_5_off = 9'd319;	
	
	localparam Columna_6_in  = 9'd320;
	localparam Columna_6_off = 9'd351;	
	
	
	//PLANTILLAS FECHA
	localparam PLANT_FECHA = 13'd7349;
	localparam PF_D_X = 8'd147; 
	localparam PF_D_Y = 6'd50;
	
	localparam PF_X_in  = 8'd159;
	localparam PF_X_off = 9'd306;
	
	localparam PF_Y_in  = 4'd13;
	localparam PF_Y_off = 6'd63;
	
	
	//PLANTILLAS HORAS
	localparam PLANT_HORA = 13'd6649;
	localparam PH_D_X = 8'd133; 
	localparam PH_D_Y = 6'd50; 
	
	localparam PH_X_in  = 8'd159;
	localparam PH_X_off = 9'd292;
	
	localparam PH_Y_in  = 8'd141;
	localparam PH_Y_off = 8'd191;
	
	//PLANTILLAS TIMER
	localparam PLANT_TIMER = 13'd7149;
	localparam PT_D_X = 8'd143; 
	localparam PT_D_Y = 6'd50;

	localparam PT_X_in  = 8'd159;
	localparam PT_X_off = 9'd302;
	
	localparam PT_Y_in  = 9'd269;
	localparam PT_Y_off = 9'd319;
	
	//Flechas  
	localparam FLECHAS   = 13'd6599;
	localparam FLE_D_X   = 7'd100; 
	localparam FLE_D_Y   = 7'd66;

	localparam FLE_X_in  = 10'd460;
	localparam FLE_X_off = 10'd560;
	
	localparam FLE_Y_in  = 6'd63;
	localparam FLE_Y_off = 8'd129;

	//Alarma 
	localparam ALARM    = 10'd624;
	localparam AL_D_X   = 5'd25;
	localparam AL_D_Y   = 5'd25;

	localparam AL_X_in  = 9'd383;
	localparam AL_X_off = 9'd408;
	
	localparam AL_Y_in  = 9'd383;
	localparam AL_Y_off = 9'd408;

	//Plantilla
	localparam PL_D_X    = 5'd25;
	localparam PL_D_Y    = 5'd25;

	localparam PL_X_in   = 1'd0;
	localparam PL_X_off  = 9'd478;
	 
	localparam PL_Y_in   = 1'd0;
	localparam PL_Y_off  = 9'd479;	


	/////////////////////////////////////////////////////////////////////////////////////////
	/////////////////////////// SELECCION DE MEMORIAS EMPLEADAS /////////////////////////////

	reg [11:0]FLECHAS_DATA[0:FLECHAS]; //Memoria donde se almacena los datos de plantilla
	reg [11:0]ALARMA_DATA[0:ALARM];   //Memoria donde se almacena los datos de plantilla
	reg [11:0]FEHA_DATA[0:PLANT_FECHA];
	reg [11:0]HORA_DATA[0:PLANT_HORA];
	reg [11:0]TIMER_DATA[0:PLANT_TIMER];
	
	initial  //Se leen los datos de los .txt o .list y se pasan a las memorias
	begin
	$readmemh ("FLECHAS.list",FLECHAS_DATA); //paso de listas txt a memorias
	$readmemh ("ALARMA.list" ,ALARMA_DATA );
	$readmemh ("FECHA.list"  ,FEHA_DATA   );
	$readmemh ("HORA.list"   ,HORA_DATA   );
	$readmemh ("TIMER.list"  ,TIMER_DATA  );

	end

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
	wire PUNTOS,SLASH,LINEA_DIV;
	
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
	
	assign PUNTOS = ((Hora_Y_in  <= ADDRV) && (ADDRV  <= Hora_Y_off) && (Columna_4_off <= ADDRH) && (ADDRH <= Columna_5_in))||
						 ((Hora_Y_in  <= ADDRV) && (ADDRV  <= Hora_Y_off) && (Columna_2_off <= ADDRH) && (ADDRH <= Columna_3_in))||						 
						 ((Timer_Y_in <= ADDRV) && (ADDRV <= Timer_Y_off) && (Columna_2_off <= ADDRH) && (ADDRH <= Columna_3_in))||
						 ((Timer_Y_in <= ADDRV) && (ADDRV <= Timer_Y_off) && (Columna_4_off <= ADDRH) && (ADDRH <= Columna_5_in));

	assign SLASH  = ((Fecha_Y_in <= ADDRV) && (ADDRV <= Fecha_Y_off) && (Columna_4_off <= ADDRH) && (ADDRH <= Columna_5_in))||
						 ((Fecha_Y_in <= ADDRV) && (ADDRV <= Fecha_Y_off) && (Columna_2_off <= ADDRH) && (ADDRH <= Columna_3_in));
	
	assign LINEA_DIV = (9'd384 <= ADDRH) && (ADDRH <= 10'd416);
	
	///////
		
	//Imagenes
	wire AL_ON;
	wire FLECHAS_ON;
	
	assign FLECHAS_ON = (FLE_Y_in <= ADDRV) && (ADDRV <= FLE_Y_off) && (FLE_X_in <= ADDRH) && (ADDRH <= FLE_X_off);	
	assign AL_ON      = (AL_Y_in  <= ADDRV) && (ADDRV <=  AL_Y_off) && (AL_X_in  <= ADDRH) && (ADDRH <=  AL_Y_off) && ALARMA;
	///////
	
	//Plantilla 
	wire PLANTILLA_ON ;
	wire PLANTILLA_OFF;
	
	assign PLANTILLA_ON  = (PL_Y_in <= ADDRV) && (ADDRV <= PL_Y_off) && (PL_X_in <= ADDRH) && (ADDRH <= PL_X_off);	
	assign PLANTILLA_OFF = (PL_Y_in > ADDRV)  || (ADDRV >  PL_Y_off) || (PL_X_in >  ADDRH) || (ADDRH >  PL_X_off);	

	///////
	wire P_FECHA;
	wire P_TIMER;
	wire P_HORA;
	
	assign P_FECHA = (PF_Y_in <= ADDRV) && (PF_Y_off >= ADDRV) && (ADDRH >= PF_X_in) && (PF_X_off >= ADDRH);
	assign P_HORA  = (PH_Y_in <= ADDRV) && (PH_Y_off >= ADDRV) && (ADDRH >= PH_X_in) && (PH_X_off >= ADDRH);
	assign P_TIMER = (PT_Y_in <= ADDRV) && (PT_Y_off >= ADDRV) && (ADDRH >= PT_X_in) && (PT_X_off >= ADDRH);	
	

	reg [4:0]Selector = 5'd0;
	always @(posedge CLK)
	begin 
		if(PLANTILLA_OFF)Selector = 5'd0;
		else Selector = Selector;
		
		if(PLANTILLA_ON) Selector = 5'd1;
		else Selector = Selector;
		
		if(A1_ON)  Selector = 5'd2;
		else Selector = Selector;
		
		if(A2_ON)  Selector = 5'd3;
		else Selector = Selector;
		
		if(ME1_ON) Selector = 5'd4;
		else Selector = Selector;
		
		if(ME2_ON) Selector = 5'd5;
		else Selector = Selector;
		
		if(D1_ON)  Selector = 5'd6;
		else Selector = Selector;
		
		if(D2_ON)  Selector = 5'd7;
		else Selector = Selector;
		
		if(H1_ON)  Selector = 5'd8;
		else Selector = Selector;
		
		if(H2_ON)  Selector = 5'd9;
		else Selector = Selector;
		
		if(M1_ON)  Selector = 5'd10;
		else Selector = Selector;
		
		if(M2_ON)  Selector = 5'd11;
		else Selector = Selector;
		
		if(S1_ON)  Selector = 5'd12;
		else Selector = Selector;
		
		if(S2_ON)  Selector = 5'd13;
		else Selector = Selector;
		
		if(HT1_ON) Selector = 5'd14;
		else Selector = Selector;
		
		if(HT2_ON) Selector = 5'd15;
		else Selector = Selector;
		
		if(MT1_ON) Selector = 5'd16;
		else Selector = Selector;
		
		if(MT2_ON) Selector = 5'd17;
		else Selector = Selector;
		
		if(ST1_ON) Selector = 5'd18;
		else Selector = Selector;
		
		if(ST2_ON) Selector = 5'd19;
		else Selector = Selector;	
	
		if(FLECHAS_ON)  Selector = 5'd20;
		else Selector = Selector;
		
		if(AL_ON)  Selector = 5'd21;
		else Selector = Selector;
		
		if(SLASH) Selector = 5'd22;
		else Selector = Selector;
		
		if(PUNTOS) Selector = 5'd23;
		else Selector = Selector;		
		
		if(P_FECHA) Selector = 5'd24;
		else Selector = Selector;		
		
		if(P_HORA) Selector = 5'd25;
		else Selector = Selector;		

		if(P_TIMER) Selector = 5'd26;
		else Selector = Selector;		
		
		if(LINEA_DIV) Selector = 5'd27;
		else Selector = Selector;		
		
	end 

	assign SelecOUT = Selector;

//Seleccion de datos
///////////////////////////////////////////////////////////////////////
//Datos internos en memoria (NUMEROS)
	reg [3:0]rom;
	always @(posedge CLK)
	begin	
		case (Selector)
		5'd2  : rom = ANO[7:4];
		5'd3  : rom = ANO[3:0];
		5'd4  : rom = MES[7:4];
		5'd5  : rom = MES[3:0];
		5'd6  : rom = DIA[7:4];
		5'd7  : rom = DIA[3:0];
		
		5'd8  : rom = HORA[7:4];
		5'd9  : rom = HORA[3:0]; 
		5'd10 : rom = MIN[7:4] ;
		5'd11 : rom = MIN[3:0] ;
		5'd12 : rom = SEG[7:4] ;
		5'd13 : rom = SEG[3:0] ;
	
		5'd14 : rom = HORAT[7:4];
		5'd15 : rom = HORAT[3:0];
		5'd16 : rom = MINT[7:4] ;
		5'd17 : rom = MINT[3:0] ;
		5'd18 : rom = SEGT[7:4] ;
		5'd19 : rom = SEGT[3:0] ;
		
		5'd22  : rom = 4'h0;
		5'd23  : rom = 4'h1;
		
		5'd27  : rom = 4'h2;
		
		default rom = 4'h0;
		endcase 
	end 
	
	wire [4:0]direccion; 
	assign direccion      = {ADDRV[5], ADDRV[4], ADDRV[3], ADDRV[2], ADDRV[1]};
	
	wire [3:0]direccion_data;
	assign direccion_data = {ADDRH[4], ADDRH[3], ADDRH[2], ADDRH[1]};
	
	wire [11:0]NUMEROS;
	wire [11:0]COSAS;
	
	Memoria_Numeros NUMEROS_MEM (direccion,rom, NUMEROS, direccion_data,CLK,RST,ADDRV); 
	MEMORIA_SP      PUNTOS_SLAS (direccion,rom, COSAS  , direccion_data);

////////////////////////////////////////////////////////////////////////////////////////
//Imagnes cargadas 

	wire [12:0]Adress1;
	reg  [9:0]Y   = 9'h1FF; //Resta en Y 
	reg  [9:0]X   = 9'h1FF; //Resta en X
	reg  [9:0]MUL = 9'h1FF; //Multiplica por parametro
	
	always @(*) //Dependiendo de el lugar de selector se escogen los paramentros a operar
	begin
		case(Selector)
		5'd20 : begin Y = FLE_Y_in; X = FLE_X_in; MUL = FLE_D_Y; end
		5'd21 : begin Y = AL_Y_in ; X = AL_X_in ; MUL = AL_D_Y ; end
		5'd24 : begin Y = PF_Y_in ; X = PF_X_in ; MUL = PF_D_Y ; end
		5'd25 : begin Y = PH_Y_in ; X = PH_X_in ; MUL = PH_D_Y ; end
		5'd26 : begin Y = PT_Y_in ; X = PT_X_in ; MUL = PT_D_Y ; end
		
		default begin Y = PL_Y_in ; X= PL_X_in; MUL= PL_D_Y; end
		endcase
	end

	//OPERADOR//

	assign Adress1 = (ADDRV - Y) + (ADDRH - X)*MUL; //Establecimieto de puntero para memoria de plantilla
	//////////////////////
	
	reg [12:0]Adress;
	always @(posedge CLK) Adress = Adress1;


	//////////////////////////////////////////////////////
	//Seleccion de salida
	
	always @(posedge CLK)
	begin	
		case (Selector)	

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
		5'd19 : COLOR_OUT = NUMEROS;
		
	   5'd20 : COLOR_OUT = FLECHAS_DATA[{Adress}];
		5'd21 : COLOR_OUT = ALARMA_DATA[{Adress}];
		
		5'd22  : COLOR_OUT = COSAS;
		5'd23  : COLOR_OUT = COSAS;
		
		5'd24 : COLOR_OUT = FEHA_DATA[{Adress}];
		5'd25 : COLOR_OUT = HORA_DATA[{Adress}];
		
		5'd26 : COLOR_OUT = TIMER_DATA[{Adress}];
		
		5'd27 : COLOR_OUT = COSAS;
		
		default COLOR_OUT = 12'h000;
		endcase
		
	end
endmodule 