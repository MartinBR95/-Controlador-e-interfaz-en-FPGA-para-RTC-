`timescale 1ns / 1ps

module transfer(
	input wire access, read, clk, reset,    				//Entradas del módulo
	output wire AD, CS, RD, WR, FRW, AValid, WValid, RValid         				//Salidas de control del RTC, en lógica negativa, donde AD es ~A/D para abreviar
   );

	reg ADr, RDr, CSr, WRr;						//Se definen los registros en los que se trabajará secuencialmente el valor de las
	reg [1:0] state;						//variables de control del RTC, el valor del estado presente, y se inicializa el contador
	reg [5:0] cycles;

	assign AD = ADr;						//Se asigna el valor de los registros a las salidas del módulo
	assign CS = CSr;
	assign RD = RDr;
	assign WR = WRr;

	reg Acceso, Acceso_prev, Acceso_nxt;

	always @(posedge clk)begin
		if(reset) begin
			Acceso_prev <= 1'b0;
		end
		else begin
			Acceso_prev <= Acceso_nxt;
			if(Acceso_nxt == 1'b1 && Acceso_prev == 1'b0) Acceso <= Acceso_nxt;
			else begin
				if (cycles == 3'h3) Acceso <= ~Acceso;
				else Acceso <= Acceso;
			end
		end
	end

	always @(*) begin
		Acceso_nxt = access;
	end

	reg [2:0] timer;
	wire leido, escrito;

	wire tcs, tw, tacc, tadt, tads, taw, tah, tdf, tdw, tdh; 	 	//Se definen las ventanas de tiempo como pulsos en los que
																			 //no se permitirá o se permitirá el cambio de señales según
	assign tads = (cycles <= 1);					//corresponda para evitar errores de lectura/escritura
	assign tcs = (cycles > 1 & cycles <= 7) | (cycles > 18 & cycles <= 26);
																			 //las ventanas de tiempo se definen haciendo uso del contador.
																//Dado que cada cuenta equivale a 10ns, dado que el CLK funciona
																	//a 100MHz, entonces se aproximan los valores de operación de cada
	assign tw = (cycles > 7 & cycles <= 17) | (cycles > 26 & cycles <= 36);
																			 //señal según se especifíca en la hoja de datos del RTC
	assign tadt = (cycles > 7 & cycles <= 10);			//y así se activan en el orden y momento correctos las señales para
																		//controlar el dispositivo V3023
																		    //Ventanas de Dato de lectura valido
	assign tdf = (cycles > 24 & cycles <= 28);
	assign RValid = (tdf && read) ? 1'b1 : 1'b0;

	assign taw = (cycles > 4 & cycles <= 7);				//Ventanas de Address valido
	assign tah = (cycles > 7 & cycles <= 14);
	assign AValid = (taw | tah) ? 1'b1 : 1'b0;

	assign tdw = (cycles > 19 & cycles <= 26);			//Ventanas de Dato de escritura valido
	assign tdh = (cycles > 25 & cycles <= 28);
	assign WValid = (~read && (tdw || tdh)) ? 1'b1 : 1'b0;


//assign AValid = ((state == 1 || state == 0) && (tdw | tdh) ? : ;


	always @(posedge clk) begin
		if (reset) begin timer <= 0; end
		else begin
			if(leido | escrito)begin
				timer <= 1;
			end
			else begin
				if (timer > 0) begin
					timer <= timer + 1;
				end
				else begin
					timer <= timer;
				end
			end
		end
	end


	assign leido = ~tcs & (state == 2);
	assign escrito = ~tcs & (state == 3);
	assign FRW = (timer == 3'h7);


	always @(posedge clk) begin 					//Se define la FSM como un dispositivo sincronico sensible al flanco positivo del reloj.
		if(reset) begin 					//Se define una rutina de reset donde se dan los valores default de las variables de control
			state <= 0;					//y estado.
			ADr <= 1;
			CSr <= 1;
			RDr <= 1'b1;					//La máquina de estados principal de este módulo consta de 4 estados, y se coordina con un contados
			WRr <= 1;					//para dar los tiempos de espera correspondientes a cada estado u operación.
		end							//Dado que el RTC especifica tiempos de diferencia entre la conmutación de algunas señales
		else begin						//cada uno de estos estados es una rutina en si, que realiza varias operaciones según se lo indique
		case(state)						//el contador.
			0:
				if(Acceso) begin 			//Para el estado inicial, o de espera, si se solicita un acceso al RTC, se inicia la rutina descrita
					ADr <= 0;			//a continuación: Se activa el bus en modo de dirección.
					if(~tads)begin			//una vez cumplido el tiempo de espera correspondiente, se procede a asignar valores a las variables
						CSr <= 0;		//de control. Una vez asignados los valores correctos, se procede al siguiente estado.
						RDr <= 1;
						WRr <= 0;
						state <= 1;
					end
					else begin
						CSr <= CSr;		//Si no se ha cumplido el tiempo de espera, se mantienen los valores de las señales de control.
						RDr <= RDr;
						WRr <= WRr;
					end
				end
				else begin
					state <= state; 		//Si no se solicita acceso al RTC, la FSM se mantien en este estado de espera.
				end
			1:
				if(~tcs) begin				//En el primer estado, una vez cumplida la condición de tiempo de espera, se cambian los valores de control
					CSr <= 1;
					WRr <= 1;
					if(CS && ~tadt) begin		//Esta lógica es muy similar en todos los estados.
						ADr <= 1;
						if(read)begin 		//Para este estado específico, la condición del siguiente estado define un salto a uno de dos estados diferentes
							RDr <= 1;	//uno de lectura, y otro de escritura.
							if(~tw) begin
								state <= 2;
							end
							else begin
								state <= state;
							end
						end
						else begin
							RDr <= 1'b1;
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
				if(~leido) begin							//Los últimos dos estados son muy similares entre si, y siguen la lógica de los estados anteriores.
					CSr <= 0;
					RDr <= 0;
					state <= state;
				end
				else begin
					if(leido) begin
						CSr <= 1;
						RDr <= 1'b1;
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
						RDr <= 1'b1;
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

	always @(posedge clk) begin 				 //Se define contador para temporización de ventanas de tiempo de señales, como se mencionó antes.
		if(state == 0 & AD) begin			 //El contador se sincroniza con el clock pero inicia una vez que se activa la escritura de dirección.
			cycles <= 0;
		end
		else begin
			cycles <= cycles + 1;
		end
	end

endmodule
