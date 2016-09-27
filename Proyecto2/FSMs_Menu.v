`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date:    15:51:55 09/13/2016
// Design Name:
// Module Name:    FSMs_Menu
// Module Name:    FSMs_Menu
// Project Name:
// Target Devices:
// Tool versions:
// Description:
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////
module FSMs_Menu (IRQ,Alarma_stop,Barriba,Babajo,Bderecha,Bizquierda,Bcentro,RST,FRW,Acceso,Mod,Alarma,STW,CLK,Dir,Numup,Numdown,Punt);

input wire CLK,Alarma_stop,IRQ,Barriba,Babajo,Bderecha,Bizquierda,Bcentro,RST,FRW; //IRQ: interrupcion del RTC para temporizador,FRW:finalizo lectura/escritura
output reg [7:0] Dir; //Direccion de memoria del rtc al que se apunta
//output reg CMD; //Indicador de que se debe habilitar la dirección de comando F0 para transferir los datos de la RAM al RTC
output reg Acceso,Mod,Alarma,STW,Numup,Numdown; //Acceso: a control RTC, Mod: modificacion del RTC, Alarma:Apagar alarma,Num++/Num--:aumentar/disminuir valor contenido en la direccion actual
output reg [6:0] Punt;//Es un puntero que guarda la direccion donde se estan editando los valores
//////////////////////////////////Maquina de Estados Principal///////////////////////////////////////////////////
localparam [7:0]TiempoEspera=8'd3;
//Registros de estado
reg [2:0] EstadoActual;
reg [2:0] EstadoSiguiente;
reg Mod_Siguiente;
reg Numup_Siguiente;
reg Numdown_Siguiente;
//Registros Internos
reg Barrido; //Indica que se debe recorrer la memoria
reg FBarrido; //Proviene de la maquina de Cuenta e indica que se ha terminado de recorrer la memoria
reg Espera; //Indica a la maquina de estado que debe realizar un ciclo de espera
reg [7:0] cuenta_espera;
reg Accesonxt, AccesoCMD; //Variable para manejar los valores de la salida de Acceso en la l�gica combinacional
reg Fespera;//La maquina de estado de espera indica que termino la espera
wire Fcount;//Variable que indica el fin de la cuenta de direcciones
reg [6:0] Punt_Siguiente;//variable a asignar a puntero en el ciclo de relog siguiente
assign Fcount=Dir==8'hf1;//Constante de ultima direccion
//Valores Iniciales y asignacion de estado
//////////////////////////////////Maquina de estados Principal//////////////////////
always @( posedge CLK,posedge RST)
begin
	if (RST)
	begin
		EstadoActual <= 3'd1 ; //Estado inicial
		Mod<=1'b1;
		Numup<=1'b0;
		Numdown<=1'b0;
	end
	else
	begin
		EstadoActual <= EstadoSiguiente ;
		Mod<=Mod_Siguiente;
	end
end

//Logica Combinacional de siguiente estado y logica de salida
always @(*)
begin
	if(Mod_Siguiente && Fespera) Mod_Siguiente = ~Mod_Siguiente;
	else Mod_Siguiente = Mod;
	Espera=1'b0;
	Barrido=1'b0;
	if(FBarrido)AccesoCMD = 1'b1;
	else AccesoCMD = 1'b0;
	case(EstadoActual)//distintos estados
	3'd1:if(FRW)
		begin
			Barrido=1'b1;//luego de la inicializacion se realiza un barrido de lectura
			EstadoSiguiente=3'd2;
		end
		else
		begin
			EstadoSiguiente=3'd1;//se espera a que se termine la inicializacion
		end
	3'd2:if(FBarrido)
		begin
			Espera=1'b1;//en caso de terminar el barrido de memoria se inicia la maquina de estados de espera
			EstadoSiguiente=3'd3;
		end
		else
		begin
			Barrido=1'b1;//Se mantiene la se�al de barrido, y se espera a la finalizacion de la maquina de cuenta
			EstadoSiguiente=3'd2;
		end

	3'd3:if(Fespera)
		begin
			Barrido=1'b1;
			EstadoSiguiente=3'd4;//al terminar la espera se iniciara un nuevo barrido
		end
		else
		begin
			EstadoSiguiente=3'd3;//se espera a que la maquina de espera termine
		end
	3'd4:if(Bcentro)
		begin
			Mod_Siguiente=1'b1;//se ejecuta en caso de que el usuario haya introducido valores nuevos
			Barrido=1'b1;
			EstadoSiguiente = 3'd2;
		end
		else
		begin
			Barrido=1'b1;
			EstadoSiguiente = 3'd2;//Si el usuario no ha modificado ningun valor se continua con las lecturas
		end
	default
	begin
		EstadoSiguiente = 3'd1;
	end
	endcase
end

//////////////////////////////////////Maquina de estados de Cuenta////////////////////////////////////
//Registros de estado
reg [2:0] EstadoActualc;
reg [2:0] EstadoSiguientec;
reg [7:0] Dir_Siguiente;
//Valores Iniciales y asignacion de estado
always@ ( posedge CLK, posedge RST )
begin
	if (RST)
	begin
		Acceso <= 1'b1;
		EstadoActualc <= 3'd0;
		Dir <= 7'h02;
	end
	else
	begin
		Acceso <= Accesonxt;
		EstadoActualc <= EstadoSiguientec;
		Dir <= Dir_Siguiente;
	end
end

reg [2:0] cnt;   //Contador para limitar el tiempo de una señal
always @(posedge CLK) begin
	if(RST) begin
		cnt <= 1'b0;
	end
	else begin
		if(Acceso) cnt <= cnt + 1'b1;
		else cnt <= 1'b0;
	end
end

reg InicioEstado; //Variable para saber si es la primera vez que se ingresa a un estado

always @(*)
begin
	if(EstadoActualc != EstadoSiguiente) InicioEstado = 1'b1;
	else InicioEstado = 1'b0;
	if(cnt == 3'b111) Accesonxt = 1'b0;
	else begin
		if(AccesoCMD) Accesonxt = 1'b1;
		else Accesonxt = Acceso;
	end
	FBarrido=1'b0;
	EstadoSiguientec = 3'd1;
	Dir_Siguiente=Dir;
	case(EstadoActualc)
	3'd0:if(FRW)
			EstadoSiguientec = 3'd1;
		else
			EstadoSiguientec = 3'd0;
	3'd1:if(Barrido)
		begin
			EstadoSiguientec=3'd2;
			Dir_Siguiente=8'h21;
			Accesonxt=1'b1;
		end
		else
		begin
			EstadoSiguientec=3'd1;
		end
	3'd2:if(FRW)
		begin
			Dir_Siguiente = Dir + 1'b1;
			EstadoSiguientec=3'd3;
//		Accesonxt=1'b1;
		end
		else
		begin
			if(InicioEstado) Accesonxt=1'b1;
			EstadoSiguientec=3'd2;
		end

	3'd3:case(Dir)
			7'h1:
				begin
				Dir_Siguiente=8'hf0;
				EstadoSiguientec=3'd4;
				end
			7'h27:
				begin
				Dir_Siguiente=8'h41;
				EstadoSiguientec=3'd4;
				end
			7'h44:if(IRQ)
				begin
					Dir_Siguiente=8'h0;
					EstadoSiguientec=3'd4;
				end
				else
				begin
					Dir_Siguiente=8'hf0;
					EstadoSiguientec=3'd4;
				end
			default
			begin
				Dir_Siguiente=Dir;
				EstadoSiguientec=3'd4;
			end
		endcase
			
	
	
	
	
	
	
	
	/*if(Dir==7'h27)
		begin
			Dir_Siguiente=7'h41;
			EstadoSiguientec=3'd4;
		end
		else
		begin
			EstadoSiguientec=3'd4;
		end*/
	3'd4:if(Fcount)
		begin
			FBarrido=1'b1;
			EstadoSiguientec=3'd1;
			Dir_Siguiente=8'h21;
		end
		else
		begin
			EstadoSiguientec=3'd2;
			Accesonxt=1'b1;
		end
	default
	begin
		EstadoSiguientec = 3'd1;
	end
	endcase
end
//////////////////////////////////////Maquina de estados de Espera////////////////////////////////////
//Registros de estado
reg [1:0] EstadoActuale;
reg [1:0] EstadoSiguientee;
reg [7:0] cuenta_espera_sig;
//Valores Iniciales y asignacion de estado
always@ ( posedge CLK, posedge RST )
begin
	if (RST)
	begin
		EstadoActuale <= 2'd1;
		cuenta_espera <= 8'd1;
	end
	else
	begin
		cuenta_espera <= cuenta_espera_sig;
		EstadoActuale <= EstadoSiguientee;
	end
end


always @(*)
begin
	cuenta_espera_sig = cuenta_espera;
	Fespera=1'b0;
	EstadoSiguientee=2'd1;
	case(EstadoActuale)
	3'd1:if(Espera)
		begin
			EstadoSiguientee=2'd2;
		end
		else
		begin
			EstadoSiguientee=2'd1;
		end

	3'd2:if(cuenta_espera==TiempoEspera)
		begin
			cuenta_espera_sig=8'b1;
			Fespera = 1'b1;
			EstadoSiguientee=2'd1;
		end
		else
		begin
			cuenta_espera_sig = cuenta_espera+1'b1;
			EstadoSiguientee = 2'd2;
		end
	default
	begin
		EstadoSiguientee = 2'd1;
	end
	endcase
end


/////////////////////////////////////Maquina de puntero///////////////////////////
always@ ( posedge CLK, posedge RST )
begin
	if (RST)
	begin
		Punt<=7'h21;
	end
	else
	begin
		Punt<=Punt_Siguiente;
	end
end

always @(*)
begin
	Punt_Siguiente=Punt+Bizquierda - Bderecha;
	if(Bcentro)
	begin
		Punt_Siguiente=7'h21;
	end
	else
	begin
		case(Punt)
			7'h27:Punt_Siguiente=7'h41;//saltos de puntero
			7'h44:Punt_Siguiente=7'h21;
			7'h20:Punt_Siguiente=7'h43;
			7'h40:Punt_Siguiente=7'h26;
		default
		begin
			Punt_Siguiente=Punt + Bizquierda - Bderecha;
		end
		endcase
	end
end

//////////////////////////////////Maquina de encendido de Alarma////////////////////////
//Registros de estado
reg Alarma_sig;
//Valores Iniciales y asignacion de estado
always@ ( posedge CLK, posedge RST )
begin
	if (RST)
	begin
		Alarma <= 1'd0;
	end
	else
	begin
		Alarma <= Alarma_sig;
	end
end


always @(*)
begin
	STW<=1'b0;
	if(IRQ==1'b1)
	begin
		Alarma_sig=1'b1;
	end
	else
	begin
		if(Alarma_stop)
		begin
			Alarma_sig=1'b0;
			STW<=1'd1;
		end
		else
		begin
			Alarma_sig=Alarma;
		end
	end	
end

endmodule
