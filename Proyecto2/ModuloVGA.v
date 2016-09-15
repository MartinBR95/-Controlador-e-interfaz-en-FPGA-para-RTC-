//////////////////////////////////////////////////////////////////////////////////
module ModuloVGA
	(
   input  CLK,RST,    		  //Senal de reloj 
   output [11:0] COLOR_OUT,  //bits de color hacia la VGA
   output HS,					  //Sincronizacion horizontal
   output VS,					  //Sincronizacion vertical
	output ENClock
	input [7:0]DIA_T,         //Senal de dia de la RTC
	input [7:0]MES_T,         //Senal de mes de la RTC
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
	parameter Numeros_0 = 10'd600;      //En general numeros tiene 6000 pixeles
	parameter Numeros_1 = 10'd600;      //En general numeros tiene 6000 pixeles
	parameter Numeros_2 = 10'd600;      //En general numeros tiene 6000 pixeles
	parameter Numeros_3 = 10'd600;      //En general numeros tiene 6000 pixeles
	parameter Numeros_4 = 10'd600;      //En general numeros tiene 6000 pixeles
	parameter Numeros_5 = 10'd600;      //En general numeros tiene 6000 pixeles
	parameter Numeros_6 = 10'd600;      //En general numeros tiene 6000 pixeles
	parameter Numeros_7 = 10'd600;      //En general numeros tiene 6000 pixeles
	parameter Numeros_8 = 10'd600;      //En general numeros tiene 6000 pixeles
	parameter Numeros_9 = 10'd600;      //En general numeros tiene 6000 pixeles

	parameter NumerosX = 7'd20;			//Los numeros tienen una dimencion en x de 20
	parameter NumerosY = 7'd30;         //Y una dimencion en y de 30 
	
	//posiciones de los numeros en la plantilla (NO EN LA VGA)
	parameter Fecha_inY = 20;
	parameter Hora_inY  = 70;
	parameter Timer_inY = 120;

	parameter Fecha_endY = 50;          //hay tres subclases para los numeros, la fecha, la hora y el cronometro
	parameter Hora_endY  = 100;
	parameter Timer_endY = 150;

	parameter linea1_inX = 2;           //Todos los numeros se agrupan en filas verticales
	parameter linea2_inX = 24;		      //Ejemplo: en la linea 1 y 2, en fecha estan los dias, en hora estan las horas y en cronometro estan las horas
	parameter linea3_inX = 52;
	parameter linea4_inX = 74;
	parameter linea5_inX = 100;
	parameter linea6_inX = 122;
	
	parameter linea1_endX = 22;
	parameter linea2_endX = 44;
	parameter linea3_endX = 72;
	parameter linea4_endX = 94;
	parameter linea5_endX = 120;
	parameter linea6_endX = 142;
		
	//VARIABLES
	reg [11:0] PLANTILLA_DATA [0:imagen-1]; //Memoria donde se almacena los datos de plantilla
	reg [11:0] NUMEROS_DATA [0:Numeros-1];  //Memoria donde se almacena los datos de numeros
	reg [11:0] COLOR_IN;                    //Medio entre los posibles pixeles de saida y los pixeles de salida
	wire [9:0] ADDRH;		   	             //direccion Horizontal de pixel
	wire [9:0] ADDRV;			                //direccion vertical de pixel

///////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////// Direcciones de lectura en memorias  //////////////////////////////////

//Segun sea el lugar del cual se debe sacar los pixeles se usan estas direcciones 

	wire [15:0] STATE_Plantilla;           //Direccion en memoria de plantilla
	
	wire [7:0]STATE_dia1;					   //Direccion en memoria de numeros (sea cual sea)
	wire [7:0]STATE_dia2;					   //Todas las demas direcciones cumplen con el mismo fin 

	wire [7:0]STATE_mes1;						
	wire [7:0]STATE_mes2;							

	wire [7:0]STATE_ano1;                  
	wire [7:0]STATE_ano2;

	wire [7:0]STATE_Horas1;                
	wire [7:0]STATE_Horas2;

	wire [7:0]STATE_minutos1;
	wire [7:0]STATE_minutos2;

	wire [7:0]STATE_segundos1;
	wire [7:0]STATE_segundos2;

	wire [7:0]STATE_HorasT1;
	wire [7:0]STATE_HorasT2;
	
	wire [7:0]STATE_minutosT1;
	wire [7:0]STATE_minutosT2;

	wire [7:0]STATE_segundosT1;
	wire [7:0]STATE_segundosT2;


///////////////////////////////////////////////////////////////////////////////////////////////

	initial
	begin
	$readmemh ("PLANTILLA.list", PLANTILLA_DATA);
	$readmemh ("NUMEROS_0.list", NUMEROS0_DATA );
	$readmemh ("NUMEROS_1.list", NUMEROS0_DATA );
	$readmemh ("NUMEROS_2.list", NUMEROS0_DATA );
	$readmemh ("NUMEROS_3.list", NUMEROS0_DATA );
	$readmemh ("NUMEROS_4.list", NUMEROS0_DATA );
	$readmemh ("NUMEROS_5.list", NUMEROS0_DATA );
	$readmemh ("NUMEROS_6.list", NUMEROS0_DATA );
	$readmemh ("NUMEROS_7.list", NUMEROS0_DATA );
	$readmemh ("NUMEROS_8.list", NUMEROS0_DATA );
	$readmemh ("NUMEROS_9.list", NUMEROS0_DATA );
	end
	
	assign STATE_Plantilla = (ADDRH-InicioImagenX)*imagenXY+ADDRV-InicioImagenY;
	
	assign STATE_dia1       = (ADDRH-linea1)*NumerosX + ADDRV-Fecha_inY; 
	assign STATE_dia2       = (ADDRH-linea2)*NumerosX + ADDRV-Fecha_inY;
	
	assign STATE_mes1       = (ADDRH-linea3)*NumerosX + ADDRV-Fecha_inY;
	assign STATE_mes2       = (ADDRH-linea4)*NumerosX + ADDRV-Fecha_inY;
	
	assign STATE_ano1       = (ADDRH-linea5)*NumerosX + ADDRV-Fecha_inY;
	assign STATE_ano2       = (ADDRH-linea6)*NumerosX + ADDRV-Fecha_inY;
 
	assign STATE_hora1      = (ADDRH-linea1)*NumerosX + ADDRV-InicioImagenY;
	assign STATE_hora2      = (ADDRH-linea2)*NumerosX + ADDRV-InicioImagenY;
	
	assign STATE_minutos1   = (ADDRH-linea3)*NumerosX + ADDRV-InicioImagenY;
	assign STATE_minutos2   = (ADDRH-linea4)*NumerosX + ADDRV-InicioImagenY;
	
	assign STATE_segundos1  = (ADDRH-linea5)*NumerosX + ADDRV-InicioImagenY;
	assign STATE_segundos2  = (ADDRH-linea6)*NumerosX + ADDRV-InicioImagenY;
	
	assign STATE_horaT1     = (ADDRH-linea1)*NumerosX + ADDRV-InicioImagenY;
	assign STATE_horaT2     = (ADDRH-linea2)*NumerosX + ADDRV-InicioImagenY;
	
	assign STATE_minutosT1  = (ADDRH-linea3)*NumerosX + ADDRV-InicioImagenY;
	assign STATE_minutosT2  = (ADDRH-linea4)*NumerosX + ADDRV-InicioImagenY;
	
	assign STATE_segundosT1 = (ADDRH-linea5)*NumerosX + ADDRV-InicioImagenY;
	assign STATE_segundosT2 = (ADDRH-linea6)*NumerosX + ADDRV-InicioImagenY;
	
	////////////////////////////////////////////////////////////////////////////////////////

	/////////////////////////// LLAMADO A MODULO DE SINCRONIA //////////////////////////////

	
	sync Sincronia(CLK, RST, HS, VS, ENClock, ADDRH, ADDRV);  //Sincronizacion para la VGA

	
	////////////////////////////////////////////////////////////////////////////////////////

	assign D_on1 = (linea1_inX <=X) && (X <=linea1_endX) && (Fecha_inY <=Y) && (Y <=Fecha_endY);
	assign D_on2 = (linea2_inX <=X) && (X <=linea2_endX) && (Fecha_inY <=Y) && (Y <=Fecha_endY);

	assign M_on1 = (linea3_inX <=X) && (X <=linea3_endX) && (Fecha_inY <=Y) && (Y <=Fecha_endY);
	assign M_on2 = (linea4_inX <=X) && (X <=linea4_endX) && (Fecha_inY <=Y) && (Y <=Fecha_endY);

	assign A_on1 = (linea5_inX <=X) && (X <=linea5_endX) && (Fecha_inY <=Y) && (Y <=Fecha_endY);
	assign A_on2 = (linea6_inX <=X) && (X <=linea6_endX) && (Fecha_inY <=Y) && (Y <=Fecha_endY);
	
	////
	
	assign H_on1  = (linea1_inX <=X) && (X <=linea1_endX) && (Hora_inY <=Y) && (Y <=Hora_endY);
	assign H_on2  = (linea2_inX <=X) && (X <=linea2_endX) && (Hora_inY <=Y) && (Y <=Hora_endY);

	assign MI_on1 = (linea3_inX <=X) && (X <=linea3_endX) && (Hora_inY <=Y) && (Y <=Hora_endY);
	assign MI_on2 = (linea4_inX <=X) && (X <=linea4_endX) && (Hora_inY <=Y) && (Y <=Hora_endY);

	assign S_on1  = (linea5_inX <=X) && (X <=linea5_endX) && (Hora_inY <=Y) && (Y <=Hora_endY);
	assign S_on2  = (linea6_inX <=X) && (X <=linea6_endX) && (Hora_inY <=Y) && (Y <=Hora_endY);
	
	////
	
	assign HT_on1  = (linea1_inX <=X) && (X <=linea1_endX) && (Timer_inY <=Y) && (Y <=Timer_endY);
	assign HT_on2  = (linea2_inX <=X) && (X <=linea2_endX) && (Timer_inY <=Y) && (Y <=Timer_endY);

	assign MIT_on1 = (linea3_inX <=X) && (X <=linea3_endX) && (Timer_inY <=Y) && (Y <=Timer_endY);
	assign MIT_on2 = (linea4_inX <=X) && (X <=linea4_endX) && (Timer_inY <=Y) && (Y <=Timer_endY);

	assign ST_on1  = (linea5_inX <=X) && (X <=linea5_endX) && (Timer_inY <=Y) && (Y <=Timer_endY);
	assign ST_on2  = (linea6_inX <=X) && (X <=linea6_endX) && (Timer_inY <=Y) && (Y <=Timer_endY);
	
   ////
	
	always @(posedge CLK) 
	begin
		if (ADDRH>=InicioImagenX && ADDRH<InicioImagenX+imagenXY
			&& ADDRV>=InicioImagenY && ADDRV<InicioImagenY+imagenXY)
				case (Selector)				
				
				
				
				default COLOR_IN <= PLANTILLA_DATA[{STATE_Plantilla}];
			else
				COLOR_IN <= 12'hFFF;
	end
	
	assign COLOR_OUT = COLOR_IN;	

endmodule 