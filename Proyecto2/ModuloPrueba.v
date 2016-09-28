module ModuloPrueba(
	input CLK,
	
	inout [7:0]Multiplex,//Bus de datos de comunicacion entre el RTC y el circuito de la FPGA 
	
	//Senales modificadoras
	input Mod,
	input UP,
	input DOWN,
	input next,
	input prev,
	
	//Datos enviados al modulo de VGA para mostrar en pantall
	output [7:0]Dout,    //Dato de dia del RTC   
	output [7:0]Mout,		//Dato de mes del RTC  
	output [7:0]Aout,		//Dato de año del RTC  
	output [7:0]Hout,		//Dato de hora del RTC  
	output [7:0]Miout,	//Dato de minutos del RTC  
	output [7:0]Sout,		//Dato de segundos del RTC  
	output [7:0]HTout,	//Dato de horas del timer del RTC  
	output [7:0]MiTout,	//Dato de minutos del timer del RTC  
	output [7:0]STout		//Dato de segundos del timer del RTC  
	);
	
	reg Espera;
	reg FinEspera;
	reg Mod2 = 1'b0;
	reg [7:0]Puntero;
	
	always @(CLK)
	begin	
		if (Espera == 1) begin							//Si se activa la espera se cuenta
			if (FinEspera == 20'd1048575)	begin    //Si se llega al final de la cuenta se reinicia los valores iniciales 
				Espera = 1'b0;
				FinEspera = 20'd0;
				end	
			else begin
				Espera = Espera;	
				FinEspera = FinEspera + 1'b1; 
				end end
				
		if ((Espera == 1'b0) && (Mod == 1'b1)) begin
			Espera = 1'b1;	
			Mod2 = ~Mod2;
			end 
			
		if ((Espera == 1'b0) && (next == 1'b1) && (Mod == 1'b0)) begin 
			Espera = 1'b1;	
			case (Puntero)
				8'h6 : Puntero = 8'h0; 
				default Puntero = Puntero + 1'b1;
				endcase end 
				
		if ((Espera == 1'b0) && (next == 1'b0) &&(prev == 1'b1)&&(Mod == 1'b0)) begin 
			Espera = 1'b1;	
			case (Puntero)
				8'h0 : Puntero = 8'h6; 
				default Puntero = Puntero + 1'b1;
				endcase end 		
	end 			
	
	
////////////////////////////////////////////
Multiplexado M2
	(CLK,
	
	//Datos provenientes de la maquina de estados de escritura y lectura
	1'b0,   	//Bandera que indica que se debe enviar la direccion al RTC
	1'b0,  	//Bandera que indica que se debe resivir informacion del RTC
	1'b0,		//Bandera que indica que se debe enviar informacion al RTC
	
	//Datos provenientes de la maquina de estados general
	Puntero, //Puntero que indica que direccion se esta modificando 
	8'd0,		//Direccion que se envia en ciertas ocaciones al RTC
	
	//Bus de datos del multiplexado
	Multiplex,	//Bus de datos de comunicacion entre el RTC y el circuito de la FPGA 
	
	//Senales modificadoras
	Mod,
	UP,
	DOWN,
	
	//Datos enviados al modulo de VGA para mostrar en pantall
	Dout,    //Dato de dia del RTC   
	Mout,		//Dato de mes del RTC  
	Aout,		//Dato de año del RTC  
	Hout,		//Dato de hora del RTC  
	Miout,	//Dato de minutos del RTC  
	Sout,		//Dato de segundos del RTC  
	HTout,	//Dato de horas del timer del RTC  
	MiTout,	//Dato de minutos del timer del RTC  
	STout		//Dato de segundos del timer del RTC  
	);	
	
endmodule 