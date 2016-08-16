module Almacenamiento(direccion,rom, rom_data);

input wire  [2:0]direccion; // Direccion de celdas (direccion) y de direccion en la celda de memoria (rom)
input wire  [3:0]rom;

output reg  [7:0]rom_data; // Datos de salida 

wire [6:0]rom_addr = {direccion,rom};

always @(*) // Se ejecuta cada vez que se cabia la direccion ingresada 
begin
	case (rom_addr) // Dependiendo del lugar de memoria que se esta empleando se envia un bus de datos 
	 
	7'b0000000 : rom_data = 8'b00000000;
	7'b0000001 : rom_data = 8'b00000000;
	7'b0000010 : rom_data = 8'b11111110;
	7'b0000011 : rom_data = 8'b11111110;
	7'b0000100 : rom_data = 8'b00111000;
	7'b0000101 : rom_data = 8'b00111000;
	7'b0000110 : rom_data = 8'b00111000; //J
	7'b0000111 : rom_data = 8'b00111000;
	7'b0001000 : rom_data = 8'b00111000;
	7'b0001001 : rom_data = 8'b00111000;
	7'b0001010 : rom_data = 8'b00111000;
	7'b0001011 : rom_data = 8'b00111000;
	7'b0001100 : rom_data = 8'b11110000;
	7'b0001101 : rom_data = 8'b11110000;
	7'b0001110 : rom_data = 8'b00000000;
	7'b0001111 : rom_data = 8'b00000000;

	7'b0010000 : rom_data = 8'b00000000;
	7'b0010001 : rom_data = 8'b00000000;
	7'b0010010 : rom_data = 8'b11000110;
	7'b0010011 : rom_data = 8'b11000110;
	7'b0010100 : rom_data = 8'b11000110;
	7'b0010101 : rom_data = 8'b11000110;
	7'b0010110 : rom_data = 8'b11000110; //V
	7'b0010111 : rom_data = 8'b11000110;
	7'b0011000 : rom_data = 8'b11000110;
	7'b0011001 : rom_data = 8'b01101100;
	7'b0011010 : rom_data = 8'b01101100;
	7'b0011011 : rom_data = 8'b01101100;
	7'b0011100 : rom_data = 8'b00111000;
	7'b0011101 : rom_data = 8'b00010000;
	7'b0011110 : rom_data = 8'b00000000;
	7'b0011111 : rom_data = 8'b00000000;

	7'b0100000 : rom_data = 8'b00000000;
	7'b0100001 : rom_data = 8'b00000000;
	7'b0100010 : rom_data = 8'b10000010;
	7'b0100011 : rom_data = 8'b11000110;
	7'b0100100 : rom_data = 8'b11000110;
	7'b0100101 : rom_data = 8'b11000110;
	7'b0100110 : rom_data = 8'b11000110; //M
	7'b0100111 : rom_data = 8'b11101110;
	7'b0101000 : rom_data = 8'b11111110;
	7'b0101001 : rom_data = 8'b11010110;
	7'b0101010 : rom_data = 8'b11010110;
	7'b0101011 : rom_data = 8'b11000110;
	7'b0101100 : rom_data = 8'b11000110;
	7'b0101101 : rom_data = 8'b00000000;
	7'b0101110 : rom_data = 8'b00000000;
	7'b0101111 : rom_data = 8'b00000000;

	7'b0110000 : rom_data = 8'b00000000;
	7'b0110001 : rom_data = 8'b00000000;
	7'b0110010 : rom_data = 8'b11111100;
	7'b0110011 : rom_data = 8'b11000110;
	7'b0110100 : rom_data = 8'b11000010;
	7'b0110101 : rom_data = 8'b11000010;
	7'b0110110 : rom_data = 8'b11000100; //B
	7'b0110111 : rom_data = 8'b11111000;
	7'b0111000 : rom_data = 8'b11111000;
	7'b0111001 : rom_data = 8'b11000100;
	7'b0111010 : rom_data = 8'b11000010;
	7'b0111011 : rom_data = 8'b11000010;
	7'b0111100 : rom_data = 8'b11000110;
	7'b0111101 : rom_data = 8'b11111110;
	7'b0111110 : rom_data = 8'b00000000;
	7'b0111111 : rom_data = 8'b00000000;

	7'b1000000 : rom_data = 8'b00000000;
	7'b1000001 : rom_data = 8'b00000000;
	7'b1000010 : rom_data = 8'b01111110;
	7'b1000011 : rom_data = 8'b11111110;
	7'b1000100 : rom_data = 8'b11100000;
	7'b1000101 : rom_data = 8'b11100000;
  7'b1000110 : rom_data = 8'b01111000; //S	
	7'b1000111 : rom_data = 8'b00111100;
	7'b1001000 : rom_data = 8'b00001110;
	7'b1001001 : rom_data = 8'b00000110;
	7'b1001010 : rom_data = 8'b00000110;
	7'b1001011 : rom_data = 8'b00000110;
	7'b1001100 : rom_data = 8'b11111110;
	7'b1001101 : rom_data = 8'b11111100;
	7'b1001110 : rom_data = 8'b00000000;
	7'b1001111 : rom_data = 8'b00000000;

	7'b1010000 : rom_data = 8'b00000000;
	7'b1010001 : rom_data = 8'b00000000;
	7'b1010010 : rom_data = 8'b11000000;
	7'b1010011 : rom_data = 8'b11000000;
	7'b1010100 : rom_data = 8'b11000000;
	7'b1010101 : rom_data = 8'b11000000;
	7'b1010110 : rom_data = 8'b11000000; //L
	7'b1010111 : rom_data = 8'b11000000;
	7'b1011000 : rom_data = 8'b11000000;
	7'b1011001 : rom_data = 8'b11000000;
	7'b1011010 : rom_data = 8'b11000000;
	7'b1011011 : rom_data = 8'b11000000;
	7'b1011100 : rom_data = 8'b11111110;
	7'b1011101 : rom_data = 8'b11111110;
	7'b1011110 : rom_data = 8'b00000000;
	7'b1011111 : rom_data = 8'b00000000;

	default : rom_data = 8'b00000000;        //En caso de que se use una celda de memoria no especificada se envian ceros a la salida 
	endcase
end
endmodule  