//////////////////////////////////////////////////////////////////////////////////
module Modulo_Multiplexado(
	input up,
	input down,
	input next,
	input previous,
	input Modificar,
	input CLK
    );

reg [7:0]Puntero = 8'hFF;  //Indica donde se esta modificando 
reg [7:0]Modificando = 8'hFF;
////////////////////////////////////////////
/////////// Numeros hacia pantalla /////////
reg [7:0]Dia = 8'hFF;
reg [7:0]Mes = 8'hFF;
reg [7:0]Ano = 8'hFF;

reg [7:0]Hora = 8'hFF;
reg [7:0]Minutos = 8'hFF;
reg [7:0]Segundos = 8'hFF;

reg [7:0]HoraT = 8'hFF;
reg [7:0]MinutosT = 8'hFF;
reg [7:0]SegundosT = 8'hFF; 

////////////////////////////////////////////
//////////////// Banderas //////////////////
reg BanderaUP = 1'b0;
reg BanderaDOWN = 1'b0;
reg BanderaNEXT = 1'b0;
reg BanderaPRE = 1'b0;
reg BanderaMod = 1'b0;

///////////////////////////////////////////
/////////// Activador de banderas /////////
always @(posedge up)begin   //Si se tiene un flanco de subida en algun interruptor, se indica que hay una senal de modificacion 
	BanderaUP = 1'b1;
end 

always @(posedge down)begin 
	BanderaDOWN = 1'b1;
end 

always @(posedge next)begin 
	BanderaNEXT = 1'b1;
end 

always @(posedge previous)begin 
	BanderaPRE = 1'b1;
end 

always @(posedge Modificar)begin 
	BanderaMod = ~BanderaMod;
end

///////////////////////////////////////////
///////// Modificacion de puntero /////////
always @(posedge CLK)
begin
	if(BanderaUP > 1'b0 && Puntero < 8'd18)
		begin
		Puntero = Puntero + 1'b1;
		BanderaUP = 1'b0;
		end 
	
	if(BanderaUP > 1'b0 && Puntero == 8'd18)
		begin
		Puntero = 8'h0;
		BanderaUP = 1'b0;
		end 

	if(BanderaDOWN > 1'b0 && Puntero > 8'h0)
		begin 
		Puntero = Puntero + 1'b1;
		BanderaDOWN = 1'b0;
		end
	
	if(BanderaDOWN > 1'b0 && Puntero == 8'd0)
		begin
		Puntero = 8'd18;
		BanderaDOWN = 1'b0;
		end 
	else Puntero = Puntero; 
end

///////////////////////////////////////////
///////// Modificacion de numero //////////

reg [7:0]Max;
reg [7:0]add;
reg [7:0]subs;
reg [3:0]Min;

//Se establecen los valores minimos y maximos a los cuales puede llegar cada munero
always @(posedge BanderaUP, posedge BanderaDOWN)  
begin
	case (Puntero)
		8'd0: begin                //Dia
					Max  = 8'd3;
				   add  = 8'b00010000;
					subs = 8'b11110000;
					Min  = 4'hF;
				 end 
				 
		8'd2: begin                //Mes
					Max  = 8'd1;       
				   add  = 8'b00010000;
					subs = 8'b11110000;
					Min  = 4'hF;
				 end 
				 
		8'd4: begin                //Ano
					Max  = 8'd9;       
				   add  = 8'b00010000;
					subs = 8'b11110000;
					Min  = 4'hF;
				 end 
		
		8'd6: begin                //Hora
					Max  = 8'd2;
				   add  = 8'b00010000;
					subs = 8'b11110000;
					Min  = 4'hF;				
				end 
				 
		8'd8: begin                //Minuto
					Max  = 8'd6;
				   add  = 8'b00010000;
					subs = 8'b11110000;
					Min  = 4'hF;
				 end 
				 
		8'd10: begin               //Segundos
					Max  = 8'd6;
				   add  = 8'b00010000;
					subs = 8'b11110000;
					Min  = 4'hF;
				 end 	

		8'd12: begin                //HoraT
					Max  = 8'd2;
				   add  = 8'b00010000;
					subs = 8'b11110000;
					Min  = 4'hF;
				 end 
				 
		8'd14: begin                //MinutoT
					Max  = 8'd6;
				   add  = 8'b00010000;
					subs = 8'b11110000;
					Min  = 4'hF;
				 end 
				 
		8'd16: begin               //SegundosT
					Max  = 8'd6;
				   add  = 8'b00010000;
					subs = 8'b11110000;
					Min  = 4'hF;
				 end 	
				 
	   default 
		begin 
					Max  = 8'd9;
				   add  = 8'h1;
					subs = 8'h1;
					Min  = 4'h0;
		end
		endcase 
end

/////////////////////////////////////////////////////////////////
///////// Se determina el numero que se va a modificar //////////
always @(posedge BanderaUP, posedge BanderaDOWN)
begin
	case (Puntero)
		8'd0: Modificando = Dia;
		8'd1: Modificando = Dia;
		8'd2: Modificando = Mes;
		8'd3: Modificando = Mes;
		8'd4: Modificando = Ano;
		8'd5: Modificando = Ano;
		8'd6: Modificando = Hora; 
		8'd7: Modificando = Hora;
		8'd8: Modificando = Minutos;
		8'd9: Modificando = Minutos;
		8'd10: Modificando = Segundos;
		8'd11: Modificando = Segundos;
		8'd12: Modificando = Hora; 
		8'd13: Modificando = Hora;
		8'd14: Modificando = Minutos;
		8'd15: Modificando = Minutos;
		8'd16: Modificando = Segundos;
		8'd17: Modificando = Segundos;
	
	default Modificando = 8'hFF;
	endcase
end

//////////////////////////////////////////////////
///////// Se modifica el numero deseado //////////
always @(posedge CLK)
begin
	if (BanderaMod > 1'b0 && BanderaNEXT > 1'b0 && Modificando < Max)
	begin
		Modificando = Modificando + add;
		BanderaNEXT = 1'b0;
	end

	if (BanderaMod > 1'b0 && BanderaNEXT > 1'b0 && Modificando == Max)
	begin
		Modificando = Modificando - subs;
		BanderaNEXT = 1'b0;				
	end

	if (BanderaMod > 1'b0 && BanderaPRE > 1'b0 && Modificando > Min)
	begin
		Modificando = Modificando - add;
		BanderaPRE = 1'b0;
	end

	if (BanderaMod > 1'b0 && BanderaPRE > 1'b0 && Modificando == Min)	
	begin
		Modificando = Min;
		BanderaPRE = 1'b0;
	end
end

/////////////////////////////////////////////////////
///////// Se devuelve el numero modificado //////////
always @(negedge BanderaPRE, negedge BanderaNEXT)
begin
	case (Puntero)		
		8'd1: Dia = Modificando;
		8'd1: Dia = Modificando;
		8'd2: Mes = Modificando;
		8'd3: Mes = Modificando;
		8'd4: Ano = Modificando;
		8'd5: Ano = Modificando;
		8'd6: Hora = Modificando;
		8'd7: Hora = Modificando;
		8'd8: Minutos = Modificando;
		8'd9: Minutos = Modificando;
		8'd10: Segundos = Modificando;
		8'd11: Segundos = Modificando;
		8'd12: HoraT = Modificando;
		8'd13: HoraT = Modificando;
		8'd14: MinutosT = Modificando;
		8'd15: MinutosT = Modificando;
		8'd16: SegundosT = Modificando;
		8'd17: SegundosT = Modificando;
		
	default Modificando = 8'hFF;
	endcase
end
endmodule 