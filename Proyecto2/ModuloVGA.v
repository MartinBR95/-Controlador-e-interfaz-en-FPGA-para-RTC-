module ModuloVGA
	(
   input  CLK,RST,    		  //Senal de reloj
   output [11:0] COLOR_OUT,  //bits de color hacia la VGA
   output HS,					  //Sincronizacion horizontal
   output VS,					  //Sincronizacion vertical
	input [7:0]DIA_T,         //Senal de dia de la RTC
	input ALARMA,             //Senal de alarma
	wire [7:0]MES_T,          //Senal de mes de la RTC
	input wire [7:0]ANO_T,          //Senal de ano de la RTC
	input wire [7:0]HORA_T,         //Senal de horas de la RTC
	input wire [7:0]MINUTO_T,       //Senal de minutos de la RTC
	input wire [7:0]SEGUNDO_T,      //Senal de segundos de la RTC
	input wire [7:0]HORAT_T,        //Senal de horas de temporizador de la RTC
	input wire [7:0]MINUTOT_T,      //Senal de minutos de temporizador de la RTC
	input wire [7:0]SEGUNDOT_T, 	  //Senal de segundos de temporizador de la RTC
	output [4:0] SelectorOut
	);


	//NOTA IMPORTANTE: SI LA CANTIDAD DE BITS CAMBIA EN LA IMAGEN O LOS NUMEROS, SE DEBE CAMBIAR LOS PUNTEROS TAMBIEN
   //						 CON EL FIN DE QUE LA DIMENSION DE LOS PUNTEROS SEA IGUAL A LA DE LAS MEMORIAS

   //VALORES QUE CAMBIAN DEPENDIENDO DE LA IMANGEN
	//parameter imagen = 16'd39999;	     //En general la plantilla tiene esta cantidad de pixels
	//parameter ImagenX = 8'd200;	     //su dimension en pixeles X es esta
	parameter ImagenY = 8'd200;        //su dimensoon en pixeles Y es esta
	parameter InicioImagenX = 7'd100;  //Parametro de inicio de la imagen en X
	parameter InicioImagenY = 7'd100;  //Parametro de inicio de la imagen en Y
	parameter FinImagenX = 9'd299;  //Parametro de inicio de la imagen en X
	parameter FinImagenY = 9'd299;  //Parametro de inicio de la imagen en Y

	/////////////DATOS DE NUMEROS////////////////
	//VALORES QUE CAMBIAN DEPENDIENDO DE POSICION Y DIMENSIONES DE NUMEROS
	parameter Numeros = 10'd599;      //En general numeros tienen esta cantidad de pixels
	parameter NumerosX  = 5'd20;   	 //sus dimensiones en pixeles X es esta
	parameter NumerosY  = 6'd30;      //sus dimensiones en pixeles Y es esta

	/////////////DATOS DE ALARMA////////////////
	parameter Alarma  = 10'd624;
	parameter AlarmaX = 5'd25;
	parameter AlarmaY = 5'd25;

	parameter AY_in  = 9'd275;
	parameter AY_end = 9'd299;

	parameter AX_in  = 9'd275;
	parameter AX_end = 9'd299;

	//posiciones de los numeros en la plantilla (NO EN LA VGA)
	//pocision en y
	parameter SecFecha_inY = 8'd126;
	parameter SecHora_inY  = 8'd185;
	parameter SecTimer_inY = 8'd245;

	parameter SecFecha_endY = 8'd155;           //hay tres subclases para los numeros, la fecha, la hora y el cronometro
	parameter SecHora_endY  = 9'd215;
	parameter SecTimer_endY = 9'd275;

	//pocision en y
	parameter linea1_inX = 8'd134;           //Todos los numeros se agrupan en filas verticales
	parameter linea2_inX = 8'd154;		     //Ejemplo: en la linea 1 y 2, en fecha estan los dias, en hora estan las horas y en cronometro estan las horas
                                            //Recordad que cada bloque (hora, minutos, etc.) posee dos numeros
	parameter linea3_inX = 8'd179;
	parameter linea4_inX = 8'd199;

	parameter linea5_inX = 8'd224;
	parameter linea6_inX = 9'd244;

	parameter linea1_endX = 8'd153;
	parameter linea2_endX = 8'd173;

	parameter linea3_endX = 8'd198;
	parameter linea4_endX = 8'd218;

	parameter linea5_endX = 9'd243;
	parameter linea6_endX = 9'd263;

	////////////////////////////////////////////////////////////////////////////////////////

	/////////////////////////// LLAMADO A MODULO DE SINCRONIA //////////////////////////////
	wire[9:0]ADDRV;
	wire[9:0]ADDRH;

	sync Sincronia(CLK, RST, HS, VS, ADDRH, ADDRV);  //Sincronizacion para la VGA

///////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////// MEMORIAS empleadas  ////////////////////////////////////////

	//reg [11:0]PLANTILLA_DATA[0:imagen]; //Memoria donde se almacena los datos de plantilla
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
	reg [11:0]ALARMA_DATA[0:Alarma];    //Memoria donde se almacena los datos de numero 9

	reg [11:0] COLOR_IN;                    //Medio entre los posibles pixeles de saida y los pixeles de salida

	////////////////////////////////////////////////////////////////////////////////////////
	////////////  DEFINICION DE PARAMETROS DE SECCIONES PINTADA EN PANTALLA  ///////////////
	/*la logica de esta seccion es tener una senal que diga cuando es que debe de pintarse en pantalla las secciones deseadas, asi sea el numero de dias, o de meses, hasta
	la plantilla misma, se hace el parametro tomando en cuenta donde es que inicia la panalla (InicioImagen) y el lugar en el que la seccion se encuentra en la imagen
	(Linea y Sec)*/

		reg [4:0]Selector = 5'h1F;

	// 1  = Plantilla_on;
	// 2  = D_on1
	// 3  = D_on2;
	// 4  = M_on1
	// 5  = M_on2;
	// 6  = A_on1,
	// 7  = A_on2;
	// 8  = H_on1,
	// 9  = H_on2;
	// A  = MI_on1,
	// B  = MI_on2;
	// C  = S_on1,
	// D  = S_on2;
	// E  = HT_on1
	// F  = HT_on2;
	// 10 = MIT_on1
	// 11 = MIT_on2;
	// 12 = ST_on1,
	// 13 = ST_on2;
	// 14 = alarma_on;

		always @(posedge CLK)
		begin
	//// PARAMETRAS DE PLANTILLA
		if((InicioImagenX > ADDRH) || (ADDRH > FinImagenX) || (InicioImagenY > ADDRV) || (ADDRV > FinImagenY)) Selector = 5'h0;
		else Selector = Selector;
		if((InicioImagenX < ADDRH) && (ADDRH < FinImagenX) && (InicioImagenY < ADDRV) && (ADDRV < FinImagenY)) Selector = 5'h1;
		else Selector = Selector;

	//// PARAMETROS DE FECHA
		if((linea1_inX< ADDRH) && (ADDRH < linea1_endX) && (SecFecha_inY < ADDRV) && (ADDRV < SecFecha_endY)) Selector = 5'h2;
		else Selector = Selector;
		if((linea2_inX< ADDRH) && (ADDRH < linea2_endX) && (SecFecha_inY < ADDRV) && (ADDRV < SecFecha_endY)) Selector = 5'h3;
		else Selector = Selector;

		if((linea3_inX< ADDRH) && (ADDRH < linea3_endX) && (SecFecha_inY < ADDRV) && (ADDRV < SecFecha_endY)) Selector = 5'h4;
		else Selector = Selector;
		if((linea4_inX< ADDRH) && (ADDRH < linea4_endX) && (SecFecha_inY < ADDRV) && (ADDRV < SecFecha_endY)) Selector = 5'h5;
		else Selector = Selector;

		if((linea5_inX< ADDRH) && (ADDRH < linea5_endX) && (SecFecha_inY < ADDRV) && (ADDRV < SecFecha_endY)) Selector = 5'h6;
		else Selector = Selector;
		if((linea6_inX< ADDRH) && (ADDRH < linea6_endX) && (SecFecha_inY < ADDRV) && (ADDRV < SecFecha_endY)) Selector = 5'h7;
		else Selector = Selector;

	//// PARAMETROS DE HORA
		if((linea1_inX< ADDRH) && (ADDRH < linea1_endX) && (SecHora_inY < ADDRV) && (ADDRV < SecHora_endY)) Selector = 5'h8;
		else Selector = Selector;
		if((linea2_inX< ADDRH) && (ADDRH < linea2_endX) && (SecHora_inY < ADDRV) && (ADDRV < SecHora_endY)) Selector = 5'h9;
		else Selector = Selector;

		if((linea3_inX< ADDRH) && (ADDRH < linea3_endX) && (SecHora_inY < ADDRV) && (ADDRV < SecHora_endY)) Selector = 5'hA;
		else Selector = Selector;
		if((linea4_inX< ADDRH) && (ADDRH < linea4_endX) && (SecHora_inY < ADDRV) && (ADDRV < SecHora_endY)) Selector = 5'hB;
		else Selector = Selector;

		if((linea5_inX< ADDRH) && (ADDRH < linea5_endX) && (SecHora_inY < ADDRV) && (ADDRV < SecHora_endY)) Selector = 5'hC;
		else Selector = Selector;
		if((linea6_inX< ADDRH) && (ADDRH < linea6_endX) && (SecHora_inY < ADDRV) && (ADDRV < SecHora_endY)) Selector = 5'hD;
		else Selector = Selector;

	//// PARAMETROS DE TIMER
		if((linea1_inX< ADDRH) && (ADDRH < linea1_endX) && (SecTimer_inY < ADDRV) && (ADDRV < SecTimer_endY)) Selector = 5'hE;
		else Selector = Selector;
		if((linea2_inX< ADDRH) && (ADDRH < linea2_endX) && (SecTimer_inY < ADDRV) && (ADDRV < SecTimer_endY)) Selector = 5'hF;
		else Selector = Selector;

		if((linea3_inX< ADDRH) && (ADDRH < linea3_endX) && (SecTimer_inY < ADDRV) && (ADDRV < SecTimer_endY)) Selector = 5'h10;
		else Selector = Selector;
		if((linea4_inX< ADDRH) && (ADDRH < linea4_endX) && (SecTimer_inY < ADDRV) && (ADDRV < SecTimer_endY)) Selector = 5'h11;
		else Selector = Selector;

		if((linea5_inX< ADDRH) && (ADDRH < linea5_endX) && (SecTimer_inY < ADDRV) && (ADDRV < SecTimer_endY)) Selector = 5'h12;
		else Selector = Selector;
		if((linea6_inX< ADDRH) && (ADDRH < linea6_endX) && (SecTimer_inY < ADDRV) && (ADDRV < SecTimer_endY)) Selector = 5'h13;
		else Selector = Selector;

	//// PARAMETROS DE ALARMA
		if((AX_in < ADDRH) && (ADDRH < AX_end) && (AY_in < ADDRV) && (ADDRV < AY_end) && (ALARMA == 1'b0)) Selector = 5'h14;
		else Selector = Selector;
	end


	////////////////////////////////////////////////////////////////////////////////////////
	////////////////  DEFINICION DE DATOS DE PIXELES SALIENTES A PANTALLA  /////////////////

	initial  //Se leen los datos de los .txt o .list y se pasan a las memorias
	begin
	//$readmemh ("PLANTILLA.list", PLANTILLA_DATA); //paso de listas txt a memorias
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
	$readmemh ("ALARMA.list" , ALARMA_DATA );
	end

	reg  [3:0]Numero_RTC = 4'hF;

	wire [15:0]Adress1;
	reg  [8:0]Y   = 9'h1FF; //Resta en Y 
	reg  [8:0]X   = 9'h1FF; //Resta en X
	reg  [8:0]MUL = 9'h1FF; //Multiplica por parametro
	
	always @(*) //Dependiendo de el lugar de selector se escogen los paramentros a operar
	begin
		case(Selector)
		5'h1 : begin Y = InicioImagenY; X= InicioImagenX; MUL= ImagenY;  end
		5'h2  : begin Y = SecFecha_inY; X= linea1_inX; MUL= NumerosY;  end
		5'h3  : begin Y = SecFecha_inY; X= linea2_inX; MUL= NumerosY;  end
		5'h4  : begin Y = SecFecha_inY; X= linea3_inX; MUL= NumerosY;  end
		5'h5  : begin Y = SecFecha_inY; X= linea4_inX; MUL= NumerosY;  end
		5'h6  : begin Y = SecFecha_inY; X= linea5_inX; MUL= NumerosY;  end
		5'h7  : begin Y = SecFecha_inY; X= linea6_inX; MUL= NumerosY;  end
		5'h8  : begin Y =  SecHora_inY; X= linea1_inX; MUL= NumerosY;  end
		5'h9  : begin Y =  SecHora_inY; X= linea2_inX; MUL= NumerosY;  end
		5'hA  : begin Y =  SecHora_inY; X= linea3_inX; MUL= NumerosY;  end
		5'hB  : begin Y =  SecHora_inY; X= linea4_inX; MUL= NumerosY;  end
		5'hC  : begin Y =  SecHora_inY; X= linea5_inX; MUL= NumerosY;  end
		5'hD  : begin Y =  SecHora_inY; X= linea6_inX; MUL= NumerosY;  end
		5'hE  : begin Y = SecTimer_inY; X= linea1_inX; MUL= NumerosY;  end
		5'hF  : begin Y = SecTimer_inY; X= linea2_inX; MUL= NumerosY;  end
		5'h10 : begin Y = SecTimer_inY; X= linea3_inX; MUL= NumerosY;  end
		5'h11 : begin Y = SecTimer_inY; X= linea4_inX; MUL= NumerosY;  end
		5'h12 : begin Y = SecTimer_inY; X= linea5_inX; MUL= NumerosY;  end
		5'h13 : begin Y = SecTimer_inY; X= linea6_inX; MUL= NumerosY;  end
		5'h14 : begin Y = AY_in; X= AX_in; MUL= AlarmaY;   end

		default begin Y = InicioImagenY ; X= InicioImagenX; MUL= ImagenY; end
		endcase
	end

	//OPERADOR//
	assign Adress1 = (ADDRV - Y) + (ADDRH - X)*MUL; //Establecimieto de puntero para memoria de plantilla
	//////////////////////
	
	
	reg [15:0]Adress;
	always @(posedge CLK) Adress = Adress1;

	// seleccion de entradas del RTC
	always @(posedge CLK)
	begin
		case (Selector)
		5'h0  : Numero_RTC = 4'hF;
	//	5'h1  : Numero_RTC = 4'hB;
		5'h2  : Numero_RTC = {DIA_T[7],DIA_T[6],DIA_T[5],DIA_T[4]};
		5'h3  : Numero_RTC = {DIA_T[3],DIA_T[2],DIA_T[1],DIA_T[0]};
		5'h4  : Numero_RTC = {MES_T[7],MES_T[6],MES_T[5],MES_T[4]};
		5'h5  : Numero_RTC = {MES_T[3],MES_T[2],MES_T[1],MES_T[0]};
		5'h6  : Numero_RTC = {ANO_T[7],ANO_T[6],ANO_T[5],ANO_T[4]};
		5'h7  : Numero_RTC = {ANO_T[3],ANO_T[2],ANO_T[1],ANO_T[0]};
		5'h8  : Numero_RTC = {HORA_T[7],HORA_T[6],HORA_T[5],HORA_T[4]};
		5'h9  : Numero_RTC = {HORA_T[3],HORA_T[2],HORA_T[1],HORA_T[0]};
		5'hA  : Numero_RTC = {MINUTO_T[7],MINUTO_T[6],MINUTO_T[5],MINUTO_T[4]};
		5'hB  : Numero_RTC = {MINUTO_T[3],MINUTO_T[2],MINUTO_T[1],MINUTO_T[0]};
		5'hC  : Numero_RTC = {SEGUNDO_T[7],SEGUNDO_T[6],SEGUNDO_T[5],SEGUNDO_T[4]};
		5'hD  : Numero_RTC = {SEGUNDO_T[3],SEGUNDO_T[2],SEGUNDO_T[1],SEGUNDO_T[0]};
		5'hE  : Numero_RTC = {HORAT_T[7],HORAT_T[6],HORAT_T[5],HORAT_T[4]};
		5'hF  : Numero_RTC = {HORAT_T[3],HORAT_T[2],HORAT_T[1],HORAT_T[0]};
		5'h10 : Numero_RTC = {MINUTOT_T[7],MINUTOT_T[6],MINUTOT_T[5],MINUTOT_T[4]};
		5'h11 : Numero_RTC = {MINUTOT_T[3],MINUTOT_T[2],MINUTOT_T[1],MINUTOT_T[0]};
		5'h12 : Numero_RTC = {SEGUNDOT_T[7],SEGUNDOT_T[6],SEGUNDOT_T[5],SEGUNDOT_T[4]};
		5'h13 : Numero_RTC = {SEGUNDOT_T[3],SEGUNDOT_T[2],SEGUNDOT_T[1],SEGUNDOT_T[0]};
		5'h14 : Numero_RTC = 4'hA;

		default Numero_RTC = 4'hF;
		endcase
	end

	// seleccion de SALIDA
	always @(posedge CLK)
	begin
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
		4'hA : COLOR_IN = ALARMA_DATA[{Adress}];
		//4'hB : COLOR_IN = PLANTILLA_DATA[{Adress}];

		default COLOR_IN = 12'h000;
		endcase
	end

	assign SelectorOut = Selector;
	assign COLOR_OUT = COLOR_IN;
endmodule
