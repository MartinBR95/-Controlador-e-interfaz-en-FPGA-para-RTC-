`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
module Degradado(
	input video_ON,
   input CLK,RST,    		  			//Senal de reloj
   output reg [11:0]COLOR_OUT,    	//bits de color hacia la VGA
	input wire[9:0]ADDRV
	);	
		
	/////////////////////////// LLAMADO A MODULO DE SINCRONIA //////////////////////////////

	//////
	reg[11:0]FONDO  = 12'h00;
	reg[1:0]SUMA    = 2'h0; 
	
	reg ON;
	reg Bajada = 1'b0;
	
	wire OK;
	reg  OK_reg;
	reg  OK_ANTERIOR;

	localparam F_ONY = 1'b1;
	assign OK = {ADDRV == F_ONY};

	//////
	always@ (posedge CLK, posedge RST)              //Detector de flanco 
	begin
		if (RST)	begin
			OK_reg <= 1'b0;
			OK_ANTERIOR <= 1'b0;
		end

		else begin
			OK_ANTERIOR <= OK;
			if(~OK_ANTERIOR && OK) OK_reg <= 1'b1;
			else OK_reg <= 1'b0;
		end
	end
	//////
	
					
	always@(posedge CLK)		
	begin 						
			if(OK_reg)	
			begin 
					if (SUMA == 2'h3)begin ON = 1'b1; SUMA = 2'h0; end 
					else begin ON = 1'b0; SUMA = SUMA + 1'b1; end
			end	
			else begin SUMA = SUMA; ON = 1'b0; end 
					
			if(ON)
			begin 
				if(Bajada == 1'b0)
					begin 
					if(FONDO == 12'hFFF)begin FONDO = FONDO; Bajada = 1'b1; end 
					else 
						begin 					
						if (FONDO >= 12'h0FF)begin FONDO[11:8] = FONDO[11:8] + 1'h1; Bajada = Bajada; end 
						else 
							if (FONDO >= 12'h00F)begin FONDO[7:4] = FONDO[7:4] + 1'h1;  Bajada = Bajada; end 
							else begin FONDO[3:0] = FONDO[3:0] + 1'h1;  Bajada = Bajada; end   
						end 
					end
				else 
					begin 
					if(FONDO == 12'h000) begin FONDO = FONDO; Bajada = 1'b0; end
					else 
						begin 					
						if (FONDO > 12'h0FF)begin    FONDO[11:8] = FONDO[11:8] - 1'h1; Bajada = Bajada; end 
						else 
							if (FONDO > 12'h00F)begin FONDO[7:4] = FONDO[7:4] - 1'h1;  Bajada = Bajada; end 
							else begin FONDO[3:0] = FONDO[3:0] - 1'h1;  Bajada = Bajada; end   
						end 
					end
			end 
			else FONDO = FONDO;		
	end 


	always @(posedge CLK)
	begin 
		if(video_ON) COLOR_OUT = FONDO;
		else COLOR_OUT = 12'h000;
	end
	
endmodule 