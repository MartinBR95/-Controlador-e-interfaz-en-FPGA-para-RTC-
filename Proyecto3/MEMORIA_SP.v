`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
module MEMORIA_SP(direccion, rom, data_out, direccion_data); 

input wire [4:0]direccion;  // Direccion de celdas (direccion) y de direccion en la celda de memoria (rom)
input wire [3:0]rom;		    // Direccion de celda
 
input  [3:0]direccion_data; //Seleccion de datos de salida
output reg[11:0]data_out;      //Datos de salida 

wire [8:0]rom_addr = {direccion,rom}; //direccion completa en banco de memoria 
reg  [15:0]rom_data; 					   // Datos de memoria  

always @(*) 			 // Se ejecuta cada 9'h03F  : rom_data <= 384'hez que se cahia la direccion ingresada 
begin
	case (rom_addr)	 // Dependiendo del lugar de memoria que se esta empleando se en9'h03F  : rom_data <= 384'hia un hus de datos 
	
	9'h000  : rom_data <= 16'b0000000000000000;
	9'h010  : rom_data <= 16'b0000000000000000;
	9'h020  : rom_data <= 16'b0000000000000000;
	9'h030  : rom_data <= 16'b0000000000000000;
	9'h040  : rom_data <= 16'b0000000000000000;
	9'h050  : rom_data <= 16'b0000000000000000;
	9'h060  : rom_data <= 16'b0000000000000000;
	9'h070  : rom_data <= 16'b0000000000000000;
	9'h080  : rom_data <= 16'b0000000000000000;
	9'h090  : rom_data <= 16'b0000000000000000;
	9'h0A0  : rom_data <= 16'b0000000000000000;
	9'h0B0  : rom_data <= 16'b0000000000000000;
	9'h0C0  : rom_data <= 16'b0000000000000000;
	9'h0D0  : rom_data <= 16'b0000000000000000;
	9'h0E0  : rom_data <= 16'b0000000000000000;
	9'h0F0  : rom_data <= 16'b0000111111100000;
	9'h100  : rom_data <= 16'b0000111111100000;
	9'h110  : rom_data <= 16'b0000111111100000;
	9'h120  : rom_data <= 16'b0000000000000000;
	9'h130  : rom_data <= 16'b0000000000000000;
	9'h140  : rom_data <= 16'b0000000000000000;
	9'h150  : rom_data <= 16'b0000000000000000;
	9'h160  : rom_data <= 16'b0000000000000000;
	9'h170  : rom_data <= 16'b0000000000000000;
	9'h180  : rom_data <= 16'b0000000000000000;
	9'h190  : rom_data <= 16'b0000000000000000;
	9'h1A0  : rom_data <= 16'b0000000000000000;
	9'h1B0  : rom_data <= 16'b0000000000000000;
	9'h1C0  : rom_data <= 16'b0000000000000000;
	9'h1D0  : rom_data <= 16'b0000000000000000;
	9'h1E0  : rom_data <= 16'b0000000000000000;
	9'h1F0  : rom_data <= 16'b0000000000000000;


	9'h001  : rom_data <= 16'b0000000000000000;
	9'h011  : rom_data <= 16'b0000000000000000;
	9'h021  : rom_data <= 16'b0000000000000000;
	9'h031  : rom_data <= 16'b0000000000000000;
	9'h041  : rom_data <= 16'b0000000000000000;
	9'h051  : rom_data <= 16'b0000000000000000;
	9'h061  : rom_data <= 16'b0000000000000000;
	9'h071  : rom_data <= 16'b0000001100000000;
	9'h081  : rom_data <= 16'b0000011110000000;
	9'h091  : rom_data <= 16'b0000011110000000;
	9'h0A1  : rom_data <= 16'b0000001100000000;
	9'h0B1  : rom_data <= 16'b0000000000000000;
	9'h0C1  : rom_data <= 16'b0000000000000000;
	9'h0D1  : rom_data <= 16'b0000000000000000;
	9'h0E1  : rom_data <= 16'b0000000000000000;
	9'h0F1  : rom_data <= 16'b0000000000000000;
	9'h101  : rom_data <= 16'b0000000000000000;
	9'h111  : rom_data <= 16'b0000000000000000;
	9'h121  : rom_data <= 16'b0000000000000000;
	9'h131  : rom_data <= 16'b0000000000000000;
	9'h141  : rom_data <= 16'b0000000000000000;
	9'h151  : rom_data <= 16'b0000001100000000;
	9'h161  : rom_data <= 16'b0000011110000000;
	9'h171  : rom_data <= 16'b0000011110000000;
	9'h181  : rom_data <= 16'b0000001100000000;
	9'h191  : rom_data <= 16'b0000000000000000;
	9'h1A1  : rom_data <= 16'b0000000000000000;
	9'h1B1  : rom_data <= 16'b0000000000000000;
	9'h1C1  : rom_data <= 16'b0000000000000000;
	9'h1D1  : rom_data <= 16'b0000000000000000;
	9'h1E1  : rom_data <= 16'b0000000000000000;
	9'h1F1  : rom_data <= 16'b0000000000000000;


	9'h002  : rom_data <= 16'b0000011110000000;
	9'h012  : rom_data <= 16'b0000011110000000;
	9'h022  : rom_data <= 16'b0000001100000000;
	9'h032  : rom_data <= 16'b0000001100000000;
	9'h042  : rom_data <= 16'b0000011110000000;
	9'h052  : rom_data <= 16'b0000011110000000;
	9'h062  : rom_data <= 16'b0000001100000000;
	9'h072  : rom_data <= 16'b0000001100000000;
	9'h082  : rom_data <= 16'b0000011110000000;
	9'h092  : rom_data <= 16'b0000011110000000;
	9'h0A2  : rom_data <= 16'b0000001100000000;
	9'h0B2  : rom_data <= 16'b0000001100000000;
	9'h0C2  : rom_data <= 16'b0000011110000000;
	9'h0D2  : rom_data <= 16'b0000011110000000;
	9'h0E2  : rom_data <= 16'b0000001100000000;
	9'h0F2  : rom_data <= 16'b0000001100000000;
	9'h102  : rom_data <= 16'b0000011110000000;
	9'h112  : rom_data <= 16'b0000011110000000;
	9'h122  : rom_data <= 16'b0000001100000000;
	9'h132  : rom_data <= 16'b0000001100000000;
	9'h142  : rom_data <= 16'b0000011110000000;
	9'h152  : rom_data <= 16'b0000011110000000;
	9'h162  : rom_data <= 16'b0000001100000000;
	9'h172  : rom_data <= 16'b0000001100000000;
	9'h182  : rom_data <= 16'b0000011110000000;
	9'h192  : rom_data <= 16'b0000011110000000;
	9'h1A2  : rom_data <= 16'b0000001100000000;
	9'h1B2  : rom_data <= 16'b0000001100000000;
	9'h1C2  : rom_data <= 16'b0000011110000000;
	9'h1D2  : rom_data <= 16'b0000011110000000;
	9'h1E2  : rom_data <= 16'b0000001100000000;
	9'h1F2  : rom_data <= 16'b0000001100000000;

////////////////////////////////////////////////////////////
	default : rom_data <= 384'h00000000;        //En caso de que se use una celda de memoria no especificada se en9'h03F  : rom_data <= 384'hian ceros a la salida 
	endcase
end

reg ON;

always @(*)
begin
	case(direccion_data)
	
	4'h0 : if (rom_data[15]) data_out = 12'h0F0; else data_out = 12'h000; 
	4'h1 : if (rom_data[14]) data_out = 12'h0F0; else data_out = 12'h000; 
	4'h2 : if (rom_data[13]) data_out = 12'h0F0; else data_out = 12'h000;  
	4'h3 : if (rom_data[12]) data_out = 12'h0F0; else data_out = 12'h000; 
	4'h4 : if (rom_data[11]) data_out = 12'h0F0; else data_out = 12'h000; 
	4'h5 : if (rom_data[10]) data_out = 12'h0F0; else data_out = 12'h000; 
	4'h6 : if (rom_data[9])  data_out = 12'h0F0; else data_out = 12'h000; 
	4'h7 : if (rom_data[8])  data_out = 12'h0F0; else data_out = 12'h000; 
	4'h8 : if (rom_data[7])  data_out = 12'h0F0; else data_out = 12'h000; 
	4'h9 : if (rom_data[6])  data_out = 12'h0F0; else data_out = 12'h000;
	4'hA : if (rom_data[5])  data_out = 12'h0F0; else data_out = 12'h000;  
	4'hB : if (rom_data[4])  data_out = 12'h0F0; else data_out = 12'h000; 
	4'hC : if (rom_data[3])  data_out = 12'h0F0; else data_out = 12'h000; 
	4'hD : if (rom_data[2])  data_out = 12'h0F0; else data_out = 12'h000;  
	4'hE : if (rom_data[1])  data_out = 12'h0F0; else data_out = 12'h000; 
	4'hF : if (rom_data[0])  data_out = 12'h0F0; else data_out = 12'h000; 
	
	default data_out = 12'h000;		
	endcase 
end 


endmodule 