`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
module Paridad (Reloj, DATA_P, Paridad, Paridad_OK); //Comprobador de paridad

input Reloj;						 //Reloj del sistema 
input Paridad;          		 //bit de paridad 
input wire [7:0]DATA_P; 		 //Datos de entrada 
output reg Paridad_OK;         //Paridad OK 

//Funcionamiento de la paridad impar 

wire[3:0]SUMA; 
assign SUMA = (DATA_P[7] + DATA_P[6] + DATA_P[5] + DATA_P[4] + DATA_P[3] + DATA_P[2] + DATA_P[1] + DATA_P[0]); //Se suma el valor unitario de cada bit de entrada
reg Determinador = 1'b0; //determinador va a determinar el valor que deberia posseer el bit de paridad

always @(posedge Reloj)
begin 
	case (SUMA) //determinador toma el valor que deberia poseer paridad
	4'h0 : Determinador = 1'b1;
	4'h1 : Determinador = 1'b0;
	4'h2 : Determinador = 1'b1;
	4'h3 : Determinador = 1'b0;
	4'h4 : Determinador = 1'b1;
	4'h5 : Determinador = 1'b0;
	4'h6 : Determinador = 1'b1;
	4'h7 : Determinador = 1'b0;
	4'h8 : Determinador = 1'b1;
	
	default Determinador = Determinador; 
	endcase
	
	if (Determinador == Paridad) Paridad_OK = 1'b1; //si el determinador posee el mismo valor que paridad significa que los datos estan correctos 
	else Paridad_OK = 1'b0;
end 

endmodule 