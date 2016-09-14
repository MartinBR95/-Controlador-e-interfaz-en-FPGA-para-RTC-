`timescale 1ns / 1ps

module transfer(
	input Acceso, read, clk, reset,  							 //Entradas del m�dulo
	output wire AD, CS, RD, WR										 //Salidas de control del RTC, en l�gica negativa, donde AD es ~A/D para abreviar
   );
	
	reg ADr, RDr, CSr, WRr;											 //Se definen los registros en los que se trabajar� secuencialmente el valor de las
	reg [1:0] state;													 //variables de control del RTC, el valor del estado presente, y se inicializa el contador
	reg [5:0] cycles;
	
	assign AD = ADr;													 //Se asigna el valor de los registros a las salidas del m�dulo
	assign CS = CSr;
	assign RD = RDr;
	assign WR = WRr;
	
	wire tcs, tw, tacc, tadt, tads, twr, tdf, tdw, tdh; 	 //Se definen las ventanas de tiempo como pulsos en los que 
																			 //no se permitir� o se permitir� el cambio de se�ales seg�n 							 
	assign tads = (cycles <= 1);								 	 //corresponda para evitar errores de lectura/escritura
	assign tcs = (cycles > 1 & cycles <= 7) | (cycles > 18 & cycles <= 24);				 	 
																			 //las ventanas de tiempo se definen haciendo uso del contador.
//	assign twr = (cycles > 1 & cycles <= 7);				 	 //Dado que cada cuenta equivale a 10ns, dado que el CLK funciona
//	assign tacc = (cycles > 1 & cycles <= 4);				 	 //a 100MHz, entonces se aproximan los valores de operaci�n de cada
	assign tw = (cycles > 7 & cycles <= 17) | (cycles > 24 & cycles <= 34);				 	 
																			 //se�al seg�n se especif�ca en la hoja de datos del RTC
	assign tadt = (cycles > 12 & cycles <= 14);			 	 //y as� se activan en el orden y momento correctos las se�ales para
//	assign tdf = (cycles > 12 & cycles <= 16);           	 //controlar el dispositivo V3023
//	assign tdw = (cycles > 4 & cycles <= 12);					 
//	assign tdh = (cycles > 12 & cycles <= 16);
	
	wire leido, escrito;

	assign leido = ~tcs & (state == 2);
	assign escrito = ~tcs & (state == 3);
	
	
	always @(posedge clk) begin 									 //Se define la FSM como un dispositivo sincronico sensible al flanco positivo del reloj.
		if(reset) begin 												 //Se define una rutina de reset donde se dan los valores default de las variables de control
			state <= 0;													 //y estado.
			ADr <= 1;
			CSr <= 1;
			RDr <= 1'bz;												 //La m�quina de estados principal de este m�dulo consta de 4 estados, y se coordina con un contados
			WRr <= 1;													 //para dar los tiempos de espera correspondientes a cada estado u operaci�n.
		end																 //Dado que el RTC especifica tiempos de diferencia entre la conmutaci�n de algunas se�ales
		else begin														 //cada uno de estos estados es una rutina en si, que realiza varias operaciones seg�n se lo indique
		case(state)														 //el contador.
			0:																 
				if(Acceso) begin 										 //Para el estado inicial, o de espera, si se solicita un acceso al RTC, se inicia la rutina descrita
					ADr <= 0;											 //a continuaci�n: Se activa el bus en modo de direcci�n.
					if(~tads)begin										 //una vez cumplido el tiempo de espera correspondiente, se procede a asignar valores a las variables
						CSr <= 0;										 //de control. Una vez asignados los valores correctos, se procede al siguiente estado.
						RDr <= 1;
						WRr <= 0;
						state <= 1;
					end
					else begin 
						CSr <= CSr;										 //Si no se ha cumplido el tiempo de espera, se mantienen los valores de las se�ales de control. 	
						RDr <= RDr;
						WRr <= WRr;
					end
				end
				else begin
					state <= state; 							       //Si no se solicita acceso al RTC, la FSM se mantien en este estado de espera.
				end
			1:
				if(~tcs) begin											 //En el primer estado, una vez cumplida la condici�n de tiempo de espera, se cambian los valores de control
					CSr <= 1;											 			
					WRr <= 1;
					if(CS && ~tadt) begin							 //Esta l�gica es muy similar en todos los estados.
						ADr <= 1; 
						if(read)begin 									 //Para este estado espec�fico, la condici�n del siguiente estado define un salto a uno de dos estados diferentes
							RDr <= 1;									 //uno de lectura, y otro de escritura. 
							if(~tw) begin
								state <= 2;
							end
							else begin
								state <= state;
							end
						end
						else begin 
							RDr <= 1'bz;
							if(~tw) begin
								state <= 3;
							end
							else begin
								state <= state;
							end
						end
					end
					else begin
						ADr <= ADr;
					end
				end
				else begin 
					state <= state; 
				end
			2:
				if(~leido) begin											 //Los �ltimos dos estados son muy similares entre si, y siguen la l�gica de los estados anteriores. 
					CSr <= 0;
					RDr <= 0;
					state <= state;
				end
				else begin 
					if(leido) begin
						CSr <= 1;
						RDr <= 1'bz;
						state <= 0;
					end
					else begin
						CSr <= CSr;
						RDr <= RDr;
					end
				end
								
			3:
				if(~escrito) begin
					CSr <= 0;
					RDr <= 1;
					WRr <= 0;
					state <= state;
				end
				else begin 
					if(escrito) begin
						CSr <= 1;
						WRr <= 1;
						RDr <= 1'bz;
						state <= 0;
					end
					else begin
						CSr <= CSr;
						RDr <= RDr;
					end
				end
		
		endcase
		end
	end
	
	always @(posedge clk) begin 							 		 //Se define contador para temporizaci�n de ventanas de tiempo de se�ales, como se mencion� antes.
		if(state == 0 & AD) begin			 //El contador se sincroniza con el clock pero inicia una vez que se activa la escritura de direcci�n.
			cycles <= 0;
		end
		else begin
			cycles <= cycles + 1;
		end	
	end
	
endmodule