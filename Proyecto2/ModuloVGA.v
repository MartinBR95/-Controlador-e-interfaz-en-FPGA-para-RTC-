//////////////////////////////////////////////////////////////////////////////////
module ModuloVGA(
   input  CLK,					  //Senal de reloj 
   output [11:0] COLOR_OUT, //bits de color hacia la VGA
   output HS,					  //Sincronizacion horizontal
   output VS					  //Sincronizacion vertical
	);
	
   //VALORES QUE CAMBIAN DEPENDIENDO DE LA IMANGEN 
	parameter imagen = 16'd40000;	     //En general la plantilla tiene 40000 pixels
	parameter imagenXY = 8'd200;	     //sus dimenciones son 200x200 pixels
	parameter InicioImagenX = 10'd100; //Parametro de inicio de la imagen en X
	parameter InicioImagenY  = 9'd100; //Parametro de inicio de la imagen en Y
	
	//VALORES QUE CAMBIAN DEPENDIENDO DE POSICION Y DIMENSIONES DE NUMEROS 
	parameter Numeros = 13'd6000;      //En general numeros tiene 6000 pixeles
	parameter NumerosX = 7'd20;			  //Los numeros tienen una dimencion en x de 20
	parameter NumerosY = 7'd30;         //Y una dimencion en y de 30 
	
	//posiciones de los numeros en la plantilla (NO EN LA VGA)
	parameter Fecha_inY = 20;
	parameter Hora_inY  = 70;
	parameter Timer_inY = 120;

	parameter Fecha_endY = 50;     //hay tres subclases para los numeros, la fecha, la hora y el cronometro
	parameter Hora_endY  = 100;
	parameter Timer_endY = 150;

	parameter linea1_inX = 2;      //Todos los numeros se agrupan en filas verticales
	parameter linea2_inX = 24;		 //Ejemplo: en la linea 1 y 2, en fecha estan los dias, en hora estan las horas y en cronometro estan las horas
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
	wire ENclock;
	reg [11:0] PLANTILLA_DATA [0:imagen-1]; //Memoria donde se almacena los datos de plantilla
	reg [11:0] NUMEROS_DATA [0:Numeros-1];   //Memoria donde se almacena los datos de numeros
	reg [11:0] COLOR_IN;
	wire [9:0] ADDRH;		   	//direccion Horizontal de pixel
	wire [9:0] ADDRV;			   //direccion vertical de pixel

///////////////////////////////////////////////////////////////////////////////////////////////
	wire [15:0] STATE_Plantilla;            
/*
	wire [7:0]STATE_dia1;
	wire [7:0]STATE_dia2;

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
*/

///////////////////////////////////////////////////////////////////////////////////////////////

	initial
	begin
	$readmemh ("PLANTILLA.list", PLANTILLA_DATA);
	$readmemh ("NUMEROS.list", NUMEROS_DATA);
	end
	
	assign STATE_Plantilla = (ADDRH-InicioImagenX)*imagenXY+ADDRV-InicioImagenY;
	
	/*
	assign STATE_dia1 =  (ADDRH-linea1)*NumerosX + ADDRV-Fecha_inY; 
	assign STATE_dia2 =  (ADDRH-linea2)*NumerosX + ADDRV-Fecha_inY;
	
	assign STATE_mes1 =  (ADDRH-linea3)*NumerosX + ADDRV-Fecha_inY;
	assign STATE_mes2 =  (ADDRH-linea4)*NumerosX + ADDRV-Fecha_inY;
	
	assign STATE_ano1 =  (ADDRH-linea5)*NumerosX + ADDRV-Fecha_inY;
	assign STATE_ano2 =  (ADDRH-linea6)*NumerosX + ADDRV-Fecha_inY;

	assign STATE_hora1 =      (ADDRH-linea1)*NumerosX + ADDRV-InicioImagenY;
	assign STATE_hora2 =      (ADDRH-linea2)*NumerosX + ADDRV-InicioImagenY;
	
	assign STATE_minutos1 =   (ADDRH-linea3)*NumerosX + ADDRV-InicioImagenY;
	assign STATE_minutos2 =   (ADDRH-linea4)*NumerosX + ADDRV-InicioImagenY;
	
	assign STATE_segundos1 =  (ADDRH-linea5)*NumerosX + ADDRV-InicioImagenY;
	assign STATE_segundos2 =  (ADDRH-linea6)*NumerosX + ADDRV-InicioImagenY;
	
	assign STATE_horaT1 =     (ADDRH-linea1)*NumerosX + ADDRV-InicioImagenY;
	assign STATE_horaT2 =     (ADDRH-linea2)*NumerosX + ADDRV-InicioImagenY;
	
	assign STATE_minutosT1 =  (ADDRH-linea3)*NumerosX + ADDRV-InicioImagenY;
	assign STATE_minutosT2 =  (ADDRH-linea4)*NumerosX + ADDRV-InicioImagenY;
	
	assign STATE_segundosT1 = (ADDRH-linea5)*NumerosX + ADDRV-InicioImagenY;
	assign STATE_segundosT2 = (ADDRH-linea6)*NumerosX + ADDRV-InicioImagenY;
	*/
	
	always @(posedge CLK) 
	begin
		if (ADDRH>=InicioImagenX && ADDRH<InicioImagenX+imagenXY
			&& ADDRV>=InicioImagenY && ADDRV<InicioImagenY+imagenXY)
				COLOR_IN <= PLANTILLA_DATA[{STATE_Plantilla}];
			else
				COLOR_IN <= 12'hFFF;
	end
	
	assign COLOR_OUT = COLOR_IN;
	
	sync Sincronia(CLK, RST, HS, VS, ENclock, ADDRH, ADDRV);  //Sincronizacion para la VGA

endmodule 