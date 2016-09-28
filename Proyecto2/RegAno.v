//////////////////////////////////////////////////////////////////////////////////
module RegAno
	(
	input CLK, 				//Reloj general del circuito
	input UP,  				//Señal de incremento
	input DOWN,				//Señal de decremento
	input Modificando,	//Señal de modificacion 
	input Actualizar, 	//Señal de actualizacion de datos
	input  [7:0]DATA_in,	//Datos de entrada 
	output [7:0]DATA_out	//Datos de salida
   );

reg [7:0]Auxiliar  =  8'd0; //

////////////////////////////////////////////////
//////////// SECCION DE ESPERA /////////////////
reg[19:0]FinEspera = 20'd0; 	//Señal de fin de espera
reg Espera;				//Señal de espera

////////////////////////////////////////////////
/////////// SECCION DE BANDERAS ////////////////
always @(posedge CLK)		//Modificacion de datos
begin
	if((UP == 1'b1) && (Espera == 1'b0) && (Modificando == 1'b1)) 	 //Si se incrementa manualmente 
	begin
	Espera = 1'b1; 
	case (Auxiliar)
			8'h09 : Auxiliar = 8'h10; 
			8'h19 : Auxiliar = 8'h20; 
			8'h29 : Auxiliar = 8'h30; 
			8'h39 : Auxiliar = 8'h40; 
			8'h49 : Auxiliar = 8'h50; 
			8'h59 : Auxiliar = 8'h60; 
			8'h69 : Auxiliar = 8'h70; 
			8'h79 : Auxiliar = 8'h80; 
			8'h89 : Auxiliar = 8'h90; 
			8'h99 : Auxiliar = 8'h00; 
			default Auxiliar = Auxiliar + 1'b1;
	endcase 
	end 

	if((UP == 1'b0) && (DOWN == 1'b1) && (Espera == 1'b0) && (Modificando == 1'b1)) //Si se decrementa manualmente
	begin
	Espera = 1'b1; 
	case (Auxiliar)
			8'h00 : Auxiliar = 8'h99; 
			8'h10 : Auxiliar = 8'h09; 
			8'h20 : Auxiliar = 8'h19; 
			8'h30 : Auxiliar = 8'h29; 
			8'h40 : Auxiliar = 8'h39; 
			8'h50 : Auxiliar = 8'h49; 
			8'h60 : Auxiliar = 8'h59; 
			8'h70 : Auxiliar = 8'h69; 
			8'h80 : Auxiliar = 8'h79; 
			8'h90 : Auxiliar = 8'h89; 
			default Auxiliar = Auxiliar - 1'b1;
	endcase 
	end 

	if (Espera == 1) begin							//Si se activa la espera se cuenta
			if (FinEspera == 20'd1048575)	begin    //Si se llega al final de la cuenta se reinicia los valores iniciales 
				Espera = 1'b0;
				FinEspera = 20'd0;
			end	
			else begin
				Espera = Espera;	
				FinEspera = FinEspera + 1'b1; 
			end
		end 
	
	if(Modificando == 1'b0 && Actualizar == 1'b1) Auxiliar = DATA_in; //Si se debe actualizar el registro con los datos de entrada
	else Auxiliar = Auxiliar;
end

assign DATA_out = Auxiliar; 
endmodule 