////////////////////////////////////////////
module Multiplexado
	(input CLK,RST,

	//Datos provenientes de la maquina de estados de escritura y lectura
	input BEnv_Adress,   //Bandera que indica que se debe enviar la direccion al RTC
	input BRes_Data,  	//Bandera que indica que se debe resivir informacion del RTC
	input BEnv_Data,		//Bandera que indica que se debe enviar informacion al RTC
	input IRQ,
	input Alarma_stop,
	//Datos provenientes de la maquina de estados general
	input [6:0]Puntero,  //Puntero que indica que direccion se esta modificando
	input [7:0]ADRESS,	//Direccion que se envia en ciertas ocaciones al RTC

	//Bus de datos del multiplexado
	inout [7:0]Multiplex,//Bus de datos de comunicacion entre el RTC y el circuito de la FPGA

	//Senales modificadoras
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


///////////////////////////////////////////////////////////////////
////////////////  Detector de flanco de UP y DOWN /////////////////

reg UP_Reg;
reg UP_Reg_anterior;   //Valor anterior se usa para detectar el flanco
reg DOWN_Reg;
reg DOWN_Reg_anterior; //Valor anterior se usa para detectar el flanco

///////////////////////////////////////////////////////////

always@ (posedge CLK, posedge RST)
begin
	if (RST)	begin
		UP_Reg <= 1'b0;
		UP_Reg_anterior <=1'b0;

		DOWN_Reg <= 1'b0;
		DOWN_Reg_anterior <=1'b0;
	end

	else begin
		UP_Reg_anterior <= UP;
		if(~UP_Reg_anterior && UP) UP_Reg<=1'b1;
		else  UP_Reg<=1'b0;

		DOWN_Reg_anterior <= DOWN;
		if(~DOWN_Reg_anterior && DOWN) DOWN_Reg<=1'b1;
		else DOWN_Reg<=1'b0;
	end
end

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
///////// MODIFICACION DE DIRECCIONES //////////
reg [8:0]Mod2 = 9'b000000000;
reg [8:0]actualizar = 9'b000000000;

always @(*) //Seleccion de modificacion manual de registro
begin
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
end

always @(posedge CLK) //Seleccion de actualizacion de registro
begin
	if(BRes_Data == 1'b1)
	case (ADRESS)//El dato depende del lugar donde el puntero de la RTC se encuentre
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

wire [7:0] Multiplex_ajusteH, Multiplex_ajusteM, Multiplex_ajusteS;
BCDsub hor_in(Multiplex_ajusteH,8'h23,Multiplex);
BCDsub min_in(Multiplex_ajusteM,8'h59,Multiplex);
BCDsub seg_in(Multiplex_ajusteS,8'h59,Multiplex);
	
//AJUSTE 
// Condicion para cuando se tiene la alarma encendida 
wire Condicion23;    //Condicion si se ha llegado al final de la alarma 	
assign Condicion23 = {(HoraT == 8'h23) && (MinutosT == 8'h59) && (SegundosT == 8'h59)};

wire [7:0] T1,T2,T3; //T1 para horas T2 para minutos y T3 para segundos
	
assign T1 =  (Condicion23) ? 8'h00 : Multiplex_ajusteH; //Si se cumple la condicion se envian 00
assign T2 =  (Condicion23) ? 8'h00 : Multiplex_ajusteM;
assign T3 =  (Condicion23) ? 8'h00 : Multiplex_ajusteS;


////////////////////////////////////////////////
//////////// SECCION DE REGISTROS //////////////
RegAno   R_Ano (CLK,RST,  UP_Reg, DOWN_Reg, Mod2[0], actualizar[0], Multiplex, Ano); //Ano
RegMes   R_Mes (CLK,RST,  UP_Reg, DOWN_Reg, Mod2[1], actualizar[1], Multiplex, Mes); //Mes
RegDias  R_Dia (CLK,RST,  UP_Reg, DOWN_Reg, Mod2[2], actualizar[2], Multiplex, Dia); //Dia

RegHoras R_Hora(CLK,RST,  UP_Reg, DOWN_Reg, Mod2[3], actualizar[3], Multiplex, Hora);      //Hora
RegMin   R_Mins(CLK,RST,  UP_Reg, DOWN_Reg, Mod2[4], actualizar[4], Multiplex, Minutos);   //Minutos
RegSeg   R_Segs(CLK,RST,  UP_Reg, DOWN_Reg, Mod2[5], actualizar[5], Multiplex, Segundos);  //Segundos

RegHoras R_HorT(CLK,RST,  UP_Reg, DOWN_Reg, Mod2[6], actualizar[6], T1, HoraT);     //Horas de timer
RegMin   R_MinT(CLK,RST,  UP_Reg, DOWN_Reg, Mod2[7], actualizar[7], T2, MinutosT);  //Minutos de timer
RegSeg   R_SegT(CLK,RST,  UP_Reg, DOWN_Reg, Mod2[8], actualizar[8], T3, SegundosT); //Segundos de timer

////////////////////////////////////////////////
////////// DATOS HACAI LA RTC //////////////////
reg[7:0]DATA_out;
reg inicializacion;
reg BEnv_Data_ant;

wire [7:0] HoraT_out, MinutosT_out, SegundosT_out;  //Registros para el valor ajustado de salida al RTC
BCDsub hor_out(HoraT_out,8'h23,HoraT);
BCDsub min_out(MinutosT_out,8'h59,MinutosT);
BCDsub seg_out(SegundosT_out,8'h59,SegundosT);


always @(posedge CLK, posedge RST) //Seleccion de datos que pueden ser enviados a escribir a la RTC
begin
	if (RST == 1'b1) inicializacion <= 1'h0;

	else begin
	BEnv_Data_ant <= BEnv_Data;
	if(BEnv_Data == 1'b0 && BEnv_Data_ant == 1'b1) inicializacion <= 1'b1;
	else inicializacion <= inicializacion;

	case (ADRESS) //El dato depende del lugar donde el puntero de la RTC se encuentre
		8'h00 : if((~IRQ)||Alarma_stop)
				begin
				DATA_out <= 8'h00; //Timeroff
				end
				else
				begin
				DATA_out <= 8'h08;  //timeron
				end
		8'h01 : DATA_out <= 8'h04;	//flagdown
		8'h02 : begin if(inicializacion == 1'h0) begin
		 					DATA_out <= 8'h10;
						end
				  	else
						begin
							DATA_out <= 8'h00;
						end
					end

		8'h26 : DATA_out <= Ano;
		8'h25 : DATA_out <= Mes;
		8'h24 : DATA_out <= Dia;
		8'h23 : DATA_out <= Hora;
		8'h22 : DATA_out <= Minutos;
		8'h21 : DATA_out <= Segundos;
		8'h43 : DATA_out <= HoraT_out;
		8'h42 : DATA_out <= MinutosT_out;
		8'h41 : DATA_out <= SegundosT_out;

		default DATA_out <= 8'hFF;
	endcase end
end

////////////////////////////////////////////////
//////////// ASIGNACION DE SALIDAS /////////////

assign Dout   = Dia;  //Si se esta modificando se asigna
assign Mout   = Mes;
assign Aout   = Ano;
assign Hout   = Hora;
assign Miout  = Minutos;
assign Sout   = Segundos;
assign HTout  = HoraT;
assign MiTout = MinutosT;
assign STout  = SegundosT;

////////////////////////////////////////////////
/////////////// SECCION DE I/0 /////////////////
wire [7:0]out;

assign out = (BEnv_Adress) ? ADRESS : DATA_out;
assign Multiplex =  (BEnv_Data||BEnv_Adress) ? out : 8'bz;
endmodule
