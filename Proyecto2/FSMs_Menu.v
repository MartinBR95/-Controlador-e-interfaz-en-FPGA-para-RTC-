 `timescale 500ns/100ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:51:55 09/13/2016 
// Design Name: 
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
module FSMs_Menu (IRQ,Barriba,Babajo,Bderecha,Bizquierda,Bcentro,RST,FRW,Acceso,Mod,Alarma,STW,CLK,DIR,Numup,Numdown,Punt);

input wire CLK,IRQ,Barriba,Babajo,Bderecha,Bizquierda,Bcentro,RST,FRW; //IRQ: interrupcion del RTC para temporizador,FRW:finalizo lectura/escritura
output reg [2:0] DIR; //Direccion de memoria del rtc al que se apunta
output reg Acceso,Mod,Alarma,STW,Numup,Numdown; //Acceso: a control RTC, Mod: modificacion del RTC, Alarma:Apagar alarma,Num++/Num--:aumentar/disminuir valor contenido en la direccion actual
output reg [2:0] Punt;//Es un puntero que guarda la direccion donde se estan editando los valores
//////////////////////////////////Maquina de Estados Principal///////////////////////////////////////////////////
localparam TiempoEspera=100;
//Registros de estado
reg [2:0] EstadoActual;
reg [2:0] EstadoSiguiente;

//Registros Internos
reg Barrido; //Indica que se debe recorrer la memoria
reg FBarrido; //Proviene de la maquina de Cuenta e indica que se ha terminado de recorrer la memoria
reg Espera; //Indica a la maquina de estado que debe realizar un ciclo de espera
reg [8:0] cuenta_espera;
reg Fespera;//La maquina de estado de espera indica que termino la espera
reg Fcount;
reg [2:0] PuntSiguiente;
wire cond1;
assign cond1 = Barriba|Babajo|Bderecha|Bizquierda|Bcentro;

//Valores Iniciales y asignacion de estado
always @( posedge CLK,posedge RST)
begin
	if (RST)
	begin
		EstadoActual <= 3'd1 ; //Estado inicial
		Punt<=3'b1;
		

	end
	else
	begin
		EstadoActual <= EstadoSiguiente ;
		Punt<=PuntSiguiente;
	end
end
//Logica Combinacional de siguiente estado y logica de salida
always @(*)
begin
	Mod=1'b0;
	Acceso=1'b1;
	Espera=1'b0;
	Barrido=1'b0;
	Numup=1'b0;
	Numdown=1'b0;
	PuntSiguiente=Punt;
	case(EstadoActual)
	3'd1:if(FRW)
		begin
			Barrido=1'b1;
			EstadoSiguiente=3'd2;
		end
		else
		begin
			EstadoSiguiente=3'd1;			
		end
	3'd2:if(FBarrido)
		begin
			Espera=1'b1;
			EstadoSiguiente=3'd3;
		end
		else
		begin
			Barrido=1'b1;
			EstadoSiguiente=3'd2;
		end
		
	3'd3:if(Fespera)
		begin
			Barrido=1'b1;
			EstadoSiguiente=3'd4;
		end
		else
		begin
			EstadoSiguiente=3'd3;
		end
	3'd4:if(cond1)
		begin
			Acceso = 1'b1;			
			Numup = Barriba;
			Numdown = Babajo;
			Mod=1'b1;
			if(Bcentro)
			begin
				PuntSiguiente = 3'd1;
			end
			else
			begin
				PuntSiguiente = DIR + Bizquierda - Bderecha;
			end
			EstadoSiguiente = 3'd2;			
		end
		else
		begin
			Acceso=1'b1;
			EstadoSiguiente=3'd2;
		end
		
	default
	begin
		EstadoSiguiente = 3'd1;
	end
	endcase
end

//////////////////////////////////////Maquina de estados de Cuenta////////////////////////////////////
//Registros de estado
reg [1:0] EstadoActualc;
reg [1:0] EstadoSiguientec;
reg [2:0] DIRSiguiente;
//Valores Iniciales y asignacion de estado
always@ ( posedge CLK, posedge RST )
begin
	if (RST)
	begin
		EstadoActualc <= 2'd1;
		DIR <= 3'b1;
	end
	else
	begin
		EstadoActualc <= EstadoSiguientec;
		DIR <= DIRSiguiente;
	end
end


always @(*)
begin
	Fcount=1'b0;
	FBarrido=1'b0;
	EstadoSiguientec = 2'd1;
	DIRSiguiente = DIR;
	case(EstadoActualc)	
	2'd1:if(Barrido)
		begin
			EstadoSiguientec=2'd2;		
		end
		else
		begin
			EstadoSiguientec=2'd1;
		end
	2'd2:if(FRW)
		begin		
			if(DIR==3'b111)
			begin
				Fcount=1'b1;
			end
			else
			begin
				DIRSiguiente = DIR + 1'b1;
			end	
			EstadoSiguientec=2'd3;			
		end
		else
		begin
			EstadoSiguientec=2'd2;
		end
	2'd3:if(Fcount)
		begin
			FBarrido=1'b1;
			EstadoSiguientec=2'd1;
			DIRSiguiente=1'b1;
		end
		else
		begin	
			EstadoSiguientec=2'd1;
		end
	default
	begin
		EstadoSiguientec = 2'd1;
	end	
	endcase	
end
//////////////////////////////////////Maquina de estados de Espera////////////////////////////////////
//Registros de estado
reg [1:0] EstadoActuale;
reg [1:0] EstadoSiguientee;
//Valores Iniciales y asignacion de estado
always@ ( posedge CLK, posedge RST )
begin
	if (RST)
	begin
		EstadoActuale <= 2'd1;
	end
	else
	begin
		EstadoActuale <= EstadoSiguientee;
	end
end


always @(*)
begin
	cuenta_espera=8'b0;
	Fespera=1'b0;
	case(EstadoActuale)	
	3'd1:if(Espera)
		begin
			EstadoSiguientee=2'd2;
		end
		else
		begin
			EstadoSiguientee=2'd1;
		end

	3'd2:if(Fespera)
		begin
			EstadoSiguientee=2'd1;
		end
		else
		begin
			if(cuenta_espera==TiempoEspera)
			begin
				cuenta_espera=8'b1;
				Fespera=1'b1;
				EstadoSiguientee=2'd1;
			end
			else
			begin			
				cuenta_espera=cuenta_espera+1;
			end
		end
	default
	begin
		EstadoSiguientee = 2'd1;
	end	
	endcase	
end
endmodule


















