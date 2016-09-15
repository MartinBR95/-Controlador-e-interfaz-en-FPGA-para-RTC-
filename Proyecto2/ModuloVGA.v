//////////////////////////////////////////////////////////////////////////////////
module ModuloVGA
	(
   input  CLK,RST,    		  //Senal de reloj 
   output [11:0] COLOR_OUT,  //bits de color hacia la VGA
   output HS,					  //Sincronizacion horizontal
   output VS,					  //Sincronizacion vertical
	output ENClock,
	input [7:0]DIA_T,         //Senal de dia de la RTC
	input [7:0]MES_T,         //Senal de mes de la RTC
	input [7:0]ANO_T,         //Senal de ano de la RTC
	input [7:0]HORA_T,        //Senal de horas de la RTC
	input [7:0]MINUTO_T,      //Senal de minutos de la RTC
	input [7:0]SEGUNDO_T,     //Senal de segundos de la RTC
	input [7:0]HORAT_T,       //Senal de horas de temporizador de la RTC
	input [7:0]MINUTOT_T,     //Senal de minutos de temporizador de la RTC
	input [7:0]SEGUNDOT_T	  //Senal de segundos de temporizador de la RTC
	);
	
   //VALORES QUE CAMBIAN DEPENDIENDO DE LA IMANGEN 
	parameter imagen = 15'd25600;	     //En general la plantilla tiene 25600 pixels
	parameter imagenXY = 8'd160;	     //sus dimenciones son 200x200 pixels
	parameter InicioImagenX = 10'd100; //Parametro de inicio de la imagen en X
	parameter InicioImagenY  = 9'd100; //Parametro de inicio de la imagen en Y
	
	//VALORES QUE CAMBIAN DEPENDIENDO DE POSICION Y DIMENSIONES DE NUMEROS 
	parameter Numeros = 10'd600;      //En general numeros tiene 6000 pixeles
	
	parameter NumerosX  = 5'd20;			//Los numeros tienen una dimencion en x de 20
	parameter NumerosY  = 5'd30;         //Y una dimencion en y de 30 
	
	//posiciones de los numeros en la plantilla (NO EN LA VGA)
	parameter Fecha_inY = 7'd120;
	parameter Hora_inY  = 8'd170;
	parameter Timer_inY = 8'd220;

	parameter Fecha_endY = 8'd150;          //hay tres subclases para los numeros, la fecha, la hora y el cronometro
	parameter Hora_endY  = 8'd200;
	parameter Timer_endY = 8'd250;

	parameter linea1_inX = 7'd102;           //Todos los numeros se agrupan en filas verticales
	parameter linea2_inX = 7'd124;		      //Ejemplo: en la linea 1 y 2, en fecha estan los dias, en hora estan las horas y en cronometro estan las horas
	parameter linea3_inX = 8'd152;
	parameter linea4_inX = 8'd174;
	parameter linea5_inX = 8'd200;
	parameter linea6_inX = 8'd222;
	
	parameter linea1_endX = 7'd122; 
	parameter linea2_endX = 8'd144;
	parameter linea3_endX = 8'd172;
	parameter linea4_endX = 8'd194;
	parameter linea5_endX = 8'd220;
	parameter linea6_endX = 8'd242;
		
	//VARIABLES
	reg [11:0] PLANTILLA_DATA [0:imagen-1]; //Memoria donde se almacena los datos de plantilla
	reg [11:0] NUMERO0_DATA [0:Numeros -1];  //Memoria donde se almacena los datos de numeros
	reg [11:0] NUMERO1_DATA [0:Numeros -1];  //Memoria donde se almacena los datos de numeros
	reg [11:0] NUMERO2_DATA [0:Numeros -1];  //Memoria donde se almacena los datos de numeros
	reg [11:0] NUMERO3_DATA [0:Numeros -1];  //Memoria donde se almacena los datos de numeros
	reg [11:0] NUMERO4_DATA [0:Numeros -1];  //Memoria donde se almacena los datos de numeros
	reg [11:0] NUMERO5_DATA [0:Numeros -1];  //Memoria donde se almacena los datos de numeros
	reg [11:0] NUMERO6_DATA [0:Numeros -1];  //Memoria donde se almacena los datos de numeros
	reg [11:0] NUMERO7_DATA [0:Numeros -1];  //Memoria donde se almacena los datos de numeros
	reg [11:0] NUMERO8_DATA [0:Numeros -1];  //Memoria donde se almacena los datos de numeros
	reg [11:0] NUMERO9_DATA [0:Numeros -1];  //Memoria donde se almacena los datos de numeros

	reg [11:0] COLOR_IN;                    //Medio entre los posibles pixeles de saida y los pixeles de salida
	wire [9:0] ADDRH;		   	             //direccion Horizontal de pixel
	wire [9:0] ADDRV;			                //direccion vertical de pixel

///////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////// Direcciones de lectura en memorias  //////////////////////////////////

//Segun sea el lugar del cual se debe sacar los pixeles se usan estas direcciones 

	wire [14:0] STATE_Plantilla;           //Direccion en memoria de plantilla
	
	wire [9:0]STATE_dia1;					   //Direccion en memoria de numeros (sea cual sea)
	wire [9:0]STATE_dia2;					   //Todas las demas direcciones cumplen con el mismo fin 

	wire [9:0]STATE_mes1;						
	wire [9:0]STATE_mes2;							

	wire [9:0]STATE_ano1;                  
	wire [9:0]STATE_ano2;

	wire [9:0]STATE_Horas1;                
	wire [9:0]STATE_Horas2;

	wire [9:0]STATE_minutos1;
	wire [9:0]STATE_minutos2;

	wire [9:0]STATE_segundos1;
	wire [9:0]STATE_segundos2;

	wire [9:0]STATE_HorasT1;
	wire [9:0]STATE_HorasT2;
	
	wire [9:0]STATE_minutosT1;
	wire [9:0]STATE_minutosT2;

	wire [9:0]STATE_segundosT1;
	wire [9:0]STATE_segundosT2;


///////////////////////////////////////////////////////////////////////////////////////////////

	initial
	begin
	$readmemh ("PLANTILLA.list", PLANTILLA_DATA);
	$readmemh ("NUMERO0.list", NUMERO0_DATA );
	$readmemh ("NUMERO1.list", NUMERO1_DATA );
	$readmemh ("NUMERO2.list", NUMERO2_DATA );
	$readmemh ("NUMERO3.list", NUMERO3_DATA );
	$readmemh ("NUMERO4.list", NUMERO4_DATA );
	$readmemh ("NUMERO5.list", NUMERO5_DATA );
	$readmemh ("NUMERO6.list", NUMERO6_DATA );
	$readmemh ("NUMERO7.list", NUMERO7_DATA );
	$readmemh ("NUMERO8.list", NUMERO8_DATA );
	$readmemh ("NUMERO9.list", NUMERO9_DATA );
	end
	
	assign STATE_Plantilla  = (ADDRV-InicioImagenY)*imagenXY+ADDRH-InicioImagenX;
	
	assign STATE_dia1       = (ADDRV-Fecha_inY)*NumerosX + ADDRH- linea1_inX; 
	assign STATE_dia2       = (ADDRV-Fecha_inY)*NumerosX + ADDRH- linea2_inX;
  	
	assign STATE_mes1       = (ADDRV-Fecha_inY)*NumerosX + ADDRH- linea3_inX;
	assign STATE_mes2       = (ADDRV-Fecha_inY)*NumerosX + ADDRH- linea4_inX;
	
	assign STATE_ano1       = (ADDRV-Fecha_inY)*NumerosX + ADDRH- linea5_inX;
	assign STATE_ano2       = (ADDRV-Fecha_inY)*NumerosX + ADDRH- linea6_inX;

	assign STATE_Horas1     = (ADDRV-Hora_inY)*NumerosX + ADDRH- linea1_inX;
	assign STATE_Horas2     = (ADDRV-Hora_inY)*NumerosX + ADDRH- linea2_inX;
	
	assign STATE_minutos1   = (ADDRV-Hora_inY)*NumerosX + ADDRH- linea3_inX;
	assign STATE_minutos2   = (ADDRV-Hora_inY)*NumerosX + ADDRH- linea4_inX;
	
	assign STATE_segundos1  = (ADDRV-Hora_inY)*NumerosX + ADDRH- linea5_inX;
	assign STATE_segundos2  = (ADDRV-Hora_inY)*NumerosX + ADDRH- linea6_inX;
	
	assign STATE_HorasT1    = (ADDRV-Timer_inY)*NumerosX + ADDRH- linea1_inX;
	assign STATE_HorasT2    = (ADDRV-Timer_inY)*NumerosX + ADDRH- linea2_inX;
	
	assign STATE_minutosT1  = (ADDRV-Timer_inY)*NumerosX + ADDRH- linea3_inX;
	assign STATE_minutosT2  = (ADDRV-Timer_inY)*NumerosX + ADDRH- linea4_inX;
	
	assign STATE_segundosT1 = (ADDRV-Timer_inY)*NumerosX + ADDRH- linea5_inX;
	assign STATE_segundosT2 = (ADDRV-Timer_inY)*NumerosX + ADDRH- linea6_inX;
	
	////////////////////////////////////////////////////////////////////////////////////////

	/////////////////////////// LLAMADO A MODULO DE SINCRONIA //////////////////////////////

	
	sync Sincronia(CLK, RST, HS, VS, ENClock, ADDRH, ADDRV);  //Sincronizacion para la VGA
	
	////////////////////////////////////////////////////////////////////////////////////////
	//////////////////  DEFINICION DE PARAMETROS DE SECCIONES NUMERICAS  ///////////////////

	//// PARAMETROS DE FECHA
	assign D_on1 = (linea1_inX <= ADDRH) && (ADDRH <=linea1_endX) && (Fecha_inY <= ADDRV) && (ADDRV <=Fecha_endY);
	assign D_on2 = (linea2_inX <= ADDRH) && (ADDRH <=linea2_endX) && (Fecha_inY <= ADDRV) && (ADDRV <=Fecha_endY);

	assign M_on1 = (linea3_inX <= ADDRH) && (ADDRH <=linea3_endX) && (Fecha_inY <= ADDRV) && (ADDRV <=Fecha_endY);
	assign M_on2 = (linea4_inX <= ADDRH) && (ADDRH <=linea4_endX) && (Fecha_inY <= ADDRV) && (ADDRV <=Fecha_endY);

	assign A_on1 = (linea5_inX <= ADDRH) && (ADDRH <=linea5_endX) && (Fecha_inY <= ADDRV) && (ADDRV <=Fecha_endY);
	assign A_on2 = (linea6_inX <= ADDRH) && (ADDRH <=linea6_endX) && (Fecha_inY <= ADDRV) && (ADDRV <=Fecha_endY);
	
	//// PARAMETROS DE HORA 
	assign H_on1  = (linea1_inX <= ADDRH) && (ADDRH <=linea1_endX) && (Hora_inY <= ADDRV) && (ADDRV <=Hora_endY);
	assign H_on2  = (linea2_inX <= ADDRH) && (ADDRH <=linea2_endX) && (Hora_inY <= ADDRV) && (ADDRV <=Hora_endY);

	assign MI_on1 = (linea3_inX <= ADDRH) && (ADDRH <=linea3_endX) && (Hora_inY <= ADDRV) && (ADDRV <=Hora_endY);
	assign MI_on2 = (linea4_inX <= ADDRH) && (ADDRH <=linea4_endX) && (Hora_inY <= ADDRV) && (ADDRV <=Hora_endY);

	assign S_on1  = (linea5_inX <= ADDRH) && (ADDRH <=linea5_endX) && (Hora_inY <= ADDRV) && (ADDRV <=Hora_endY);
	assign S_on2  = (linea6_inX <= ADDRH) && (ADDRH <=linea6_endX) && (Hora_inY <= ADDRV) && (ADDRV <=Hora_endY);
	
	//// PARAMETROS DE TIMER
	assign HT_on1  = (linea1_inX <= ADDRH) && (ADDRH <=linea1_endX) && (Timer_inY <= ADDRV) && (ADDRV <=Timer_endY);
	assign HT_on2  = (linea2_inX <= ADDRH) && (ADDRH <=linea2_endX) && (Timer_inY <= ADDRV) && (ADDRV <=Timer_endY);

	assign MIT_on1 = (linea3_inX <= ADDRH) && (ADDRH <=linea3_endX) && (Timer_inY <= ADDRV) && (ADDRV <=Timer_endY);
	assign MIT_on2 = (linea4_inX <= ADDRH) && (ADDRH <=linea4_endX) && (Timer_inY <= ADDRV) && (ADDRV <=Timer_endY);

	assign ST_on1  = (linea5_inX <= ADDRH) && (ADDRH <=linea5_endX) && (Timer_inY <= ADDRV) && (ADDRV <=Timer_endY);
	assign ST_on2  = (linea6_inX <= ADDRH) && (ADDRH <=linea6_endX) && (Timer_inY <= ADDRV) && (ADDRV <=Timer_endY);
   
	
	
	////////////////////////////////////////////////////////////////////////////////////////
	////////////////  DEFINICION DE DATOS DE PIXELES SALIENTES A PANTALLA  /////////////////	
	
	wire [17:0]Selector ={D_on1,D_on2,M_on1,M_on2,A_on1,A_on2,H_on1,H_on2,MI_on1,MI_on2,S_on1,S_on2,HT_on1,HT_on2,MIT_on1,MIT_on2,ST_on1,ST_on2};
	reg [9:0]Adress;
	reg [3:0]Numero_RTC;
	reg BanderaN;
	
	// seleccion de direccion en memoria de numeros  
	always @(*) 
	begin 
		case (Selector)
		18'b100000000000000000 : Adress = STATE_dia1;               
		18'b010000000000000000 : Adress = STATE_dia2;
		18'b001000000000000000 : Adress = STATE_mes1;
		18'b000100000000000000 : Adress = STATE_mes2;
		18'b000010000000000000 : Adress = STATE_ano1;
		18'b000001000000000000 : Adress = STATE_ano2;
		18'b000000100000000000 : Adress = STATE_Horas1;
		18'b000000010000000000 : Adress = STATE_Horas2;
		18'b000000001000000000 : Adress = STATE_minutos1;
		18'b000000000100000000 : Adress = STATE_minutos2;
		18'b000000000010000000 : Adress = STATE_segundos1;
		18'b000000000001000000 : Adress = STATE_segundos2;
		18'b000000000000100000 : Adress = STATE_HorasT1;
		18'b000000000000010000 : Adress = STATE_HorasT2;
		18'b000000000000001000 : Adress = STATE_minutosT1;
		18'b000000000000000100 : Adress = STATE_minutosT2;
		18'b000000000000000010 : Adress = STATE_segundosT1;
		18'b000000000000000001 : Adress = STATE_segundosT2;
		default Adress = 8'hFF;
		endcase
	end 
	
	//Indicacion de si se esta trabajando un numero o no 
	always @(*) 
	begin 
		case (Selector)
		18'b100000000000000000 : BanderaN = 1'b1;               
		18'b010000000000000000 : BanderaN = 1'b1; 
		18'b001000000000000000 : BanderaN = 1'b1; 
		18'b000100000000000000 : BanderaN = 1'b1; 
		18'b000010000000000000 : BanderaN = 1'b1; 
		18'b000001000000000000 : BanderaN = 1'b1; 
		18'b000000100000000000 : BanderaN = 1'b1; 
		18'b000000010000000000 : BanderaN = 1'b1; 
		18'b000000001000000000 : BanderaN = 1'b1; 
		18'b000000000100000000 : BanderaN = 1'b1; 
		18'b000000000010000000 : BanderaN = 1'b1; 
		18'b000000000001000000 : BanderaN = 1'b1; 
		18'b000000000000100000 : BanderaN = 1'b1; 
		18'b000000000000010000 : BanderaN = 1'b1; 
		18'b000000000000001000 : BanderaN = 1'b1; 
		18'b000000000000000100 : BanderaN = 1'b1; 
		18'b000000000000000010 : BanderaN = 1'b1; 
		18'b000000000000000001 : BanderaN = 1'b1; 
		default BanderaN = 1'b0;
		endcase
	end 	
	
	// seleccion de entradas del RTC 	
	always @(*) 
	begin 
		case (Selector)
		18'b100000000000000000 : Numero_RTC = {DIA_T[0],DIA_T[1],DIA_T[2],DIA_T[3]};               
		18'b010000000000000000 : Numero_RTC = {DIA_T[4],DIA_T[5],DIA_T[6],DIA_T[7]};
		18'b001000000000000000 : Numero_RTC = {MES_T[0],MES_T[1],MES_T[2],MES_T[3]};
		18'b000100000000000000 : Numero_RTC = {MES_T[4],MES_T[5],MES_T[6],MES_T[7]};
		18'b000010000000000000 : Numero_RTC = {ANO_T[0],ANO_T[1],ANO_T[2],ANO_T[3]};
		18'b000001000000000000 : Numero_RTC = {ANO_T[4],ANO_T[5],ANO_T[6],ANO_T[7]};
		18'b000000100000000000 : Numero_RTC = {HORA_T[0],HORA_T[1],HORA_T[2],HORA_T[3]};
		18'b000000010000000000 : Numero_RTC = {HORA_T[4],HORA_T[5],HORA_T[6],HORA_T[7]};
		18'b000000001000000000 : Numero_RTC = {MINUTO_T[0],MINUTO_T[1],MINUTO_T[2],MINUTO_T[3]};
		18'b000000000100000000 : Numero_RTC = {MINUTO_T[4],MINUTO_T[5],MINUTO_T[6],MINUTO_T[7]};
		18'b000000000010000000 : Numero_RTC = {SEGUNDO_T[0],SEGUNDO_T[1],SEGUNDO_T[2],SEGUNDO_T[3]};
		18'b000000000001000000 : Numero_RTC = {SEGUNDO_T[4],SEGUNDO_T[5],SEGUNDO_T[6],SEGUNDO_T[7]};
		18'b000000000000100000 : Numero_RTC = {HORAT_T[0],HORAT_T[1],HORAT_T[2],HORAT_T[3]};
		18'b000000000000010000 : Numero_RTC = {HORAT_T[4],HORAT_T[5],HORAT_T[6],HORAT_T[7]};
		18'b000000000000001000 : Numero_RTC = {MINUTOT_T[0],MINUTOT_T[1],MINUTOT_T[2],MINUTOT_T[3]};
		18'b000000000000000100 : Numero_RTC = {MINUTOT_T[4],MINUTOT_T[5],MINUTOT_T[6],MINUTOT_T[7]};
		18'b000000000000000010 : Numero_RTC = {SEGUNDOT_T[0],SEGUNDOT_T[1],SEGUNDOT_T[2],SEGUNDOT_T[3]};
		18'b000000000000000001 : Numero_RTC = {SEGUNDOT_T[4],SEGUNDOT_T[5],SEGUNDOT_T[6],SEGUNDOT_T[7]};
		default Numero_RTC = 4'hF;
		endcase 
	end 	
	
	// seleccion de SALIDA 
	always @(posedge CLK) 
	begin
		if (ADDRH>=InicioImagenX && ADDRH<InicioImagenX+imagenXY
			&& ADDRV>=InicioImagenY && ADDRV<InicioImagenY+imagenXY)
				if (BanderaN > 1'b0)
				begin 
					case (Numero_RTC)
					8'h0 : COLOR_IN <= NUMERO0_DATA[{Adress}];
					8'h1 : COLOR_IN <= NUMERO1_DATA[{Adress}];
					8'h2 : COLOR_IN <= NUMERO2_DATA[{Adress}];
					8'h3 : COLOR_IN <= NUMERO3_DATA[{Adress}];
					8'h4 : COLOR_IN <= NUMERO4_DATA[{Adress}];
					8'h5 : COLOR_IN <= NUMERO5_DATA[{Adress}];
					8'h6 : COLOR_IN <= NUMERO6_DATA[{Adress}];
					8'h7 : COLOR_IN <= NUMERO7_DATA[{Adress}];
					8'h8 : COLOR_IN <= NUMERO8_DATA[{Adress}];
					8'h9 : COLOR_IN <= NUMERO9_DATA[{Adress}];
					default COLOR_IN <= PLANTILLA_DATA[{STATE_Plantilla}];
					endcase 
				end 
				else 
				COLOR_IN <= PLANTILLA_DATA[{STATE_Plantilla}];
			else
				COLOR_IN <= 12'hFFF;
	end
	
	assign COLOR_OUT = COLOR_IN;	

endmodule 