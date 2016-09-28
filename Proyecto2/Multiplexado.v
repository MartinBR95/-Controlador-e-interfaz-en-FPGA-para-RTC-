////////////////////////////////////////////
module Multiplexado
	(input CLK,

	//Datos provenientes de la maquina de estados de escritura y lectura
	input BEnv_Adress,   //Bandera que indica que se debe enviar la direccion al RTC
	input BRes_Data,  	//Bandera que indica que se debe resivir informacion del RTC
	input BEnv_Data,		//Bandera que indica que se debe enviar informacion al RTC

	//Datos provenientes de la maquina de estados general
	input [6:0]Puntero,  //Puntero que indica que direccion se esta modificando
	input [7:0]ADRESS,	//Direccion que se envia en ciertas ocaciones al RTC

	//Bus de datos del multiplexado
	inout [7:0]Multiplex,//Bus de datos de comunicacion entre el RTC y el circuito de la FPGA

	//Senales modificadoras
	input Mod,
	input UP,
	input DOWN,

	//Datos enviados al modulo de VGA para mostrar en pantall
	output [7:0]Dout,    //Dato de dia del RTC
	output [7:0]Mout,		//Dato de mes del RTC
	output [7:0]Aout,		//Dato de a�o del RTC
	output [7:0]Hout,		//Dato de hora del RTC
	output [7:0]Miout,	//Dato de minutos del RTC
	output [7:0]Sout,		//Dato de segundos del RTC
	output [7:0]HTout,	//Dato de horas del timer del RTC
	output [7:0]MiTout,	//Dato de minutos del timer del RTC
	output [7:0]STout		//Dato de segundos del timer del RTC
	);

////////////////////////////////////////////
/////////// Numeros hacia pantalla /////////

wire [7:0]Dia;
wire [7:0]Mes;
wire [7:0]Ano;

wire [7:0]Hora;
wire [7:0]Minutos;
wire [7:0]Segundos;

wire [7:0]HoraT;
wire [7:0]MinutosT;
wire [7:0]SegundosT;

////////////////////////////////////////////////
///////// ALMACENAMIENTO DE DIERCCION //////////

reg [7:0]Direccion = 8'd0; //Almacenamiento de la direccion de memoria

always @(posedge CLK)
begin
	if (BEnv_Adress == 1'b1) Direccion = ADRESS;
	else Direccion = Direccion;
end

////////////////////////////////////////////////
///////// MODIFICACION DE DIRECCIONES //////////
reg [8:0]Mod2 = 9'b000000000;
reg [8:0]actualizar = 9'b000000000;

always @(*) //Seleccion de modificacion manual de registro
begin
	if (Mod == 1'b1)
	case (Puntero)//El dato depende del lugar donde se este modificando
		8'h26 : Mod2 = 9'b000000001;
		8'h25 : Mod2 = 9'b000000010;
		8'h24 : Mod2 = 9'b000000100;
		8'h23 : Mod2 = 9'b000001000;
		8'h22 : Mod2 = 9'b000010000;
		8'h21 : Mod2 = 9'b000100000;
		8'h43 : Mod2 = 9'b001000000;
		8'h42 : Mod2 = 9'b010000000;
		8'h41 : Mod2 = 9'b100000000;
		default Mod2 = 9'b000000000;
	endcase
	else Mod2 = 9'b000000000;
end

always @(*) //Seleccion de actualizacion de registro
begin
	if(BRes_Data == 1'b1)
	case (Direccion)//El dato depende del lugar donde el puntero de la RTC se encuentre
		8'h26 : actualizar = 9'b000000001;
		8'h25 : actualizar = 9'b000000010;
		8'h24 : actualizar = 9'b000000100;
		8'h23 : actualizar = 9'b000001000;
		8'h22 : actualizar = 9'b000010000;
		8'h21 : actualizar = 9'b000100000;
		8'h43 : actualizar = 9'b001000000;
		8'h42 : actualizar = 9'b010000000;
		8'h41 : actualizar = 9'b100000000;
		default actualizar = 9'b000000000;
	endcase
	else actualizar = 9'b000000000;
end

////////////////////////////////////////////////
//////////// SECCION DE REGISTROS //////////////
RegAno   R_Ano (CLK, UP, DOWN, Mod2[0], actualizar[0], Multiplex, Ano); //Ano
RegMes   R_Mes (CLK, UP, DOWN, Mod2[1], actualizar[1], Multiplex, Mes); //Mes
RegDias  R_Dia (CLK, UP, DOWN, Mod2[2], actualizar[2], Multiplex, Dia); //Dia

RegHoras R_Hora(CLK, UP, DOWN, Mod2[3], actualizar[3], Multiplex, Hora);      //Hora
RegMin   R_Mins(CLK, UP, DOWN, Mod2[4], actualizar[4], Multiplex, Minutos);   //Minutos
RegSeg   R_Segs(CLK, UP, DOWN, Mod2[5], actualizar[5], Multiplex, Segundos);  //Segundos

RegHoras R_HorT(CLK, UP, DOWN, Mod2[6], actualizar[6], Multiplex, HoraT);     //Horas de timer
RegMin   R_MinT(CLK, UP, DOWN, Mod2[7], actualizar[7], Multiplex, MinutosT);  //Minutos de timer
RegSeg   R_SegT(CLK, UP, DOWN, Mod2[8], actualizar[8], Multiplex, SegundosT); //Segundos de timer


////////////////////////////////////////////////
////////// DATOS HACAI LA RTC //////////////////
reg[7:0]DATA_out;


always @(*) //Seleccion de datos que pueden ser enviados a escribir a la RTC
begin
	case (Direccion) //El dato depende del lugar donde el puntero de la RTC se encuentre
		8'h26 : DATA_out = Ano;
		8'h25 : DATA_out = Mes;
		8'h24 : DATA_out = Dia;
		8'h23 : DATA_out = Hora;
		8'h22 : DATA_out = Minutos;
		8'h21 : DATA_out = Segundos;
		8'h43 : DATA_out = HoraT;
		8'h42 : DATA_out = MinutosT;
		8'h41 : DATA_out = SegundosT;

		default DATA_out = 8'hFF;
	endcase
end

////////////////////////////////////////////////
//////////// ASIGNACION DE SALIDAS /////////////

assign Dout   = Dia;  //Si se esta modificando se asigna
assign Mout   = Mes;
assign Aout   = Ano;
assign Hout   = Hora;
assign HTout  = HoraT;
assign Miout  = Minutos;
assign Sout   = Segundos;
assign MiTout = MinutosT;
assign STout  = SegundosT;

////////////////////////////////////////////////
/////////////// SECCION DE I/0 /////////////////
wire [7:0]out;
/*wire Enviar;
or Or1(Enviar,BEnv_Adress,BEnv_Data);*/

assign out = (BEnv_Adress) ? ADRESS : DATA_out;
assign Multiplex =  (BEnv_Data||BEnv_Adress) ? out : 8'bz;
endmodule
