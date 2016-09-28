/////////////////////////////////////////////////////////////////////////////////
module ModuloVGA
	(
   input  CLK,RST,    		  //Senal de reloj 
   output [11:0] COLOR_OUT,  //bits de color hacia la VGA
   output HS,					  //Sincronizacion horizontal
   output VS,					  //Sincronizacion vertical
	input [7:0]DIA_T,         //Senal de dia de la RTC
	input ALARMA,             //Senal de alarma
	output Video_on,
	input wire [7:0]MES_T,          //Senal de mes de la RTC
	input wire [7:0]ANO_T,          //Senal de ano de la RTC
	input wire [7:0]HORA_T,         //Senal de horas de la RTC
	input wire [7:0]MINUTO_T,       //Senal de minutos de la RTC 
	input wire [7:0]SEGUNDO_T,      //Senal de segundos de la RTC
	input wire [7:0]HORAT_T,        //Senal de horas de temporizador de la RTC
	input wire [7:0]MINUTOT_T,      //Senal de minutos de temporizador de la RTC
	input wire [7:0]SEGUNDOT_T, 	  //Senal de segundos de temporizador de la RTC
	output [9:0]DIR
	);
	/////////////DATOS DE PLANTILLA////////////////
	
	//NOTA IMPORTANTE: SI LA CANTIDAD DE BITS CAMBIA EN LA IMAGEN O LOS NUMEROS, SE DEBE CAMBIAR LOS PUNTEROS TAMBIEN
   //						 CON EL FIN DE QUE LA DIMENSION DE LOS PUNTEROS SEA IGUAL A LA DE LAS MEMORIAS	
	
   //VALORES QUE CAMBIAN DEPENDIENDO DE LA IMANGEN 
	parameter imagen = 18'd159999;	     //En general la plantilla tiene esta cantidad de pixels
	parameter ImagenX = 9'd400;	     //su dimension en pixeles X es esta 
	parameter ImagenY = 9'd400;        //su dimensoon en pixeles Y es esta
	parameter InicioImagenX = 7'd100;  //Parametro de inicio de la imagen en X
	parameter InicioImagenY = 7'd50;  //Parametro de inicio de la imagen en Y

	/////////////DATOS DE NUMEROS////////////////   
	//VALORES QUE CAMBIAN DEPENDIENDO DE POSICION Y DIMENSIONES DE NUMEROS 
	parameter Numeros = 12'd2846;      //En general numeros tienen esta cantidad de pixels
	parameter NumerosX  = 6'd39;   	 //sus dimensiones en pixeles X es esta 
	parameter NumerosY  = 7'd73;      //sus dimensiones en pixeles Y es esta 
	 
	/////////////DATOS DE ALARMA////////////////   
	parameter Alarma  = 12'd2500;
	parameter AlarmaX = 6'd50;
	parameter AlarmaY = 6'd50;
	
	parameter AY_in  = 9'd350;
	parameter AY_end = 9'd399;
	
	parameter AX_in  = 9'd350;
	parameter AX_end = 9'd399;
	
	//posiciones de los numeros en la plantilla (NO EN LA VGA)
	//pocision en y 
	parameter SecFecha_inY = 7'd45;
	parameter SecHora_inY  = 8'd171;
	parameter SecTimer_inY = 9'd294;

	parameter SecFecha_endY = 7'd118;           //hay tres subclases para los numeros, la fecha, la hora y el cronometro
	parameter SecHora_endY  = 8'd243;
	parameter SecTimer_endY = 9'd368;

	//pocision en y 
	parameter linea1_inX = 7'd70;           //Todos los numeros se agrupan en filas verticales
	parameter linea2_inX = 7'd109;		     //Ejemplo: en la linea 1 y 2, en fecha estan los dias, en hora estan las horas y en cronometro estan las horas
                                            //Recordad que cada bloque (hora, minutos, etc.) posee dos numeros 
	parameter linea3_inX = 8'd160;      
	parameter linea4_inX = 8'd199;

	parameter linea5_inX = 8'd250;
	parameter linea6_inX = 9'd289;
	
	parameter linea1_endX = 7'd108; 
	parameter linea2_endX = 8'd147; 

	parameter linea3_endX = 8'd198;
	parameter linea4_endX = 8'd237;

	parameter linea5_endX = 9'd288;
	parameter linea6_endX = 9'd328;


	////////////////////////////////////////////////////////////////////////////////////////

	/////////////////////////// LLAMADO A MODULO DE SINCRONIA //////////////////////////////
	wire[9:0]ADDRV;
	wire[9:0]ADDRH;
	
	sync Sincronia(CLK, RST, HS, VS, Video_on, ADDRH, ADDRV);  //Sincronizacion para la VGA		

///////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////// MEMORIAS empleadas  ////////////////////////////////////////

	reg [11:0]PLANTILLA_DATA[0:imagen];  //Memoria donde se almacena los datos de plantilla
	reg [11:0]NUMERO0_DATA[0:Numeros];  //Memoria donde se almacena los datos de numero 0
	reg [11:0]NUMERO1_DATA[0:Numeros];  //Memoria donde se almacena los datos de numero 1
	reg [11:0]NUMERO2_DATA[0:Numeros];  //Memoria donde se almacena los datos de numero 2
	reg [11:0]NUMERO3_DATA[0:Numeros];  //Memoria donde se almacena los datos de numero 3
	reg [11:0]NUMERO4_DATA[0:Numeros];  //Memoria donde se almacena los datos de numero 4
	reg [11:0]NUMERO5_DATA[0:Numeros];  //Memoria donde se almacena los datos de numero 5
	reg [11:0]NUMERO6_DATA[0:Numeros];  //Memoria donde se almacena los datos de numero 6
	reg [11:0]NUMERO7_DATA[0:Numeros];  //Memoria donde se almacena los datos de numero 7
	reg [11:0]NUMERO8_DATA[0:Numeros];  //Memoria donde se almacena los datos de numero 8
	reg [11:0]NUMERO9_DATA[0:Numeros];  //Memoria donde se almacena los datos de numero 9
	reg [11:0]ALARMA_DATA[0:Alarma];  //Memoria donde se almacena los datos de numero 9
	
	reg [11:0] COLOR_IN;                    //Medio entre los posibles pixeles de saida y los pixeles de salida

	////////////////////////////////////////////////////////////////////////////////////////
	////////////  DEFINICION DE PARAMETROS DE SECCIONES PINTADA EN PANTALLA  ///////////////
	/*la logica de esta seccion es tener una senal que diga cuando es que debe de pintarse en pantalla las secciones deseadas, asi sea el numero de dias, o de meses, hasta 
	la plantilla misma, se hace el parametro tomando en cuenta donde es que inicia la panalla (InicioImagen) y el lugar en el que la seccion se encuentra en la imagen 
	(Linea y Sec)*/
	
	wire Plantilla_on;
	wire D_on1,D_on2;
	wire M_on1,M_on2;
	wire A_on1,A_on2;
	wire H_on1,H_0n2;
	wire MI_on1,MI_on2;
	wire S_on1,S_on2;
	wire HT_on1,HT_on2;
	wire MIT_on1,MIT_on2;
	wire ST_on1,ST_on2;
	wire alarma_on;
	
	//// PARAMETRAS DE PLANTILLA 
	assign Plantilla_on =(InicioImagenX < ADDRH) && (ADDRH < (InicioImagenX + ImagenX)) && (InicioImagenY < ADDRV) && (ADDRV < (InicioImagenY + ImagenY));
	
	//// PARAMETROS DE FECHA
	assign D_on1  = ((InicioImagenX + linea1_inX)<= ADDRH) && (ADDRH < (InicioImagenX + linea1_endX)) && ((InicioImagenY + SecFecha_inY) < ADDRV) && (ADDRV < (InicioImagenY + SecFecha_endY));
	assign D_on2  = ((InicioImagenX + linea2_inX)<= ADDRH) && (ADDRH < (InicioImagenX + linea2_endX)) && ((InicioImagenY + SecFecha_inY) < ADDRV) && (ADDRV < (InicioImagenY + SecFecha_endY));

	assign M_on1  = ((InicioImagenX + linea3_inX)<= ADDRH) && (ADDRH < (InicioImagenX + linea3_endX)) && ((InicioImagenY + SecFecha_inY) < ADDRV) && (ADDRV < (InicioImagenY + SecFecha_endY));
	assign M_on2  = ((InicioImagenX + linea4_inX)<= ADDRH) && (ADDRH < (InicioImagenX + linea4_endX)) && ((InicioImagenY + SecFecha_inY) < ADDRV) && (ADDRV < (InicioImagenY + SecFecha_endY));
	
	assign A_on1  = ((InicioImagenX + linea5_inX)<= ADDRH) && (ADDRH < (InicioImagenX + linea5_endX)) && ((InicioImagenY + SecFecha_inY) < ADDRV) && (ADDRV < (InicioImagenY + SecFecha_endY));
	assign A_on2  = ((InicioImagenX + linea6_inX)<= ADDRH) && (ADDRH < (InicioImagenX + linea6_endX)) && ((InicioImagenY + SecFecha_inY) < ADDRV) && (ADDRV < (InicioImagenY + SecFecha_endY));
	
	//// PARAMETROS DE HORA 
	assign H_on1  = ((InicioImagenX + linea1_inX)<= ADDRH) && (ADDRH < (InicioImagenX + linea1_endX)) && ((InicioImagenY + SecHora_inY) < ADDRV) && (ADDRV < (InicioImagenY + SecHora_endY));
	assign H_on2  = ((InicioImagenX + linea2_inX)<= ADDRH) && (ADDRH < (InicioImagenX + linea2_endX)) && ((InicioImagenY + SecHora_inY) < ADDRV) && (ADDRV < (InicioImagenY + SecHora_endY));

	assign MI_on1 = ((InicioImagenX + linea3_inX)<= ADDRH) && (ADDRH < (InicioImagenX + linea3_endX)) && ((InicioImagenY + SecHora_inY) < ADDRV) && (ADDRV < (InicioImagenY + SecHora_endY));
	assign MI_on2 = ((InicioImagenX + linea4_inX)<= ADDRH) && (ADDRH < (InicioImagenX + linea4_endX)) && ((InicioImagenY + SecHora_inY) < ADDRV) && (ADDRV < (InicioImagenY + SecHora_endY));

	assign S_on1  = ((InicioImagenX + linea5_inX)<= ADDRH) && (ADDRH < (InicioImagenX + linea5_endX)) && ((InicioImagenY + SecHora_inY) < ADDRV) && (ADDRV < (InicioImagenY + SecHora_endY));
	assign S_on2  = ((InicioImagenX + linea6_inX)<= ADDRH) && (ADDRH < (InicioImagenX + linea6_endX)) && ((InicioImagenY + SecHora_inY) < ADDRV) && (ADDRV < (InicioImagenY + SecHora_endY));
	
	//// PARAMETROS DE TIMER
	assign HT_on1 = ((InicioImagenX + linea1_inX)<= ADDRH) && (ADDRH < (InicioImagenX + linea1_endX)) && ((InicioImagenY + SecTimer_inY) < ADDRV) && (ADDRV < (InicioImagenY + SecTimer_endY));
	assign HT_on2 = ((InicioImagenX + linea2_inX)<= ADDRH) && (ADDRH < (InicioImagenX + linea2_endX)) && ((InicioImagenY + SecTimer_inY) < ADDRV) && (ADDRV < (InicioImagenY + SecTimer_endY));

	assign MIT_on1= ((InicioImagenX + linea3_inX)<= ADDRH) && (ADDRH < (InicioImagenX + linea3_endX)) && ((InicioImagenY + SecTimer_inY) < ADDRV) && (ADDRV < (InicioImagenY + SecTimer_endY));
	assign MIT_on2= ((InicioImagenX + linea4_inX)<= ADDRH) && (ADDRH < (InicioImagenX + linea4_endX)) && ((InicioImagenY + SecTimer_inY) < ADDRV) && (ADDRV < (InicioImagenY + SecTimer_endY));

	assign ST_on1 = ((InicioImagenX + linea5_inX)<= ADDRH) && (ADDRH < (InicioImagenX + linea5_endX)) && ((InicioImagenY + SecTimer_inY) < ADDRV) && (ADDRV < (InicioImagenY + SecTimer_endY));
	assign ST_on2 = ((InicioImagenX + linea6_inX)<= ADDRH) && (ADDRH < (InicioImagenX + linea6_endX)) && ((InicioImagenY + SecTimer_inY) < ADDRV) && (ADDRV < (InicioImagenY + SecTimer_endY));

	//// PARAMETROS DE ALARMA
	assign alarma_on = ((InicioImagenX +  AX_in)<= ADDRH) && (ADDRH < (InicioImagenX +  AX_end)) && ((InicioImagenY +  AY_in) < ADDRV) && (ADDRV < (InicioImagenY +  AY_end) && ALARMA);	
	
	///////////////////////////////////


///////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////// Direcciones de lectura en memorias  //////////////////////////////////

//Segun sea el lugar del cual se debe sacar los pixeles se usan estas direcciones 

//DECLARACIONES  
//Se declaran los punteros de las memorias
 	wire [17:0]STATE_Plantilla;          //Puntero de memoria de plantilla general    
	
	//NOTA IMPORTANTE, LA DIMENSION DE LOS PUNTEROS DEBE SER LA MISMA QUE EL REGISTRO "Adress"
	
	wire [11:0]STATE_dia1;					 //Puntero a una de las memorias de numeros dependiendo de la entrada "DIA_T"
	wire [11:0]STATE_dia2;					   

	wire [11:0]STATE_mes1;					 //Puntero a una de las memorias de numeros dependiendo de la entrada "MES_T"
	wire [11:0]STATE_mes2;							

	wire [11:0]STATE_ano1;                //Puntero a una de las memorias de numeros dependiendo de la entrada "ANO_T"
	wire [11:0]STATE_ano2;

	wire [11:0]STATE_Horas1;              //Puntero a una de las memorias de numeros dependiendo de la entrada "HORA_T"
	wire [11:0]STATE_Horas2;

	wire [11:0]STATE_minutos1;				 //Puntero a una de las memorias de numeros dependiendo de la entrada "MINUTO_T"
	wire [11:0]STATE_minutos2;
	
	wire [11:0]STATE_segundos1;           //Puntero a una de las memorias de numeros dependiendo de la entrada "SEGUNDO_T"
	wire [11:0]STATE_segundos2;

	wire [11:0]STATE_HorasT1;             //Puntero a una de las memorias de numeros dependiendo de la entrada "HORAT_T"
	wire [11:0]STATE_HorasT2;
	
	wire [11:0]STATE_minutosT1;           //Puntero a una de las memorias de numeros dependiendo de la entrada "HORAT_T"
	wire [11:0]STATE_minutosT2;

	wire [11:0]STATE_segundosT1;          //Puntero a una de las memorias de numeros dependiendo de la entrada "SEGUNDOT_T"
	wire [11:0]STATE_segundosT2;

	wire [11:0]STATE_ALARMA;	

//ASIGNACIONES  	
//Se asigna los valores que deben tener estos punteros para leer las memorias
//Esto se hace tomando en cuenta los parametros previamente definidos 
/*Para los STATE que no son el de plantilla; estos punteros pueden apuntar a cualquier memoria de numeros, dependiendo de las 
entradas provenientes de multiplexado */

	assign STATE_Plantilla  = (ADDRV- InicioImagenY) + (ADDRH-InicioImagenX)*ImagenY; //Establecimieto de puntero para memoria de plantilla 

	assign STATE_ALARMA     = (ADDRV- InicioImagenY- AY_in) + (ADDRH- InicioImagenX- AX_in)*AlarmaY;     //Establecimieto de puntero para memoria de NUMERON 
	
	assign STATE_dia1       = (ADDRV- InicioImagenY- SecFecha_inY) + (ADDRH- InicioImagenX- linea1_inX)*NumerosY;     //Establecimieto de puntero para memoria de NUMERON 
	assign STATE_dia2       = (ADDRV- InicioImagenY- SecFecha_inY) + (ADDRH- InicioImagenX- linea2_inX)*NumerosY;
  	
	assign STATE_mes1       = (ADDRV- InicioImagenY- SecFecha_inY) + (ADDRH- InicioImagenX- linea3_inX)*NumerosY; 		//Establecimieto de puntero para memoria de NUMERON 
	assign STATE_mes2       = (ADDRV- InicioImagenY- SecFecha_inY) + (ADDRH- InicioImagenX- linea4_inX)*NumerosY;

	assign STATE_ano1       = (ADDRV- InicioImagenY- SecFecha_inY) + (ADDRH- InicioImagenX- linea5_inX)*NumerosY;		//Establecimieto de puntero para memoria de NUMERON 
	assign STATE_ano2       = (ADDRV- InicioImagenY- SecFecha_inY) + (ADDRH- InicioImagenX- linea6_inX)*NumerosY;

	assign STATE_Horas1     = (ADDRV- InicioImagenY- SecHora_inY)  + (ADDRH- InicioImagenX- linea1_inX)*NumerosY;		//Establecimieto de puntero para memoria de NUMERON 
	assign STATE_Horas2     = (ADDRV- InicioImagenY- SecHora_inY)  + (ADDRH- InicioImagenX- linea2_inX)*NumerosY;
	
	assign STATE_minutos1   = (ADDRV- InicioImagenY- SecHora_inY)  + (ADDRH- InicioImagenX- linea3_inX)*NumerosY;		//Establecimieto de puntero para memoria de NUMERON 
	assign STATE_minutos2   = (ADDRV- InicioImagenY- SecHora_inY)  + (ADDRH- InicioImagenX- linea4_inX)*NumerosY;
	
	assign STATE_segundos1  = (ADDRV- InicioImagenY- SecHora_inY)  + (ADDRH- InicioImagenX- linea5_inX)*NumerosY;		//Establecimieto de puntero para memoria de NUMERON 
	assign STATE_segundos2  = (ADDRV- InicioImagenY- SecHora_inY)  + (ADDRH- InicioImagenX- linea6_inX)*NumerosY;
	
	assign STATE_HorasT1    = (ADDRV- InicioImagenY- SecTimer_inY) + (ADDRH- InicioImagenX- linea1_inX)*NumerosY;		//Establecimieto de puntero para memoria de NUMERON 
	assign STATE_HorasT2    = (ADDRV- InicioImagenY- SecTimer_inY) + (ADDRH- InicioImagenX- linea2_inX)*NumerosY;
		
	assign STATE_minutosT1  = (ADDRV- InicioImagenY- SecTimer_inY) + (ADDRH- InicioImagenX- linea3_inX)*NumerosY;		//Establecimieto de puntero para memoria de NUMERON 
	assign STATE_minutosT2  = (ADDRV- InicioImagenY- SecTimer_inY) + (ADDRH- InicioImagenX- linea4_inX)*NumerosY;		
	
	assign STATE_segundosT1 = (ADDRV- InicioImagenY- SecTimer_inY) + (ADDRH- InicioImagenX- linea5_inX)*NumerosY;	   //Establecimieto de puntero para memoria de NUMERON 
	assign STATE_segundosT2 = (ADDRV- InicioImagenY- SecTimer_inY) + (ADDRH- InicioImagenX- linea6_inX)*NumerosY;		
	

	////////////////////////////////////////////////////////////////////////////////////////
	////////////////  DEFINICION DE DATOS DE PIXELES SALIENTES A PANTALLA  /////////////////	
	
	initial  //Se leen los datos de los .txt o .list y se pasan a las memorias 
	begin
	$readmemh ("PLANTILLA.txt", PLANTILLA_DATA); //paso de listas txt a memorias 
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
	$readmemh ("ALARMA.txt" , ALARMA_DATA );
	end

	wire [18:0]Selector = {D_on1,D_on2,M_on1,M_on2,A_on1,A_on2,H_on1,H_on2,MI_on1,MI_on2,S_on1,S_on2,HT_on1,HT_on2,MIT_on1,MIT_on2,ST_on1,ST_on2,alarma_on};
	reg  [12:0]Adress = 10'h0;
	reg  [3:0]Numero_RTC = 4'hF;
	
	// seleccion de direccion en memoria de numeros  
	always @(*) 
	begin 
		case (Selector)
		19'b1000000000000000000 : Adress = STATE_dia1;               
		19'b0100000000000000000 : Adress = STATE_dia2;
		19'b0010000000000000000 : Adress = STATE_mes1;
		19'b0001000000000000000 : Adress = STATE_mes2;
		19'b0000100000000000000 : Adress = STATE_ano1;
		19'b0000010000000000000 : Adress = STATE_ano2;
		19'b0000001000000000000 : Adress = STATE_Horas1;
		19'b0000000100000000000 : Adress = STATE_Horas2;
		19'b0000000010000000000 : Adress = STATE_minutos1;
		19'b0000000001000000000 : Adress = STATE_minutos2;
		19'b0000000000100000000 : Adress = STATE_segundos1;
		19'b0000000000010000000 : Adress = STATE_segundos2;
		19'b0000000000001000000 : Adress = STATE_HorasT1;
		19'b0000000000000100000 : Adress = STATE_HorasT2;
		19'b0000000000000010000 : Adress = STATE_minutosT1;
		19'b0000000000000001000 : Adress = STATE_minutosT2;
		19'b0000000000000000100 : Adress = STATE_segundosT1;
		19'b0000000000000000010 : Adress = STATE_segundosT2;
		default Adress = 12'hFFF;
		endcase
	end 
	

	// seleccion de entradas del RTC 	
	always @(*) 
	begin 
		case (Selector)
		19'b1000000000000000000 : Numero_RTC = {DIA_T[7],DIA_T[6],DIA_T[5],DIA_T[4]};               
		19'b0100000000000000000 : Numero_RTC = {DIA_T[3],DIA_T[2],DIA_T[1],DIA_T[0]};
		19'b0010000000000000000 : Numero_RTC = {MES_T[7],MES_T[6],MES_T[5],MES_T[4]};
		19'b0001000000000000000 : Numero_RTC = {MES_T[3],MES_T[2],MES_T[1],MES_T[0]};
		19'b0000100000000000000 : Numero_RTC = {ANO_T[7],ANO_T[6],ANO_T[5],ANO_T[4]};
		19'b0000010000000000000 : Numero_RTC = {ANO_T[3],ANO_T[2],ANO_T[1],ANO_T[0]};
		19'b0000001000000000000 : Numero_RTC = {HORA_T[7],HORA_T[6],HORA_T[5],HORA_T[4]};
		19'b0000000100000000000 : Numero_RTC = {HORA_T[3],HORA_T[2],HORA_T[1],HORA_T[0]};
		19'b0000000010000000000 : Numero_RTC = {MINUTO_T[7],MINUTO_T[6],MINUTO_T[5],MINUTO_T[4]};
		19'b0000000001000000000 : Numero_RTC = {MINUTO_T[3],MINUTO_T[2],MINUTO_T[1],MINUTO_T[0]};
		19'b0000000000100000000 : Numero_RTC = {SEGUNDO_T[7],SEGUNDO_T[6],SEGUNDO_T[5],SEGUNDO_T[4]};
		19'b0000000000010000000 : Numero_RTC = {SEGUNDO_T[3],SEGUNDO_T[2],SEGUNDO_T[1],SEGUNDO_T[0]};
		19'b0000000000001000000 : Numero_RTC = {HORAT_T[7],HORAT_T[6],HORAT_T[5],HORAT_T[4]};
		19'b0000000000000100000 : Numero_RTC = {HORAT_T[3],HORAT_T[2],HORAT_T[1],HORAT_T[0]};
		19'b0000000000000010000 : Numero_RTC = {MINUTOT_T[7],MINUTOT_T[6],MINUTOT_T[5],MINUTOT_T[4]};
		19'b0000000000000001000 : Numero_RTC = {MINUTOT_T[3],MINUTOT_T[2],MINUTOT_T[1],MINUTOT_T[0]};
		19'b0000000000000000100 : Numero_RTC = {SEGUNDOT_T[7],SEGUNDOT_T[6],SEGUNDOT_T[5],SEGUNDOT_T[4]};
		19'b0000000000000000010 : Numero_RTC = {SEGUNDOT_T[3],SEGUNDOT_T[2],SEGUNDOT_T[1],SEGUNDOT_T[0]};
		19'b0000000000000000001 : Numero_RTC =	4'hA;
		default Numero_RTC = 4'hF;
		endcase 
	end 	
	
	// seleccion de SALIDA 
	always @(posedge CLK) 
	begin
		if (Plantilla_on == 1'b1)begin
					case (Numero_RTC)
					4'h0 : COLOR_IN = NUMERO0_DATA[{Adress}];
					4'h1 : COLOR_IN = NUMERO1_DATA[{Adress}];
					4'h2 : COLOR_IN = NUMERO2_DATA[{Adress}];
					4'h3 : COLOR_IN = NUMERO3_DATA[{Adress}];
					4'h4 : COLOR_IN = NUMERO4_DATA[{Adress}];
					4'h5 : COLOR_IN = NUMERO5_DATA[{Adress}];
					4'h6 : COLOR_IN = NUMERO6_DATA[{Adress}];
					4'h7 : COLOR_IN = NUMERO7_DATA[{Adress}];
					4'h8 : COLOR_IN = NUMERO8_DATA[{Adress}];
					4'h9 : COLOR_IN = NUMERO9_DATA[{Adress}];
					4'hA : COLOR_IN = ALARMA_DATA[{STATE_ALARMA}];
									
					default COLOR_IN = PLANTILLA_DATA[{STATE_Plantilla}];
					endcase 
					end 
		else COLOR_IN = 12'h000;
	end
	
	assign COLOR_OUT = COLOR_IN;	
	assign DIR = ADDRH;

endmodule 